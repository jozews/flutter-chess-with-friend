
import 'package:flutter/material.dart';

import 'Const.dart';


class WidgetHistory extends StatefulWidget {

  WidgetHistory({Key key}) : super(key: key);

  @override
  StateWidgetHistory createState() => StateWidgetHistory();
}


class StateWidgetHistory extends State<WidgetHistory> {

  get colorBackground1 => Colors.black.withAlpha((0.75 * 255).toInt());
  get colorPNGSelected => Colors.white54;

  double get heightScreen => (MediaQuery.of(context).size.height - MediaQuery.of(context).padding.vertical);
  double get widthScreen => (MediaQuery.of(context).size.width - MediaQuery.of(context).padding.horizontal);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Material(
      child: Container(
        child: SafeArea(
          left: true,
          bottom: true,
          child: Stack(
            children: <Widget>[
              ListView(
                children: [],
              ),
              widgetIconClose(),
            ],
          ),
        ),
        color: colorBackground1,
        height: heightScreen,
        width: widthScreen,
      ),
    );
  }

  Widget widgetIconClose() {
    return Align(
      alignment: Alignment.topLeft,
      child: GestureDetector(
        child: Container(
          child: Icon(
            Icons.close,
            color: Colors.white,
            size: Const.SIZE_ICON_MENU,
          ),
          padding: EdgeInsets.only(
              top: Const.INSET_ICON_MENU,
              left: Const.INSET_ICON_MENU
          ),
        ),
        onTap: () {
          onTapIconClose();
        },
      ),
    );
  }

  onTapIconClose() async {
    Navigator.pop(context);
  }
}