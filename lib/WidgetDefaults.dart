
import 'package:flutter/material.dart';

import 'Defaults.dart';
import 'Const.dart';


class WidgetDefaults extends StatefulWidget {

  WidgetDefaults({Key key}) : super(key: key);

  @override
  StateWidgetDefaults createState() => StateWidgetDefaults();
}


class StateWidgetDefaults extends State<WidgetDefaults> {

  // DEFAULTS
  // ...
  var defaults = Defaults();
  bool didLoadDefaults = false;

  MaterialAccentColor get accentBoard => defaults.indexAccent != null ? Const.ACCENTS[defaults.indexAccent] : null;
  Color get colorBackground1 => Colors.black.withAlpha((0.75 * 255).toInt());

  double get heightScreen => (MediaQuery.of(context).size.height - MediaQuery.of(context).padding.vertical);
  double get widthScreen => (MediaQuery.of(context).size.width - MediaQuery.of(context).padding.horizontal);

  @override
  void initState() {
    super.initState();
    setup();
  }

  setup() async {
    await defaults.getBoard();
    setState(() {
      didLoadDefaults = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        child: SafeArea(
          left: true,
          bottom: true,
          child: Stack(
            children: <Widget>[
              didLoadDefaults ? ListView(
                children:
                      widgetsShowValidMoves()
                    + widgetsShowTagSquares()
                    + widgetsRotatesAutomatically()
                    + widgetsPromotesAutomatically()
                    + widgetsColors()
                    + widgetsPieces(),
              ) : Container(),
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

  List<Widget> widgetsShowValidMoves() {
    return [
      Center(
          child: widgetTitleSettings(
              "Show valid moves"
          )
      ),
      Center(
        child: Container(
          child: Wrap(
            children: <Widget>[
              GestureDetector(
                child: widgetSelectionSettings(
                    title: "yes",
                    isSelected: defaults.showsValidMoves
                ),
                onTap: () {
                  setState(() {
                    defaults.showsValidMoves = true;
                  });
                },
              ),
              GestureDetector(
                child: widgetSelectionSettings(
                    title: "no",
                    isSelected: !defaults.showsValidMoves
                ),
                onTap: () {
                  setState(() {
                    defaults.showsValidMoves = false;
                  });
                },
              ),
            ],
            spacing: 0,
          ),
          margin: EdgeInsets.only(
            top: Const.INSET_VERTICAL_SHORT_SETTINGS,
          ),
        ),
      ),
    ];
  }

  List<Widget> widgetsShowTagSquares() {
    return [
      Center(
          child: widgetTitleSettings(
              "Show square names"
          )
      ),
      Center(
        child: Container(
          child: Wrap(
            children: <Widget>[
              GestureDetector(
                child: widgetSelectionSettings(
                    title: "yes",
                    isSelected: defaults.showsTagSquares
                ),
                onTap: () {
                  setState(() {
                    defaults.showsTagSquares = true;
                  });
                },
              ),
              GestureDetector(
                child: widgetSelectionSettings(
                    title: "no",
                    isSelected: !defaults.showsTagSquares
                ),
                onTap: () {
                  setState(() {
                    defaults.showsTagSquares = false;
                  });
                },
              ),
            ],
            spacing: 0,
          ),
          margin: EdgeInsets.only(
            top: Const.INSET_VERTICAL_SHORT_SETTINGS,
          ),
        ),
      ),
    ];
  }

  List<Widget> widgetsRotatesAutomatically() {
    return [
      Center(
          child: widgetTitleSettings(
              "Auto rotate when not connected"
          )
      ),
      Center(
        child: Container(
          child: Wrap(
            children: <Widget>[
              GestureDetector(
                child: widgetSelectionSettings(
                    title: "yes",
                    isSelected: defaults.rotatesAutomatically
                ),
                onTap: () {
                  setState(() {
                    defaults.rotatesAutomatically = true;
                  });
                },
              ),
              GestureDetector(
                child: widgetSelectionSettings(
                    title: "no",
                    isSelected: !defaults.rotatesAutomatically
                ),
                onTap: () {
                  setState(() {
                    defaults.rotatesAutomatically = false;
                  });
                },
              ),
            ],
            spacing: 0,
          ),
          margin: EdgeInsets.only(
            top: Const.INSET_VERTICAL_SHORT_SETTINGS,
          ),
        ),
      ),
    ];
  }


  List<Widget> widgetsPromotesAutomatically() {
    return [
      Center(
          child: widgetTitleSettings(
              "Promote always to queen"
          )
      ),
      Center(
        child: Container(
          child: Wrap(
            children: <Widget>[
              GestureDetector(
                child: widgetSelectionSettings(
                    title: "yes",
                    isSelected: defaults.promotesAutomatically
                ),
                onTap: () {
                  setState(() {
                    defaults.promotesAutomatically = true;
                  });
                },
              ),
//              GestureDetector(
//                child: widgetSelectionSettings(
//                    title: "no",
//                    isSelected: !defaults.promotesAutomatically
//                ),
//                onTap: () {
//                  setState(() {
//                    defaults.promotesAutomatically = false;
//                  });
//                },
//              ),
            ],
            spacing: 0,
          ),
          margin: EdgeInsets.only(
            top: Const.INSET_VERTICAL_SHORT_SETTINGS,
          ),
        ),
      ),
    ];
  }


  List<Widget> widgetsColors() {
    return [
      Center(
          child: widgetTitleSettings(
              "Color"
          )
      ),
      Center(
        child: Container(
          child: Wrap(
            children: Const.ACCENTS.map<Widget>((accent) {
              return GestureDetector(
                child: widgetAccent(
                  accent,
                  isSelected: accent == accentBoard,
                ),
                onTap: () {
                  setState(() {
                    defaults.indexAccent = Const.ACCENTS.indexOf(accent);
                  });
                },
              );
            }).toList(),
            spacing: 4,
            runSpacing: 4,
          ),
          margin: EdgeInsets.only(
            top: Const.INSET_VERTICAL_SHORT_SETTINGS,
            left: Const.INSET_HORIZONTAL_SETTINGS,
            right: Const.INSET_HORIZONTAL_SETTINGS,
          ),
        ),
      )
    ];
  }


  List<Widget> widgetsPieces() {
    return <Widget>[
      Center(
          child: widgetTitleSettings(
              "Pieces"
          )
      ),
      Center(
        child: Container(
          child: Wrap(
            children: Const.NAME_PIECES.map<Widget>((namePiece) {
              return GestureDetector(
                child: widgetSetPiece(
                  namePiece,
                  isSelected: (Const.NAME_PIECES.indexOf(namePiece) == defaults.indexNamePieces),
                ),
                onTap: () {
                  setState(() {
                    defaults.indexNamePieces = Const.NAME_PIECES.indexOf(namePiece);
                  });
                },
              );
            }).toList(),
            spacing: 4,
            runSpacing: 4,
          ),
          margin: EdgeInsets.only(
              top: Const.INSET_VERTICAL_SHORT_SETTINGS,
              left: Const.INSET_HORIZONTAL_SETTINGS,
              right: Const.INSET_HORIZONTAL_SETTINGS,
              bottom: Const.INSET_VERTICAL_SHORT_SETTINGS
          ),
        ),
      )
    ];
  }

  Widget widgetTitleSettings(String title, {bool header = false}) {
    return Container(
      child: Text(
        title,
        style: TextStyle(
            color: Colors.white,
            fontSize: Const.SIZE_TITLE,
            fontWeight: FontWeight.w400
        ),
      ),
      margin: EdgeInsets.only(
          top: Const.INSET_VERTICAL_SETTINGS
      ),
    );
  }

  Widget widgetSelectionSettings({String title, bool isSelected}) {
    return Container(
      child: Text(
        title,
        style: TextStyle(
            color: Colors.white,
            fontSize: Const.SIZE_SUBTITLE
        ),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
            Radius.circular(
                Const.SIZE_SUBTITLE
            )
        ),
        color: isSelected ? Const.COLOR_SELECTED : Colors.transparent,
      ),
      padding: EdgeInsets.symmetric(
          horizontal: Const.INSET_HORIZONTAL_SELECTION,
          vertical: Const.INSET_VERTICAL_SELECTION
      ),
    );
  }

  Widget widgetAccent(MaterialAccentColor accent, {bool isSelected}) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
            color: isSelected ? Const.COLOR_SELECTED : Colors.transparent,
            width: Const.WIDTH_BORDER
        ),
        borderRadius: BorderRadius.all(
            Radius.circular(
                Const.RADIUS_SOFT
            ),
        ),
        color: accent.shade200,
      ),
      height: Const.SIZE_ACCENT,
      width: Const.SIZE_ACCENT,
    );
  }

  Widget widgetSetPiece(String namePiece, {bool isSelected}) {
    return Container(
      child: namePiece.isNotEmpty ? Image.asset(
          "sets/$namePiece/king-light.png"
      ) : Center(
        child: Text(
          "?",
          style: TextStyle(
              color: Colors.white,
              fontSize: Const.SIZE_PIECE_EMPTY
          ),
        ),
      ),
      decoration: BoxDecoration(
        border: Border.all(
            color: isSelected ? Const.COLOR_SELECTED : Colors.transparent,
            width: Const.WIDTH_BORDER
        ),
        borderRadius: BorderRadius.all(
            Radius.circular(
                Const.SIZE_PIECE/2
            )
        ),
      ),
      height: Const.SIZE_PIECE,
      width: Const.SIZE_PIECE,
    );
  }

  onTapIconClose() async {
    await defaults.setBoard();
    Navigator.pop(context);
  }
}