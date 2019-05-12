import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:my_wallet/data/data.dart';
import 'package:my_wallet/data/local/data_observer.dart';
import 'package:my_wallet/utils.dart' as Utils;
import 'package:my_wallet/shared_pref/shared_preference.dart';

import 'package:flutter/foundation.dart';

// private declaration for database
const tblAccount = "_Account";
const tblTransaction = "_Transaction";
const tblCategory = "_Category";
const tblUser = "_User";
const tblBudget = "_Budget";
const tblTransfer = "_Transfer";
const tblDischargeOfLiability = "_DischargeOfLiability";

const fldName = "_name";
const fldType = "_type";
const fldGroup = "_group";
const fldInitialBalance = "_initialBalance";
const fldCreated = "_created";
const fldCurrency = "_currency";
const fldBalance = "_balance";
const fldSpent = "_spent";
const fldEarn = "_earn";
const fldColorHex = "_colorHex";
const fldDateTime = "_dateTime";
const fldAccountId = "_accountId";
const fldCategoryId = "_categoryId";
const fldAmount = "_amount";
const fldDesc = "_description";
const fldEmail = "_email";
const fldDisplayName = "_displayName";
const fldPhotoUrl = "_photoUrl";
const fldUuid = "_uuid";
const fldColor = "_color";
const fldStart = "_start";
const fldEnd = "_end";
const fldEmailVerified = "_emailVerified";
const fldTransferId = "_transferId";
const fldTransferFrom = "_fromAccount";
const fldTransferTo = "_toAccount";
const fldLiabilityId = "_liabilityId";

const allTables = [
  tblAccount,
  tblTransaction,
  tblCategory,
  tblUser,
  tblBudget,
  tblTransfer,
  tblDischargeOfLiability
];
// #############################################################################################################################
// public util
// #############################################################################################################################
// private database is singleton
_Database _db = new _Database();
_Converter _converter = new _Converter();
var _tableChanged = Set<String>();

const DEFAULT_IDENTIFIER = "DEFAULT_IDENTIFIER";

Future<void> init() async {
  return _db.init();
}

Future<void> dropAllTables() {
  return _db._deleteDb();
}

String startTransaction() {
  return _db.startTransaction();
}

Future<void> execute({String batchIdentifier = DEFAULT_IDENTIFIER}) async {
  Batch batch = _db._getBatch(batchIdentifier: batchIdentifier);

  await batch.commit();

  _db._clearBatch(batchIdentifier);
  _db._notifyObservers(_tableChanged.toList());
}

void registerDatabaseObservable(List<String> tables, DatabaseObservable observable) {
  _db.registerDatabaseObservable(tables, observable);
}

void unregisterDatabaseObservable(List<String> tables, DatabaseObservable observable) {
  _db.unregisterDatabaseObservable(tables, observable);
}

Future<void> resume() {
  return init();
}

Future<void> dispose() {
  return _db.dispose();
}

// -----------------------------------------------------------------------------------------------------------------------------
// cross tables query
Future<List<T>> queryCategoryWithBudgetAndTransactionsForMonth<T>(DateTime month, CategoryType type, Function(AppCategory cat, double budgetPerMonth, double transaction) conversion) async {
  List<T> result = [];

  List<Map<String, dynamic>> cats = await _db._query(tblCategory, where: "$fldType = ${type.id}");

  DateTime firstDay = Utils.firstMomentOfMonth(month);
  DateTime lastDay = Utils.lastDayOfMonth(month);

  if(cats != null) {
    for(Map<String, dynamic> f in cats) {
      var category = _converter.toCategory(f);

      var findBudget = _compileFindBudgetSqlQuery(firstDay.millisecondsSinceEpoch, lastDay.millisecondsSinceEpoch);
      var rawBudgetPerMonth = await _db._executeSql(
          """
               SELECT SUM($fldAmount)
               FROM $tblBudget
                WHERE $fldCategoryId = ${category.id} AND $findBudget
                """);

      var rawTransaction = await _db._executeSql(
        """
        SELECT SUM($fldAmount)
            FROM $tblTransaction
            WHERE $fldCategoryId = ${category.id}
            AND ($fldDateTime BETWEEN ${firstDay.millisecondsSinceEpoch} AND ${lastDay.millisecondsSinceEpoch})
            AND $fldType in ${type.id == CategoryType.expense.id ? TransactionType.typeExpense.map((f) => "${f.id}").toString() : TransactionType.typeIncome.map((f) => "${f.id}").toString()}
        """
      );

      var transaction = rawTransaction.first.values.first ?? 0.0;
      var budgetPerMonth = rawBudgetPerMonth.first.values.first ?? 0.0;

      result.add(conversion(category, budgetPerMonth, transaction));
    }
  }

  return result;
}

Future<double> querySumAllBudgetForCategoryInMonth(DateTime start, DateTime end, CategoryType type) async {
  var monthStart = Utils.firstMomentOfMonth(start).millisecondsSinceEpoch;
  var monthEnd = end == null ? null : Utils.lastDayOfMonth(end).millisecondsSinceEpoch;

  var findBudget = _compileFindBudgetSqlQuery(monthStart, monthEnd);

  var listMap = await _db._executeSql("SELECT SUM($fldAmount) FROM $tblBudget WHERE $findBudget AND $fldCategoryId IN (SELECT $_id from $tblCategory WHERE $fldType = ${type.id})");

  double amount = listMap.first.values.first ?? 0.0;
  return amount;
}

Future<List<AppCategory>> queryCategoryWithTransaction({DateTime from, DateTime to, List<TransactionType> type, bool filterZero = false, bool orderByType = false}) async {
  String where;
  int _from = 0;
  int _to = DateTime.now().millisecondsSinceEpoch;

  if (from != null) {
    _from = from.millisecondsSinceEpoch;
  }

  if (to != null) {
    _to = to.millisecondsSinceEpoch;
  }
  where = "$fldDateTime BETWEEN $_from AND $_to";

  if(type != null) {
    var types = type.map((f) => "${f.id}").toString();
    where = "($where) AND ($fldType IN $types)";
  }

    List<AppCategory> appCat = [];

    List<Map<String, dynamic>> catMaps = await _db._query(tblCategory);

    if(catMaps != null && catMaps.isNotEmpty) {
      for(Map<String, dynamic> category in catMaps) {
        int categoryId = category[_id];

        if(categoryId != null) {
          String sqlIncome = "SELECT SUM($fldAmount) as income FROM $tblTransaction WHERE $fldCategoryId = $categoryId AND $where AND ($fldType IN ${TransactionType.typeIncome.map((f) => "${f.id}").toString()})";
          String sqlExpense = "SELECT SUM($fldAmount) as expense FROM $tblTransaction WHERE $fldCategoryId = $categoryId AND $where AND ($fldType IN ${TransactionType.typeExpense.map((f) => "${f.id}").toString()})";

          var incomeMap = await _db._executeSql(sqlIncome);
          var expenseMap = await _db._executeSql(sqlExpense);

          var income = 0.0;
          var expense = 0.0;

          if(incomeMap != null && incomeMap.isNotEmpty && incomeMap.first != null && incomeMap.first.values != null && incomeMap.first.values.first != null) income = incomeMap.first.values.first;
          if(expenseMap != null && expenseMap.isNotEmpty && expenseMap.first != null && expenseMap.first.values != null && expenseMap.first.values.first != null) expense = expenseMap.first.values.first;

          var appCategory = _converter.toCategory(category);
          appCategory.income = income ?? 0.0;
          appCategory.expense = expense ?? 0.0;

          if(!filterZero) appCat.add(appCategory);
          else if(income > 0 || expense > 0) appCat.add(appCategory);
        }
      }
    }

  if(orderByType && type != null) {
    if(type == TransactionType.typeExpense) {
      // sort by expenses
      appCat.sort((a, b) => b.expense.floor() - a.expense.floor());
    } else if(type == TransactionType.typeIncome) {
      // sort by income
      appCat.sort((a, b) => b.income.floor() - a.income.floor());
    }
  }

    // no category found, return empty list;
    return appCat;
}

Future<Account> loadLastUsedAccountForCategory({int categoryId}) async {
  String where;

  if(categoryId != null) where = "$fldCategoryId = $categoryId";

  var rawAccountId = await _db._query(tblTransaction, columns: [fldAccountId, "MAX($fldDateTime)"], where: where);

  Account account;

  do {
    if(rawAccountId == null) break;
    if(rawAccountId.isEmpty) break;

    var accountId = rawAccountId.first[fldAccountId];

    if(accountId == null) break;

    var rawAccount = await _db._query(tblAccount, where: "$_id = $accountId");

    if(rawAccount == null) break;
    if(rawAccount.isEmpty) break;

    account = _converter.toAccount(rawAccount.first);
  } while(false);

  return account;
}

Future<List<DateTime>> findTransactionsDates(DateTime day, {int accountId, int categoryId}) async {
  Map<DateTime, DateTime> dates = {};

  DateTime start = Utils.firstMomentOfMonth(day == null ? DateTime.now() : day);
  DateTime end = Utils.lastDayOfMonth(day == null ? DateTime.now() : day);

  // transaction table
  {
    String where;

    String dateWhere = "($fldDateTime BETWEEN ${start.millisecondsSinceEpoch} AND ${end.millisecondsSinceEpoch})";

    if(accountId != null) where = "$fldAccountId = $accountId";
    if(categoryId != null) where = "${where != null ? "$where AND " : ""}$fldCategoryId = $categoryId";

    where = "${where != null && where.isNotEmpty ? "$where AND ($dateWhere)" : "$dateWhere"}";

    List<Map<String, dynamic>> map = await _db._query(tblTransaction, where: where, columns: [fldDateTime]);

    if(map != null && map.isNotEmpty) {
      map.forEach((f) {
        var date = Utils.startOfDay(DateTime.fromMillisecondsSinceEpoch(f[fldDateTime]));

        dates.putIfAbsent(date, () => date);
      });
    }
  }

  // transfer table
  if(categoryId == null || accountId !=  null){
    String where;

    String dateWhere = "$fldDateTime BETWEEN ${start.millisecondsSinceEpoch} AND ${end.millisecondsSinceEpoch}";

    if(accountId != null) where = "($fldTransferFrom = $accountId OR $fldTransferTo = $accountId)";

    where = "${where != null && where.isNotEmpty ? "$where AND ($dateWhere)" : "$dateWhere"}";

    List<Map<String, dynamic>> map = await _db._query(tblTransfer, where: where, columns: [fldDateTime]);

    if(map != null && map.isNotEmpty) {
      map.forEach((f) {
        var date = Utils.startOfDay(DateTime.fromMillisecondsSinceEpoch(f[fldDateTime]));

        dates.putIfAbsent(date, () => date);
      });
    }
  }

  // discharge liability table
  if(accountId != null || (accountId == null && categoryId == null)){
    String where;

    String dateWhere = "$fldDateTime BETWEEN ${start.millisecondsSinceEpoch} AND ${end.millisecondsSinceEpoch}";

    if(accountId != null) where = "($fldAccountId = $accountId OR $fldLiabilityId = $accountId)";
    if(categoryId != null) where = "${where != null ? "$where AND " : ""}$fldCategoryId = $categoryId";

    where = "${where != null && where.isNotEmpty ? "$where AND ($dateWhere)" : "$dateWhere"}";

    List<Map<String, dynamic>> map = await _db._query(tblDischargeOfLiability, where: where, columns: [fldDateTime]);

    if(map != null && map.isNotEmpty) {
      map.forEach((f) {
        var date = Utils.startOfDay(DateTime.fromMillisecondsSinceEpoch(f[fldDateTime]));

        dates.putIfAbsent(date, () => date);
      });
    }
  }

  return dates.keys.toList();
}

// -----------------------------------------------------------------------------------------------------------------------------
// Accounts
Future<int> generateAccountId() {
  return _db._generateId(tblAccount);
}

Future<Account> queryAccount(int id) async {
  List<Map<String, dynamic>> map = await _db._query(tblAccount, where: "$_id = ?", whereArgs: [id]);

  if (map != null && map.length == 1) {
    return _converter.toAccount(map[0]);
  }

  return null;
}

Future<List<Account>> queryAccountsExcept(List<int> exceptAccountId) async {
  if (exceptAccountId == null || exceptAccountId.isEmpty) throw Exception("No list of account IDs to exclude");

  String where = "$_id NOT IN ${exceptAccountId.map((f) => "$f").toString()}";

  List<Map<String, dynamic>> map = await _db._query(tblAccount, where: where);

  if (map != null) {
    return map.map((f) => _converter.toAccount(f)).toList();
  }

  return null;
}

Future<List<Account>> queryAccounts({AccountType type}) async {
  String where;
  List whereArgs;

  if (type != null) {
    where = "$fldType = ?";
    whereArgs = [type.id];
  } else {
    where = null;
    whereArgs = null;
  }

  List<Map<String, dynamic>> map = await _db._query(tblAccount, where: where, whereArgs: whereArgs);

  if (map != null) {
    return map.map((f) => _converter.toAccount(f)).toList();
  }

  return null;
}

Future<void> insertAccount(Account account, {String batchIdentifier = DEFAULT_IDENTIFIER}) async {
  if (await _db.isExist(tblAccount, _id, account.id)) {
    _db._getBatch(batchIdentifier: batchIdentifier).update(tblAccount, _converter.accountToMap(account), where: "$_id = ?", whereArgs: [account.id]);
  } else {
    _db._getBatch(batchIdentifier: batchIdentifier).insert(tblAccount, _converter.accountToMap(account, includeId: true));
  }

  _tableChanged.add(tblAccount);
}

Future<void> updateAccount(Account account, {String batchIdentifier = DEFAULT_IDENTIFIER}) async {
  _db._getBatch(batchIdentifier: batchIdentifier).update(tblAccount, _converter.accountToMap(account), where: "$_id = ?", whereArgs: [account.id]);
  _tableChanged.add(tblAccount);
}

Future<void> deleteAccount(int accountId, {String batchIdentifier = DEFAULT_IDENTIFIER}) async {
  _db._getBatch(batchIdentifier: batchIdentifier).delete(tblAccount, where: "$_id = ?", whereArgs: [accountId]);
  _tableChanged.add(tblAccount);
}

// -----------------------------------------------------------------------------------------------------------------------------
// Category
Future<void> insertCategory(AppCategory category, {String batchIdentifier = DEFAULT_IDENTIFIER}) async {
  if(await _db.isExist(tblCategory, _id, category.id)) {
    _db._getBatch(batchIdentifier: batchIdentifier).update(tblCategory, _converter.categoryToMap(category), where: "$_id = ?", whereArgs: [category.id]);
  } else {
    _db._getBatch(batchIdentifier: batchIdentifier).insert(tblCategory, _converter.categoryToMap(category, includeId: true));
  }

  _tableChanged.add(tblCategory);
}

Future<void> updateCategory(AppCategory category, {String batchIdentifier = DEFAULT_IDENTIFIER}) async {
  _db._getBatch(batchIdentifier: batchIdentifier).update(tblCategory, _converter.categoryToMap(category), where: "$_id = ?", whereArgs: [category.id]);
  _tableChanged.add(tblCategory);
}

Future<void> deleteCategory(int catId, {String batchIdentifier = DEFAULT_IDENTIFIER}) async {
  _db._getBatch(batchIdentifier: batchIdentifier).delete(tblCategory, where: "$_id = ?", whereArgs: [catId]);
  _tableChanged.add(tblCategory);
}

Future<List<AppCategory>> queryCategory({int id, CategoryType type}) async {
  String where;
  List<int> whereArg;

  if (id == null && type == null) {
    where = null;
    whereArg = null;
  } else if (id != null) {
    where = "$_id = ?";
    whereArg = [id];
  } else if (type != null) {
    where = "$fldType = ?";
    whereArg = [type.id];
  }
  List<Map<String, dynamic>> map = await _db._query(tblCategory, where: where, whereArgs: whereArg);

  if (map != null) return map.map((f) => _converter.toCategory(f)).toList();

  return null;
}

Future<int> generateCategoryId() {
  return _db._generateId(tblCategory);
}

// -----------------------------------------------------------------------------------------------------------------------------
// Transaction
Future<void> insertTransaction(AppTransaction transaction, {String batchIdentifier = DEFAULT_IDENTIFIER}) async {
  if(await _db.isExist(tblTransaction, _id, transaction.id)) {
    _db._getBatch(batchIdentifier: batchIdentifier).update(tblTransaction, _converter.transactionToMap(transaction), where: "$_id = ?", whereArgs: [transaction.id]);
  } else {
    _db._getBatch(batchIdentifier: batchIdentifier).insert(tblTransaction, _converter.transactionToMap(transaction, includeId: true));
  }

  _tableChanged.add(tblTransaction);
}

Future<void> updateTransaction(AppTransaction transaction, {String batchIdentifier = DEFAULT_IDENTIFIER}) async {
  _db._getBatch(batchIdentifier: batchIdentifier).update(tblTransaction, _converter.transactionToMap(transaction), where: "$_id = ?", whereArgs: [transaction.id]);
  _tableChanged.add(tblTransaction);
}

Future<void> deleteTransaction(int id, {String batchIdentifier = DEFAULT_IDENTIFIER}) async {
  _db._getBatch(batchIdentifier: batchIdentifier).delete(tblTransaction, where: "$_id = ?", whereArgs: [id]);
  _tableChanged.add(tblTransaction);
}

Future<int> generateTransactionId() {
  return _db._generateId(tblTransaction);
}

Future<List<AppTransaction>> queryTransactions({int accountId, int categoryId, int transactionId, DateTime day, List<TransactionType> types}) async {
  String where;

  if(accountId != null) {
    where = "$fldAccountId = $accountId";
  }

  if(transactionId != null) {
    var transactionWhere = "$_id = $transactionId";

    where = where == null || where.isEmpty ? transactionWhere : "$where AND $transactionWhere";
  }

  if(day != null) {
    var startOfDay = Utils.startOfDay(day == null ? DateTime.now() : day);
    var endOfDay = Utils.endOfDay(day == null ? DateTime.now() : day);

    var dateWhere = "$fldDateTime BETWEEN ${startOfDay.millisecondsSinceEpoch} AND ${endOfDay.millisecondsSinceEpoch}";

    where = where == null || where.isEmpty ? dateWhere : "$where AND ($dateWhere)";
  }

  if (categoryId != null) {
    var categoryWhere = "$fldCategoryId = $categoryId";

    where = where == null || where.isEmpty ? categoryWhere : "$where AND $categoryWhere";
  }

  if (types != null) {
    var typeWhere = "$fldType in [${types.join(",")}]";

    where = where == null || where.isEmpty ? typeWhere : "$where AND $typeWhere";
  }

  List<Map<String, dynamic>> map = await _db._query(tblTransaction, where: where);

  return map == null ? [] : map.map((f) => _converter.toTransaction(f)).toList();
}

Future<List<AppTransaction>> queryTransactionsBetweenDates(DateTime from, DateTime to, {TransactionType type}) async {
  String where = from != null && to != null ? "$fldDateTime BETWEEN ${from.millisecondsSinceEpoch} AND ${to.millisecondsSinceEpoch}" : null;

  if(type != null) {
    where = "($where) AND $fldType = ${type.id}";
  }

  List<Map<String, dynamic>> map = await _db._query(tblTransaction, where: where);

  return map == null ? [] : map.map((f) => _converter.toTransaction(f)).toList();
}


Future<double> sumAllTransactionBetweenDateByType(DateTime from, DateTime to, List<TransactionType> type, {int accountId, int categoryId}) async {
  var amount = 0.0;

  // query from transaction table
  {
    var dateQuery = "($fldDateTime BETWEEN ${from.millisecondsSinceEpoch} AND ${to.millisecondsSinceEpoch})";
    var transactionTypeQuery = "$fldType IN ${type.map((f) => "${f.id}").toString()}";

    // additional queries
    var accountQuery = "";
    var categoryQuery = "";

    if (accountId != null) accountQuery = " AND $fldAccountId = $accountId";
    if (categoryId != null) categoryQuery = " AND $fldCategoryId = $categoryId";

    var sum = await _db._executeSql("SELECT SUM($fldAmount) FROM $tblTransaction WHERE $dateQuery AND $transactionTypeQuery$accountQuery$categoryQuery");
    amount += sum[0].values.first ?? 0.0;
  }

  return amount;
}


// -----------------------------------------------------------------------------------------------------------------------------
// User
Future<void> insertUser(User user, {String batchIdentifier = DEFAULT_IDENTIFIER}) async {
  if(await _db.isExist(tblUser, _id, user.uuid)) {
    _db._getBatch(batchIdentifier: batchIdentifier).update(tblUser, _converter.userToMap(user), where: "$_id = ?", whereArgs: [user.uuid]);
  } else {
    _db._getBatch(batchIdentifier: batchIdentifier).insert(tblUser, _converter.userToMap(user, includeId: true));
  }
  _tableChanged.add(tblUser);
}

Future<void> updateUser(User user, {String batchIdentifier = DEFAULT_IDENTIFIER}) async {
  _db._getBatch(batchIdentifier: batchIdentifier).update(tblUser, _converter.userToMap(user), where: "$_id = ?", whereArgs: [user.uuid]);
  _tableChanged.add(tblUser);
}

Future<void> deleteUser(String uid, {String batchIdentifier = DEFAULT_IDENTIFIER}) async {
  _db._getBatch(batchIdentifier: batchIdentifier).delete(tblUser, where: "$_id = ?", whereArgs: [uid]);
  _tableChanged.add(tblUser);
}

Future<User> queryUser(String uuid) async {
  String where;
  List whereArgs;

  if(uuid != null) {
    where = "$_id = ?";
    whereArgs = [uuid];
  }
  List<Map<String, dynamic>> map = await _db._query(tblUser, where: where, whereArgs: whereArgs);

  if(map != null && map.length == 1) {
    return _converter.toUser(map[0]);
  }

  return null;
}

// -----------------------------------------------------------------------------------------------------------------------------
// Budget
Future<void> insertBudget(Budget budget, {String batchIdentifier = DEFAULT_IDENTIFIER}) async {
  if (await _db.isExist(tblBudget, _id, budget.id)) {
    _db._getBatch(batchIdentifier: batchIdentifier).update(tblBudget, _converter.budgetToMap(budget), where: "$_id = ?", whereArgs: [budget.id]);
  } else {
    _db._getBatch(batchIdentifier: batchIdentifier).insert(tblBudget, _converter.budgetToMap(budget, includeId: true));
  }
  _tableChanged.add(tblBudget);
}

Future<void> updateBudget(Budget budget, {String batchIdentifier = DEFAULT_IDENTIFIER}) async {
  _db._getBatch(batchIdentifier: batchIdentifier).update(tblBudget, _converter.budgetToMap(budget), where: "$_id = ?", whereArgs: [budget.id]);
  _tableChanged.add(tblBudget);
}

Future<void> deleteBudget(int id, {String batchIdentifier = DEFAULT_IDENTIFIER}) async {
  _db._getBatch(batchIdentifier: batchIdentifier).delete(tblBudget, where: "$_id = ?", whereArgs: [id]);
  _tableChanged.add(tblBudget);
}

Future<int> generateBudgetId() {
  return _db._generateId(tblBudget);
}

Future<Budget> queryBudget({int catId, DateTime start, DateTime end}) async {
  var monthStart = Utils.firstMomentOfMonth(start).millisecondsSinceEpoch;
  var monthEnd = end == null ? null : Utils.lastDayOfMonth(end).millisecondsSinceEpoch;

  var findBudget = "";

  var findCategory = "";
  if(catId != null) findCategory = "$fldCategoryId = $catId AND ";

  findBudget = _compileFindBudgetSqlQuery(monthStart, monthEnd);

    var listMap = await _db._query(tblBudget, where: "$findCategory$findBudget", );

    if(listMap != null && listMap.isNotEmpty) {
      var budget = _converter.toBudget(listMap.first);
      return budget;
    }
    return null;
}

Future<DateTime> queryMinBudgetStart() async {
  var min = await _db._executeSql("SELECT MIN($fldStart) FROM $tblBudget");

  return min == null || min[0].values == null || min[0].values.first == null ? DateTime.now() : DateTime.fromMillisecondsSinceEpoch(min[0].values.first);
}

Future<DateTime> queryMaxBudgetEnd() async {
  var max = await _db._executeSql("SELECT MAX($fldEnd) FROM $tblBudget");

  return max == null || max[0].values == null || max[0].values.first == null ? DateTime.now() : DateTime.fromMillisecondsSinceEpoch(max[0].values.first);
}


/// Find budget IDs for this category with start/end time, which means any budget with duration collapse with this duration
/// There can be multiple ID returns, incase there are multiple budgets fall that cover the period between start and end time.
/// Cases
///     - 0 ID is returned: create new budget
///     - more IDs are returned: Update the first budget, and delete other collapsing budgets
Future<List<Budget>> queryCollapsingBudgets({@required int catId, @required DateTime start, @required DateTime end}) async {
  int monthStart = Utils.firstMomentOfMonth(start == null ? DateTime.now() : start).millisecondsSinceEpoch;
  int monthEnd = end == null ? null : Utils.lastDayOfMonth(end).millisecondsSinceEpoch;
  String findBudget = _compileFindBudgetSqlQuery(monthStart, monthEnd);

  // additional case when $start is before $monthStart, and endDate is null
  // is this special case for budget coverage, not to be used in other budget query
  findBudget += " OR ($monthStart <= $fldStart${monthEnd == null ? "" : " AND $fldEnd >= $monthEnd"})";

  var map = await _db._query(tblBudget, where: "$fldCategoryId = $catId AND ($findBudget)",);

  return map == null ? [] : map.map((f) => _converter.toBudget(f)).toList();
}

String _compileFindBudgetSqlQuery(int monthStart, int monthEnd) {
  String findBudget = "";

  if(monthEnd == null) {
    findBudget = "$fldStart <= $monthStart";
  } else {
    // case 1
    // start to end   -----------|duration is around here|----------
    // budget -----------------------| budget is here until forever
    // include the case when budget starts before this period
    // budget --------------| budget is here until forever
    findBudget = "($fldEnd IS NULL AND $fldStart < $monthEnd)";
    // case 2
    // start to end   -----------|duration is around here|----------
    // budget -----------------------| budget is here |-------------
    findBudget += " OR ($fldStart >= $monthStart AND $fldEnd <= $monthEnd)";
    // case 3
    // start to end   -----------|duration is around here|----------
    // budget ---------------| budget is here until after end|----------
    // OR
    // budget ---------------| budget is here|----------
    findBudget += " OR ($fldStart <= $monthStart AND $fldEnd >= $monthStart)";

    // add bracelet
    findBudget = "($findBudget)";
  }

  return findBudget;
}

// -----------------------------------------------------------------------------------------------------------------------------
// Transfer
Future<void> insertTransfer(Transfer transfer, {String batchIdentifier = DEFAULT_IDENTIFIER}) async {
  if(await _db.isExist(tblTransfer, _id, transfer.id)) {
    _db._getBatch(batchIdentifier: batchIdentifier).update(tblTransfer, _converter.transferToMap(transfer), where: "$_id = ?", whereArgs: [transfer.id]);
  } else {
    _db._getBatch(batchIdentifier: batchIdentifier).insert(tblTransfer, _converter.transferToMap(transfer, includeId: true));
  }
  _tableChanged.add(tblTransfer);
}

Future<void> updateTransfer(Transfer transfer, {String batchIdentifier = DEFAULT_IDENTIFIER}) async {
  _db._getBatch(batchIdentifier: batchIdentifier).update(tblTransfer, _converter.transferToMap(transfer), where: "$_id = ?", whereArgs: [transfer.id]);
  _tableChanged.add(tblTransfer);
}

Future<void> deleteTransfer(int id, {String batchIdentifier = DEFAULT_IDENTIFIER}) async {
  _db._getBatch(batchIdentifier: batchIdentifier).delete(tblTransfer, where: "$_id = ?", whereArgs: [id]);
  _tableChanged.add(tblTransfer);
}

Future<List<Transfer>> queryTransfer({int account, DateTime day}) async {
  String query = "";

  if(day != null) {
    var startOfDay = Utils.startOfDay(day == null ? DateTime.now() : day);
    var endOfDay = Utils.endOfDay(day == null ? DateTime.now() : day);

    query = "($fldDateTime BETWEEN ${startOfDay.millisecondsSinceEpoch} AND ${endOfDay.millisecondsSinceEpoch})";
  }

  if(account != null) {
    query = "${query == null || query.isEmpty ? "" : "$query AND "}($fldTransferFrom = $account OR $fldTransferTo = $account)";
  }

  List<Map<String, dynamic>> map = await _db._query(tblTransfer, where: "$query");

  return map == null ? [] : map.map((f) => _converter.toTransfer(f)).toList();
}

Future<int> generateTransferId() {
  return _db._generateId(tblTransfer);
}

// -----------------------------------------------------------------------------------------------------------------------------
// DischargeOfLiability
Future<void> insertDischargeOfLiability(DischargeOfLiability liability, {String batchIdentifier = DEFAULT_IDENTIFIER}) async{
  if(await _db.isExist(tblDischargeOfLiability, _id, liability.id)) {
    _db._getBatch(batchIdentifier: batchIdentifier).update(tblDischargeOfLiability, _converter.dischargeLiabilityToMap(liability), where: "$_id = ?", whereArgs: [liability.id]);
  } else {
    _db._getBatch(batchIdentifier: batchIdentifier).insert(tblDischargeOfLiability, _converter.dischargeLiabilityToMap(liability, includeId: true));
  }
  _tableChanged.add(tblDischargeOfLiability);
}

Future<void> updateDischargeOfLiability(DischargeOfLiability liability, {String batchIdentifier = DEFAULT_IDENTIFIER}) async {
  _db._getBatch(batchIdentifier: batchIdentifier).update(tblDischargeOfLiability, _converter.dischargeLiabilityToMap(liability), where: "$_id = ?", whereArgs: [liability.id]);
  _tableChanged.add(tblDischargeOfLiability);
}

Future<void> deleteDischargeOfLiability(int id, {String batchIdentifier = DEFAULT_IDENTIFIER}) async {
  _db._getBatch(batchIdentifier: batchIdentifier).delete(tblDischargeOfLiability, where: "$_id = ?", whereArgs: [id]);
  _tableChanged.add(tblDischargeOfLiability);
}

Future<int> generateDischargeLiabilityId() {
  return _db._generateId(tblDischargeOfLiability);
}

Future<List<DischargeOfLiability>> queryDischargeOfLiability({int account, DateTime day}) async {
  var query = "";
  if(day != null) {
    var startOfDay = Utils.startOfDay(day == null ? DateTime.now() : day);
    var endOfDay = Utils.endOfDay(day == null ? DateTime.now() : day);

    query = "($fldDateTime BETWEEN ${startOfDay.millisecondsSinceEpoch} AND ${endOfDay.millisecondsSinceEpoch})";
  }

  if(account != null) {
    query = "${query == null || query.isEmpty ? "" : "$query AND "}($fldLiabilityId = $account OR $fldTransferFrom = $account)";
  }

  List<Map<String, dynamic>> map = await _db._query(tblDischargeOfLiability, where: "$query");

  return map == null ? [] : map.map((f) => _converter.toDischargeOfLiability(f)).toList();
}


// #############################################################################################################################
// private converters
// #############################################################################################################################
class _Converter {
  Map<String, dynamic> accountToMap(Account acc, {bool includeId = false}) {
    if (acc.id == null) return null;

    var map = <String, dynamic>{};

    if (acc.name != null) map.putIfAbsent(fldName, () => acc.name);
    if (acc.initialBalance != null) map.putIfAbsent(fldInitialBalance, () => acc.initialBalance);
    if (acc.created != null) map.putIfAbsent(fldCreated, () => acc.created.millisecondsSinceEpoch);
    if (acc.type != null) map.putIfAbsent(fldType, () => acc.type.id);
    if (acc.currency != null) map.putIfAbsent(fldCurrency, () => acc.currency);

    if(includeId) map.putIfAbsent(_id, () => acc.id);
    map.putIfAbsent(_updated, () => DateTime.now().millisecondsSinceEpoch);

    return map;
  }

  Account toAccount(Map<String, dynamic> map) {
    Account acc = new Account(
        map[_id], map[fldName],
        (map[fldInitialBalance] == null ? 0 : map[fldInitialBalance]) * 1.0,
        map[fldType] == null ? null : AccountType.all[map[fldType]],
        map[fldCurrency],
        map[fldCreated] == null ? null : DateTime.fromMillisecondsSinceEpoch(map[fldCreated]));

    return acc;
  }

  Map<String, dynamic> categoryToMap(AppCategory cat, {bool includeId = false}) {
    if (cat.id == null) return null;

    var map = <String, dynamic>{};

    if (cat.name != null) map.putIfAbsent(fldName, () => cat.name);
    if (cat.colorHex != null) map.putIfAbsent(fldColorHex, () => cat.colorHex);
    if (cat.categoryType != null) map.putIfAbsent(fldType, () => cat.categoryType.id);
    if (cat.group != null) map.putIfAbsent(fldGroup, () => cat.group);

    if(includeId) map.putIfAbsent(_id, () => cat.id);
    map.putIfAbsent(_updated, () => DateTime.now().millisecondsSinceEpoch);

    return map;
  }

  AppCategory toCategory(Map<String, dynamic> map) {
    return AppCategory(
      map[_id],
      map[fldName],
      map[fldColorHex],
      CategoryType.all[map[fldType] == null ? 0 : map[fldType]],
      group: map[fldGroup],
    );
  }

  Map<String, dynamic> transactionToMap(AppTransaction transaction, {bool includeId = false}) {
    if (transaction.id == null) return null;

    var map = <String, dynamic>{};

    if (transaction.dateTime != null) map.putIfAbsent(fldDateTime, () => transaction.dateTime.millisecondsSinceEpoch);
    if (transaction.accountId != null) map.putIfAbsent(fldAccountId, () => transaction.accountId);
    if (transaction.categoryId != null) map.putIfAbsent(fldCategoryId, () => transaction.categoryId);
    if (transaction.amount != null) map.putIfAbsent(fldAmount, () => transaction.amount);
    if (transaction.desc != null) map.putIfAbsent(fldDesc, () => transaction.desc);
    if (transaction.type != null) map.putIfAbsent(fldType, () => transaction.type.id);
    if (transaction.userUid != null) map.putIfAbsent(fldUuid, () => transaction.userUid);

    if(includeId) map.putIfAbsent(_id, () => transaction.id);
    map.putIfAbsent(_updated, () => DateTime.now().millisecondsSinceEpoch);

    return map;
  }

  AppTransaction toTransaction(Map<String, dynamic> map) {
    return AppTransaction(
        map[_id],
        DateTime.fromMillisecondsSinceEpoch(map[fldDateTime]),
        map[fldAccountId],
        map[fldCategoryId],
        (map[fldAmount] == null ? 0 : map[fldAmount]) * 1.0,
        map[fldDesc],
        map[fldType] == null ? null : TransactionType.all[map[fldType]],
        map[fldUuid]);
  }


  Map<String, dynamic> userToMap(User user, {bool includeId = false}) {
    if (user.uuid == null) return null;

    var map = <String, dynamic>{};

    if (user.email != null) map.putIfAbsent(fldEmail, () => user.email);
    if (user.displayName != null) map.putIfAbsent(fldDisplayName, () => user.displayName);
    if (user.photoUrl != null) map.putIfAbsent(fldPhotoUrl, () => user.photoUrl);
    if (user.color != null) map.putIfAbsent(fldColor, () => user.color);
    map.putIfAbsent(fldEmailVerified, () => user.isVerified ?? false);

    if(includeId) map.putIfAbsent(_id, () => user.uuid);
    map.putIfAbsent(_updated, () => DateTime.now().millisecondsSinceEpoch);

    return map;
  }

  User toUser(Map<String, dynamic> map) {
    return User(
      map[_id],
      map[fldEmail],
      map[fldDisplayName],
      map[fldPhotoUrl],
      map[fldColor],
      map[fldEmailVerified] == "true"
    );
  }

  Map<String, dynamic> budgetToMap(Budget budget, {bool includeId = false}) {
    if (budget.id == null) return null;

    var map = <String, dynamic>{};

    if (budget.categoryId != null) map.putIfAbsent(fldCategoryId, () => budget.categoryId);
    if (budget.budgetPerMonth != null) map.putIfAbsent(fldAmount, () => budget.budgetPerMonth);
    if (budget.budgetStart != null) map.putIfAbsent(fldStart, () => budget.budgetStart.millisecondsSinceEpoch);
    if (budget.budgetEnd != null) map.putIfAbsent(fldEnd, () => budget.budgetEnd.millisecondsSinceEpoch);

    if(includeId) map.putIfAbsent(_id, () => budget.id);
    map.putIfAbsent(_updated, () => DateTime.now().millisecondsSinceEpoch);

    return map;
  }

  Budget toBudget(Map<String, dynamic> map) {
  return Budget(
      map[_id],
      map[fldCategoryId],
      map[fldAmount] != null ? map[fldAmount] * 1.0 : 0.0,
      DateTime.fromMillisecondsSinceEpoch(map[fldStart]),
      map[fldEnd] == null ? null : DateTime.fromMillisecondsSinceEpoch(map[fldEnd]),
      );
  }

  Map<String, dynamic> transferToMap(Transfer transfer, {bool includeId = false}) {
    if (transfer.id == null) return null;

    var map = <String, dynamic>{};

    if (transfer.transferDate != null) map.putIfAbsent(fldDateTime, () => transfer.transferDate.millisecondsSinceEpoch);
    if (transfer.amount != null) map.putIfAbsent(fldAmount, () => transfer.amount);
    if (transfer.fromAccount != null) map.putIfAbsent(fldTransferFrom, () => transfer.fromAccount);
    if (transfer.toAccount != null) map.putIfAbsent(fldTransferTo, () => transfer.toAccount);
    if (transfer.userUuid != null) map.putIfAbsent(fldUuid, () => transfer.userUuid);

    if(includeId) map.putIfAbsent(_id, () => transfer.id);
    map.putIfAbsent(_updated, () => DateTime.now().millisecondsSinceEpoch);

    return map;
  }

  Transfer toTransfer(Map<String, dynamic> map) {
    return Transfer(
      map[_id],
      map[fldTransferFrom],
      map[fldTransferTo],
      map[fldAmount],
      map[fldDateTime] == null ? DateTime.now() : DateTime.fromMillisecondsSinceEpoch(map[fldDateTime]),
      map[fldDateTime]
    );
  }


  Map<String, dynamic> dischargeLiabilityToMap(DischargeOfLiability discharge, {bool includeId = false}) {
    if (discharge.id == null) return null;

    var map = <String, dynamic>{};

    if (discharge.liabilityId != null) map.putIfAbsent(fldLiabilityId, () => discharge.liabilityId);
    if (discharge.dateTime != null) map.putIfAbsent(fldDateTime, () => discharge.dateTime.millisecondsSinceEpoch);
    if (discharge.accountId != null) map.putIfAbsent(fldAccountId, () => discharge.accountId);
    if (discharge.categoryId != null) map.putIfAbsent(fldCategoryId, () => discharge.categoryId);
    if (discharge.amount != null) map.putIfAbsent(fldAmount, () => discharge.amount);
    if (discharge.userUid != null) map.putIfAbsent(fldUuid, () => discharge.userUid);

    if(includeId) map.putIfAbsent(_id, () => discharge.id);
    map.putIfAbsent(_updated, () => DateTime.now().millisecondsSinceEpoch);

    return map;
  }

  DischargeOfLiability toDischargeOfLiability(Map<String, dynamic> map) {
    return DischargeOfLiability(
      map[_id],
      map[fldDateTime] == null ? DateTime.now() : DateTime.fromMillisecondsSinceEpoch(map[fldDateTime]),
      map[fldLiabilityId],
      map[fldAccountId],
      map[fldCategoryId],
      map[fldAmount],
      map[fldUuid]
    );
  }
}

// #############################################################################################################################
// private database handler
// #############################################################################################################################
const _id = "_id";
const _updated = "_updated";

class _Database {
  Database db;
  Map<String, List<DatabaseObservable>> _watchers = {};
  _PrivateDbHelper _privateDbHelper = _PrivateDbHelper();
  Map<String, Batch> _batch = {};

  Future<Database> _openDatabase() async {
    String dbPath = join((await getApplicationDocumentsDirectory()).path, "MyWalletDb");
    return await openDatabase(dbPath, version: 12, onCreate: (Database db, int version) async {
      await _privateDbHelper._executeCreateDatabase(db);
    }, onUpgrade: (Database db, int oldVersion, int newVersion) async {
      // on upgrade? delete all tables and create all new
      for (String tbl in allTables) {
        try {
          await db.execute("DROP TABLE $tbl");
        } catch (e, stacktrace) {
          debugPrint(stacktrace.toString());
        }
      }

      await _privateDbHelper._executeCreateDatabase(db);
    });
  }

  Future<void> init() async {
    db = await _openDatabase();

    // create default batch
    _batch.putIfAbsent(DEFAULT_IDENTIFIER, () => db.batch());
  }

  Future<void> dispose() async {
    await SharedPreferences.setPausedTime(DateTime.now().millisecondsSinceEpoch);
    await db.close();
  }

  Batch _getBatch({String batchIdentifier = DEFAULT_IDENTIFIER}) {
    if (_batch == null || _batch.isEmpty) throw Exception("No transaction to execute. You need to call startTransaction() before calling execute()");

    return _batch[batchIdentifier];
  }

  void _clearBatch(String batchIdentifier) {
    if(_batch == null) return;
    if(_batch.isEmpty) return;
    _batch.removeWhere((key, value) => batchIdentifier == key);

    if(batchIdentifier == DEFAULT_IDENTIFIER) {
      // put new
      _batch.putIfAbsent(DEFAULT_IDENTIFIER, () => db.batch());
    }
  }

  Future<bool> isExist(String table, String column, dynamic value) async {
    var row = await db.query(table, where: "$column = ?", whereArgs: [value]);

    return row.length > 0;
  }

  Future<int> _generateId(String table) async {
    int id = 0;

    var ids = await db.rawQuery("SELECT MAX($_id) FROM $table");

    if (ids.length >= 0) {
      id = ids[0].values.first;
    }

    return id == null ? 0 : id + 1;
  }

  String startTransaction() {
    if(_batch == null) _batch = {};

    Batch batch = db.batch();
    String batchIdentifier = batch.hashCode.toRadixString(6);
    _batch.putIfAbsent(batchIdentifier, () => batch);

    return batchIdentifier;
  }

  Future<List<Map<String, dynamic>>> _executeSql(String sql) async {
    var result = await db.rawQuery(sql);

    return result;
  }

  Future<List<Map<String, dynamic>>> _query(String table, {String where, List whereArgs, String orderBy, List<String> columns}) async {
    List<Map<String, dynamic>> map;
    try {
      map = await db.query(table, where: where, whereArgs: whereArgs, orderBy: orderBy, columns: columns);
    } catch (e) {
      debugPrint("$e - Error with query for table $table with where clause $where and arguments $whereArgs for columns $columns");
    }

    return map;
  }

  Future<void> _deleteDb() async {
    String path = db.path;

    await db.close();
    await deleteDatabase(path);
  }

  Future<void> deleteTable(String name) async {}

  void _notifyObservers(List<String> tables) {
    Set<DatabaseObservable> observables = new Set();

    tables.forEach((table) {
      if (_watchers[table] != null) _watchers[table].forEach((f) => observables.add(f));
    });

    observables.forEach((f) {
      f.onDatabaseUpdate(tables);
    });
  }

  void registerDatabaseObservable(List<String> tables, DatabaseObservable observable) {
    if (tables != null) {
      tables.forEach((f) {
        List<DatabaseObservable> list = _watchers[f];

        if (list == null) list = [];

        list.add(observable);

        _watchers.remove(f);
        _watchers.putIfAbsent(f, () => list);
      });
    }
  }

  void unregisterDatabaseObservable(List<String> tables, DatabaseObservable observable) {
    if (tables != null) {
      tables.forEach((f) {
        List<DatabaseObservable> list = _watchers[f];

        if (list != null) list.remove(observable);

        _watchers.remove(f);
        _watchers.putIfAbsent(f, () => list);
      });
    }
  }
}

class _PrivateDbHelper {
  Future<void> _executeCreateDatabase(Database db) async {
    for (String table in allTables) {
      await db.execute(_generateCreateTableSql(table));
    }
  }

  String _generateCreateTableSql(String table) {
    if (table == tblAccount) return _createAccountTable();
    if (table == tblTransaction) return _createTransactionTable();
    if (table == tblCategory) return _createCategoryTable();
    if (table == tblBudget) return _createBudgetTable();
    if (table == tblUser) return _createUserTable();
    if (table == tblTransfer) return _createTransferTable();
    if (table == tblDischargeOfLiability) return _createDischargeLiabilityTable();

    throw Exception("Table $table is not defined");
  }

  String _createAccountTable() {
    return """
            CREATE TABLE $tblAccount (
              $_id INTEGER PRIMARY KEY,
              $fldName TEXT NOT NULL,
              $fldInitialBalance DOUBLE NOT NULL,
              $fldCreated INTEGER NOT NULL,
              $fldType INTEGER NOT NULL,
              $fldCurrency TEXT NOT NULL,
              $fldBalance DOUBLE,
              $fldSpent DOUBLE,
              $fldEarn DOUBLE,
              $_updated INTEGER NOT NULL
            )""";
  }

  String _createTransactionTable() {
    return """
          CREATE TABLE $tblTransaction (
          $_id INTEGER PRIMARY KEY,
          $fldDateTime LONG NOT NULL,
          $fldAccountId INTEGER NOT NULL,
          $fldCategoryId INTEGER NOT NULL,
          $fldAmount DOUBLE NOT NULL,
          $fldDesc TEXT,
          $fldType INTEGER NOT NULL,
          $fldUuid TEXT NOT NULL,
          $_updated INTEGER NOT NULL
          )""";
  }

  String _createCategoryTable() {
    return """
        CREATE TABLE $tblCategory (
        $_id INTEGER PRIMARY KEY,
        $fldName TEXT NOT NULL,
        $fldColorHex TEXT NOT NULL,
        $fldType INTEGER NOT NULL,
        $fldGroup INTEGER,
        $_updated INTEGER NOT NULL
        )
        """;
  }

  String _createBudgetTable() {
    return """
        CREATE TABLE $tblBudget (
        $_id INTEGER PRIMARY KEY,
        $fldCategoryId INTEGER NOT NULL,
        $fldAmount DOUBLE NOT NULL,
        $fldStart INTEGER NOT NULL,
        $fldEnd INTEGER,
        $_updated INTEGER NOT NULL
        )
        """;
  }

  String _createUserTable() {
    return """
        CREATE TABLE $tblUser (
        $_id TEXT NOT NULL PRIMARY KEY,
        $fldDisplayName TEXT NOT NULL,
        $fldEmail TEXT NOT NULL,
        $fldPhotoUrl TEXT,
        $fldColor INTEGER,
        $fldEmailVerified TEXT,
        $_updated INTEGER NOT NULL
      )
      """;
  }

  String _createTransferTable() {
    return """
        CREATE TABLE $tblTransfer (
        $_id INTEGER PRIMARY KEY,
        $fldTransferFrom INTEGER NOT NULL,
        $fldTransferTo INTEGER NOT NULL,
        $fldAmount DOUBLE NOT NULL,
        $fldDateTime INTEGER NOT NULL,
        $fldUuid TEXT NOT NULL,
        $_updated INTEGER NOT NULL
        )
        """;
  }

  String _createDischargeLiabilityTable() {
    return """
      CREATE TABLE $tblDischargeOfLiability (
      $_id INTEGER PRIMARY KEY,
      $fldLiabilityId INTEGER NOT NULL,
      $fldAccountId INTEGER NOT NULL,
      $fldAmount DOUBLE NOT NULL,
      $fldDateTime INTEGER NOT NULL,
      $fldCategoryId INTEGER NOT NULL,
      $fldUuid TEXT NOT NULL,
      $_updated INTEGER NOT NULL
      )
    """;
  }
}

// private implementation of Batch to handle error gracefully
//class _Queue {
//  List<_Action> actions;
//  final Database _db;
//
//  _Queue(this._db) : actions = [];
//
//  Future<void> commit() async{
//    if(actions != null) {
//      for (_Action action in actions) {
//        try {
//          await action.task;
//        } catch (e) {
//          print("Exception on commit ${e.toString()}");
//
//          if(action.onError != null) {
//            await action.onError;
//          }
//        }
//      }
//    }
//  }
//
//  Future<void> insert(String tableName, Map<String, dynamic> data) async {
//    Map<String, dynamic> updateData = Map.from(data);
//    updateData.remove(_id);
//    actions.add(_Action(_db.insert(tableName, data), onError: _db.update(tableName, updateData)));
//  }
//
//  Future<void> update(String tableName, Map<String, dynamic> data, {String where, List<dynamic> whereArgs}) async {
//    actions.add(_Action(_db.update(tableName, data, where: where, whereArgs: whereArgs)));
//  }
//
//  Future<void> delete(String tableName, {String where, List<dynamic> whereArgs}) async {
//    actions.add(_Action(_db.delete(tableName, where: where, whereArgs: whereArgs)));
//  }
//
//}
//
//class _Action {
//  final Future task;
//  final Future onError;
//
//  _Action(this.task, {this.onError});
//}
