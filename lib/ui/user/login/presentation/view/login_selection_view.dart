import 'package:my_wallet/app_material.dart';
import 'package:flutter/gestures.dart';
import 'package:auto_size_text/auto_size_text.dart';

class LoginSelectionView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PlainScaffold(
      body: Padding(
        padding: EdgeInsets.all(MediaQuery.of(context).size.width / 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Nartus logo
            SizedBox(
              child: Image.asset("assets/nartus.png", alignment: Alignment.topLeft),
              height: 80,
            ),
            // introduction text
            AutoSizeText("Start managing your budget",
              style: Theme.of(context).textTheme.display3.apply(color: AppTheme.darkBlue, fontWeightDelta: 3),
            ),
            // login buttons,
            RoundedButton(
              onPressed: () => Navigator.pushNamed(context, routes.Login),
              child: Text("Login", ),
              color: AppTheme.darkBlue,
            ),
            Text.rich(
              TextSpan(children: [
                TextSpan(
                    style: Theme.of(context).textTheme.body1.apply(color: AppTheme.darkBlue),
                    text: "You do not have an account? "),
                TextSpan(
                    style: Theme.of(context).textTheme.subtitle.apply(color: AppTheme.darkBlue),
                    text: "Sign up here",
                    recognizer: TapGestureRecognizer()..onTap = () => Navigator.pushNamed(context, routes.Register))
              ]),
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }
}
