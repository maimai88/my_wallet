import 'package:my_wallet/ca/presentation/view/ca_state.dart';

import 'package:my_wallet/ui/account/liability/payment/presentation/view/payment_data_view.dart';
import 'package:my_wallet/ui/account/liability/payment/presentation/presenter/payment_presenter.dart';

import 'package:my_wallet/data/local/data_observer.dart' as observer;
import 'package:intl/intl.dart';

import 'package:my_wallet/resources.dart' as R;

class PayLiability extends StatefulWidget {
  final int _id;
  final String _name;

  PayLiability(this._id, this._name);

  @override
  State<StatefulWidget> createState() {
    return _PayLiabilityState();
  }
}

class _PayLiabilityState extends CleanArchitectureView<PayLiability, PayLiabilityPresenter> implements PayLiabilityDataView, observer.DatabaseObservable {
  _PayLiabilityState() : super(PayLiabilityPresenter());

  final _nf = NumberFormat("\$#,###.##");
  final _dateFormat = DateFormat("dd MMM, yyyy");
  final _timeFormat = DateFormat("HH:mm");

  final GlobalKey<BottomViewContentState<Account>> _accountKey = GlobalKey();
  final GlobalKey<BottomViewContentState<AppCategory>> _categoryKey = GlobalKey();

  final tables = [
    observer.tableAccount,
    observer.tableCategory
  ];

  String _name;
  Account _account;
  List<Account> _accounts;
  AppCategory _category;
  List<AppCategory> _categories;
  DateTime _date = DateTime.now();

  // payment
  double _dischargeLiability = 0.0;
  double _interest = 0.0;
  double _additionalPayment = 0.0;

  @override
  void init() {
    presenter.dataView = this;
  }

  @override
  void onDatabaseUpdate(String table) {
    if(table == observer.tableAccount) _loadAccounts();
    if(table == observer.tableCategory) _loadCategories();
  }

  @override
  void initState() {
    super.initState();

    _name = widget._name;

    observer.registerDatabaseObservable(tables, this);

    _loadAccounts();
    _loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: MyWalletAppBar(
        title: R.string.make_a_payment,
        actions: <Widget>[
          FlatButton(
            child: Text(R.string.save),
              onPressed: _savePayment
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              color: AppTheme.white,
              alignment: Alignment.center,
              child: FittedBox(
                child: Column(
                  children: <Widget>[
                    ConversationRow(R.string.pay_to, _name,),
                    ConversationRow(
                      R.string.from, _account == null ? R.string.select_account : _account.name,
                      dataColor: AppTheme.darkBlue,
                    onPressed: _showAccountListSelection,),
                    ConversationRow(
                      R.string.txt_in,
                        _category == null ? R.string.select_category : _category.name,
                      dataColor: _category == null ? AppTheme.pinkAccent : Color(AppTheme.hexToInt(_category.colorHex)),
                      onPressed: _showCategoryListSelection,
                    ),
                    Row(
                      children: <Widget>[
                        ConversationRow(R.string.on, _dateFormat.format(_date)),
                        ConversationRow(R.string.at, _timeFormat.format(_date))
                      ],
                    ),
                    ConversationRow(
                      R.string.discharge_liability,
                      _nf.format(_dischargeLiability),
                      onPressed: _changeDischargeLiability,
                    ),
                    ConversationRow(
                      R.string.interest,
                      _nf.format(_interest),
                      onPressed: _changeInterest,
                    ),
                    ConversationRow(
                      R.string.additional_payment,
                      _nf.format(_additionalPayment),
                      onPressed: _changeAdditionalPayment,
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _changeDischargeLiability() {
    Navigator.push(context,
        SlidePageRoute(builder:
            (context) => _AmountInput(
                R.string.discharge_liability)))
    .then((value) => setState(() => _dischargeLiability = value ?? 0.0));
  }

  void _changeInterest() {
    Navigator.push(context,
        SlidePageRoute(builder:
            (context) => _AmountInput(
            R.string.interest)))
        .then((value) => setState(() => _interest = value ?? 0.0));
  }

  void _changeAdditionalPayment() {
    Navigator.push(context,
        SlidePageRoute(builder:
            (context) => _AmountInput(
            R.string.additional_payment)))
        .then((value) => setState(() => _additionalPayment = value ?? 0.0));
  }

  void _showAccountListSelection() {
    showModalBottomSheet(context: context, builder: (context) =>
        BottomViewContent(
          _accounts,
              (context, f) => Align(
                child: InkWell(
                  child: Padding(padding: EdgeInsets.all(10.0),
                      child: Text(
                        f.name,
                        style: Theme.of(context).textTheme.title.apply(color: AppTheme.brightPink),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,)
                  ),
                  onTap: () {
                    setState(() => _account = f);

                    Navigator.pop(context);
                    },
                ),
              ),
          R.string.select_account,
          noDataDescription: Stack(
            children: <Widget>[
              Center(
                child: Text(R.string.no_account_available, style: Theme.of(context).textTheme.title.apply(color: AppTheme.darkBlue),),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: RoundedButton(
                  onPressed: () => Navigator.pushNamed(context, routes.AddAccount),
                  child: Text(R.string.add_account),
                  color: AppTheme.darkBlue,
                ),
              )
            ],
          ),
          key: _accountKey,
        )
    );
  }

  void _showCategoryListSelection() {
    showModalBottomSheet(context: context, builder: (context) =>
        BottomViewContent(
          _categories,
              (context, f) => Align(
                child: InkWell(
                child: Padding(padding: EdgeInsets.all(10.0),
                    child: Text(
                      f.name,
                      style: Theme.of(context).textTheme.title.apply(color: AppTheme.brightPink),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,)
                ),
                  onTap: () {
                  setState(() => _category = f);
                  Navigator.pop(context);
            },
          ),
        ),
          R.string.select_category,
          noDataDescription: Stack(
            children: <Widget>[
              Center(
                child: Text(
                  R.string.no_category_available,
                  style: Theme.of(context).textTheme.title.apply(color: AppTheme.darkBlue),
                  textAlign: TextAlign.center,),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: RoundedButton(
                    onPressed: () => Navigator.pushNamed(context, routes.CreateCategory),
                    child: Text(R.string.create_category),
                color: AppTheme.darkBlue,),
              )
            ],
          ),
          key: _categoryKey,
        )
    );
  }

  void _savePayment() {
    presenter.savePayment(
      widget._id,
      _account,
      _category,
      _dischargeLiability,
      _interest,
      _additionalPayment,
      _date
    );
  }

  void _loadAccounts() {
    presenter.loadAccounts(widget._id);
  }

  void _loadCategories() {
    presenter.loadCategories(CategoryType.expense);
  }

  @override
  void onAccountListLoaded(List<Account> accounts) {
    setState(() => _accounts = accounts);
    if(_accountKey.currentContext != null) _accountKey.currentState.updateData(accounts);
  }

  @override
  void onAccountLoadFailed(Exception e) {

  }

  @override
  void onCategoryLoaded(List<AppCategory> categories) {
    setState(() => _categories = categories);
    if(_categoryKey.currentContext != null) _categoryKey.currentState.updateData(categories);
  }

  @override
  void onCategoryLoadFailed(Exception e) {

  }

  @override
  void onSaveSuccess(bool result) {
    Navigator.pop(context);
  }

  @override
  void onSaveFailed(Exception e) {
    showDialog(context: context,
    builder: (context) => AlertDialog(
      title: Text(R.string.failed_to_save_payment),
      content: Text(e.toString()),
      actions: <Widget>[
        FlatButton(
          child: Text(R.string.ok),
          onPressed: () => Navigator.pop(context),
        )
      ],
    ));
  }
}

class _AmountInput extends StatefulWidget {

  final String _caption;
  _AmountInput(this._caption);

  @override
  State<StatefulWidget> createState() {
    return _AmountInputState();
  }

}

class _AmountInputState extends State<_AmountInput> {

  final _nf = NumberFormat("\$#,###.##");
  double number = 0.0;
  final GlobalKey<NumberInputPadState> _numPadKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return PlainScaffold(
      appBar: MyWalletAppBar(
        title: R.string.enter_amount,
        actions: <Widget>[
          FlatButton(
            child: Text(R.string.save),
            onPressed: () => Navigator.pop(context, number),
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              color: AppTheme.white,
              alignment: Alignment.center,
              child: FittedBox(
                child: Column(
                  children: <Widget>[
                    ConversationRow(
                        widget._caption,
                        _nf.format(number)
                    )
                  ],
                ),
              ),
            ),
          ),
          Container(
            child: NumberInputPad(
                _numPadKey,
                _updateNumber,
                null,
                null
            ),
            decoration: BoxDecoration(
              gradient: AppTheme.bgGradient
            ),
          )
        ],
      ),
    );
  }

  void _updateNumber(double value) {
    setState(() {
      number = value;
    });
  }
}