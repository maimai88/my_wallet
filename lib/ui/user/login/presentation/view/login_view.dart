import 'package:my_wallet/ui/user/login/presentation/view/login_data_view.dart';
import 'package:my_wallet/ca/presentation/view/ca_state.dart';
import 'package:my_wallet/ui/user/login/presentation/presenter/login_presenter.dart';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/gestures.dart';

class Login extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LoginState();
  }
}

class _LoginState extends CleanArchitectureView<Login, LoginPresenter> implements LoginDataView {
  _LoginState() : super(LoginPresenter());

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final GlobalKey<RoundedButtonState> _loginKey = GlobalKey();
  final GlobalKey<RoundedButtonState> _googleKey = GlobalKey();
  final GlobalKey<RoundedButtonState> _facebookKey = GlobalKey();

  bool _obscureText = true;

  bool _signingIn = false;

  String _emailErrorText;
  String _passwordErrorText;

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
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            AutoSizeText(
              "Sign In",
              style: TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.w900, color: AppTheme.white, fontSize: 60.0),
            ),
            Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: "Email Address",
                    labelStyle: TextStyle(color: AppTheme.nartusOrange),
                    errorStyle: TextStyle(color: AppTheme.pinkAccent),
                    errorText: _emailErrorText,
                    errorMaxLines: 2
                  ),
                ),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                      labelText: "Password",
                      labelStyle: TextStyle(color: AppTheme.nartusOrange),
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
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: RoundedButton(
                    key: _loginKey,
                    onPressed: _signIn,
                    child: Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text(
                        "Sign In",
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
                        text: "First time here? "),
                    TextSpan(
                        style: Theme.of(context).textTheme.subtitle.apply(color: AppTheme.white, fontFamily: 'Raleway', fontWeightDelta: 2),
                        text: "Sign up",
                        recognizer: TapGestureRecognizer()..onTap = () => Navigator.popAndPushNamed(context, routes.Register))
                  ]),
                  textAlign: TextAlign.center,
                )

              ],
            ),
          ],
        ),
      ),
    );
  }


  void _signIn() {
    if (_signingIn) return;

    _signingIn = true;
    _loginKey.currentState.process();

    presenter.signIn(_emailController.text, _passwordController.text);
  }

  @override
  void onSignInSuccess(LoginResult user) {
    do {
      if (!user.isVerified) {
        Navigator.pushNamed(context, routes.RequestValidation);
        break;
      }
      presenter.checkUserHome();
    } while (false);
  }

  @override
  void onSignInFailed(Exception e) {
    stopProcessing();

    if (e is LoginException) {
      _passwordErrorText = e.passwordException;
      _emailErrorText = e.emailException;

      if (_emailErrorText == null) {
        _emailErrorText = e.loginException;
      }
    } else {
      _emailErrorText = e.toString();
    }

    setState(() {});
//    showDialog(
//        context: context,
//        builder: (_) => AlertDialog(
//              title: Text("Sign in failed"),
//              content: Text("Sign in to email ${_emailController.text} failed with error ${e.toString()}"),
//              actions: <Widget>[
//                FlatButton(
//                  onPressed: () {
//                    Navigator.pop(context);
//                  },
//                  child: Text("Try Again"),
//                )
//              ],
//            ));
  }

  void onUserHomeResult(bool exist) {
    stopProcessing();

    Navigator.pushReplacementNamed(context, exist ? routes.MyHome : routes.HomeProfile);
  }

  void onUserHomeFailed(Exception e) {
    stopProcessing();

    debugPrint(e.toString());

    onUserHomeResult(true);
  }

  void _register() {
    Navigator.pushNamed(context, routes.Register);
  }

//  void _onFacebookButtonPressed() {
//    debugPrint("Facebook authentication");
//    if(_signingIn) return;
//
//    _signingIn = true;
//    _facebookKey.currentState.process();
//    presenter.signInWithFacebook();
//  }
//
//  void _onGoogleButtonPressed() {
//    debugPrint("Google Authentication");
//    if(_signingIn) return;
//
//    _signingIn = true;
//    _googleKey.currentState.process();
//    presenter.signInWithGoogle();
//  }

  void stopProcessing() {
    _signingIn = false;

    if (_loginKey.currentState != null) _loginKey.currentState.stop();
    if (_googleKey.currentState != null) _googleKey.currentState.stop();
    if (_facebookKey.currentState != null) _facebookKey.currentState.stop();
  }
}
