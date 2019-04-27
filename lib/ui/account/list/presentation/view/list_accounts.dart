import 'package:my_wallet/data/data.dart';
import 'package:intl/intl.dart';
import 'package:my_wallet/ui/account/list/presentation/presenter/list_accounts_presenter.dart';
import 'package:my_wallet/ca/presentation/view/ca_state.dart';
import 'package:my_wallet/ui/account/list/presentation/view/list_account_dataview.dart';
import 'package:my_wallet/data/data_observer.dart' as observer;

import 'package:my_wallet/resources.dart' as R;

class ListAccounts extends StatefulWidget {
  final String _title;

  ListAccounts(this._title);

  @override
  State<StatefulWidget> createState() {
    return _ListAccountsState();
  }
}

class _ListAccountsState extends CleanArchitectureView<ListAccounts, ListAccountsPresenter> implements ListAccountDataView, observer.DatabaseObservable {
  _ListAccountsState() : super(ListAccountsPresenter());

  var tables = [observer.tableAccount];

  var isEditMode = false;

  List<Account> _accounts = [];
  final NumberFormat _nf = NumberFormat("#,##0.00");

  @override
  void init() {
    presenter.dataView = this;
  }

  @override
  void initState() {
    super.initState();

    observer.registerDatabaseObservable(tables, this);
    _loadAllAccounts();
  }

  @override
  void dispose() {
    observer.unregisterDatabaseObservable(tables, this);
    super.dispose();
  }

  @override
  void onDatabaseUpdate(String table) {
    presenter.loadAllAccounts();
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: MyWalletAppBar(
        title: widget._title,
        actions: <Widget>[
          FlatButton(
            child: Text(isEditMode ? R.string.done : R.string.edit),
            onPressed: () {
              setState(() {
                isEditMode = !isEditMode;
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(10.0),
        child: ListView.builder(
            itemCount: _accounts.length,
            itemBuilder: (context, index) => CardListTile(
              title: _accounts[index].name,
                onTap: () {
                if(isEditMode) return;
                if(_accounts[index].type == AccountType.liability) {
                  // open liability view
                  Navigator.pushNamed(context, routes.LiabilityDetail(accountId: _accounts[index].id, accountName: _accounts[index].name));
//                } else if(_accounts[index].type == AccountType.assets) {
                  // open access view
                } else {
                  // open transaction account view
                  Navigator.pushNamed(context,
                    routes.AccountDetail(accountId: _accounts[index].id, accountName: _accounts[index].name),);
                }
                },
              subTitle: _accounts[index].type == AccountType.liability ? "(-${_nf.format(_accounts[index].balance)})" : "${_nf.format(_accounts[index].balance ?? 0.0)}",
              trailing: isEditMode ? IconButton(
                onPressed: () {
                  _deleteAccount(_accounts[index]);
                },
                icon: Icon(Icons.close, color: AppTheme.pinkAccent,),
              ) : null,
            )
        ),
      ),
      floatingActionButton: isEditMode ? RoundedButton(onPressed: () => Navigator.pushNamed(context, routes.AddAccount)
          .then((value) {
            if(value != null) _loadAllAccounts();
          }),
        child: Text(R.string.create_account,),
        color: AppTheme.pinkAccent,) : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void _loadAllAccounts() {
    presenter.loadAllAccounts();
  }

  void onAccountListLoaded(List<Account> acc) {
    setState(() {
      _accounts = acc;
    });
  }

  void _deleteAccount(Account account) {
    showDialog(context: context, builder: (context) => AlertDialog(
      title: Text("${R.string.delete_account} ${account.name}"),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Padding(
            child: Icon(Icons.warning, color: Colors.yellow, size: 36.0,),
            padding: EdgeInsets.all(10.0),
          ),
          Flexible(
            child: Text(R.string.delete_account_warning),
          ),
        ],
      ),
      actions: <Widget>[
        FlatButton(
          child: Text(R.string.delete),
          onPressed: () {
            Navigator.pop(context);

            presenter.deleteAccount(account);
          },
        ),
        FlatButton(
          child: Text(R.string.cancel),
          onPressed: () => Navigator.pop(context),
        )
      ],
    ));
  }
}