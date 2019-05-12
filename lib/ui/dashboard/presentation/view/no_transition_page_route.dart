import 'package:flutter/material.dart';

class NoTransitionPageRoute extends MaterialPageRoute {
  NoTransitionPageRoute({@required WidgetBuilder builder}) : super(builder: builder);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    return FadeTransition(
      opacity: AlwaysStoppedAnimation<double>(1.0),
      child: child,
    );
  }
}