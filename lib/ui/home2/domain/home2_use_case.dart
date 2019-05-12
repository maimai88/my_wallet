import 'package:my_wallet/ca/domain/ca_use_case.dart';

import 'package:my_wallet/ui/home2/data/home2_repository.dart';

class MyWalletHomeUseCase extends CleanArchitectureUseCase<MyWalletHomeRepository> {
  MyWalletHomeUseCase() : super(MyWalletHomeRepository());

  void loadExpense(onNext<HomeEntity> next) {
    execute(Future(() async {
      List<ExpenseEntity> expensesEntity = await repo.loadExpense();
      double totalOverview = await repo.loadTotalOverview();
      ChartTitleEntity chartTitleEntity = await repo.loadChartTitleEntity();
      List<TransactionEntity> incomeEntity = await repo.loadIncomeEntity();
      List<TransactionEntity> expenseEntity = await repo.loadExpenseEntity();
      ChartBudgetEntity chartBudgetEntity = await repo.loadChartBudgetEntity();

      next(HomeEntity(totalOverview, chartTitleEntity, incomeEntity, expenseEntity, chartBudgetEntity, expensesEntity));
    }), next, (e) {
      next(null);
    });
//    execute(repo.loadExpense(), next, (e) {
//      debugPrint("Load expense error $e");
//      next([]);
//    });
  }

  void resumeDatabase(onNext<bool> next) {
    execute(repo.resumeDatabase(), next, (e) {
      next(false);
    });
  }
}