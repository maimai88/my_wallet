import 'package:my_wallet/ca/presentation/view/ca_state.dart';

import 'package:my_wallet/ui/budget/list/presentation/presenter/list_presenter.dart';
import 'package:my_wallet/ui/budget/list/presentation/view/list_data_view.dart';
import 'package:my_wallet/data/data_observer.dart' as observer;

import 'package:my_wallet/ui/budget/budget_config.dart';
import 'package:my_wallet/utils.dart';

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
  final _df = DateFormat("${DateFormat.MONTH}");

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
    var size = MediaQuery.of(context).size.width / crossAxisCount - 20;
    var padding = size / 4;
    final _style = Theme.of(context).textTheme.title.apply(color: AppTheme.darkBlue);

    return PlainScaffold(
      body: _generateBudgetBody(),
    );
  }

  Widget _generateBudgetBody() {
    List<Widget> budgetBody = [];

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = 10.0;

    budgetBody.add(_generateMonthlyBudgetOverview(screenHeight * 0.35, screenWidth - 2 * padding));
//    budgetBody.add(_generateIncomeExpensesTab());

    return CustomScrollView(
      slivers: budgetBody,
    );
  }

  Widget _generateMonthlyBudgetOverview(double height, double width) {
    final daysRemains = _daysRemain();
    final totalDays = _totalDaysOfMonth();

    return SliverAppBar(
//      title: Text("Your Budget", style: Theme.of(context).textTheme.title.apply(color: AppTheme.white),),
      expandedHeight: height,
      flexibleSpace: Container(
        padding: EdgeInsets.only(top: height / 4, bottom: 5.0),
        height: height,
        decoration: BoxDecoration(gradient: AppTheme.bgGradient),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    moneyNumberFormat.format(_budgetList.totalExpense),
                    style: Theme.of(context).textTheme.display1.apply(color: AppTheme.white),
                  ),
                  Text("spent in ${_df.format(DateTime.now())}")
                ],
              ),
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.only(left: 20.0),
            ),
            Expanded(
                child: BudgetSlider(
                  context,
                  primaryValue: _budgetList.totalExpense,
                  primaryMax: max(_budgetList.expenseBudget, _budgetList.totalExpense),
                  primaryLabel: moneyNumberFormat.format(_budgetList.expenseBudget),
                  primaryIndicatorLine1: moneyNumberFormat.format(_budgetList.expenseBudget - _budgetList.totalExpense),
                  primaryIndicatorLine2: "remaining",
                  secondaryMax: totalDays.toDouble(),
                  secondaryValue: (totalDays - daysRemains).toDouble(),
                  secondaryLabel: "$daysRemains days\nleft",
                  sliderWidth: width,
                  sliderHeight: 50.0,
                  size: Size(width, height),)
                )
          ],
        ),
      ),
    );
  }

//  Widget _generateIncomeExpensesTab() {
//    return Text("TBD");
//  }

  @override
  void onBudgetLoaded(BudgetListEntity list) {
    setState(() => _budgetList = list);
  }

  void loadData() {
    presenter.loadThisMonthBudgetList(_month);
  }

  int _daysRemain() {
    final lastMonthDate = lastDayOfMonth(DateTime.now());

    return lastMonthDate
        .difference(DateTime.now())
        .inDays;
  }

  int _totalDaysOfMonth() {
    final firstDay = firstMomentOfMonth(DateTime.now());
    final lastDay = lastDayOfMonth(DateTime.now());

    return lastDay
        .difference(firstDay)
        .inDays;
  }
}
