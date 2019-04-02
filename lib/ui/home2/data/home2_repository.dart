import 'package:my_wallet/ca/data/ca_repository.dart';
import 'package:my_wallet/ui/home2/data/home2_entity.dart';
import 'package:my_wallet/data/database_manager.dart' as _db;
import 'package:my_wallet/data/firebase/database.dart' as _fdb;

import 'package:my_wallet/utils.dart' as Utils;
export 'package:my_wallet/ui/home2/data/home2_entity.dart';

import 'dart:core';

class MyWalletHomeRepository extends CleanArchitectureRepository {
  final _MyWalletHomeDatabaseRepository _dbRepo = _MyWalletHomeDatabaseRepository();
  final _MyWalletHomeFirebaseRepository _fbRepo = _MyWalletHomeFirebaseRepository();

  final _HomeOverviewDatabaseRepository _homeRepo = _HomeOverviewDatabaseRepository();
  final _ChartTitleRepository _chartTitleRepository = _ChartTitleRepository();

  Future<List<ExpenseEntity>> loadExpense() {
    return _dbRepo.loadExpense();
  }

  Future<double> loadTotalOverview() {
    return _homeRepo.loadTotal();
  }

  Future<ChartTitleEntity> loadChartTitleEntity() {
    return _chartTitleRepository.loadTitleDetail();
  }

  Future<bool> resumeDatabase() async {
    await _dbRepo.resume();
    await _fbRepo.resume();

    return true;
  }

  Future<bool> dispose() async {
    await _dbRepo.dispose();
    await _fbRepo.dispose();

    return true;
  }
}

class _MyWalletHomeDatabaseRepository {
  Future<List<ExpenseEntity>> loadExpense() async {
    var start = Utils.firstMomentOfMonth(DateTime.now());
    var end = Utils.lastDayOfMonth(DateTime.now());

    List<AppCategory> cats = await _db.queryCategoryWithTransaction(from: start, to: end, filterZero: false);

    List<ExpenseEntity> homeEntities = [];

    if (cats != null && cats.isNotEmpty) {
      for(AppCategory cat in cats) {
        var budget = await _db.findBudget(start: start, end: end, catId: cat.id);

        var transaction = cat.categoryType == CategoryType.expense ? cat.expense : cat.income;

        var remainFactor = 1 - (budget == null || budget.budgetPerMonth == 0 ? 0.0 : transaction/budget.budgetPerMonth);
        var remain = (budget == null ? 0.0 : budget.budgetPerMonth) - transaction;

        if(remainFactor < 0) remainFactor = 0.0;

        if(cat.categoryType == CategoryType.income) remain = remain.abs();

        homeEntities.add(ExpenseEntity(cat.id, cat.name, cat.colorHex, transaction, remain, budget != null ? budget.budgetPerMonth : 0.0, remainFactor, cat.categoryType));
      }
    }

    return homeEntities;
  }

  Future<void> resume() {
    return _db.resume();
  }

  Future<void> dispose() {
    return _db.dispose();
  }
}

class _MyWalletHomeFirebaseRepository {
  Future<void> resume() {
    return _fdb.resume();
  }

  Future<void> dispose() {
    return _fdb.dispose();
  }
}

// home overview
class _HomeOverviewDatabaseRepository {
  Future<double> loadTotal() async {
    var start = Utils.firstMomentOfMonth(DateTime.now());
    var end = Utils.lastDayOfMonth(DateTime.now());

    var expenses = await _db.sumAllTransactionBetweenDateByType(start, end, TransactionType.typeExpense);
    var income = await _db.sumAllTransactionBetweenDateByType(start, end, TransactionType.typeIncome);

    return income - expenses;
  }
}
// --------------------------------------------------

class _ChartTitleRepository extends CleanArchitectureRepository{
  Future<ChartTitleEntity> loadTitleDetail() async {
    var from = Utils.firstMomentOfMonth(DateTime.now());
    var to = Utils.lastDayOfMonth(DateTime.now());

    var income = await _db.sumAllTransactionBetweenDateByType(from, to, TransactionType.typeIncome) ?? 0;
    var expenses = await _db.sumAllTransactionBetweenDateByType(from, to, TransactionType.typeExpense) ?? 0;
    var budget = await _db.querySumAllBudgetForMonth(from, to, CategoryType.expense);

    return ChartTitleEntity(expenses, income, budget == 0 ? 0.0 : expenses < budget ? expenses / budget : 1.0);
  }
}