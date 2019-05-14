import 'package:my_wallet/ca/presentation/view/ca_state.dart';

import 'package:my_wallet/ui/budget/detail/presentation/presenter/detail_presenter.dart';
import 'package:my_wallet/ui/budget/detail/presentation/view/detail_data_view.dart';
import 'package:my_wallet/data/data_observer.dart' as observer;
import 'package:my_wallet/ui/budget/budget_config.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';

import 'package:my_wallet/resources.dart' as R;

class BudgetDetail extends StatefulWidget {
  final String title;
  final int categoryId;
  final DateTime month;

  BudgetDetail(this.title, {@required this.categoryId, this.month});

  @override
  State<StatefulWidget> createState() {
    return _BudgetDetailState();
  }
}

class _BudgetDetailState extends CleanArchitectureView<BudgetDetail, BudgetDetailPresenter> implements BudgetDetailDataView, observer.DatabaseObservable {
  _BudgetDetailState() : super(BudgetDetailPresenter());

  var tables = [observer.tableCategory, observer.tableBudget];

  var _savingBudget = false;

  GlobalKey<NumberInputPadState> numPadKey = GlobalKey();
  GlobalKey alertDialog = GlobalKey();

  DateTime _from, _to;
  AppCategory _category;
  double _amount = 0.0;

  NumberFormat _nf = NumberFormat("\$##0.00");

  void loadData() {
    presenter.loadCategoryBudget(widget.categoryId, _from, _to);
  }

  @override
  void init() {
    presenter.dataView = this;
  }

  @override
  void onDatabaseUpdate(String table) {
    if(_savingBudget) return;

    if(table == observer.tableCategory) loadData();
  }

  @override
  void initState() {
    super.initState();

    observer.registerDatabaseObservable(tables, this);

    _from = widget.month == null ? DateTime.now() : widget.month;

    loadData();
  }

  @override
  void dispose() {
    observer.unregisterDatabaseObservable(tables, this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: MyWalletAppBar(
        title: widget.title,
        actions: <Widget>[
          FlatButton(
            onPressed: _saveBudget,
            child: Text(R.string.save),
          )
        ],
      ),
      body: NumberInputPad(numPadKey,
      onValueChange: _onNumberInput,
      initialValue: 0.0,
      child: Container(
        padding: EdgeInsets.all(10.0),
        color: AppTheme.white,
        width: MediaQuery.of(context).size.width,
        child: FittedBox(
          child: Column(
            children: <Widget>[
              ConversationRow(
                R.string.a_monthly_budget_for,
                _category == null ? R.string.select_category : _category.name,
                onPressed: () => Navigator.pushNamed(context, routes.EditCategory(categoryId: _category.id, categoryName: _category.name)),
              ),
              ConversationRow(
                R.string.from,
                df.format(_from),
                dataColor: AppTheme.darkBlue,
                onPressed: _showFromMonth,
              ),
              ConversationRow(
                R.string.to,
                _to == null ? R.string.forever : df.format(_to),
                dataColor: AppTheme.darkBlue,
                onPressed: _showToMonth,
                trail: _to == null ? null : IconButton(
                    icon: Icon(Icons.close, color: AppTheme.pinkAccent,),
                    onPressed: () => setState(() => _to = null)),
              ),
              ConversationRow(
                R.string.at_max,
                _nf.format(_amount),
                style: Theme.of(context).textTheme.display2,
              )
            ],
          ),
        ),
      ),)
//      body: Column(
//        children: <Widget>[
//          Expanded(
//            child: Container(
//              padding: EdgeInsets.all(10.0),
//              color: AppTheme.white,
//              width: MediaQuery.of(context).size.width,
//              child: FittedBox(
//                child: Column(
//                  children: <Widget>[
//                    ConversationRow(
//                      R.string.a_monthly_budget_for,
//                      _category == null ? R.string.select_category : _category.name,
//                      onPressed: () => Navigator.pushNamed(context, routes.EditCategory(categoryId: _category.id, categoryName: _category.name)),
//                    ),
//                        ConversationRow(
//                          R.string.from,
//                          df.format(_from),
//                          dataColor: AppTheme.darkBlue,
//                          onPressed: _showFromMonth,
//                        ),
//                    ConversationRow(
//                      R.string.to,
//                      _to == null ? R.string.forever : df.format(_to),
//                      dataColor: AppTheme.darkBlue,
//                      onPressed: _showToMonth,
//                      trail: _to == null ? null : IconButton(
//                          icon: Icon(Icons.close, color: AppTheme.pinkAccent,),
//                          onPressed: () => setState(() => _to = null)),
//                    ),
//                    ConversationRow(
//                      R.string.at_max,
//                      _nf.format(_amount),
//                      style: Theme.of(context).textTheme.display2,
//                    )
//                  ],
//                ),
//              ),
//            ),
//          ),
//          Align(
//            child: NumberInputPad(
//              numPadKey,
//              _onNumberInput,
//              null,
//              null,
//              showNumPad: true,
//            ),
//            alignment: Alignment.bottomCenter,
//          )
//        ],
//      ),
    );
  }

  void _showFromMonth() {
    showBottomSheetForMonths(_from, (date) {
      if(_to != null && date.isAfter(_to)) {
        _to = date;
      }

        setState(() => _from = date);
        Navigator.pop(context);
    });
  }

  void _showToMonth() {
    showBottomSheetForMonths(_to, (date) {
      debugPrint("select $date as end date");
      setState(() => _to = date);
      Navigator.pop(context);
    });

  }

  void showBottomSheetForMonths(DateTime selectedDate, ValueChanged<DateTime> onSelected) {
    showModalBottomSheet(
        context: context,
        builder: (_) => CalendarCarousel(
          selectedDateTime: selectedDate,
          height: 430.0,
          onDayPressed: (date, events) => onSelected(date),
        ));
  }

  void _onNumberInput(double amount) {
    setState(() {
      _amount = amount;
    });
  }

  void _saveBudget() {
    if(_savingBudget) return;

    _savingBudget = true;

    showDialog(context: context, builder: (_) => AlertDialog(
      key: alertDialog,
      content: SizedBox(
        width: 300.0,
        height: 300.0,
        child: Stack(
          children: <Widget>[
            Center(child: SizedBox(
              width: 200.0,
              height: 200.0,
              child: CircularProgressIndicator(),
            ),),
            Center(child: Text(R.string.saving, style: Theme.of(context).textTheme.title,),)
          ],
        ),
      ),
    ));
    presenter.saveBudget(
      _category,
      _amount,
      _from,
      _to
    );
  }

  @override
  void onSaveBudgetSuccess(bool result) {
    debugPrint("save budget success $result");
    dismissDialog();

    Navigator.pop(context);
  }

  @override
  void onSaveBudgetFailed(Exception e) {
    dismissDialog();

    showDialog(context: context,
        builder: (context) =>
            AlertDialog(
              title: Text(R.string.failed_to_save_budget),
              content: Text("Failed to save budget with error ${e.toString()}"),
              actions: <Widget>[
                FlatButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(R.string.try_again),
                )
              ],
            )
    );
  }

  @override
  void onBudgetLoaded(BudgetDetailEntity entity) {
    if(entity != null) {
      setState(() {
        this._to = entity.to;
        this._from = entity.from;
        this._amount = entity.amount;
        this._category = entity.category;
      });
    }
  }

  void dismissDialog() {
    _savingBudget = false;
    debugPrint("Dismiss dialog ${alertDialog.currentContext}");
    if(alertDialog.currentContext != null) {
      // alert dialog is showing
      Navigator.pop(context);
    }
  }
}
