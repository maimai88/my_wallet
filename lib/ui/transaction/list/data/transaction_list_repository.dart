import 'package:my_wallet/data/database_manager.dart' as db;
import 'package:my_wallet/utils.dart' as Utils;
import 'package:my_wallet/ca/data/ca_repository.dart';
import 'package:my_wallet/ui/transaction/list/data/transaction_list_entity.dart';
import 'package:my_wallet/data/data.dart';
import 'package:my_wallet/style/app_theme.dart';

import 'package:my_wallet/resources.dart' as R;

class TransactionListRepository extends CleanArchitectureRepository {
  final _TransactionListDatabaseRepository _dbRepo = _TransactionListDatabaseRepository();

  Future<TransactionListEntity> loadDataFor(
      int accountId,
      int categoryId,
      DateTime day
      ) {
    return _dbRepo.loadDataFor(accountId, categoryId, day);
  }
}

class _TransactionListDatabaseRepository {
  Future<TransactionListEntity> loadDataFor(
      int accountId,
      int categoryId,
      DateTime day
      ) async {
    List<TransactionEntity> entities = [];
    List<Transfer> transfers = [];
    List<DischargeOfLiability> discharge = [];
    List<DateTime> dates = [];
    var total = 0.0;

    dates = await db.findTransactionsDates(day, accountId : accountId, categoryId : categoryId, );

    List<AppTransaction> transactions = [];
    if(accountId != null) {
      transactions = await db.queryTransactionForAccount(accountId, day);
      transfers = await db.queryTransfer(account: accountId, day: day);
      discharge = await db.queryDischargeOfLiability(account: accountId, day: day);
    }

    if(categoryId != null) {
      transactions = await db.queryTransactionForCategory(categoryId, day);
    }

    if(accountId == null && categoryId == null && day != null) {
      // only load for days when there's no account or category required
      transactions = await db.queryTransactionsBetweenDates(Utils.startOfDay(day), Utils.endOfDay(day));
      transfers = await db.queryTransfer(account: accountId, day: day);
      discharge = await db.queryDischargeOfLiability(account: accountId, day: day);
    }

    if (transactions != null) {
      Map<int, String> categoryNames = {};

      for(AppTransaction trans in transactions) {
        if(trans.userUid == null || trans.userUid.isEmpty) continue;

        // get category name
        var catName = categoryNames[trans.categoryId];

        if(catName == null) {
          var category = await db.queryCategory(id: trans.categoryId);
          if(category != null && category.isNotEmpty) catName = category[0].name;

          // put category name for this ID into map, to be reused later
          categoryNames.putIfAbsent(trans.categoryId, () => catName);
        }

        // get user initial
        List<User> users = await db.queryUser(uuid: trans.userUid);

        if(users != null && users.isNotEmpty) {
          User user = users[0];
          var initial = _buildUserInitial(user);

          total += TransactionType.isExpense(trans.type) ? trans.amount : 0.0;
          entities.add(TransactionEntity(trans.id, initial, catName, trans.desc, trans.amount, trans.dateTime, user.color, TransactionType.isIncome(trans.type) ? AppTheme.tealAccent.value : AppTheme.pinkAccent.value, trans.type));
        }
      }
    }

    if(transfers != null && transfers.isNotEmpty) {
      for(Transfer transfer in transfers) {
        // get user initial
        List<User> users = await db.queryUser(uuid: transfer.userUuid);
        User user = users[0];
        var initial = _buildUserInitial(user);

        List<Account> from = await db.queryAccounts(id: transfer.fromAccount);
        List<Account> to = await db.queryAccounts(id: transfer.toAccount);

        entities.add(TransactionEntity(transfer.id, initial, R.string.transfer, "${R.string.from} ${from[0].name} ${R.string.to} ${to[0].name}", transfer.amount, transfer.transferDate, user.color, AppTheme.blueGrey.value, TransactionType.moneyTransfer));
      }
    }

    if(discharge != null && discharge.isNotEmpty) {
      for (DischargeOfLiability dischargeOfLiability in discharge) {
        // get user initial
        List<User> users = await db.queryUser(uuid: dischargeOfLiability.userUid);
        User user = users[0];
        var initial = _buildUserInitial(user);

        List<Account> from = await db.queryAccounts(id: dischargeOfLiability.accountId);
        List<Account> to = await db.queryAccounts(id: dischargeOfLiability.liabilityId);

        entities.add(TransactionEntity(dischargeOfLiability.id, initial, R.string.discharge_of_liability, "${R.string.from} ${from[0].name} ${R.string.to} ${to[0].name}", dischargeOfLiability.amount, dischargeOfLiability.dateTime, user.color, AppTheme.blueGrey.value, TransactionType.dischargeOfLiability));

      }
    }

    // calculate total expenses for each day
    Map<DateTime, double> dateExpenses = {};
    if(dates != null && dates.isNotEmpty) {
      for(DateTime dateTime in dates) {
        dateExpenses.putIfAbsent(dateTime, () => 0.0);
      }
    }

    // sort transactions by date
    entities.sort((a, b) => a.dateTime.millisecondsSinceEpoch - b.dateTime.millisecondsSinceEpoch);

    var budget = await db.findBudget(start: Utils.firstMomentOfMonth(day == null ? DateTime.now() : day), end: Utils.lastDayOfMonth(day == null ? DateTime.now() : day), catId: categoryId);
    var fraction = budget == null || budget.budgetPerMonth == 0 ? 1.0 : total/budget.budgetPerMonth;
    return TransactionListEntity(entities, dateExpenses, total, fraction);
  }

  String _buildUserInitial(User user) {
    var splits = user.displayName.split(" ");
    var initial = splits.map((f) => f.substring(0, 1).toUpperCase()).join();
    return initial.substring(0, initial.length < 2 ? initial.length : 2);
  }
}
