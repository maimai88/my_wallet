import 'package:my_wallet/ca/presentation/view/ca_state.dart';
import 'package:my_wallet/ui/user/register/presentation/presenter/register_presenter.dart';
import 'package:my_wallet/ui/user/register/presentation/view/register_data_view.dart';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/gestures.dart';

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
      body: Padding(
        padding: EdgeInsets.only(left: 30.0, right: 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            AutoSizeText(
              "Sign Up",
              style: TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.w900, color: AppTheme.white, fontSize: 60.0),
            ),
            Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TextField(
                  controller: _displayNameController,
                  decoration: InputDecoration(
                      labelText: "Display name",
                      labelStyle: TextStyle(color: AppTheme.nartusOrange),
                      errorStyle: TextStyle(color: AppTheme.pinkAccent),
                      errorText: _displayNameErrorText,
                      errorMaxLines: 2
                  ),
                ),
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
                TextField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                      labelText: "Confirm password",
                      labelStyle: TextStyle(color: AppTheme.nartusOrange),
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
                        "Register",
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
                        text: "Not the first time here? "),
                    TextSpan(
                        style: Theme.of(context).textTheme.subtitle.apply(color: AppTheme.white, fontFamily: 'Raleway', fontWeightDelta: 2),
                        text: "Sign In",
                        recognizer: TapGestureRecognizer()..onTap = () => Navigator.pushNamedAndRemoveUntil(context, routes.Login, (route) => route.isFirst))
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

//  @override
//  Widget build(BuildContext context) {
//    return PlainScaffold(
//      color: AppTheme.darkGrey,
//        appBar: MyWalletAppBar(
//          color: AppTheme.darkGrey,
//          elevation: 0.0,
//        ),
//        body: ListView(
//          shrinkWrap: true,
//          children: <Widget>[
//            Align(
//              alignment: Alignment.center,
//              child: Padding(
//                padding: EdgeInsets.only(top: 10.0, bottom: 20.0),
//                child: Text(
//                  "Create your account",
//                  style: Theme.of(context).textTheme.display1.apply(color: AppTheme.black),
//                ),
//              ),
//            ),
////            Align(
////                alignment: Alignment.center,
////                child: Padding(
////                  padding: EdgeInsets.only(top: 00.0, bottom: 10.0),
////                  child: Text(
////                    "Signup with Social Network or Email",
////                    style: Theme.of(context).textTheme.title.apply(color: AppTheme.blueGrey),
////                  ),
////                )
////            ),
////            Padding(
////              padding: EdgeInsets.only(left: 20.0, right: 20.0),
////              child: Row(
////                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
////                mainAxisSize: MainAxisSize.max,
////                children: <Widget>[
////                  Expanded(
////                    child: RoundedButton(
////                      onPressed: _onFacebookButtonPressed,
////                      padding: EdgeInsets.all(10.0),
////                      child: Icon(
////                        MyFlutterApp.facebook_rect,
////                        color: AppTheme.white,
////                      ),
////                      radius: 5.0,
////                      color: AppTheme.facebookColor,
////                    ),
////                  ),
////                  Expanded(
////                    child: RoundedButton(
////                      onPressed: _onGoogleButtonPressed,
////                      padding: EdgeInsets.all(10.0),
////                      child: Icon(
////                        MyFlutterApp.googleplus_rect,
////                        color: AppTheme.white,
////                      ),
////                      radius: 5.0,
////                      color: AppTheme.googleColor,
////                    ),
////                  ),
////                ],
////              ),
////            ),
////            Padding(
////              padding: EdgeInsets.only(top: 10.0, bottom: 10.0, left: 20.0, right: 20.0),
////              child: Row(
////                children: <Widget>[
////                  Expanded(
////                    child: Container(
////                      height: 1.0,
////                      color: AppTheme.blueGrey,
////                    ),
////                  ),
////                  Padding(
////                    padding: EdgeInsets.all(5.0),
////                    child: Text(
////                      "OR",
////                      style: Theme.of(context).textTheme.title.apply(color: AppTheme.blueGrey),
////                    ),
////                  ),
////                  Expanded(
////                    child: Container(
////                      height: 1.0,
////                      color: AppTheme.blueGrey,
////                    ),
////                  )
////                ],
////              ),
////            ),
//            Container(
//              height: 0.5,
//              color: AppTheme.blueGrey,
//            ),
//            Padding(
//              padding: EdgeInsets.only(left: 20.0, top: 10.0, bottom: 10.0),
//              child: Text(
//                "NAME",
//                style: Theme.of(context).textTheme.title.apply(color: AppTheme.black),
//              ),
//            ),
//            Padding(
//              padding: EdgeInsets.only(left: 20.0, bottom: 10.0),
//              child: TextField(
//                controller: _displayNameController,
//                decoration: InputDecoration(hintText: "Sample Name", hintStyle: Theme.of(context).textTheme.title.apply(color: AppTheme.blueGrey)),
//                style: Theme.of(context).textTheme.title.apply(color: AppTheme.black),
//              ),
//            ),
//            Container(
//              height: 0.5,
//              color: AppTheme.blueGrey,
//            ),
//            Padding(
//              padding: EdgeInsets.only(left: 20.0, top: 10.0, bottom: 10.0),
//              child: Text(
//                "EMAIL ADDRESS",
//                style: Theme.of(context).textTheme.title.apply(color: AppTheme.black),
//              ),
//            ),
//            Padding(
//              padding: EdgeInsets.only(left: 20.0, bottom: 10.0),
//              child: TextField(
//                controller: _emailController,
//                decoration: InputDecoration(hintText: "SampleEmail@domain.com", hintStyle: Theme.of(context).textTheme.title.apply(color: AppTheme.blueGrey)),
//                style: Theme.of(context).textTheme.title.apply(color: AppTheme.black),
//              ),
//            ),
//            Container(
//              height: 0.5,
//              color: AppTheme.blueGrey,
//            ),
//            Padding(
//              padding: EdgeInsets.only(left: 20.0, top: 10.0, bottom: 10.0),
//              child: Text(
//                "PASSWORD",
//                style: Theme.of(context).textTheme.title.apply(color: AppTheme.black),
//              ),
//            ),
//            Padding(
//              padding: EdgeInsets.only(left: 20.0, bottom: 10.0),
//              child: TextField(
//                controller: _passwordController,
//                decoration: InputDecoration(
//                    hintText: "samplepassword",
//                    hintStyle: Theme.of(context).textTheme.title.apply(color: AppTheme.blueGrey),
//                    suffixIcon: IconButton(icon: Icon(Icons.remove_red_eye, color: _obscureText ? AppTheme.blueGrey : AppTheme.blueGrey.withOpacity(0.4),), onPressed: () => setState(() => _obscureText = !_obscureText))
//                ),
//                obscureText: _obscureText,
//                style: Theme.of(context).textTheme.title.apply(color: AppTheme.black),
//              ),
//            ),
//            Container(
//              height: 0.5,
//              color: AppTheme.blueGrey,
//            ),
//            Padding(
//              padding: EdgeInsets.only(top: 20.0, left: 5.0, right: 5.0),
//              child: Row(
//                children: <Widget>[
//                  Expanded(
//                    child: RoundedButton(
//                      key: _registerKey,
//                      onPressed: _registerEmail,
//                      child: Text("Register", style: TextStyle(color: AppTheme.white),),
//                      color: AppTheme.blue,
//                    ),
////                      child: FlatButton(
////                        padding: EdgeInsets.all(15.0),
////                        onPressed: _registerEmail,
////                        child: Text("Register"),
////                        color: AppTheme.darkBlue,))
//                  )
//                ],
//              ),
//            )
//          ],
//        ),
//    );
//  }

//  void _onFacebookButtonPressed() {
//    debugPrint("Facebook");
//  }
//
//  void _onGoogleButtonPressed() {
//    debugPrint("Google");
//  }

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
//    showDialog(context: context, builder: (context) => AlertDialog(
//      title: Text("Registration failed"),
//      content: Text("Registration failed with error ${e.toString()}"),
//      actions: <Widget>[
//        FlatButton(
//          onPressed: () => Navigator.pop(context),
//          child: Text("Try Again"),
//        )
//      ],
//    ));

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
