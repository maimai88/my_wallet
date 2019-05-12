import 'package:my_wallet/ui/account/list/presentation/presenter/list_accounts_presenter.dart';
import 'package:my_wallet/ca/presentation/view/ca_state.dart';
import 'package:my_wallet/ui/account/list/presentation/view/list_account_dataview.dart';
import 'package:my_wallet/data/local/data_observer.dart' as observer;

import 'package:my_wallet/resources.dart' as R;

class ListAccounts extends StatefulWidget {

  ListAccounts();

  @override
  State<StatefulWidget> createState() {
    return _ListAccountsState();
  }
}

class _ListAccountsState extends CleanArchitectureView<ListAccounts, ListAccountsPresenter> implements ListAccountDataView, observer.DatabaseObservable {
  _ListAccountsState() : super(ListAccountsPresenter());

  var tables = [observer.tableAccount];

  List<AccountEntity> _accounts = [];

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
  void onDatabaseUpdate(List<String> tables) {
    presenter.loadAllAccounts();
  }

  @override
  Widget build(BuildContext context) {
    return PlainScaffold(
      floatingActionButton: RoundedButton(
          onPressed: () => Navigator.pushNamed(context, routes.AddAccount),
          child: Text(R.string.add_account),
        color: Colors.orange[700],),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Padding(
        padding: EdgeInsets.all(10.0),
        child: ListView.builder(
            itemCount: _accounts.length + 1,
            itemBuilder: (context, index) {
              if (index < _accounts.length) {
                return CardListTile(
                    cardName: _accounts[index].name,
                    cardDescription: _accounts[index].type,
                    cardBalance: moneyFormatter.format(_accounts[index].balance),
                    cardSpent: moneyFormatter.format(_accounts[index].spent),
                    onTap: () {
                      if(_accounts[index].isLiability) {
                        // open liability view
                        Navigator.pushNamed(context, routes.LiabilityDetail(accountId: _accounts[index].id, accountName: _accounts[index].name));
                      } else {
                        // open transaction account view
                        Navigator.pushNamed(context,
                          routes.AccountDetail(accountId: _accounts[index].id, accountName: _accounts[index].name),);
                      }
                    },
                    cardColor: AppTheme.orange
                );
              }

              return Container(
                height: 50,
              );
            }
        ),
      ),
    );
  }

  void _loadAllAccounts() {
    presenter.loadAllAccounts();
  }

  void onAccountListLoaded(List<AccountEntity> acc) {
    setState(() {
      _accounts = acc;
    });
  }
}