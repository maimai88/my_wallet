import 'package:my_wallet/app_material.dart';
import 'package:my_wallet/utils.dart';
import 'package:intl/intl.dart';
import 'package:my_wallet/ui/budget/list/data/list_entity.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:my_wallet/ui/budget/budget_config.dart';

import 'package:my_wallet/resources.dart' as R;

class TransactionPage extends StatelessWidget {
  final String title;
  final double total;
  final double budget;
  final List<BudgetEntity> entities;
  final LinearGradient _gradient;
  final Color safeColor;
  final Color overColor;
  final bool reverse;
  final Color mainColor;

  TransactionPage(this.title, this.total, this.budget, this.entities, Color color, {this.reverse = false})
      : assert(color != null),
        mainColor = color,
        _gradient = LinearGradient(colors: <Color>[color, color.withOpacity(0.4)]),
        safeColor = reverse ? AppTheme.pinkAccent : AppTheme.tealAccent,
        overColor = reverse ? AppTheme.tealAccent : AppTheme.pinkAccent;

  final _df = DateFormat("${DateFormat.MONTH}");

  @override
  Widget build(BuildContext context) {
    return _generateBudgetBody(context);
  }

  Widget _generateBudgetBody(BuildContext context) {
    List<Widget> budgetBody = [];

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = 10.0;

    budgetBody.add(_generateMonthlyBudgetOverview(context, screenHeight * 0.35, screenWidth - 2 * padding));
    budgetBody.add(SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.all(10.0),
        alignment: Alignment.centerRight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(R.string.categories, style: Theme.of(context).textTheme.title.apply(color: mainColor),),
            RaisedButton(
              onPressed: () => Navigator.pushNamed(context, routes.CreateCategory).then((categoryId) {
                if(categoryId != null) {
                  Navigator.pushNamed(context, routes.EditBudget(categoryId: categoryId, month: DateTime.now()));
                }
              }),
              elevation: 4.0,
              color: mainColor,
              child: Text(R.string.add),
            )
          ],
        )
      )
    ));
    budgetBody.add(_generateBudgetGrid(context));

    return CustomScrollView(
      slivers: budgetBody,
    );
  }

  Widget _generateMonthlyBudgetOverview(BuildContext context, double height, double width) {
    final daysRemains = _daysRemain();
    final totalDays = _totalDaysOfMonth();

    return SliverAppBar(
        expandedHeight: height,
        flexibleSpace: FlexibleSpaceBar(
          background: Container(
            padding: EdgeInsets.only(top: height / 5, bottom: 5.0),
            height: height,
            decoration: BoxDecoration(gradient: _gradient),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Text(title, style: Theme.of(context).textTheme.display1,),
                    ),
                    Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Text(
                            budgetCurrencyFormatter.format(total),
                            style: Theme.of(context).textTheme.display1.apply(color: AppTheme.white),
                          ),
                          Text("spent in ${_df.format(DateTime.now())}")
                        ],
                      ),
                      alignment: Alignment.centerRight,
                      margin: EdgeInsets.only(right: 20.0),
                    )
                  ],
                ),
                Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: PrimarySecondaryProgressBar(
                        context,
                        primaryValue: total,
                        primaryMax: max(budget, total),
                        primaryLabel: budgetCurrencyFormatter.format(budget),
                        primaryIndicatorLine1: budgetCurrencyFormatter.format(budget - total),
                        primaryIndicatorLine2: reverse ? "more" : "remaining",
                        primaryTextColor: mainColor,
                        secondaryMax: totalDays.toDouble(),
                        secondaryValue: (totalDays - daysRemains).toDouble(),
                        secondaryLabel: "$daysRemains days\nleft",
                      secondaryTextColor: AppTheme.white,),
                    )
                )
              ],
            ),
          ),
          collapseMode: CollapseMode.pin,
        )
    );
  }

  Widget _generateBudgetGrid(BuildContext context) {
    return SliverGrid.count(
      crossAxisCount: 2,
      mainAxisSpacing: 10.0,
      children:  entities == null ? <Widget> [] : entities.map((f) => _generateGridItemView(context, f)).toList(),);
  }

  Widget _generateGridItemView(BuildContext context, BudgetEntity entity) {
    final _iconSize = 60.0;
    final _left = (entity.total - entity.transaction);

    var _transactionDesc = "";
    if(_left >= 0) {
      _transactionDesc = "${budgetCurrencyFormatter.format(_left)} ${reverse ? "more" : "left"}";
    } else {
      _transactionDesc = "${budgetCurrencyFormatter.format(_left * (-1))} over";
    }

    final _color = _left == 0 ? AppTheme.amber : _left > 0 ? safeColor : overColor;

    return InkWell(
      child: Stack(
        children: <Widget>[
          Container(
            alignment: Alignment.topCenter,
            padding: EdgeInsets.only(top: _iconSize/3, left: 10.0, right: 10.0),
            child: Card(
                color: AppTheme.white,
                elevation: 3.0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    side: BorderSide(color: _color)
                ),
                borderOnForeground: true,
                child: Padding(
                  padding: EdgeInsets.only(top: _iconSize - _iconSize/3, left: 5.0, right: 5.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(
                        entity.categoryName,
                        style: Theme.of(context).textTheme.body1.apply(color: AppTheme.darkBlue),
                        textAlign: TextAlign.center,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,),
                      Text(budgetCurrencyFormatter.format(entity.total), style: Theme.of(context).textTheme.title.apply(color: AppTheme.black), textAlign: TextAlign.center,),
                      Text(_transactionDesc, style: Theme.of(context).textTheme.body2.apply(color: _color), textAlign: TextAlign.center, ),
                      Padding(
                        padding: EdgeInsets.only(top:10.0, bottom: 10.0),
                        child: LinearPercentIndicator(
                          width: MediaQuery.of(context).size.width/2
                              - /* left padding */ 10
                              - /* right padding */ 10
                              - /* margin padding left */ 10
                              - /* margin padding right*/ 10,
                          lineHeight: 10,
                          percent: entity.total == 0 || entity.transaction > entity.total ? 1.0 : entity.transaction / entity.total,
                          alignment: MainAxisAlignment.center,
                          backgroundColor: AppTheme.blueGrey.withOpacity(0.2),
                          progressColor: _color,),
                      )
                    ],
                  ),
                )
            ),
          ),
          Align(
              alignment: Alignment.topLeft,
              child: CircleAvatar(
                child: Icon(Icons.monetization_on, color: Color(AppTheme.hexToInt(entity.colorHex)), size: _iconSize,),
                backgroundColor: AppTheme.white,
              )
          ),
        ],
      ),
      onTap: () => Navigator.pushNamed(context, routes.EditBudget(categoryId: entity.categoryId, month: DateTime.now())),
    );
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