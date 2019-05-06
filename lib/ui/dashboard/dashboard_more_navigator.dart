import 'package:my_wallet/app_material.dart';

import 'package:my_wallet/ui/dashboard/no_transition_page_route.dart';

import 'package:my_wallet/resources.dart' as R;

import 'package:my_wallet/ui/user/detail/presentation/view/detail_view.dart';
import 'package:my_wallet/ui/about/presentation/view/about_view.dart';
import 'package:my_wallet/ui/user/logout/presentation/view/sign_out_view.dart';

class MoreNavigator extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  MoreNavigator(this.navigatorKey);

  final drawerListItems = [
    _DrawerTitle(R.menu.profile),
    _DrawerItem(R.menu.your_profile, routes.UserProfile),
    _DrawerTitle(R.menu.apps),
    _DrawerItem(R.menu.about_us, routes.AboutUs),
    _DrawerItem(R.menu.sign_out, routes.SignOut)
  ];

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (setting) => createRoute(context, setting.name),
      initialRoute: '/',
    );
  }

  MaterialPageRoute createRoute(BuildContext context, String name) {
    if (name == '/') {
      return NoTransitionPageRoute(
          builder: (context) => _createMoreListing(context)
      );
    }

    return MaterialPageRoute(
      builder: (context) {
        switch(name) {
          case routes.UserProfile: return UserDetail();
          case routes.AboutUs: return AboutUs();
          case routes.SignOut: return SignOut();
        }
      },
    );
  }

  Widget _createMoreListing(BuildContext context) {
    return Scaffold(
      body: ListView.separated(
          itemBuilder: (context, index) => drawerListItems[index].build(context),
          separatorBuilder: (context, index) => Divider(
            height: 1.0,
            color: AppTheme.darkBlue,
          ),
          itemCount: drawerListItems.length),
    );
  }
}

abstract class _DrawerData {
  final String name;

  _DrawerData(this.name);

  Widget build(BuildContext context);
}

class _DrawerTitle extends _DrawerData{

  _DrawerTitle(String name) : super(name);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.0),
      color: AppTheme.teal,
      child: Text(name, style: Theme.of(context).textTheme.title.apply(color: AppTheme.white),),
    );
  }
}

class _DrawerItem extends _DrawerData {
  final String routeName;

  _DrawerItem(String name, this.routeName) : super(name);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(name, style: Theme.of(context).textTheme.subtitle.apply(color: AppTheme.darkBlue)),
      onTap: () => Navigator.pushNamed(context, routeName),
    );
  }
}