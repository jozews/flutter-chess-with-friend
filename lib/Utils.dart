
import 'package:flutter/material.dart';

typedef void OnPopCleanPageRoute();

class ScrollBehaviorClean extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}

class CleanPageRoute<T> extends MaterialPageRoute<T> {

  OnPopCleanPageRoute onPop;

  CleanPageRoute({this.onPop, @required WidgetBuilder builder, RouteSettings settings, bool maintainState = true, bool fullscreenDialog = false,}) : super(builder: builder, maintainState: maintainState, settings: settings, fullscreenDialog: fullscreenDialog);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return child;
  }

  @override
  bool didPop(T result) {
    if (onPop != null) {
      onPop();
    }
    return super.didPop(result);
  }

}