import 'package:my_wallet/ca/presentation/view/ca_state.dart';

import 'package:my_wallet/ui/budget/list/presentation/presenter/list_presenter.dart';
import 'package:my_wallet/ui/budget/list/presentation/view/list_data_view.dart';
import 'package:my_wallet/data/data_observer.dart' as observer;

import 'package:my_wallet/ui/budget/list/presentation/view/transaction_page_view.dart';
import 'package:page_indicator/page_indicator.dart';

class ListBudgets extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ListBudgetsState();
  }
}

typedef OnMonthSelected = Function(DateTime month, double budget);

class _ListBudgetsState extends CleanArchitectureView<ListBudgets, ListBudgetsPresenter> implements ListBudgetsDataView, observer.DatabaseObservable {
  _ListBudgetsState() : super(ListBudgetsPresenter());

  final _tables = [observer.tableBudget, observer.tableCategory, observer.tableTransactions];

  BudgetListEntity _budgetList = BudgetListEntity.empty();

  var _month = DateTime.now();

  final crossAxisCount = 3;

  @override
  void init() {
    presenter.dataView = this;
  }

  @override
  void onDatabaseUpdate(String table) {
    loadData();
  }

  @override
  void initState() {
    super.initState();

    observer.registerDatabaseObservable(_tables, this);

    loadData();
  }

  @override
  void dispose() {
    observer.unregisterDatabaseObservable(_tables, this);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PlainScaffold(
      body: PageIndicatorContainer(
        pageView: PageView.builder(itemBuilder: (context, index) {
          switch(index) {
            case 0: return TransactionPage(
                "Expenses",
                _budgetList.totalExpense,
                _budgetList.expenseBudget,
                _budgetList.expense,
                AppTheme.pinkAccent);
            case 1: return TransactionPage("Income", _budgetList.totalIncome, _budgetList.incomeBudget, _budgetList.income, AppTheme.darkGreen);
          }
        }, itemCount: 2),
        length: 2,
        align: IndicatorAlign.bottom,
        indicatorColor: AppTheme.darkBlue.withOpacity(0.3),
        indicatorSelectorColor: AppTheme.darkBlue,),
    );
  }



  @override
  void onBudgetLoaded(BudgetListEntity list) {
    setState(() => _budgetList = list);
  }

  void loadData() {
    presenter.loadThisMonthBudgetList(_month);
  }


}
