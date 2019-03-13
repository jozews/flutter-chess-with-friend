
import 'package:flutter/material.dart';

import 'Defaults.dart';
import 'Const.dart';


class WidgetSettings extends StatefulWidget {

  WidgetSettings({Key key}) : super(key: key);

  @override
  StateWidgetSettings createState() => StateWidgetSettings();
}


class StateWidgetSettings extends State<WidgetSettings> {

  MaterialAccentColor accentBoard;
  bool showsValidMoves;
  bool autoRotates;
  int indexNamePieces;

  get colorBackground1 => Colors.black.withAlpha((0.75 * 255).toInt());

  double get heightScreen => (MediaQuery.of(context).size.height - MediaQuery.of(context).padding.vertical);
  double get widthScreen => (MediaQuery.of(context).size.width - MediaQuery.of(context).padding.horizontal);

  @override
  void initState() {
    super.initState();
    setup();
  }

  setup() async {
    await getDefaults();
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
                children: widgetsShowValidMoves() + widgetsAutoRotates() + widgetsColors() + widgetsPieces(),
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
                  isSelected: accent == accentBoard ?? false,
                ),
                onTap: () {
                  setState(() {
                    accentBoard = accent;
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
                    isSelected: showsValidMoves ?? false
                ),
                onTap: () {
                  setState(() {
                    this.showsValidMoves = true;
                  });
                },
              ),
              GestureDetector(
                child: widgetSelectionSettings(
                    title: "no",
                    isSelected: !(showsValidMoves ?? true)
                ),
                onTap: () {
                  setState(() {
                    this.showsValidMoves = false;
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

  List<Widget> widgetsAutoRotates() {
    return [
      Center(
          child: widgetTitleSettings(
              "Auto rotates when not connected"
          )
      ),
      Center(
        child: Container(
          child: Wrap(
            children: <Widget>[
              GestureDetector(
                child: widgetSelectionSettings(
                    title: "yes",
                    isSelected: autoRotates ?? false
                ),
                onTap: () {
                  setState(() {
                    this.autoRotates = true;
                  });
                },
              ),
              GestureDetector(
                child: widgetSelectionSettings(
                    title: "no",
                    isSelected: !(autoRotates ?? true)
                ),
                onTap: () {
                  setState(() {
                    this.autoRotates = false;
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
                  isSelected: (Const.NAME_PIECES.indexOf(namePiece) == indexNamePieces) ?? false,
                ),
                onTap: () {
                  setState(() {
                    indexNamePieces = Const.NAME_PIECES.indexOf(namePiece);
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

  getDefaults() async {

    var showsValidMoves = await Defaults.getBool(Defaults.SHOWS_VALID_MOVES) ?? true;
    var indexAccent = await Defaults.getInt(Defaults.INDEX_ACCENT) ?? 0; //Random().nextInt(ACCENTS.length - 1);
    var indexNamePieces = await Defaults.getInt(Defaults.INDEX_NAME_PIECES) ?? 0;
    var autoRotates = await Defaults.getBool(Defaults.AUTO_ROTATES) ?? false;

    setState(() {
      this.showsValidMoves = showsValidMoves;
      accentBoard = Const.ACCENTS[indexAccent];
      this.indexNamePieces = indexNamePieces;
      this.autoRotates = autoRotates;
    });
  }

  setDefaults() async {
    await Defaults.setBool(Defaults.SHOWS_VALID_MOVES, showsValidMoves);
    await Defaults.setInt(Defaults.INDEX_ACCENT, Const.ACCENTS.indexOf(accentBoard));
    await Defaults.setInt(Defaults.INDEX_NAME_PIECES, indexNamePieces);
    await Defaults.setBool(Defaults.AUTO_ROTATES, autoRotates);
  }

  onTapIconClose() async {
    await setDefaults();
    Navigator.pop(context);
  }
}