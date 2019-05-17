import 'package:my_wallet/data/data.dart';
import 'package:my_wallet/ca/presentation/view/ca_state.dart';

import 'package:my_wallet/ui/account/create/presentation/presenter/create_account_presenter.dart';
import 'package:my_wallet/ui/account/create/presentation/view/create_account_dataview.dart';

import 'package:my_wallet/resources.dart' as R;

class CreateAccount extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CreateAccountState();
  }
}

class _CreateAccountState extends CleanArchitectureView<CreateAccount, CreateAccountPresenter> implements CreateAccountDataView {
  _CreateAccountState() : super(CreateAccountPresenter());

  final GlobalKey<NumberInputPadState> _numPadKey = GlobalKey();

  AccountType _type = AccountType.paymentAccount;
  String _name = "";
  double _amount = 0.0;

  init() {
    presenter.dataView = this;
  }

  @override
  Widget build(BuildContext context) {
    var appBar = MyWalletAppBar(
      title: R.string.create_account,
      actions: <Widget>[
        FlatButton(
          child: Text(R.string.save),
          onPressed: _saveAccount,
        )
      ],
    );

    return GradientScaffold(
        appBar: appBar,
        body: NumberInputPad(_numPadKey,
            onValueChange: _onNumberInput,
            initialValue: 0.0,
            child: Container(
              alignment: Alignment.center,
              color: AppTheme.white,
              child: FittedBox(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    ConversationRow(R.string.create_new, _type.name, dataColor: AppTheme.darkBlue, onPressed: _showAccountTypeSelection),
                    ConversationRow(
                      R.string.with_name,
                      _name == null || _name.isEmpty ? "Enter a name" : _name,
                      dataColor: AppTheme.darkBlue,
                      onPressed: _showAccountNameDialog,
                    ),
                    ConversationRow(
                      R.string.and_initial_amount,
                      moneyFormatter.format(_amount),
                      dataColor: AppTheme.brightPink,
                      style: Theme.of(context).textTheme.display2,
                    ),
                  ],
                ),
              ),
            )
        )
    );
  }

  void _showAccountTypeSelection() {
    showModalBottomSheet(
        context: context,
        builder: (context) => BottomViewContent(
              AccountType.all,
              (context, f) => Align(
                    child: InkWell(
                      child: Padding(padding: EdgeInsets.all(10.0), child: Text(f.name, style: Theme.of(context).textTheme.title.apply(color: AppTheme.darkBlue))),
                      onTap: () {
                        setState(() => _type = f);

                        Navigator.pop(context);
                      },
                    ),
                    alignment: Alignment.center,
                  ),
              R.string.select_account_type,
            ));
  }

  void _showAccountNameDialog() {
    Navigator.push(
        context,
        SlidePageRoute(
            builder: (context) => InputName(
                  R.string.account_name,
                  (name) => setState(() => _name = name),
                  hintText: R.string.enter_account_name,
                )));
  }

  void _onNumberInput(double amount) {
    setState(() => _amount = amount);
  }

  void _saveAccount() {
    presenter.saveAccount(_type, _name, _amount);
  }

  void onAccountSaved(bool result) {
    if (result) Navigator.pop(context, result);
  }

  void onError(Exception e) {
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
}
