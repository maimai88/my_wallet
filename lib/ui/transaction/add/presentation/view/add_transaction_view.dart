import 'package:my_wallet/ca/presentation/view/ca_state.dart';
import 'package:my_wallet/ui/transaction/add/presentation/view/add_transaction_data_view.dart';
import 'package:my_wallet/ui/transaction/add/presentation/presenter/add_transaction_presenter.dart';
import 'package:my_wallet/data/data_observer.dart' as observer;
import 'package:flutter/cupertino.dart';
import 'package:my_wallet/ui/transaction/add/data/add_transaction_entity.dart';
import 'package:intl/intl.dart';

import 'package:flutter/scheduler.dart';

import 'package:my_wallet/resources.dart' as R;

class AddTransaction extends StatefulWidget {
  final int transactionId;
  final int accountId;
  final int categoryId;

  AddTransaction({this.transactionId, this.categoryId, this.accountId});

  @override
  State<StatefulWidget> createState() {
    return _AddTransactionState();
  }
}

class _AddTransactionState extends CleanArchitectureView<AddTransaction, AddTransactionPresenter> implements AddTransactionDataView, observer.DatabaseObservable {
  _AddTransactionState() : super(AddTransactionPresenter());

  var _numberFormat = NumberFormat("\$#,##0.00");

  final tables = [observer.tableAccount, observer.tableCategory, observer.tableUser, observer.tableTransactions];

  final GlobalKey<NumberInputPadState> numPadKey = GlobalKey();
  final GlobalKey<BottomViewContentState<Account>> _accountKey = GlobalKey();
  final GlobalKey<BottomViewContentState<AppCategory>> _categoryKey = GlobalKey();

  var _amount = 0.0;
  var _type = TransactionType.expenses;
  var _date = DateTime.now();

  GlobalKey _alertDialog = GlobalKey();
  bool _isSaving = false;

  Account _account;
  AppCategory _category;

  UserDetail _user;

  String _note;

  List<Account> _accountList = [];
  List<AppCategory> _categoryList = [];

  @override
  void init() {
    presenter.dataView = this;
  }

  @override
  void onDatabaseUpdate(String table) {
    debugPrint("on database update $table");

    if(table == observer.tableAccount) {
      presenter.loadAccounts();
    }

    if (table == observer.tableCategory) presenter.loadCategory(_type);

    if(table == observer.tableTransactions || table == observer.tableUser) {
      if(widget.transactionId == null) {
        presenter.loadCurrentUserName();
      } else if(!_isSaving){
        presenter.loadTransactionDetail(widget.transactionId);
      }
    }
  }

  @override
  void initState() {
    super.initState();

    observer.registerDatabaseObservable(tables, this);

    presenter.loadAccounts();
    presenter.loadCategory(_type);

    if(widget.transactionId != null) {
      presenter.loadTransactionDetail(widget.transactionId);
    } else {
      presenter.loadPresetDetail(widget.accountId, widget.categoryId);
    }
  }

  @override
  void dispose() {
    observer.unregisterDatabaseObservable(tables, this);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var appBar = MyWalletAppBar(
      title: R.string.create_transaction,
      actions: <Widget>[
        FlatButton(
          onPressed: _saveTransaction,
          child: Text(R.string.save,),
        )
      ],
    );

    return GradientScaffold(
      appBar: appBar,
      body: Column(
          children: <Widget>[
          Expanded(
            child: Container(
              color: AppTheme.white,
              alignment: Alignment.center,
              child: FittedBox(
                child: Column(children: <Widget> [
                  ConversationRow(
                      widget.transactionId == null ? R.string.create_new : R.string.an,
                      _type.name,
                      dataColor: AppTheme.darkBlue,
                      onPressed: _showTransactionTypeSelection,
                  ),
                  ConversationRow(
                      widget.transactionId == null ? R.string.of : R.string.value_of,
                      _numberFormat.format(_amount),
                      dataColor: TransactionType.isIncome(_type) ? AppTheme.tealAccent : TransactionType.isExpense(_type) ? AppTheme.pinkAccent : AppTheme.blueGrey,
                      style: Theme.of(context).textTheme.display2,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      ConversationRow(
                          "${widget.transactionId == null ? "" : R.string.was_made}${TransactionType.isExpense(_type) ? R.string.from : TransactionType.isIncome(_type) ? R.string.into : R.string.from}",
                          _account == null ? R.string.select_account : _account.name,
                          dataColor: AppTheme.darkGreen,
                          onPressed: _showSelectAccount,
                      ),
                      ConversationRow(
                          R.string.by,
                          _user == null ? R.string.unknown : _user.firstName,
                          dataColor: AppTheme.darkGreen,
                      )
                    ],
                  ),
                  ConversationRow(
                      R.string.txt_for,
                      _category == null ? R.string.select_category : _category.name,
                      dataColor: AppTheme.brightPink,
                      onPressed: _showSelectCategory,
                    trail: IconButton(
                      icon: Icon(_note == null || _note.isEmpty ? Icons.note_add : Icons.note, color: _note == null || _note.isEmpty ? AppTheme.darkGreen : AppTheme.pinkAccent,),
                      onPressed: () => Navigator.push(context, SlidePageRoute(
                          builder: (context) => InputName(
                            R.string.enter_note,
                                (name) =>_note = name,
                            hintText: _note == null || _note.isEmpty ? R.string.add_your_note : _note,))),
                    )
                  ),
                  DateTimeRow(_date, _showDatePicker, _showTimePicker,),
                ],),
              ),
            ),
          ),
            Align(
              child: NumberInputPad(numPadKey, _onNumberInput, null, null, showNumPad: true,),
              alignment: Alignment.bottomCenter,
            )
          ],
        ),
    );
  }

  void _showTransactionTypeSelection() {
    showModalBottomSheet(context: context, builder: (context) =>
        BottomViewContent(
            TransactionType.dailyTransaction, (context, f) =>
            Align(
              child: InkWell(
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(f.name, style: Theme.of(context).textTheme.title.apply(color: AppTheme.darkBlue))
                ),
                onTap: () {
                  setState(() {
                    _type = f;

                    presenter.loadCategory(_type);
                  });

                  Navigator.pop(context);
                },
              ),
              alignment: Alignment.center,
            ),
          R.string.select_transaction_type,
        )
    );
  }

  void _showSelectAccount() {
    showModalBottomSheet(context: context, builder: (context) =>
        BottomViewContent(
          _accountList, (context, f) => Align(
          child: InkWell(
            child: Padding(padding: EdgeInsets.all(10.0),
              child: Text(f.name, style: Theme.of(context).textTheme.title.apply(color: AppTheme.darkGreen), overflow: TextOverflow.ellipsis, maxLines: 1,) //Data(f.name, theme.darkGreen)
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
                child: Text(R.string.no_account_available,
                  style: Theme.of(context).textTheme.title.apply(color: AppTheme.darkBlue),
                textAlign: TextAlign.center,),
              ),
                 Align(
                   alignment: Alignment.bottomCenter,
                   child: RoundedButton(
                      onPressed: () => Navigator.of(context).pushNamed(routes.AddAccount),
                      child: Text(R.string.add_account,),
                      color: AppTheme.darkBlue,),
                 ),
            ],
          ),
          key: _accountKey,
        ),
    );
  }

  void _showSelectCategory() {
    TextStyle style = Theme.of(context).textTheme.title.apply(color: AppTheme.darkBlue);
    showModalBottomSheet(context: context, builder: (context) =>
        BottomViewContent(
          _categoryList, (context, f) => Align(
          child: InkWell(
            child: Padding(padding: EdgeInsets.all(10.0),
                child: Text(f.name, style: Theme.of(context).textTheme.title.apply(color: AppTheme.brightPink), overflow: TextOverflow.ellipsis, maxLines: 1,)
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
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: <TextSpan> [
                      TextSpan(text: R.string.no_category_for_transaction_type, style: style),
                      TextSpan(text: _type.name, style: style.apply(color: AppTheme.pinkAccent)),
                      TextSpan(text: R.string.please_create_new_category_for_transaction_type, style: style),
                      TextSpan(text: _type.name, style: style.apply(color: AppTheme.pinkAccent)),
                      TextSpan(text: R.string.or_change_transaction_type, style: style)
                    ]
                  )
        ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: RoundedButton(
                  onPressed: () => Navigator.pushNamed(context, routes.CreateCategory),
                  child: Text(R.string.create_category),
                  color: AppTheme.darkBlue,
                ),
              )
            ],
          ),
          key: _categoryKey,
    )
    );
  }

  void _showDatePicker() {
    showDatePicker(context: context, initialDate: _date, firstDate: _date.subtract(Duration(days: 365)), lastDate: _date.add(Duration(days: 365))).then((selected) {
      if(selected != null) setState(() => _date = DateTime(selected.year, selected.month, selected.day, _date.hour, _date.minute, _date.second, _date.millisecond));
    });
  }

  void _showTimePicker() {
    showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_date)).then((selected) {
      if(selected != null) setState(() => _date = DateTime(_date.year, _date.month, _date.day, selected.hour, selected.minute, _date.second));
    });
  }

  void _onNumberInput(double amount) {
    setState(() {
      this._amount = amount;
    });
  }

  void _saveTransaction() {
    if(_isSaving) return;

    _isSaving = true;

    showDialog(context: context, builder: (_) => AlertDialog(
      key: _alertDialog,
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

    SchedulerBinding.instance.addPostFrameCallback((duration) => presenter.saveTransaction(
        widget.transactionId,
        _type,
        _account,
        _category,
        _amount,
        _date,
        _note
    ));
  }

  @override
  void onAccountListLoaded(List<Account> value) {
    setState(() => this._accountList = value);
    if(_accountKey.currentContext != null) _accountKey.currentState.updateData(value);
  }

  @override
  void onCategoryListLoaded(List<AppCategory> value) {
    setState(() => this._categoryList = value);
    if(_categoryKey.currentContext != null) _categoryKey.currentState.updateData(value);
  }

  @override
  void onSaveTransactionSuccess(bool result) {
    _dismissDialog();
    Navigator.pop(context);
  }

  @override
  void onSaveTransactionFailed(Exception e) {
    _dismissDialog();

    debugPrint(e.toString());
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
      title: Text(R.string.error),
      content: Text(e.toString()),
      actions: <Widget>[
        FlatButton(
          onPressed: () => Navigator.pop(context),
          child: Text(R.string.ok),
        )
      ],
    ));
  }

  @override
  void onLoadTransactionDetail(TransactionDetail detail) {
    setState(() {
      _type = detail.type ;
      _date = detail.dateTime;
      _account = detail.account;
      _category = detail.category;
      _amount = detail.amount;
      _user = detail.user;
      _note = detail.desc;
    });
  }

  @override
  void onLoadTransactionFailed(Exception e) {
  }

  void _dismissDialog() {
    _isSaving = false;
    if(_alertDialog.currentContext != null) {
      // alert dialog is showing
      Navigator.pop(context);
    }
  }

  @override
  void updateUserDisplayName(UserDetail detail) {
    setState(() => _user = detail);
  }
}
