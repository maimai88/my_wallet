import 'package:my_wallet/ca/presentation/view/ca_state.dart';

import 'package:my_wallet/app_material.dart';
import 'package:my_wallet/ui/account/detail/presentation/presenter/detail_presenter.dart';
import 'package:my_wallet/ui/account/detail/presentation/view/detail_data_view.dart';

import 'package:my_wallet/data/data_observer.dart' as observer;
import 'package:my_wallet/style/routes.dart';
import 'package:intl/intl.dart';

import 'package:my_wallet/resources.dart' as R;

class AccountDetail extends StatefulWidget {
  final int _accountId;
  final String _name;

  AccountDetail(this._accountId, this._name);

  @override
  State<StatefulWidget> createState() {
    return _AccountDetailState();
  }
}

class _AccountDetailState extends CleanArchitectureView<AccountDetail, AccountDetailPresenter> implements AccountDetailDataView, observer.DatabaseObservable {
  _AccountDetailState() : super(AccountDetailPresenter());

  final _tables = [observer.tableAccount, observer.tableTransactions];
  final _nf = NumberFormat("\$#,###.##");
  final _df = DateFormat("dd MMM, yyyy HH:mm");

  Account _account;

  @override
  void init() {
    presenter.dataView = this;
  }

  @override
  void initState() {
    super.initState();

    observer.registerDatabaseObservable(_tables, this);

    _loadData();
  }

  @override
  void dispose() {
    observer.unregisterDatabaseObservable(_tables, this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PlainScaffold(
      appBar: MyWalletAppBar(
        title: _account == null ? widget._name : _account.name,
      ),
      body: Padding(
        padding: EdgeInsets.only(left: 8.0, right: 8.0),
        child: ListView(
          children: <Widget>[
            DataRowView(R.string.account, _account == null ? "" : _account.name),
            DataRowView(R.string.created, _account == null ? "" : _df.format(_account.created)),
            DataRowView(R.string.type, _account == null ? "" : _account.type.name),
            DataRowView(R.string.balance, _account == null ? "" : _nf.format(_account.balance)),
            DataRowView(R.string.spent, _account == null ? "" : _nf.format(_account.spent)),
            DataRowView(R.string.earn, _account == null ? "" : _nf.format(_account.earn)),
            RoundedButton(
              onPressed: () {
                if(_account != null) Navigator.pushNamed(context, routes.TransactionList(_account.name, accountId: _account.id));
              },
              child: Padding(padding: EdgeInsets.all(12.0), child: Text(R.string.view_transactions, style: TextStyle(color: AppTheme.white),),),
              color: AppTheme.blue,
            ),
            RoundedButton(
              onPressed: () {
                if(_account != null) Navigator.pushNamed(context, routes.TransferToAccount(accountName: _account.name, accountId: _account.id));
              },
              child: Padding(padding: EdgeInsets.all(12.0), child: Text(R.string.make_a_transfer, style: TextStyle(color: AppTheme.white),),),
              color: AppTheme.blue,
            ),
          ],
        )
      ),
    );
  }

  void onDatabaseUpdate(String table) {
    _loadData();
  }

  void _loadData() {
    presenter.loadAccount(widget._accountId);
  }

  @override
  void onAccountLoaded(Account account) {
    setState(() => _account = account);
  }

  @override
  void failedToLoadAccount(Exception ex) {
    debugPrint("Error $ex");
  }
}
