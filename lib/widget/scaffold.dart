import 'package:flutter/material.dart';
import 'package:my_wallet/style/app_theme.dart';
import 'my_wallet_app_bar.dart';

class GradientScaffold extends Scaffold {
  GradientScaffold({
    Key key,
    MyWalletAppBar appBar,
    Widget body,
    Widget floatingActionButton,
    FloatingActionButtonLocation floatingActionButtonLocation,
    FloatingActionButtonAnimator floatingActionButtonAnimator,
    List<Widget> persistentFooterButtons,
    Widget drawer,
    Widget endDrawer,
    Widget bottomNavigationBar,
    Widget bottomSheet,
    bool primary = true,
  }) : super(
      key: key,
      appBar: appBar,
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.bgGradient),
        child: body,
      ),
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      floatingActionButtonAnimator: floatingActionButtonAnimator,
      persistentFooterButtons: persistentFooterButtons,
      drawer: drawer,
      endDrawer: endDrawer,
      bottomNavigationBar: bottomNavigationBar,
      bottomSheet: bottomSheet,
      resizeToAvoidBottomPadding: true,
      primary: primary,);
}

class PlainScaffold extends Scaffold {
  PlainScaffold({
    Key key,
    MyWalletAppBar appBar,
    Widget body,
    Widget floatingActionButton,
    FloatingActionButtonLocation floatingActionButtonLocation,
    FloatingActionButtonAnimator floatingActionButtonAnimator,
    List<Widget> persistentFooterButtons,
    Widget drawer,
    Widget endDrawer,
    Widget bottomNavigationBar,
    Widget bottomSheet,
    bool primary = true,
    Color color,
    EdgeInsetsGeometry padding,
  }) : super(
      key: key,
      appBar: appBar,
      body: Container(
        color: color == null ? AppTheme.white : color,
        child: body,
        padding: padding,
      ),
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      floatingActionButtonAnimator: floatingActionButtonAnimator,
      persistentFooterButtons: persistentFooterButtons,
      drawer: drawer,
      endDrawer: endDrawer,
      bottomNavigationBar: bottomNavigationBar,
      bottomSheet: bottomSheet,
      resizeToAvoidBottomPadding: true,
      primary: primary);
}