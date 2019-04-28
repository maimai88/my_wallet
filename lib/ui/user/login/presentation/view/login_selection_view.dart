import 'package:my_wallet/app_material.dart';
import 'package:flutter/gestures.dart';
import 'package:auto_size_text/auto_size_text.dart';

import 'package:my_wallet/resources.dart' as R;

class LoginSelectionView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PlainScaffold(
      body: Padding(
        padding: EdgeInsets.only(left: MediaQuery.of(context).size.width / 8, right: MediaQuery.of(context).size.width / 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Nartus logo
            SizedBox(
              child: Image.asset(R.asset.nartus, alignment: Alignment.topLeft),
              height: 80,
            ),
            // introduction text
            AutoSizeText(R.string.start_managing_your_budget,
              style: TextStyle(
                fontFamily: R.font.raleway,
                fontWeight: FontWeight.w900,
                color: AppTheme.darkBlue,
                fontSize: 55.0
              ),
            ),
            // login buttons,
            RoundedButton(
              onPressed: () => Navigator.pushNamed(context, routes.Login),
              child: Text(R.string.sign_in),
              color: AppTheme.amber,
            ),
            Text.rich(
              TextSpan(children: [
                TextSpan(
                    style: Theme.of(context).textTheme.body1.apply(color: AppTheme.darkGrey),
                    text: R.string.you_do_not_have_an_account),
                TextSpan(
                    style: Theme.of(context).textTheme.subtitle.apply(color: AppTheme.darkGrey, fontFamily: R.font.raleway, fontWeightDelta: 2),
                    text: R.string.sign_up_here,
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
