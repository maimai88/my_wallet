import 'package:my_wallet/ca/presentation/view/ca_state.dart';

import 'package:my_wallet/ui/user/logout/presentation/presenter/sign_out_presenter.dart';
import 'package:my_wallet/ui/user/logout/presentation/view/sign_out_data_view.dart';

class SignOut extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SignOutState();
}

class _SignOutState extends CleanArchitectureView<SignOut, SignOutPresenter> implements SignOutDataView {

  _SignOutState() : super(SignOutPresenter());

  @override
  void init() {
    presenter.dataView = this;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text("WARNING",
          style: TextStyle(fontSize: 24.0, color: AppTheme.red),
          textAlign: TextAlign.center,),
        Text(
            "By Signing Out, all your local data will be deleted.\n",
            style: TextStyle(color: AppTheme.darkBlue),
          textAlign: TextAlign.center,
        ),
        RoundedButton(
          color: AppTheme.pinkAccent,
          onPressed: () => presenter.signOut(),
          child: Text("Sign Out"),
        )
      ],
    );
  }

  @override
  void onSignOutSuccess(bool result) {
    Navigator.of(context, rootNavigator: true).pushReplacementNamed(routes.LoginSelection);
  }

  @override
  void onSignOutFailed(Exception exception) {

  }
}
