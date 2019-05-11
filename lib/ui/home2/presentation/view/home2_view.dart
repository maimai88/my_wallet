import 'package:my_wallet/app_material.dart';

import 'package:my_wallet/ui/home2/presentation/view/home2_data_view.dart';
import 'package:my_wallet/ui/home2/presentation/presenter/home2_presenter.dart';
import 'package:my_wallet/ca/presentation/view/ca_state.dart';

import 'package:my_wallet/data/local/data_observer.dart' as observer;

import 'package:intl/intl.dart';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:charts_flutter/flutter.dart';

import 'package:my_wallet/resources.dart' as R;

class MyWalletHome extends StatefulWidget {
  MyWalletHome({GlobalKey<MyWalletState> key}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return MyWalletState();
  }
}

class MyWalletState extends CleanArchitectureView<MyWalletHome, MyWalletHomePresenter>
    with TickerProviderStateMixin
    implements MyWalletHomeDataView, observer.DatabaseObservable {
  MyWalletState() : super(MyWalletHomePresenter());
  final _titleStyle = TextStyle(color: AppTheme.blueGrey, fontSize: 14.0, fontWeight: FontWeight.bold);
  DateFormat _df = DateFormat("MMM, yyyy");

  final _overviewRatio = 0.15;
  final _chartRatio = 0.5;
  final _titleHeight = 22.0;

  final _tables = [observer.tableTransactions, observer.tableCategory];
  final _iconSize = 45.0;

  GlobalKey _resumeDialogKey;

  List<ExpenseEntity> _homeEntities = [];

  NumberFormat _nf = NumberFormat("\$#,##0.00");
  NumberFormat _percentage = NumberFormat("#,##0.00%");

  // overview
  double _totalOverview = 0.0;

  // tab view
  TabController _tabController;
  ChartTitleEntity _chartTitleEntity;
  List<TransactionEntity> _incomeEntity;
  List<TransactionEntity> _expenseEntity;
  ChartBudgetEntity _budgetEntity;

  @override
  void init() {
    presenter.dataView = this;
  }

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 3, vsync: this);

    observer.registerDatabaseObservable(_tables, this);
    _loadDetails();
  }

  @override
  void dispose() {
    super.dispose();

    observer.unregisterDatabaseObservable(_tables, this);
  }

  void _loadDetails() {
    presenter.loadExpense();
  }

  void onExpensesDetailLoaded(HomeEntity value) {
    if(value != null) {
      setState(() {
        _homeEntities = value.expensesEntity;
        _totalOverview = value.totalOverview;
        _chartTitleEntity = value.chartTitleEntity;
        _incomeEntity = value.incomeEntity;
        _expenseEntity = value.expenseEntity;
        _budgetEntity = value.budgetEntity;
      });
    }
  }

  void onDatabaseUpdate(List<String> tables) {
    _loadDetails();
  }

  @override
  Widget build(BuildContext context) {
    var platform = Theme.of(context).platform;

    return PlainScaffold(
      body: _generateMainBody(),
      floatingActionButton: Padding(
        padding: EdgeInsets.all(platform == TargetPlatform.iOS ? 10.0 : 0.0),
        child: RoundedButton(
          onPressed: () => Navigator.pushNamed(context, routes.AddTransaction),
          child: Container(
            margin: EdgeInsets.all(10.0),
            child: Text(
              R.string.add_transaction,
            ),
          ),
          color: AppTheme.pinkAccent,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _generateMainBody() {
    List<Widget> list = [];
    var screenHeight = MediaQuery.of(context).size.height;

    list.add(SliverAppBar(
      expandedHeight: screenHeight * (_overviewRatio + _chartRatio) + _titleHeight,
      actions: <Widget>[
        IconButton(icon: Icon(Icons.calendar_today), onPressed: () => Navigator.pushNamed(context, routes.TransactionList(R.string.transactions, datetime: DateTime.now())))
      ],
      pinned: true,
      flexibleSpace: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(gradient: AppTheme.bgGradient),
        child: FlexibleSpaceBar(
          centerTitle: true,
          title: SizedBox(
            height: _titleHeight,
            width: MediaQuery.of(context).size.width,
            child: Center(
              child: Text(
                _df.format(DateTime.now()),
                style: Theme.of(context).textTheme.title,
              ),
            ),
          ),
          collapseMode: CollapseMode.pin,
          background: ListView(
            physics: NeverScrollableScrollPhysics(),
            children: <Widget>[
              HomeOverview(_titleStyle, MediaQuery.of(context).size.height * _overviewRatio, _totalOverview, _nf),
              Container(
                alignment: Alignment.center,
                child: Column(
                  children: <Widget>[
                    ChartTitleView(
                        _tabController,
                        _chartTitleEntity,
                        _nf,
                        _percentage/*,
                        height: MediaQuery.of(context).size.height * _chartRatio * 0.25*/),
                    Container(
                      height: MediaQuery.of(context).size.height * _chartRatio * 0.75,
                      child: TabBarView(controller: _tabController, children: [
                        TransactionChart(_incomeEntity),
                        TransactionChart(_expenseEntity),
                        ChartBudgetView(_budgetEntity, _nf)
                      ]),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    ));

    list.add(SliverList(delegate: SliverChildBuilderDelegate(
          (context, index) {
        return Container(
          color: index % 2 != 0 && index < _homeEntities.length ? AppTheme.blueGrey.withOpacity(0.2) : AppTheme.white ,
          child: index >= _homeEntities.length ? ListTile(
            title: Text(""),
          ) : ListTile(
              leading: Container(
                width: _iconSize,
                height: _iconSize,
                child: Stack(
                  children: <Widget>[
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: ClipRect(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Icon(
                            Icons.monetization_on,
                            color: AppTheme.toColorFromHex(_homeEntities[index].colorHex),
                            size: _iconSize,),
                          heightFactor: _homeEntities[index].remainFactor,
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.bottomCenter,
                      width: _iconSize,
                      height: _iconSize,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.toColorFromHex(_homeEntities[index].colorHex), width: 1.0)
                      ),
                    )
                  ],
                ),
              ),
              onTap: () => Navigator.pushNamed(context, routes.TransactionList(_homeEntities[index].name, categoryId: _homeEntities[index].categoryId)),
              title: Text(_homeEntities[index].name, style: TextStyle(color: AppTheme.darkBlue),),
              trailing: RichText(
                  textAlign: TextAlign.right,
                  text: TextSpan(
                      children: [
                        TextSpan(
                          text: _nf.format(_homeEntities[index].transaction),
                          style: TextStyle(color: AppTheme.darkBlue),
                        ),
                        TextSpan(
                          text: "\n(${_nf.format(_homeEntities[index].remain)})",
                          style: TextStyle(color: _homeEntities[index].remain >= 0 ? AppTheme.tealAccent : AppTheme.red),
                        )
                      ]
                  ))
            //Text(_nf.format(_homeEntities[index].transaction), style: TextStyle(color: _homeEntities[index].transaction > _homeEntities[index].budget ? AppTheme.red : AppTheme.darkBlue),),
          ),
        );
      },
      childCount: _homeEntities.length + 1,
    )));

    return CustomScrollView(
        slivers: list);
  }

  void onResume() {
    if(_resumeDialogKey == null) {
      _resumeDialogKey = new GlobalKey();
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) =>
              AlertDialog(
                key: _resumeDialogKey,
                title: Row(
                  children: <Widget>[
                    CircularProgressIndicator(),
                    Padding(
                      padding: const EdgeInsets.only(left: 12.0),
                      child: Text(R.string.syncing),
                    )
                  ],
                ),
              )
      );
    }

    presenter.resumeDatabase();
  }

  void onResumeDone(bool done) {
    if(_resumeDialogKey != null && _resumeDialogKey.currentContext != null) Navigator.of(context).pop();

    _resumeDialogKey = null;
  }

  void onPaused() {
    presenter.dispose();
  }
}

// Home widgets
// overview
class HomeOverview extends StatelessWidget {
  final double _total;
  final double _height;
  final TextStyle _titleStyle;
  final NumberFormat _nf;

  HomeOverview(this._titleStyle, this._height, this._total, this._nf);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _height,
      padding: EdgeInsets.all(10.0),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(R.string.saving_this_month, style: _titleStyle,),
          Text("${_nf.format(_total)}", style: Theme.of(context).textTheme.headline.apply(fontSizeFactor: 1.8, color: _total <= 0 ? AppTheme.pinkAccent : AppTheme.tealAccent),)
        ],
      ),
    );
  }
}

// chart view
class ChartTitleView extends StatelessWidget {
  final ChartTitleEntity _entity;
  final TabController _controller;
  final NumberFormat _nf;
  final NumberFormat _percentage;

  ChartTitleView(this._controller, this._entity, this._nf, this._percentage);

  @override
  Widget build(BuildContext context) {
    var textStyle = Theme.of(context).textTheme.title;
    var subTitleStyle = textStyle.apply(fontSizeFactor: 0.7, color: AppTheme.white);

    return TabBar(
      tabs: <Widget>[

        Padding(
          padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              AutoSizeText(
                R.string.income,
                style: textStyle.apply(color: AppTheme.tealAccent),
                maxLines: 1,
              ),
              Text("${_entity == null ? "\$0.00" : _nf.format(_entity.incomeAmount)}", style: subTitleStyle,)
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              AutoSizeText(
                R.string.expenses,
                style: textStyle.apply(color: AppTheme.pinkAccent),
                maxLines: 1,
              ),
              Text("${_entity == null ? "\$0.00" : _nf.format(_entity.expensesAmount)}", style: subTitleStyle,)
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              AutoSizeText(R.string.budget,
                style: textStyle.apply(color: AppTheme.brightGreen),
                maxLines: 1,
              ),
              Text("${_entity == null ? "0.00%" : _percentage.format(_entity.budgetPercentage)}", style: subTitleStyle,)
            ],
          ),
        ),
      ],
      controller: _controller,
      indicatorWeight: 4.0,
      indicatorColor: Colors.white.withOpacity(0.8),
    );
  }
}

class TransactionChart extends StatelessWidget {
  final List<TransactionEntity> _transactions;

  TransactionChart(this._transactions);

  @override
  Widget build(BuildContext context) {
    return _transactions == null || _transactions.isEmpty
        ? Center(child: Text(R.string.no_transaction_found, style: Theme.of(context).textTheme.title,),)
        : PieChart([
      Series<TransactionEntity, double>(
        id: "_transactions",
        data: _transactions,
        measureFn: (data, index) => data.amount,
        domainFn: (data, index) => data.amount,
        colorFn: (data, index) => Color.fromHex(code: data.color),
        labelAccessorFn: (data, index) => "${data.category}",
      ),
    ],
      animate: false,
      defaultRenderer: ArcRendererConfig(
          arcRendererDecorators: [ ArcLabelDecorator(
            labelPosition: ArcLabelPosition.auto,
            outsideLabelStyleSpec: TextStyleSpec(
                color: Color.fromHex(code: "#FFFFFF"),
                fontSize: 14
            ),
            insideLabelStyleSpec: TextStyleSpec(
                color: Color.fromHex(code: "#FFFFFF"),
                fontSize: 14
            ),
            leaderLineStyleSpec: ArcLabelLeaderLineStyleSpec(
                color: Color.fromHex(code: "#FFFFFF"),
                thickness: 2.0,
                length: 24.0
            ),
          ) ]
      ),
    );
  }
}

class ChartBudgetView extends StatelessWidget {
  final ChartBudgetEntity _entity;
  final NumberFormat _nf;

  ChartBudgetView(this._entity, this._nf);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.bottomCenter,
            child: ClipRect(
              child: Align(
                alignment: Alignment.bottomCenter,
                heightFactor: _entity == null ? 0.0 : _entity.fraction,
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.pinkAccent),
                ),
              ),
            ),
          ),
          Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.pinkAccent, width: 3.0)),
            child: Text(_entity == null ? "\$0.00" : _nf.format(_entity.spent), style: Theme.of(context).textTheme.display2,),
          ),
        ],
      ),
    );
  }
}