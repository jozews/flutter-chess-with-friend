
import 'package:flutter/material.dart';

import 'Const.dart';
import 'History.dart';


typedef void CompletionWidgetHistory(GameHistory gameHistory);

class WidgetHistory extends StatefulWidget {

  final CompletionWidgetHistory completion;

  WidgetHistory({this.completion, Key key}) : super(key: key);

  @override
  StateWidgetHistory createState() => StateWidgetHistory(completion: completion);
}


class StateWidgetHistory extends State<WidgetHistory> {

  CompletionWidgetHistory completion;

  StateWidgetHistory({this.completion});

  List<GameHistory> games;

  get colorBackground1 => Colors.black.withAlpha((0.75 * 255).toInt());
  get colorPNGSelected => Colors.white54;

  double get heightScreen => (MediaQuery.of(context).size.height - MediaQuery.of(context).padding.vertical);
  double get heightItemMenu => heightScreen/8;

  double get widthScreen => (MediaQuery.of(context).size.width - MediaQuery.of(context).padding.horizontal);

  double get insetDivisor => Const.SIZE_ICON_MENU + Const.INSET_ICON_MENU;

  @override
  void initState() {
    super.initState();
    setupGames();
  }


  setupGames() async {
    var games = await History.getGames();
    games.sort((game1, game2) => game2.timestamp.compareTo(game1.timestamp));
    setState(() {
      this.games = games;
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
              games != null && games.isNotEmpty ? ListView(
                children: games.map<Widget>((game) => widgetGame(game)).toList(),
              ) : games != null && games.isEmpty ? Center(
                child: Text(
                  "No games yet",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: Const.SIZE_TITLE,
                      fontWeight: FontWeight.w400
                  ),

                ),
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


  Widget widgetGame(GameHistory game) {
    // TODO: SHOWS WHEN
    var nameWinner = game.isLightWinner ?? true ? game.nameLight ?? Const.STRING_LIGHT : game.nameDark ?? Const.STRING_DARK;
    var nameLoser = !(game.isLightWinner ?? true) ? game.nameLight ?? Const.STRING_LIGHT : game.nameDark ?? Const.STRING_DARK;
    var suffixVerb = nameWinner != Const.STRING_YOU ? "s" : "";
    var showsLoser = false;
    String title;
    switch (game.result) {
      case ResultGameHistory.checkmate:
        title = "$nameWinner win$suffixVerb by checkmate ${showsLoser ? "against $nameLoser" : ""}";
        break;
      case ResultGameHistory.resignation:
        title = "$nameWinner win$suffixVerb by resignation ${showsLoser ? "against $nameLoser" : ""}";
        break;
      case ResultGameHistory.timeOver:
        title = "$nameWinner win$suffixVerb by timeout ${showsLoser ? "against $nameLoser" : ""}";
        break;
      case ResultGameHistory.draw:
        title = "$nameWinner draw$suffixVerb by agreement ${showsLoser ? "against $nameLoser" : ""}";
        break;
      case ResultGameHistory.stalemate:
        title = "$nameWinner draw$suffixVerb by stalemate ${showsLoser ? "against $nameLoser" : ""}";
        break;
      case ResultGameHistory.insufficientMaterial:
        title = "$nameWinner draw$suffixVerb by insufficient material ${showsLoser ? "against $nameLoser" : ""}";
        break;
      case ResultGameHistory.abort:
        title = "game ended/aborted";
        break;
    }
    return GestureDetector(
      child: Container(
        child: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.center,
              child: Text(
                title,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: Const.SIZE_TITLE,
                    fontWeight: FontWeight.w400
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                color: Colors.white,
                height: Const.SIZE_DIVISOR,
                width: widthScreen - insetDivisor,
              ),
            ),
          ],
        ),
        height: heightItemMenu,
      ),
      onTap: () {
        onTapIconClose(game);
      },
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
          onTapIconClose(null);
        },
      ),
    );
  }


  onTapIconClose(GameHistory gameHistory) async {
    Navigator.pop(context);
    if (completion != null) {
      completion(gameHistory);
    }
  }
}