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
                  value: _budgetList.totalExpense,
                  max: max(_budgetList.expenseBudget, _budgetList.totalExpense),
                  min: 0.0,
                  label: moneyNumberFormat.format(_budgetList.totalExpense),
                  sliderWidth: width,
                  sliderHeight: 50.0,
            ))
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
}

class BudgetSlider extends StatelessWidget {
  final double value;
  final double max;
  final double min;
  final String label;
  final Color inactiveColor;
  final Color activeColor;

  final sliderHeight;
  final sliderWidth;
  final _sliderRadius = BorderRadius.circular(10.0);
  final _sliderPadding = EdgeInsets.only(right: 5.0);
  final _sliderMargin = EdgeInsets.only(left: 15.0, right: 15.0);

  BudgetSlider({
    this.value = 0.0,
    this.max = 0.0,
    this.min = 0.0,
    this.label = "",
    this.inactiveColor = AppTheme.white70,
    this.activeColor = AppTheme.white,
    this.sliderHeight = 50.0,
    this.sliderWidth = -1,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: <Widget>[
          _drawSliderBar(context),
          // value label
          _drawValueLabel(context),
          // days remaining label
          _drawDaysRemaining(context),
        ],
      ),
    );
  }

  Widget _drawSliderBar(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Stack(
        children: <Widget>[
          // inactive bar
          Container(
            height: sliderHeight,
            width: sliderWidth,
            padding: _sliderPadding,
            margin: _sliderMargin,
            decoration: BoxDecoration(
              color: inactiveColor,
              borderRadius: _sliderRadius,
            ),
          ),
          // active bar
          Container(
            height: sliderHeight,
            width: max == 0 ? 0.0 : (value / max) * sliderWidth,
            padding: _sliderPadding,
            margin: _sliderMargin,
            decoration: BoxDecoration(color: activeColor, borderRadius: _sliderRadius),
          ),
          // total label
          Container(
            height: sliderHeight,
            width: sliderWidth,
            padding: _sliderPadding,
            margin: _sliderMargin,
            alignment: Alignment.centerRight,
            child: Text(
              moneyNumberFormat.format(max),
              style: Theme.of(context).textTheme.subhead.apply(color: AppTheme.darkBlue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawValueLabel(BuildContext context) {
    return Container(
      width: 2*(max == 0 ? 0.0 : (value / max) * sliderWidth),
      margin: _sliderMargin,
      alignment: Alignment.center,
//      child: Stack(
//        alignment: Alignment.center,
//          children: <Widget>[
//            Padding(
//              padding: EdgeInsets.only(bottom: sliderHeight * 1.5, right: 3.0),
//              child: Text(moneyNumberFormat.format(value)),),
//            Container(
//              height: sliderHeight * 1.5,
//              width: 2.0,
//              color: activeColor,
//            )
//          ],
//      )
    );
  }

  Widget _drawDaysRemaining(BuildContext context) {
    final _daysLeft = _daysRemain();
    final _totalDays = _totalDaysOfMonth();

    return Container(
      width: 2*(((_totalDays - _daysLeft) / _totalDays) * sliderWidth),
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(top: sliderHeight * 2),
            child: Text("$_daysLeft days\nleft",
            textAlign: TextAlign.center,),
          ),
          Container(
            margin: _sliderMargin,
            height: sliderHeight*1.4,
            width: 3.0,
            color: activeColor,
          )
        ],
      ),
    );
  }

  int _daysRemain() {
    final lastMonthDate = lastDayOfMonth(DateTime.now());

    return lastMonthDate.difference(DateTime.now()).inDays;
  }

  int _totalDaysOfMonth() {
    final firstDay = firstMomentOfMonth(DateTime.now());
    final lastDay = lastDayOfMonth(DateTime.now());

    return lastDay.difference(firstDay).inDays;
  }
}
