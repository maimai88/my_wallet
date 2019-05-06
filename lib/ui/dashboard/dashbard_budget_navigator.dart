import 'package:my_wallet/app_material.dart';

import 'package:my_wallet/ui/dashboard/no_transition_page_route.dart';

import 'package:my_wallet/ui/budget/list/presentation/view/list_view.dart';
import 'package:my_wallet/ui/budget/detail/presentation/view/detail_view.dart';

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
    if(name.startsWith(routes.AddBudget)) {
      do {
        // get month date/time:
        List<String> splits = name.split(":");

        if(splits.length != 2) break;

        String date = splits[1];
        String title = splits[0];

        if (date == null || date.isEmpty) break;

        try {
          int millisecondsSinceEpoch = int.parse(date);

          DateTime day = DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch);

          return BudgetDetail("Budget", categoryId: int.parse(title.replaceFirst("${routes.AddBudget}/", "")), month: day,);
        } catch(e) {}
      } while (false);
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