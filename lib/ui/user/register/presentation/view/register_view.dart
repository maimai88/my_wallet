import 'package:my_wallet/ca/presentation/view/ca_state.dart';
import 'package:my_wallet/ui/user/register/presentation/presenter/register_presenter.dart';
import 'package:my_wallet/ui/user/register/presentation/view/register_data_view.dart';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/gestures.dart';

import 'package:my_wallet/resources.dart' as R;

class Register extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _RegisterState();
  }
}

class _RegisterState extends CleanArchitectureView<Register, RegisterPresenter> implements RegisterDataView {
  _RegisterState() : super(RegisterPresenter());

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();
  TextEditingController _displayNameController = TextEditingController();

  final GlobalKey<RoundedButtonState> _registerKey = GlobalKey();

  bool _obscureText = true;

  String _displayNameErrorText;
  String _emailErrorText;
  String _passwordErrorText;
  String _confirmPasswordErrorText;

  @override
  void init() {
    presenter.dataView = this;
  }

  @override
  Widget build(BuildContext context) {
    return PlainScaffold(
      color: AppTheme.darkGrey,
      appBar: MyWalletAppBar(
        color: AppTheme.darkGrey,
        elevation: 0.0,
      ),
      body:  Container(
        padding: EdgeInsets.only(left: 30.0, right: 30.0),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(bottom: 30.0),
                child: AutoSizeText(
                  R.string.sign_up,
                  style: TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.w900, color: AppTheme.white, fontSize: 55.0),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  TextField(
                    controller: _displayNameController,
                    decoration: InputDecoration(
                        labelText: R.string.display_name,
                        labelStyle: TextStyle(color: AppTheme.nartusOrange),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.nartusOrange)),
                        errorStyle: TextStyle(color: AppTheme.pinkAccent),
                        errorText: _displayNameErrorText,
                        errorMaxLines: 2
                    ),
                  ),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                        labelText: R.string.email_address,
                        labelStyle: TextStyle(color: AppTheme.nartusOrange),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.nartusOrange)),
                        errorStyle: TextStyle(color: AppTheme.pinkAccent),
                        errorText: _emailErrorText,
                        errorMaxLines: 2
                    ),
                  ),
                  TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                        labelText: R.string.password,
                        labelStyle: TextStyle(color: AppTheme.nartusOrange),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.nartusOrange)),
                        errorStyle: TextStyle(color: AppTheme.pinkAccent),
                        errorText: _passwordErrorText,
                        suffixIcon: IconButton(
                            icon: Icon(
                              Icons.remove_red_eye,
                              color: _obscureText ? AppTheme.white : AppTheme.blueGrey,
                            ),
                            onPressed: () => setState(() => _obscureText = !_obscureText))),
                    keyboardType: TextInputType.text,
                    obscureText: _obscureText,
                  ),
                  TextField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                        labelText: R.string.confirm_password,
                        labelStyle: TextStyle(color: AppTheme.nartusOrange),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.nartusOrange)),
                        errorStyle: TextStyle(color: AppTheme.pinkAccent),
                        errorText: _confirmPasswordErrorText,
                        suffixIcon: IconButton(
                            icon: Icon(
                              Icons.remove_red_eye,
                              color: _obscureText ? AppTheme.white : AppTheme.blueGrey,
                            ),
                            onPressed: () => setState(() => _obscureText = !_obscureText))),
                    keyboardType: TextInputType.text,
                    obscureText: _obscureText,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: RoundedButton(
                      key: _registerKey,
                      onPressed: _registerEmail,
                      child: Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Text(
                          R.string.register,
                          style: TextStyle(color: AppTheme.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      color: AppTheme.black,
                    ),
                  ),
                  Text.rich(
                    TextSpan(children: [
                      TextSpan(
                          style: Theme.of(context).textTheme.body1.apply(color: AppTheme.white),
                          text: R.string.not_the_first_time_here),
                      TextSpan(
                          style: Theme.of(context).textTheme.subtitle.apply(color: AppTheme.white, fontFamily: R.font.raleway, fontWeightDelta: 2),
                          text: R.string.sign_in,
                          recognizer: TapGestureRecognizer()..onTap = () => Navigator.pushNamedAndRemoveUntil(context, routes.Login, (route) => route.isFirst))
                    ]),
                    textAlign: TextAlign.center,
                  )

                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _registerEmail() {
    _registerKey.currentState.process();
    presenter.registerEmail(_displayNameController.text, _emailController.text, _passwordController.text, _confirmPasswordController.text);
  }

  @override
  void onRegisterSuccess(bool result) {
    _registerKey.currentState.stop();
    Navigator.pop(context);
    Navigator.of(context).pushReplacementNamed(routes.ValidationProcessing);
  }

  @override
  void onRegisterFailed(Exception e) {
    _registerKey.currentState.stop();

    if(e is RegisterException) {
      _displayNameErrorText = e.displayNameError;
      _emailErrorText = e.emailError;
      _passwordErrorText = e.passwordError;
      _confirmPasswordErrorText = e.confirmPasswordError;

      if(e.registerError != null) {
        _emailErrorText = e.registerError;
      }
    } else {
      _emailErrorText = e.toString();
    }

    setState(() {});
  }
}
