import 'package:my_wallet/app_material.dart';

import 'package:my_wallet/ui/dashboard/no_transition_page_route.dart';

// account navigator
import 'package:my_wallet/ui/account/list/presentation/view/list_accounts.dart';
import 'package:my_wallet/ui/account/detail/presentation/view/detail_view.dart';

class AccountNavigator extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  AccountNavigator(this.navigatorKey);

  @override
  Widget build(BuildContext context) {
    return Navigator(
        onGenerateRoute: (setting) => createRoute(setting.name)
    );
  }

  MaterialPageRoute createRoute(String name) {
    if (name == '/') {
      return NoTransitionPageRoute(builder: (context) => ListAccounts("Accounts"));
    }

    return MaterialPageRoute(
      maintainState: true,
      builder: (context) => _generateAccountRoute(name)
    );
  }

  Widget _generateAccountRoute(String name) {
    if(name.startsWith(routes.Accounts)) {
      do {
        String data = name.replaceFirst("${routes.Accounts}/", "");

        if(data == null) break;
        if(data.isEmpty) break;

        List<String> splits = data.split(":");

        String strAccId = splits[0];
        String accName = splits[1];

        try {
          int _accountId = int.parse(strAccId);
          return AccountDetail(_accountId, accName);
        } catch(e) {}
      } while(false);
    }

    return PlainScaffold(
      appBar: MyWalletAppBar(
        title: "Coming Soon",
      ),
      body: Center(
        child: Text("Unknown page $name", style: TextStyle(color: AppTheme.darkBlue),),
      ),
    );
  }
}