import 'package:my_wallet/app_material.dart';

import 'package:my_wallet/resources.dart' as R;
// home navigator
import 'package:my_wallet/ui/dashboard/dashboard_home_navigator.dart';

// account navigator
import 'package:my_wallet/ui/dashboard/dashbard_account_navigator.dart';

// profile navigator
import 'package:my_wallet/ui/dashboard/dashbard_budget_navigator.dart';

// more navigator
import 'package:my_wallet/ui/dashboard/dashboard_more_navigator.dart';

class Dashboard extends StatefulWidget {
  Dashboard({key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with TickerProviderStateMixin {

  GlobalKey<NavigatorState> homeNavigatorKey;
  GlobalKey<NavigatorState> accountNavigatorKey;
  GlobalKey<NavigatorState> profileNavigatorKey;
  GlobalKey<NavigatorState> moreNavigatorKey;

  TabController tabController;

  @override
  void initState() {
    super.initState();

    tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return PlainScaffold(
      body: TabBarView(
        controller: tabController,
          children: [
            HomeNavigator(homeNavigatorKey),
            BudgetNavigator(profileNavigatorKey),
            AccountNavigator(accountNavigatorKey),
            MoreNavigator(moreNavigatorKey),
          ]),
      bottomNavigationBar: BottomNavigationBar(items: [
        BottomNavigationBarItem(icon: Icon(Icons.home), title: Text(R.string.home)),
        BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), title: Text(R.string.budgets)),
        BottomNavigationBarItem(icon: Icon(Icons.account_balance), title: Text(R.string.accounts)),
        BottomNavigationBarItem(icon: Icon(Icons.more_horiz), title: Text(R.string.more))
      ],
      onTap: (index) {
        tabController.animateTo(index);
        setState(() {});
      },
      currentIndex: tabController.index,
      selectedItemColor: AppTheme.pinkAccent,
      unselectedItemColor: AppTheme.teal.withOpacity(0.6),
      type: BottomNavigationBarType.fixed,),
    );
  }
}