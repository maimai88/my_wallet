import 'package:my_wallet/ca/presentation/view/ca_state.dart';

import 'package:my_wallet/ui/dashboard/presentation/presenter/dashboad_presenter.dart';
import 'package:my_wallet/ui/dashboard/presentation/view/dashboard_data_view.dart';

import 'package:my_wallet/resources.dart' as R;
// home navigator
import 'package:my_wallet/ui/dashboard/presentation/view/dashboard_home_navigator.dart';

// account navigator
import 'package:my_wallet/ui/dashboard/presentation/view/dashbard_account_navigator.dart';

// profile navigator
import 'package:my_wallet/ui/dashboard/presentation/view/dashbard_budget_navigator.dart';

// more navigator
import 'package:my_wallet/ui/dashboard/presentation/view/dashboard_more_navigator.dart';

class Dashboard extends StatefulWidget {
  Dashboard({key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => DashboardState();
}

class DashboardState extends CleanArchitectureView<Dashboard, DashboardPresenter> with TickerProviderStateMixin implements DashboardDataView {

  DashboardState() : super(DashboardPresenter());

  GlobalKey<NavigatorState> homeNavigatorKey;
  GlobalKey<NavigatorState> accountNavigatorKey;
  GlobalKey<NavigatorState> profileNavigatorKey;
  GlobalKey<NavigatorState> moreNavigatorKey;

  TabController tabController;

  @override
  void init() {
    presenter.dataView = this;
  }

  @override
  void initState() {
    super.initState();

    tabController = TabController(length: 4, vsync: this);

    print("DASHBOARD ==> initState()");

    onResume();
  }

  @override
  Widget build(BuildContext context) {
    return PlainScaffold(
      body: TabBarView(
        physics: NeverScrollableScrollPhysics(),
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
      selectedItemColor: _generateSelectedColor(),
      unselectedItemColor: AppTheme.darkGrey.withOpacity(0.4),
      type: BottomNavigationBarType.fixed,),
    );
  }

  Color _generateSelectedColor() {
    switch(tabController.index) {
      case 0: return AppTheme.darkBlue;
      case 1: return AppTheme.pinkAccent;
      case 2: return Colors.orange;
      default: return AppTheme.teal;
    }
  }

  void onPaused() {
    presenter.pauseSubscription();
  }

  void onResume() {
    presenter.resumeSubscription();
  }
}