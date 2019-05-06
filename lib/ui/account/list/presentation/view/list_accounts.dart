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

  List<Account> _accounts = [];

  final NumberFormat _nf = NumberFormat("#,##0.00");
  final DateFormat _df = DateFormat("dd MMM, yyyy");

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
    return PlainScaffold(
      body: Padding(
        padding: EdgeInsets.all(10.0),
        child: ListView.builder(
            itemCount: _accounts.length,
            itemBuilder: (context, index) => CardListTile(
                cardName: _accounts[index].name,
                cardDescription: R.string.created_on(_df.format(_accounts[index].created)),
                cardBalance: _nf.format(_accounts[index].balance),
                cardSpent: _nf.format(_accounts[index].spent),
                onTap: () {
                  if(_accounts[index].type == AccountType.liability) {
                    // open liability view
                    Navigator.pushNamed(context, routes.LiabilityDetail(accountId: _accounts[index].id, accountName: _accounts[index].name));
                  } else {
                    // open transaction account view
                    Navigator.pushNamed(context,
                      routes.AccountDetail(accountId: _accounts[index].id, accountName: _accounts[index].name),);
                  }
                },
            cardColor: Colors.orange
            )
        ),
      ),
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
}