import 'package:my_wallet/ca/presentation/view/ca_state.dart';

import 'package:my_wallet/ui/account/liability/payment/presentation/view/payment_data_view.dart';
import 'package:my_wallet/ui/account/liability/payment/presentation/presenter/payment_presenter.dart';

import 'package:my_wallet/data/data_observer.dart' as observer;
import 'package:intl/intl.dart';

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
        title: "Pay money",
        actions: <Widget>[
          FlatButton(
            child: Text("Save"),
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
                    ConversationRow("Pay to", _name,),
                    ConversationRow(
                      "From ", _account == null ? "Select Account" : _account.name,
                      dataColor: AppTheme.darkBlue,
                    onPressed: _showAccountListSelection,),
                    ConversationRow(
                      "in",
                        _category == null ? "Select category" : _category.name,
                      dataColor: _category == null ? AppTheme.pinkAccent : Color(AppTheme.hexToInt(_category.colorHex)),
                      onPressed: _showCategoryListSelection,
                    ),
                    Row(
                      children: <Widget>[
                        ConversationRow("on", _dateFormat.format(_date)),
                        ConversationRow("at", _timeFormat.format(_date))
                      ],
                    ),
                    ConversationRow(
                      "Discharge liability",
                      _nf.format(_dischargeLiability),
                      onPressed: _changeDischargeLiability,
                    ),
                    ConversationRow(
                      "Interest",
                      _nf.format(_interest),
                      onPressed: _changeInterest,
                    ),
                    ConversationRow(
                      "Additional payment",
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
                "Discharge Liability")))
    .then((value) => setState(() => _dischargeLiability = value ?? 0.0));
  }

  void _changeInterest() {
    Navigator.push(context,
        SlidePageRoute(builder:
            (context) => _AmountInput(
            "Interest")))
        .then((value) => setState(() => _interest = value ?? 0.0));
  }

  void _changeAdditionalPayment() {
    Navigator.push(context,
        SlidePageRoute(builder:
            (context) => _AmountInput(
            "Additional Payment")))
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
          "Select Account",
          noDataDescription: Stack(
            children: <Widget>[
              Center(
                child: Text("No Account available.", style: Theme.of(context).textTheme.title.apply(color: AppTheme.darkBlue),),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: RoundedButton(
                  onPressed: () => Navigator.pushNamed(context, routes.AddAccount),
                  child: Text("Add Account"),
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
          "Select Category",
          noDataDescription: Stack(
            children: <Widget>[
              Center(
                child: Text(
                  "No Category available. Please create new Category to make payment.",
                  style: Theme.of(context).textTheme.title.apply(color: AppTheme.darkBlue),
                  textAlign: TextAlign.center,),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: RoundedButton(
                    onPressed: () => Navigator.pushNamed(context, routes.CreateCategory),
                    child: Text("Create Category"),
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
      title: Text("Failed to save payment"),
      content: Text(e.toString()),
      actions: <Widget>[
        FlatButton(
          child: Text("OK"),
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
        title: "Enter amount",
        actions: <Widget>[
          FlatButton(
            child: Text("Save"),
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