import 'package:my_wallet/app_material.dart';

import 'package:my_wallet/ui/dashboard/no_transition_page_route.dart';

import 'package:my_wallet/ui/budget/list/presentation/view/list_view.dart';

class BudgetNavigator extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  BudgetNavigator(this.navigatorKey);

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (setting) => createRoute(setting.name),
      initialRoute: '/',
    );
  }

  MaterialPageRoute createRoute(String name) {
    if (name == '/') {
      return NoTransitionPageRoute(
          builder: (context) => ListBudgets()
      );
    }

    return MaterialPageRoute(
      builder: (context) => _generateWidget(name),
    );
  }

  Widget _generateWidget(name) {
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