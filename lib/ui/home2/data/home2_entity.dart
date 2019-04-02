export 'package:my_wallet/data/data.dart';

import 'package:my_wallet/ui/home2/data/expenses_entity.dart';
export 'package:my_wallet/ui/home2/data/expenses_entity.dart';

import 'package:my_wallet/ui/home2/data/chart_title_entity.dart';
export 'package:my_wallet/ui/home2/data/chart_title_entity.dart';

import 'package:my_wallet/ui/home2/data/transaction_entity.dart';
export 'package:my_wallet/ui/home2/data/transaction_entity.dart';

import 'package:my_wallet/ui/home2/data/chart_budget_entity.dart';
export 'package:my_wallet/ui/home2/data/chart_budget_entity.dart';

class HomeEntity {
  final double totalOverview;
  final ChartTitleEntity chartTitleEntity;
  final List<ExpenseEntity> expensesEntity;
  final List<TransactionEntity> incomeEntity;
  final List<TransactionEntity> expenseEntity;
  final ChartBudgetEntity budgetEntity;

  HomeEntity(this.totalOverview, this.chartTitleEntity, this.incomeEntity, this.expenseEntity, this.budgetEntity, this.expensesEntity);
}