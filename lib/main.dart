import 'package:my_wallet/app_material.dart';

import 'package:my_wallet/ui/home2/presentation/view/home2_view.dart';
import 'package:my_wallet/widget/my_wallet_app_bar.dart';

import 'package:my_wallet/ui/dashboard/dashboard_view.dart';

import 'package:my_wallet/ui/user/login/presentation/view/login_selection_view.dart';
import 'package:my_wallet/ui/user/login/presentation/view/login_view.dart';
import 'package:my_wallet/ui/user/register/presentation/view/register_view.dart';
import 'package:my_wallet/ui/user/homeprofile/main/presentation/view/homeprofile_view.dart';
import 'package:my_wallet/ui/user/verify/presentation/view/verify_view.dart';

import 'package:my_wallet/ui/splash/presentation/view/splash_view.dart';

import 'package:flutter/services.dart';

void main() async {
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp
  ]);
  await SystemChrome.setEnabledSystemUIOverlays([]);

  runApp(MyApp());
}


class MyApp extends StatelessWidget {

  final GlobalKey<MyWalletState> homeKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    var app = MaterialApp(
      title: 'My Wallet',
      theme: AppTheme.appTheme,
      home: SplashView(), //hasUser && hasProfile ? MyWalletHome() : hasUser && !hasProfile ? HomeProfile() : Login(),
      debugShowCheckedModeBanner: false,
      showPerformanceOverlay: false,
      showSemanticsDebugger: false,
      onGenerateRoute: (settings) {
        return MaterialPageRoute(builder: (context) {
          switch (settings.name) {
            case routes.Login:
              return Login();
            case routes.LoginSelection:
              return LoginSelectionView();
            case routes.RequestValidation:
              return RequestValidation();
            case routes.ValidationProcessing:
              return RequestValidation(isProcessing: true,);
            case routes.MyHome:
              return Dashboard(key: homeKey);
            case routes.Register:
              return Register();
            case routes.HomeProfile:
              return HomeProfile();
            case routes.SplashView:
              return SplashView();
            default:
              return PlainScaffold(
                appBar: MyWalletAppBar(
                  title: "Coming Soon",
                ),
                body: Center(
                  child: Text("Unknown page ${settings.name}", style: Theme.of(context).textTheme.title.apply(color: AppTheme.darkBlue),),
                ),
              );
          }
        });
      },
    );

    WidgetsBinding.instance.addObserver(LifecycleEventHandler(app, homeKey));

    return app;
  }
}

class LifecycleEventHandler extends WidgetsBindingObserver {
  LifecycleEventHandler(this.app, this.homeKey);

  final MaterialApp app;
  final GlobalKey<MyWalletState> homeKey;

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.suspending:
        if(homeKey.currentContext != null) {
          homeKey.currentState.onPaused();
        }
        break;
      case AppLifecycleState.resumed:
        if(homeKey.currentContext != null) {
          homeKey.currentState.onResume();
        }
        break;
    }
  }
}
