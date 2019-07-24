
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:device_info/device_info.dart';
//import 'package:simple_permissions/simple_permissions.dart';
//import 'package:nearby_connectivity/nearby_connectivity.dart';

import 'Square.dart';
import 'Move.dart';
import 'Piece.dart';
import 'Game.dart';
import 'TimerGame.dart';
import 'Defaults.dart';
import 'Const.dart';
import 'Utils.dart';
import 'Connection.dart';
import 'PayloadGame.dart';
import 'History.dart';

import 'WidgetHistory.dart';
import 'WidgetDefaults.dart';


enum TypeStateWidgetGame {
  setup, ongoing, ended, readonly
}

class WidgetGame extends StatefulWidget {
  WidgetGame({Key key}) : super(key: key);

  @override
  StateWidgetGame createState() => StateWidgetGame();
}


class StateWidgetGame extends State<WidgetGame> {

  static const MILLISECONDS_DELAY_NEW_GAME = 1000;
  static const MILLISECONDS_DELAY_GAME_ANIMATION = 1000; // wait a bit to make proper layout

  final scaffoldKey = GlobalKey<ScaffoldState>();

  // GAME
  // ...
  TypeGame typeGame = TypeGame.chess12;
  Game game;
  TimerGame timer;

  // BOARD
  // ...
  List<Map<Square, Piece>> positions;
  int indexPosition;
  Map<Piece, Offset> offsets;

  // BOARD INTERACTION
  // ...
  Piece piecePanning;

  // DECORATIONS
  // ..
  List<Square> squaresSelected;
  List<Square> squaresValid;
  Move moveLast;
  // NOTE: not implemented
  Square squareCheck;
  Move movePre;

  // TIME
  // ...
  ControlTimer controlTimer = ControlTimer.min5; // defaults blitz

  // CONNECTION
  Connection connection;
  AndroidDeviceInfo infoDeviceAndroid;

  // NOTATIONS
  // ...
  int indexFirstNotationLeft;
  int indexFirstNotationRight;
  int countColumnChildrenMax;

  // ALERT
  // ...
  String titleAlert;

  // TYPE STATE
  // ...
  TypeStateWidgetGame typeState;

  // MENU
  // ...
  List<Widget> widgetsMenu;
  var isMenuShowing = false;

  // ORIENTATION
  // ...
  var isOrientationLight = true;

  // DEFAULTS
  // ...
  Defaults defaults;

  // UTIL
  // ...
  // ...
  MaterialAccentColor get accentBoard => defaults.indexAccent != null ?Const.ACCENTS[defaults.indexAccent] : null;
  Color get colorBoardDark => accentBoard.shade200.withAlpha((0.8 * 255).toInt());
  Color get colorBoardLight => accentBoard.shade200.withAlpha((0.3 * 255).toInt());

  double get heightScreen => MediaQuery.of(context).size.height;
  double get heightScreenSafe => (heightScreen - padding.vertical);
  double get heightSquare => heightScreenSafe / 8;
  double get heightNotation => Const.SIZE_NOTATION + insetNotationInner*2;
  double get heightMenu => heightSquare;
  double get heightWidgetTime => heightSquare*2/3;

  double get widthScreen => MediaQuery.of(context).size.width;
  double get widthScreenSafe => (widthScreen - padding.horizontal);
  double get widthDark => widthScreenSafe - heightScreenSafe;
  double get widthSide => widthDark/2;
  double get widthWidgetTime => widthSide;
  double get widthAlert => heightSquare * 4.5;

  EdgeInsets get padding => MediaQuery.of(context).padding;

  double get insetIconMenu => (heightSquare - Const.SIZE_ICON_MENU)/2;
  double get insetTime => (heightSquare - Const.SIZE_TIME)/2;
  double get insetNameConnection => (heightSquare*2/3 - Const.SIZE_NAME_CONNECTION)/2;
  double get insetTitleAlert => heightSquare*1/3;
  double get insetActionAlert => heightSquare*1/3;
  double get insetNotationsStart => (isConnected ? heightSquare*3/2 : heightSquare) + (heightSquare - heightNotation)/2;
  double get insetNotationsEnd => heightSquare/2;
  double get insetNotationInner => heightSquare - Const.SIZE_NOTATION*2;

  double get sizePiece => heightSquare * 9/10;
  double get sizeDotSquareValid => heightSquare / 4;

  bool get isConnected => connection != null;
  bool get isGameSetup => typeState == TypeStateWidgetGame.setup;
  bool get isGameOngoing => typeState == TypeStateWidgetGame.ongoing;
  bool get isGameEnded => typeState == TypeStateWidgetGame.ended;
  bool get isLeftToMove => isOrientationLight && game.isLightToMove;
  bool get isLeftWhite => isOrientationLight;

  bool get isAlertShowing => titleAlert != null;
  String get keyScoreLocal => "${Defaults.SCORE_LOCAL}${connection.idDevice}";
  String get keyScoreRemote => "${Defaults.SCORE_REMOTE}${connection.idDevice}";

  bool get canMove => isGameOngoing || isGameSetup;
  bool get canPayloadGameSetControl => !isGameOngoing;
  bool get canPayloadGameNewGame => !isGameOngoing;
  bool get canPayloadGameResign => isGameOngoing;
  bool get canPayloadGameDraw => isGameOngoing;
  bool get canSelectNotations => !isGameOngoing;

  bool get showsMenuNewStandard => (typeState != TypeStateWidgetGame.ongoing && typeGame != TypeGame.standard) || typeState == TypeStateWidgetGame.ended;
  bool get showsMenuNewChess12 => (typeState != TypeStateWidgetGame.ongoing && typeGame != TypeGame.chess12) || typeState == TypeStateWidgetGame.ended;
  bool get showsMenuNewChess12Revolution => (typeState != TypeStateWidgetGame.ongoing && typeGame != TypeGame.chess12Revolution) || typeState == TypeStateWidgetGame.ended;
  bool get showsMenuEnd => !isConnected && typeState == TypeStateWidgetGame.ongoing;
  bool get showsMenuResign => isConnected && isGameOngoing;
  bool get showsMenuDraw => isConnected && isGameOngoing;
  bool get showsMenuTime => isGameSetup;
  bool get showsMenuHistory => !isConnected;
  bool get showsMenuAnimate => typeState == TypeStateWidgetGame.ended || typeState == TypeStateWidgetGame.readonly;
  bool get showsDim => isAlertShowing || isMenuShowing;
  bool get showsNewInAlert => true;

  Color get colorBackground1 => Colors.black.withAlpha((0.75 * 255).toInt());
  Color get colorBackground2 => Colors.white;
  Color get colorSelection => accentBoard.shade700.withAlpha((0.75 * 255).toInt());
  Color get colorSquareValid => accentBoard.shade400.withAlpha((0.95 * 255).toInt());
  Color get colorLastMove => colorSquareValid;
  Color get colorSquareCheck => Colors.red.withAlpha((0.75 * 255).toInt());
  Color get colorTagSquare => accentBoard.shade700;


  // STATE
  // ...
  // ...
  // ...
  @override
  void initState() {
    super.initState();
    setupGame();
//    setupConnection();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: Container(
        child: SafeArea(
            top: true,
            left: true,
            right: true,
            bottom: true,
            child: Stack(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    widgetSide(),
                    defaults.indexAccent != null ? widgetCenter() : Container(),
                    widgetSide(atLeft: false),
                  ],
                  mainAxisAlignment: MainAxisAlignment.center,
                ),
                showsDim ? widgetDim() : Container(),
                isMenuShowing ? widgetMenu() : Container(),
                isAlertShowing ? widgetAlert() : Container(),
                widgetIconMenu(),
              ],
            )
        ),
        color: colorBackground1,
        height: heightScreen,
        width: widthScreen,
      ),
    );
  }



  // WIDGETS
  // ...
  // ...
  // ...
  Widget widgetIconMenu() {
    return Align(
      alignment: Alignment.topLeft,
      child: GestureDetector(
        child: Container(
          child: Icon(
            !isMenuShowing ? Icons.menu : null,
            color: Colors.white,
            size: Const.SIZE_ICON_MENU,
          ),
          padding: EdgeInsets.only(
            top: insetIconMenu,
            left: insetIconMenu
          ),
        ),
        onTap: () {
          onTapIconMenu();
        },
      ),
    );
  }


  Widget widgetCenter() {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        child: ScrollConfiguration(
          behavior: ScrollBehaviorClean(),
          child: Stack(
            children: [ widgetBoard() ]
                + (squaresSelected ?? []).map<Widget>((square) {
                  return widgetSquareOverlay(square, isSelected: true);
                }).toList()
                + (moveLast != null ? [
                  widgetSquareOverlay(moveLast.square1, isLast: true), widgetSquareOverlay(moveLast.square2, isLast: true)
                ] : [])
                + (offsets != null ? offsets.entries.map<Widget>((entry) {
                        var piece = entry.key;
                        return widgetPiece(piece);
                      }).toList()
                    : [])
                + (defaults.showsValidMoves ? (squaresValid ?? []).map<Widget>((square) {
                  return widgetSquareValidOverlay(square);
                }).toList() : []),
          ),
        ),
      ),
    );
  }


  Widget widgetSide({bool atLeft = true}) {
    var name = "";
    var score = "";
    if (isConnected) {
      var isLocal = connection.isLocalLight == (atLeft == isLeftWhite);
      name = isLocal ? "You" : connection.nameEndpoint;
      var scoreValue = isLocal ? connection.scoreLocal : connection.scoreRemote;
      if (scoreValue != null) {
        if (scoreValue % 1.0 == 0.0) {
          score = scoreValue.toInt().toString();
        }
        else {
          score = scoreValue.toString();
        }
      }
    }
    return Expanded(
      child: Container(
        child: Stack(
          children: <Widget>[
            Align(
              alignment: atLeft ? Alignment.bottomCenter : Alignment.topCenter,
                child: Column(
                  children: <Widget>[
                    isConnected ? Container(
                      child: Text(
                        "$name - $score",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: Const.SIZE_NAME_CONNECTION,
                            fontWeight: FontWeight.w600
                        ),
                      ),
                      margin: EdgeInsets.only(
                        bottom: atLeft ? insetNameConnection : 0.0,
                        top: !atLeft ? insetNameConnection : 0.0,
                      ),
                    ) : Container(),
                    timer != null ? Container(
                      child: Text(
                        atLeft ? (isOrientationLight
                            ? getFormattedInterval(timer.timeLight)
                            : getFormattedInterval(timer.timeDark))
                            : (!isOrientationLight ? getFormattedInterval(timer.timeLight)
                            : getFormattedInterval(timer.timeDark)),
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: Const.SIZE_TIME,
                            fontWeight: FontWeight.w500
                        ),
                      ),
                      margin: EdgeInsets.only(
                        bottom: atLeft ? insetTime : 0.0,
                        top: !atLeft ? insetTime : 0.0,
                      ),
                    ) : Container(),
                  ],
                  verticalDirection: atLeft ? VerticalDirection.up : VerticalDirection.down,
                )
            ),
            game?.notations != null ? Align(
              alignment: atLeft ? Alignment.bottomCenter : Alignment.topCenter,
              child: Container(
                child: GestureDetector(
                    child: LayoutBuilder(
                        builder: (context, constraints) {
                          // set count notations
                          if (countColumnChildrenMax == null) {
                            countColumnChildrenMax = ((constraints.maxHeight - insetNotationsStart) / heightNotation).floor();
                          }
                          var countNotations = getCountNotationsAll(atLeft: atLeft);
                          var countNotationsMin = min(countColumnChildrenMax, countNotations);
                          return Column(
                            children: List.generate(countNotationsMin, (index) => widgetNotation(
                                index,
                                atLeft
                            )),
                            verticalDirection: atLeft ? VerticalDirection.up : VerticalDirection.down,
                          );
                        }),
                    onPanStart: (pan) {
                      var indexChildren = getIndexChildrenFromYPosition(pan.globalPosition.dy, atLeft: atLeft);
                      onPanStartSide(indexChildren: indexChildren, atLeft: atLeft);
                    },
                    onPanUpdate: (pan) {
                      var indexChildren = getIndexChildrenFromYPosition(pan.globalPosition.dy, atLeft: atLeft);
                      onPanUpdateSide(indexChildren: indexChildren, atLeft: atLeft);
                    },
                ),
                margin: EdgeInsets.only(
                  top: !atLeft ? insetNotationsStart : insetNotationsEnd,
                  bottom: atLeft ? insetNotationsStart : insetNotationsEnd,
                ),
              ),
            ) : Container()
          ],
        ),
      ),
    );
  }


  Widget widgetBoard() {
    return Container(
      child: GestureDetector(
          child: GridView.count(
            scrollDirection: Axis.horizontal,
            crossAxisCount: 8,
            children: List.generate(64, (index) {
              var column = index ~/ 8;
              var row = 7 - (index % 8);
              var square = Square(column + 1, row + 1);
              var tag = defaults.showsTagSquares ? getSquareTag(square) : null;
              var color = (index % 2) != (column % 2) ? colorBoardDark : colorBoardLight;
              return Container(
                color: color,
                child: tag != null ? Align(
                  alignment: Alignment.bottomLeft,
                  child: Container(
                    child: Text(
                      tag,
                      style: TextStyle(
                        color: colorTagSquare,
                        fontSize: Const.SIZE_TAG_SQUARE,
                        fontWeight: FontWeight.w400
                      ),
                    ),
                    padding: EdgeInsets.only(
                      left: Const.INSET_TAG_SQUARE,
                      bottom: Const.INSET_TAG_SQUARE
                    ),
                  ),
                ) : Container(),
              );
            }),
          ),
          onTapDown: (tap) {
            onTapDownBoard(tap);
          },
          onTapUp: (tap) {
            onTapUpBoard(tap);
          },
          onPanStart: (pan) {
            onPanStartBoard(pan);
          },
          onPanUpdate: (pan) {
            onPanUpdateBoard(pan);
          },
          onPanEnd: (pan) {
            onPanEndBoard(pan);
          }
      ),
      color: Colors.white,
    );
  }


  Widget widgetPiece(Piece piece) {
    var nameTypePiece = piece.type.toString().replaceFirst("TypePiece.", "");
    var nameIsLight = piece.isLight ? "light" : "dark";
    var namePiece = "$nameTypePiece-$nameIsLight";
    var nameSet = Const.NAME_PIECES[defaults.indexNamePieces];
    var offsetCorrection = (heightSquare - sizePiece)/2;
    return Positioned(
      left: offsets[piece].dx + offsetCorrection,
      top: offsets[piece].dy + offsetCorrection,
      child: IgnorePointer(
        child: Container(
          child: nameSet.isNotEmpty ? Image.asset(
              "sets/$nameSet/$namePiece.png"
          ) : Container(),
          height: sizePiece,
          width: sizePiece,
        ),
      ),
    );
  }


  Widget widgetSquareOverlay(Square square, {bool isSelected = false, bool isLast = false}) {
    var offset = offsetFromSquare(square);
    return Positioned(
      left: offset.dx,
      top: offset.dy,
      child: IgnorePointer(
        child: Container(
          color: isSelected ? colorSelection : colorSelection,
          height: heightSquare * 1,
          width: heightSquare * 1,
        ),
      ),
    );
  }


  Widget widgetSquareValidOverlay(Square square) {
    var offset = offsetFromSquare(square);
    var offsetCorrection = (heightSquare - sizeDotSquareValid)/2;
    return Positioned(
      left: offset.dx + offsetCorrection,
      top: offset.dy + offsetCorrection,
      child: ClipOval(
          child: IgnorePointer(
            child: Container(
              color: colorSquareValid,
              height: sizeDotSquareValid,
              width: sizeDotSquareValid,
            ),
          ),
      ),
    );
  }


  Widget widgetNotation(int index, bool atLeft) {
    var indexNotation = getIndexNotationFromIndexChildren(index, atLeft: atLeft);
    var indexPosition = getIndexPositionFromIndexChildren(index, atLeft: atLeft);
    var notation = game.notations[indexNotation];
    var isSelected = indexPosition == this.indexPosition;
    return Center(
      child: Container(
        child: Text(
          notation,
          style: TextStyle(
            color: Colors.white,
            fontSize: Const.SIZE_NOTATION,
            fontWeight: FontWeight.normal,
          ),
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(
              Radius.circular(
                  Const.RADIUS_SOFT
              )
          ),
          color: isSelected ? Const.COLOR_SELECTED : Colors.transparent,
        ),
        margin: EdgeInsets.all(
            insetNotationInner/2
        ),
        padding: EdgeInsets.all(
            insetNotationInner/2
        ),
      ),
    );
  }


  Widget widgetMenu() {
    return Container(
      child: Container(
        child: ListView(
          children: widgetsMenu,
        ),
        color: colorBackground1,
        height: heightScreenSafe,
        width: widthSide,
      ),
      color: colorBackground2,
      height: heightScreenSafe,
      width: widthSide,
    );
  }


  List<Widget> widgetsMenuEntry() {
    return [
      showsMenuNewStandard ? GestureDetector(
        child: widgetItemMenu(
            title: "new classic"
        ),
        onTap: () {
          onTapMenuNew(TypeGame.standard);
        },
      ) : Container(),
      showsMenuNewChess12 ? GestureDetector(
        child: widgetItemMenu(
            title: "new chess12"
        ),
        onTap: () {
          onTapMenuNew(TypeGame.chess12);
        },
      ) : Container(),
      showsMenuNewChess12Revolution ? GestureDetector(
        child: widgetItemMenu(
            title: "new chess12 revolution"
        ),
        onTap: () {
          onTapMenuNew(TypeGame.chess12Revolution);
        },
      ) : Container(),
      showsMenuEnd ? GestureDetector(
        child: widgetItemMenu(
            title: "end"
        ),
        onTap: () {
          onTapMenuEnd();
        },
      ) : Container(),
      showsMenuResign ? GestureDetector(
        child: widgetItemMenu(
            title: "resign"
        ),
        onTap: () {
          onTapMenuResign();
        },
      ) : Container(),
      showsMenuDraw ? GestureDetector(
        child: widgetItemMenu(
            title: "draw"
        ),
        onTap: () {
          onTapMenuDraw();
        },
      ) : Container(),
      GestureDetector(
        child: widgetItemMenu(
            title: "flip"
        ),
        onTap: () {
          onTapMenuOrientation();
        },
      ),
      showsMenuAnimate ? GestureDetector(
        child: widgetItemMenu(
            title: "animate"
        ),
        onTap: () {
          onTapMenuAnimate();
        },
      ) : Container(),
      showsMenuTime ? GestureDetector(
        child: widgetItemMenu(
            title: "time"
        ),
        onTap: () {
          onTapMenuTime();
        },
      ) : Container(),
      GestureDetector(
        child: widgetItemMenu(
            title: "board"
        ),
        onTap: () {
          onTapMenuBoard();
        },
      ),
      showsMenuHistory ? GestureDetector(
        child: widgetItemMenu(
            title: "history"
        ),
        onTap: () {
          onTapMenuHistory();
        },
      ) : Container(),
    ];
  }


  List<Widget> widgetsMenuTime() {
    var widgets = <Widget>[
      GestureDetector(
        child: widgetItemMenu(
            title: "back"
        ),
        onTap: () {
          onTapMenuTimeBack();
        },
      )
    ];
    var widgetsControls = ControlTimer.values.map<Widget>((control) {
      String title;
      switch (control) {
        case ControlTimer.min1:
          title = "1 min";
          break;
        case ControlTimer.min1plus1:
          title = "1 min and 1 bonus";
          break;
        case ControlTimer.min3:
          title = "3 min";
          break;
        case ControlTimer.min3plus2:
          title = "3 min and 2 bonus";
          break;
        case ControlTimer.min5:
          title = "5 min";
          break;
        case ControlTimer.min5plus2:
          title = "5 min and 2 bonus";
          break;
        case ControlTimer.min10:
          title = "10 min";
          break;
        case ControlTimer.min15:
          title = "15 min";
          break;
      }
      return GestureDetector(
        child: widgetItemMenu(
            title: title
        ),
        onTap: () {
          onTapMenuTimeControl(control);
        },
      );
    }).toList();
    widgets.addAll(widgetsControls);
    return widgets;
  }


  Widget widgetItemMenu({String title}) {
    return Container(
      child: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.center,
            child: Text(
              title,
              textAlign: TextAlign.center,
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
              width: widthSide - Const.INSET_DIVISOR_ITEM_MENU,
            ),
          ),
        ],
      ),
      height: heightMenu,
    );
  }


  Widget widgetAlert() {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.all(
            Radius.circular(
                Const.RADIUS_SOFT
            )
        ),
        child: Container(
          child: Container(
            child: Column(
              children: <Widget>[
                Container(
                  child: Text(
                    titleAlert,
                    style: TextStyle(
                        color: Colors.white
                    ),
                    textAlign: TextAlign.center,
                  ),
                  padding: EdgeInsets.all(
                    insetTitleAlert,
                  ),
                ),
                showsNewInAlert ? Flexible(
                  child: Container(
                    color: Colors.white,
                    height: Const.SIZE_DIVISOR,
                  ),
                ) : Container(),
                IntrinsicHeight(
                  child: Row(
                    children: <Widget>[
                      GestureDetector(
                        child: Center(
                          child: Container(
                            child: Text(
                              "new",
                              style: TextStyle(
                                  color: Colors.white
                              ),
                              textAlign: TextAlign.center,
                            ),
                            width: (widthAlert - Const.SIZE_DIVISOR)/2,
                            padding: EdgeInsets.all(
                              insetActionAlert,
                            ),
                          ),
                        ),
                        onTap: () {
                          newGame();
                          setState(() {
                            titleAlert = null;
                          });
                        },
                      ),
                      Expanded(
                        child: Container(
                          color: Colors.white,
                          width: Const.SIZE_DIVISOR,
                        ),
                      ),
                      GestureDetector(
                        child: Center(
                          child: Container(
                            child: Text(
                              "new chess12",
                              style: TextStyle(
                                  color: Colors.white
                              ),
                              textAlign: TextAlign.center,
                            ),
                            width: (widthAlert - Const.SIZE_DIVISOR)/2,
                            padding: EdgeInsets.all(
                              insetActionAlert,
                            ),
                          ),
                        ),
                        onTap: () {
                          newGame(type: TypeGame.chess12);
                          setState(() {
                            titleAlert = null;
                          });
                        },
                      )
                    ],
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                  ),
                ),
              ],
              mainAxisSize: MainAxisSize.min,
            ),
            color: colorBackground1,
            width: widthAlert,
          ),
          color: colorBackground2,
        ),
      ),
    );
  }


  Widget widgetDim() {
    return GestureDetector(
      child: Container(
        color: Colors.black54,
      ),
      onTap: () {
        onTapDim();
      },
    );
  }


  Widget widgetConnection() {
    return Text(
        "You are now connected with ${connection.nameEndpoint}\n"
            "Make a move to start the game",
        textAlign: TextAlign.center
    );
  }


  Widget widgetDrawSent() {
    return Text(
        "Draw offer sent",
        textAlign: TextAlign.center
    );
  }


  Widget widgetDrawOffered() {
    return Wrap(
      children: <Widget>[
        Text(
          "${connection.nameEndpoint} has offered a draw",
          style: TextStyle(
              color: Colors.white
          ),
        ),
        GestureDetector(
          child: Text(
            "Accept",
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500
            ),
          ),
          onTap: () {
            drawGame();
            scaffoldKey.currentState.hideCurrentSnackBar();
          },
        ),
        GestureDetector(
          child: Text(
            "Ignore",
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500
            ),
          ),
          onTap: () {
            scaffoldKey.currentState.hideCurrentSnackBar();
          },
        )
      ],
      spacing: 5.0,
      alignment: WrapAlignment.center,
    );
  }

  Widget widgetDrawAgreed() {
    return Text(
        "Game drawn by agreement",
        textAlign: TextAlign.center
    );
  }

  Widget widgetConnectionLost({bool isAbort = false}) {
    return Text(
        "Connection lost",
//        "Connection lost" + (isAbort ? ". Game aborted." : ""),
        textAlign: TextAlign.center
    );
  }



  // ACTIONS
  // ...
  // ...
  // ...
  onTapDownBoard(TapDownDetails tap) {
    var isLastPosition = indexPosition == positions.length - 1;
    if (!isLastPosition || !canMove) {
      return;
    }
    var offset = offsetFromGlobalPosition(tap.globalPosition);
    var square = squareFromOffset(offset);
    var piece = positions.last[square];
    if (squaresSelected.isEmpty && piece != null) {
      var squaresValid = List<Square>();
      if (!isConnected || connection.isLocalLight == game.isLightToMove) {
        squaresValid = game.getValidMoves(square).map((move) => move.square2).toList();
      }
      setState(() {
        squaresSelected = [square];
        this.squaresValid = squaresValid;
      });
    }
    else if (squaresSelected.isNotEmpty) {
      var isSquareValid = squaresValid.contains(square);
      if (isSquareValid) {
        setState(() {
          squaresSelected.add(square);
        });
      }
      else if (piece != null) {
        var squaresValid = List<Square>();
        if (!isConnected || connection.isLocalLight == game.isLightToMove) {
          squaresValid = game.getValidMoves(square).map((move) => move.square2).toList();
        }
        setState(() {
          squaresSelected = [square];
          this.squaresValid = squaresValid;
        });
      }
      else {
        setState(() {
          squaresSelected = [];
          squaresValid = [];
        });
      }
    }
  }


  onTapUpBoard(TapUpDetails tap) {
    var isLastPosition = indexPosition == positions.length - 1;
    if (!isLastPosition || !canMove) {
      return;
    }
    if (squaresSelected.length == 2) {
      var move = Move(squaresSelected.first, squaresSelected.last);
      var _ = moveGame(move);
      if (_ != null) {
        setState(() {
          squaresSelected = [];
          squaresValid = [];
        });
      }
    }
  }


  onPanStartBoard(DragStartDetails pan) {
    var isLastPosition = indexPosition == positions.length - 1;
    if (!isLastPosition || !canMove) {
      return;
    }
    var offset = offsetFromGlobalPosition(pan.globalPosition);
    var square = squareFromOffset(offset);
    var piece = positions.last[square];
    if (piece != null) {
      var squaresValid = List<Square>();
      if (!isConnected || connection.isLocalLight == game.isLightToMove) {
        squaresValid = game.getValidMoves(square).map((move) => move.square2).toList();
      }
      piecePanning = positions.last[square];
      var offsetCentered = Offset(offset.dx - heightSquare/2, offset.dy - heightSquare/2);
      setState(() {
        squaresSelected = [square];
        offsets[piecePanning] = offsetCentered;
        this.squaresValid = squaresValid;
      });
    }
    else if (squaresSelected.isNotEmpty && squaresSelected.last != square) {
      setState(() {
        squaresSelected = [squaresSelected.first, square];
      });
    }
  }


  onPanUpdateBoard(DragUpdateDetails pan) {
    var isLastPosition = indexPosition == positions.length - 1;
    if (!isLastPosition || !canMove) {
      return;
    }
    var offset = offsetFromGlobalPosition(pan.globalPosition);
    var square = squareFromOffset(offset);
    if (piecePanning != null) {
      var offset = offsets[piecePanning];
      var offsetUpdated = Offset(offset.dx + pan.delta.dx, offset.dy + pan.delta.dy);
      var squaresSelected = List<Square>.from(this.squaresSelected);
      if (squaresValid.contains(square) && squaresSelected.last != square) {
        squaresSelected = [squaresSelected.first, square];
      }
      else if (!squaresValid.contains(square)) {
        squaresSelected = [squaresSelected.first];
      }
      setState(() {
        offsets[piecePanning] = offsetUpdated;
        this.squaresSelected = squaresSelected;
      });
    }
    else if (squaresSelected.isNotEmpty && squaresSelected.last != square) {
      if (squaresValid.contains(square)) {
        setState(() {
          squaresSelected = [squaresSelected.first, square];
        });
      }
      else {
        setState(() {
          squaresSelected = [squaresSelected.first];
        });
      }
    }
  }


  onPanEndBoard(DragEndDetails pan) {
    var isLastPosition = indexPosition == positions.length - 1;
    if (!isLastPosition || !canMove) {
      return;
    }
    if (squaresSelected.isNotEmpty && piecePanning != null) {
      var offset = offsets[piecePanning];
      var offsetCentered = Offset(offset.dx + heightSquare/2, offset.dy + heightSquare/2);
      var square2 = squareFromOffset(offsetCentered);
      var move = Move(squaresSelected.first, square2);
      var _ = moveGame(move);
      if (_ != null) {
        setState(() {
          squaresSelected = [];
          squaresValid = [];
        });
      }
      piecePanning = null;
    }
    else if (squaresSelected.length == 2) {
      var move = Move(squaresSelected.first, squaresSelected.last);
      var _ = moveGame(move);
      if (_ != null) {
        setState(() {
          squaresSelected = [];
          squaresValid = [];
        });
      }
    }
  }


  onPanStartSide({int indexChildren, bool atLeft}) {
    if (!canSelectNotations) {
      return;
    }
    var indexPosition = getIndexPositionFromIndexChildren(indexChildren, atLeft: atLeft);
    selectPosition(index: indexPosition);
  }


  onPanUpdateSide({int indexChildren, bool atLeft}) {
    if (!canSelectNotations) {
      return;
    }
    var indexPosition = getIndexPositionFromIndexChildren(indexChildren, atLeft: atLeft);
    selectPosition(index: indexPosition);
  }


  onTapDim() {
    setState(() {
      if (isAlertShowing) {
        titleAlert = null;
      }
      else if (isMenuShowing) {
        isMenuShowing = false;
      }
    });
  }


  onTapIconMenu() {
    var widgetsMenu = widgetsMenuEntry();
    setState(() {
      this.widgetsMenu = widgetsMenu;
      isMenuShowing = true;
    });
  }

  onTapMenuNew(TypeGame type) {
    newGame(type: type);
    setState(() {
      isMenuShowing = false;
    });
  }

  onTapMenuEnd() {
    endGame(isAbort: true);
    setState(() {
      isMenuShowing = false;
    });
  }


  onTapMenuResign() {
    setState(() {
      isMenuShowing = false;
    });
    resignGame();
  }


  onTapMenuDraw() {
    setState(() {
      isMenuShowing = false;
    });
    drawGame();
  }

  
  onTapMenuAnimate() {
    animateGame(millisecondsDelay: MILLISECONDS_DELAY_GAME_ANIMATION);
    setState(() {
      isMenuShowing = false;
    });
  }


  onTapMenuOrientation() {
    isOrientationLight = !isOrientationLight;
    setOffsetsOfPosition();
    setState(() {
      isMenuShowing = false;
    });
  }
  

  onTapMenuTime() {
    var widgetsMenu = widgetsMenuTime();
    setState(() {
      this.widgetsMenu = widgetsMenu;
    });
  }


  onTapMenuHistory() {
    pushHistory();
    setState(() {
      isMenuShowing = false;
    });
  }


  onTapMenuBoard() async {
    await pushBoard();
    setState(() {
      isMenuShowing = false;
    });
  }


  onTapMenuTimeBack() {
    var widgetsMenu = widgetsMenuEntry();
    setState(() {
      this.widgetsMenu = widgetsMenu;
    });
  }

  onTapMenuTimeControl(ControlTimer controlTimer) {
    this.controlTimer = controlTimer;
    setState(() {
      this.timer = TimerGame.control(this.controlTimer);
      isMenuShowing = false;
    });
    if (isConnected) {
      var payloadControl = PayloadGame.setControl(timer.control);
//      sendPayload(payloadControl);
    }
  }



  // CONNECTION
  // ...
  // ...
  // ...
//  setupConnection() async {
//    await Future.delayed(Duration(seconds: 5));
//    await SimplePermissions.requestPermission(Permission.AccessCoarseLocation);
//    infoDeviceAndroid = await DeviceInfoPlugin().androidInfo;
//    startAdvertising();
//    await Future.delayed(Duration(seconds: 5));
//    startDiscovering();
//  }
//
//
//  startAdvertising() async {
//    NearbyConnectivity.startAdvertising(name: infoDeviceAndroid.model, idService: Const.ID_SERVICE).listen((advertise) {
//      switch (advertise.type) {
//        case TypeLifecycle.initiated:
//          acceptConnection(advertise);
//          connect(idEndpoint: advertise.idEndpoint, nameEndpoint: advertise.nameEndpoint, isDiscoverer: false);
//          break;
//        case TypeLifecycle.result:
//          break;
//        case TypeLifecycle.disconnected:
//          disconnect();
//          break;
//      }
//    });
//  }
//
//
//  startDiscovering() {
//    NearbyConnectivity.startDiscovering(idService: Const.ID_SERVICE).listen((discovery) {
//      switch (discovery.type) {
//        case TypeDiscovery.found:
//          if (isConnected) {
//            return;
//          }
//          requestConnection(discovery);
//          break;
//        case TypeDiscovery.lost:
//          break;
//      }
//    });
//  }
//
//
//  requestConnection(Discovery discovery) {
//    NearbyConnectivity.requestConnection(idEndpoint: discovery.idEndpoint).listen((lifecycle) {
//      switch (lifecycle.type) {
//        case TypeLifecycle.initiated:
//          acceptConnection(lifecycle, isDiscoverer: true);
//          connect(idEndpoint: lifecycle.idEndpoint, nameEndpoint: lifecycle.nameEndpoint, isDiscoverer: true);
//          break;
//        case TypeLifecycle.result:
//          break;
//        case TypeLifecycle.disconnected:
//          disconnect();
//          break;
//      }
//    });
//  }
//
//
//  acceptConnection(Lifecycle advertise, {bool isDiscoverer = false}) {
//    NearbyConnectivity.acceptConnection(idEndpoint: advertise.idEndpoint).listen((payload) {
//      switch (payload.type) {
//        case TypePayload.received:
//          handlePayload(payload);
//          break;
//        case TypePayload.transferred:
//          break;
//      }
//    });
//  }
//
//
//  connect({String idEndpoint, String nameEndpoint, bool isDiscoverer}) async {
//
//    await Future.delayed(Duration(seconds: 5)); // wait for accept handshake to complete
//
//    this.connection = Connection(idEndpoint, nameEndpoint);
//
//    var payloadIdDevice = PayloadGame.setIdDevice(infoDeviceAndroid.androidId);
//    sendPayload(payloadIdDevice);
//
//    if (isDiscoverer) {
//      // TODO: MERGE CALLS?
//      await Future.delayed(Duration(seconds: 10));
//      var payloadControl = PayloadGame.setControl(timer.control);
//      sendPayload(payloadControl);
//    }
//
//    setState(() {
//      connection = connection;
//      connection.isLocalLight = isDiscoverer ? true : true; // both devices start as white
//    });
//
//    newGame();
//
//    showSnackBar(
//        widgetConnection()
//    );
//  }
//
//
//  disconnect() {
//
//    if (isGameOngoing) {
//      endGame(isAbort: true);
//    }
//
//    showSnackBar(
//        widgetConnectionLost(isAbort: isGameOngoing)
//    );
//
//    setState(() {
//      this.connection = null;
//    });
//  }
//
//
//  sendPayload(PayloadGame payload) {
//    var bytesPayload = payload.toBytes();
//    NearbyConnectivity.sendPayloadBytes(idEndpoint: connection.idEndpoint, bytes: bytesPayload);
//  }
//
//
//  handlePayload(Payload payload) {
//    var payloadGame = PayloadGame.fromBytes(payload.bytes);
//    switch (payloadGame.type) {
//      case TypePayloadGame.setIdDevice:
//        connection.idDevice = payloadGame.idDevice;
//        getScore();
//        break;
//      case TypePayloadGame.setControl:
//        if (canPayloadGameSetControl) {
//          setState(() {
//            controlTimer = payloadGame.control;
//            timer = TimerGame.control(controlTimer);
//          });
//        }
//        break;
//      case TypePayloadGame.newGame:
//        if (canPayloadGameNewGame) {
//          newGame(payload: payloadGame);
//        }
//        break;
//      case TypePayloadGame.startMove:
//        timer.addTimestampStart(timestamp: payloadGame.timestampStart);
//        break;
//      case TypePayloadGame.endMove:
//        moveGame(payloadGame.move, payload: payloadGame);
//        break;
//      case TypePayloadGame.endTime:
//        endGame(isTimeLightOver: !connection.isLocalLight);
//        break;
//      case TypePayloadGame.resign:
//        if (canPayloadGameResign) {
//          resignGame(payload: payloadGame);
//        }
//        break;
//      case TypePayloadGame.draw:
//        if (canPayloadGameDraw) {
//          drawGame(payload: payloadGame);
//        }
//        break;
//    }
//  }
//
//
//  getScore() async {
//    var scoreLocal = await Defaults.getDouble(keyScoreLocal) ?? 0.0;
//    var scoreRemote = await Defaults.getDouble(keyScoreRemote) ?? 0.0;
//    setState(() {
//      connection.scoreLocal = scoreLocal;
//      connection.scoreRemote = scoreRemote;
//    });
//  }
//
//
//  setScore({double scoreLocal, double scoreRemote}) async {
//    if (scoreLocal != null) {
//      await Defaults.setDouble(keyScoreLocal, scoreLocal);
//    }
//    if (scoreRemote != null) {
//      await Defaults.setDouble(keyScoreRemote, scoreRemote);
//    }
//    setState(() {
//      connection.scoreLocal = scoreLocal;
//      connection.scoreRemote = scoreRemote;
//    });
//  }



  // GAME
  // ...
  // ...
  // ...
  setupGame() async {
    defaults = Defaults();
    await defaults.getBoard();
    setState(() {
      defaults = defaults;
    });
    await Future.delayed(Duration(milliseconds: MILLISECONDS_DELAY_NEW_GAME));
    newGame(type: typeGame);
  }


  // TODO: HANDLE TYPE
  newGame({PayloadGame payload, TypeGame type = TypeGame.standard}) async {

    var isLocal = payload == null;
    typeGame = payload?.type ?? type;

    if (isConnected && isLocal) {
      var payloadNew = PayloadGame.newGame(typeGame);
//      sendPayload(payloadNew);
    }

    game = Game.type(typeGame);
    timer = TimerGame.control(controlTimer);

    positions = [game.board];
    setOffsetsOfPosition();

    setState(() {
      typeState = TypeStateWidgetGame.setup;
      squaresSelected = [];
      squaresValid = [];
      indexFirstNotationLeft = 0;
      indexFirstNotationRight = 0;
      timer.timeTotal = timer.timeTotal;
      timer.timeTotal = timer.timeTotal;
//      titleAlert = null;
    });
  }


  createGameFromHistory(GameHistory gameHistory) {

    game = Game.type(gameHistory.type);
    timer = TimerGame(timeTotal: gameHistory.moves.first.time);
    positions = [];

    gameHistory.moves.forEach((moveGameHistory) {
      var position = Map<Square, Piece>.from(game.board);
      positions.add(position);
      var move = game.getMoveFromNotation(moveGameHistory.notation);
      game.makeMove(move, shouldValidate: false);
    });

    // add last position
    var position = Map<Square, Piece>.from(game.board);
    positions.add(position);

    setOffsetsOfPosition(index: 0);

    timer.moves = gameHistory.moves.map<MoveTimer>((move) => MoveTimer(move.time)).toList();

    setState(() {
      squaresSelected = [];
      squaresValid = [];
      indexFirstNotationLeft = 0;
      indexFirstNotationRight = 0;
      typeState = TypeStateWidgetGame.readonly;
    });
  }


  startGame({PayloadGame payload}) {

    setState(() {
      typeState = TypeStateWidgetGame.ongoing;
      if (isConnected) {
        var isLocal = payload == null;
        connection.isLocalLight = isLocal ? true : false;
        isOrientationLight = connection.isLocalLight;
      }
    });

    timer.start().listen((time) {
      listenTimer();
    });
  }


  listenTimer() {

    setState(() {
      timer.timeLight = max(0.0, timer.timeLight);
      timer.timeDark = max(0.0, timer.timeDark);
    });

    var isTimeLightOver = timer.timeLight == 0.0 ? true
        : timer.timeDark == 0.0 ? false
        : null;

    if (isTimeLightOver != null) {
      if (isConnected && connection.isLocalLight == isTimeLightOver) {
        var payloadEnd = PayloadGame.endTime();
//        sendPayload(payloadEnd);
      }
      if (!isConnected || connection.isLocalLight == isTimeLightOver) {
        endGame(isTimeLightOver: isTimeLightOver);
      }
    }
  }


  bool moveGame(Move move, {PayloadGame payload}) {

    var isLocal = payload == null;

    if (isConnected && isLocal && connection.isLocalLight != game.isLightToMove) {
      setOffsetsOfPosition();
      return false;
    }

    var wasPositionLastShowing = indexPosition == positions.length - 1;

    var isValid = game.makeMove(move);

    if (isValid) {

      if (!isGameOngoing) {
        startGame(payload: payload);
      }

      var timestampNow = TimerGame.timestampNow;

      timer.addTimestampEnd(timestamp: payload?.timestampEnd ?? timestampNow);

      if (isConnected && isLocal) {
        var payloadEnd = PayloadGame.endMove(move, timestampNow);
//        sendPayload(payloadEnd);
      }

      // start move
      if (!isConnected || !isLocal) {
        timer.addTimestampStart(timestamp: timestampNow);
        if (isConnected) {
          var payloadStart = PayloadGame.startMove(timestampNow);
//          sendPayload(payloadStart);
        }
      }

      if (isConnected) {
        connection.didLocalDraw = null;
        connection.didRemoteDraw = null;
      }

      var wasLeftMove = !isLeftToMove;
      var indexFirstAtSide = getIndexFirstNotation(atLeft: wasLeftMove);

      setState(() {
        autoRotateIfNeeded();
        game.notations = game.notations;
        var countCodesAll = getCountNotationsAll(atLeft: wasLeftMove);
        if (indexFirstAtSide + countColumnChildrenMax < countCodesAll) {
          setIndexFirstNotation(indexFirstAtSide + 1, atLeft: wasLeftMove);
        }
      });

      var position = Map<Square, Piece>.from(game.board);
      positions.add(position);

      if (game.state != StateGame.ongoing) {
        endGame();
      }
    }

    var indexPositionNew = wasPositionLastShowing ? positions.length - 1 : indexPosition;
    if (wasPositionLastShowing) {
      setOffsetsOfPosition(index: indexPositionNew);
    }

    return isValid;
  }


  resignGame({PayloadGame payload}) {
    var isLocal = payload == null;
    if (isLocal) {
      var payloadResign = PayloadGame.resign();
//      sendPayload(payloadResign);
    }
    endGame(isResignLocal: isLocal);
  }


  drawGame({PayloadGame payload}) {
    var isLocal = payload == null;
    if (isLocal) {
      connection.didLocalDraw = true;
    }
    else {
      connection.didRemoteDraw = true;
    }
    if (connection.didLocalDraw == true && connection.didRemoteDraw) {
      endGame(isDraw: true);
      showSnackBar(
          widgetDrawAgreed()
      );
    }
    else if (isLocal) {
      var payloadDraw = PayloadGame.draw();
//      sendPayload(payloadDraw);
      showSnackBar(
          widgetDrawSent()
      );
    }
    else {
      showSnackBar(
        widgetDrawOffered()
      );
    }
  }


  endGame({bool isResignLocal, bool isTimeLightOver, bool isDraw = false, bool isAbort = false}) async  {

    setOffsetsOfPosition();
    timer.stop();

    String titleAlert;

    var nameLight = isConnected ? connection.isLocalLight ? Const.STRING_YOU
        : connection.nameEndpoint
        : null;
    var nameDark = isConnected ? !connection.isLocalLight ? Const.STRING_YOU
        : connection.nameEndpoint
        : null;

    var gameHistory = GameHistory(
        idDevice: isConnected ? connection.idDevice : null,
        nameLight: nameLight,
        nameDark: nameDark,
        moves: [],
        type: typeGame
    );
    game.notations.asMap().forEach((index, notation) {
      var moveGameHistory = MoveGameHistory(notation, timer.moves[index].time);
      gameHistory.moves.add(moveGameHistory);
    });

    if (isConnected) {

      connection.didLocalDraw = null;
      connection.didRemoteDraw = null;

      var scoreLocalUpdated = connection.scoreLocal ?? 0;
      var scoreRemoteUpdated = connection.scoreRemote ?? 0;

      if (game.state == StateGame.checkmate) {
        var didLocalWin = connection.isLocalLight == !game.isLightToMove;
        scoreLocalUpdated += didLocalWin ? 1.0 : 0.0;
        scoreRemoteUpdated += !didLocalWin ? 1.0 : 0.0;
        var nameWinner = didLocalWin ? Const.STRING_YOU : connection.nameEndpoint;
        var showsS = nameWinner == Const.STRING_YOU;
        titleAlert = "checkmate!\n"
            "$nameWinner win${showsS ? "s" : ""}";
        gameHistory.result = ResultGameHistory.checkmate;
        gameHistory.isLightWinner = !game.isLightToMove;
      }
      else if (isTimeLightOver != null) {
        if (game.isThereSufficientMaterialToCheckmate(isLight: !isTimeLightOver)) {
          var didLocalWin = connection.isLocalLight == !isTimeLightOver;
          var nameWinner = didLocalWin ? Const.STRING_YOU : connection.nameEndpoint;
          var showsS = nameWinner == Const.STRING_YOU;
          titleAlert = "time over!\n"
              "$nameWinner win${showsS ? "s" : ""}";
          gameHistory.result = ResultGameHistory.timeOver;
          gameHistory.isLightWinner = connection.isLocalLight == didLocalWin;
        }
        else {
          titleAlert = "insufficient material\n"
              "Game drawn";
          gameHistory.result = ResultGameHistory.insufficientMaterial;
        }
      }
      else if (game.state == StateGame.stalemate) {
        scoreLocalUpdated += 0.5;
        scoreRemoteUpdated += 0.5;
        titleAlert = "stalemate\n"
            "Game drawn";
        gameHistory.result = ResultGameHistory.stalemate;
      }
      else if (game.state == StateGame.insufficientMaterial) {
        scoreLocalUpdated += 0.5;
        scoreRemoteUpdated += 0.5;
        titleAlert = "insufficient material\n"
            "Game drawn";
        gameHistory.result = ResultGameHistory.insufficientMaterial;
      }
      else if (isResignLocal != null) {
        scoreLocalUpdated += !isResignLocal ? 1.0 : 0.0;
        scoreRemoteUpdated += isResignLocal ? 1.0 : 0.0;
        var nameWinner = !isResignLocal ? Const.STRING_YOU : connection.nameEndpoint;
        var showsS = nameWinner == Const.STRING_YOU;
        titleAlert = "resignation!\n"
            "$nameWinner win${showsS ? "s" : ""}";
        gameHistory.result = ResultGameHistory.resignation;
        gameHistory.isLightWinner = connection.isLocalLight == !isResignLocal;
      }
      else if (isDraw ?? false) {
        scoreLocalUpdated += 0.5;
        scoreRemoteUpdated += 0.5;
        titleAlert = "draw by agreement";
        gameHistory.result = ResultGameHistory.draw;
      }
      else {
        gameHistory.result = ResultGameHistory.abort;
      }
//      setScore(scoreLocal: scoreLocalUpdated, scoreRemote: scoreRemoteUpdated);
    }
    else {
      if (game.state == StateGame.checkmate) {
        var nameWinner = game.isLightToMove ? Const.STRING_DARK : Const.STRING_LIGHT;
        titleAlert = "checkmate!\n"
            "$nameWinner wins";
        gameHistory.result = ResultGameHistory.checkmate;
        gameHistory.isLightWinner = !game.isLightToMove;
      }
      else if (isTimeLightOver != null) {
        if (game.isThereSufficientMaterialToCheckmate(isLight: !isTimeLightOver)) {
          var nameWinner = isTimeLightOver ? Const.STRING_DARK : Const.STRING_LIGHT;
          titleAlert = "time over!\n"
              "$nameWinner wins";
          gameHistory.result = ResultGameHistory.timeOver;
          gameHistory.isLightWinner = !isTimeLightOver;
        }
        else {
          titleAlert = "insufficient material\n"
              "Game drawn";
          gameHistory.result = ResultGameHistory.insufficientMaterial;
        }
      }
      else if (game.state == StateGame.stalemate) {
        titleAlert = "Stalemate\n"
            "game drawn";
        gameHistory.result = ResultGameHistory.stalemate;
      }
      else if (game.state == StateGame.insufficientMaterial) {
        titleAlert = "Insufficient material\n"
            "game drawn";
        gameHistory.result = ResultGameHistory.insufficientMaterial;
      }
      else {
        gameHistory.result = ResultGameHistory.end;
      }
    }

    setState(() {
      typeState = TypeStateWidgetGame.ended;
      squaresSelected = [];
      squaresValid = [];
      this.titleAlert = titleAlert;
      if (isAbort) {
        connection = null;
      }
    });

    saveGame(gameHistory);
  }


  saveGame(GameHistory gameHistory) async {
    await History.saveGame(gameHistory);
  }

  
  animateGame({int millisecondsDelay = 0}) async {
    if (indexPosition != 0) {
      selectPosition(index: 0);
      await Future.delayed(Duration(milliseconds: millisecondsDelay));
    }
    for (int indexPosition in List.generate(positions.length - 1, (length) => 1 + length)) {
      selectPosition(index: indexPosition);
      await Future.delayed(Duration(milliseconds: millisecondsDelay));
    }
  }
  
  
  
  // UTIL
  // ...
  // ...
  // ...
  selectPosition({int index}) {
    var atLeft = getAtLeftFromIndexPosition(index);
    var indexChildren = getIndexChildrenFromIndexPosition(index, atLeft: atLeft);
    if (index > 0 && !isGameOngoing) {
      var indexNotation = getIndexNotationFromIndexChildren(indexChildren, atLeft: atLeft);
      var indexLight = indexNotation - (isLeftWhite == atLeft ? 0 : 1);
      var indexDark = max(0, indexNotation - (!isLeftWhite == atLeft ? 0 : 1));
      var moveLastLight = timer.moves[indexLight];
      var moveLastDark = timer.moves[indexDark];
      setState(() {
        timer.timeLight = moveLastLight.time;
        timer.timeDark = moveLastDark.time;
      });
    }
    if (index != this.indexPosition) {
      setOffsetsOfPosition(index: index);
      scrollNotationsIfNeeded(indexChildren: indexChildren, atLeft: atLeft);
    }
  }
  
  
  Offset offsetFromGlobalPosition(Offset position) {
    return Offset(position.dx - padding.left - (widthDark/2), position.dy - padding.top);
  }


  Offset offsetFromSquare(Square square) {
    var dx = (square.column - 1) * heightSquare;
    var dy = isOrientationLight ? (8 - square.row) * heightSquare : (square.row - 1) * heightSquare;
    return Offset(dx, dy);
  }


  Square squareFromOffset(Offset offset) {
    var column = (offset.dx / heightSquare + 1);
    var row = (isOrientationLight ? -offset.dy / heightSquare + 9 : offset.dy / heightSquare + 1);
    return Square(column.floor(), row.floor());
  }


  String getSquareTag(Square square) {
    var isFirstColumn = square.column == 1;
    var isFirstRow = square.row == 1;
    if (isFirstColumn && isFirstRow) {
      return square.notation;
    }
    else if (square.column == 1) {
      return square.notation.split("").last;
    }
    else if (square.row == 1) {
      return square.notation.split("").first;
    }
    return null;
  }


  Map<Piece, Offset> calculateOffsets(Map<Square, Piece> position) {
    var map = Map.fromIterable(position.entries,
        key: (entry) => entry.value as Piece,
        value: (entry) {
          var square = entry.key;
          var offset = offsetFromSquare(square);
          return offset;
        });
    return map;
  }

  
  setOffsetsOfPosition({int index}) {
    index = index == null ? positions.length - 1 : index; // defaults to last position
    indexPosition = min(positions.length - 1, index);
    var position = positions[indexPosition];
    var offsets = calculateOffsets(position);
    var moveLast = index > 0 && index - 1 < game.moves.length ? game.moves[index - 1] : null;
    setState(() {
      this.moveLast = moveLast;
      this.offsets = offsets;
    });
  }

  
  autoRotateIfNeeded() {
    if (!isConnected && defaults.rotatesAutomatically) {
      isOrientationLight = !isOrientationLight;
    }
  }

  
  int getIndexChildrenFromYPosition(double yPosition, {bool atLeft}) {
    var yPositionNormal = atLeft ? -1*(yPosition + insetNotationsStart - heightScreenSafe) : yPosition - insetNotationsStart;
    var indexChildren = min(countColumnChildrenMax - 1, max(0, yPositionNormal/heightNotation)).floor();
    return indexChildren;
  }

  
  int getIndexNotationFromIndexChildren(int index, {bool atLeft}) {
    var indexPosition = (getIndexFirstNotation(atLeft: atLeft) + index)*2 + (atLeft ? (isOrientationLight ? 0 : 1) : (isOrientationLight ? 1 : 0));
    var indexPositionMaxed = min(game.notations.length - 1, indexPosition);
    return indexPositionMaxed;
  }
  

  int getIndexPositionFromIndexChildren(int index, {bool atLeft}) {
    var indexPosition = (getIndexFirstNotation(atLeft: atLeft) + index)*2 + (atLeft == isOrientationLight ? 1 : 2);
    var indexPositionMaxed = min(positions.length - 1, indexPosition);
    return indexPositionMaxed;
  }

  
  bool getAtLeftFromIndexPosition(int indexPosition) {
    return (indexPosition % 2 == 1) == isOrientationLight;
  }


  int getIndexChildrenFromIndexPosition(int indexPosition, {bool atLeft}) {
    return (indexPosition - (atLeft == isOrientationLight ? 1 : 2)) ~/ 2 - getIndexFirstNotation(atLeft: atLeft);
  }

  
  int getIndexFirstNotation({bool atLeft}) {
    return atLeft ? indexFirstNotationLeft : indexFirstNotationRight;
  }

  
  setIndexFirstNotation(int index, {bool atLeft}) {
    if (atLeft) {
      indexFirstNotationLeft = index;
    }
    else {
      indexFirstNotationRight = index;
    }
  }
  

  int getCountNotationsAll({bool atLeft}) {
    var doubleCountNotation = (game?.notations?.length ?? 0)/2;
    int countNotations;
    if ((atLeft && isOrientationLight) || (!atLeft && !isOrientationLight)) {
      countNotations = doubleCountNotation.ceil();
    }
    else {
      countNotations = doubleCountNotation.floor();
    }
    return countNotations;
  }
  
  
  scrollNotationsIfNeeded({int indexChildren, bool atLeft}) async {

    var indexFirstNotation = getIndexFirstNotation(atLeft: atLeft);

    var isPanInFirstChildren = indexChildren == 0;
    var isFirstNotationNotShowing = indexFirstNotation > 0;
    var shouldScrollDown = isPanInFirstChildren && isFirstNotationNotShowing;

    var isPanInLastChildren = indexChildren + 1 == countColumnChildrenMax;
    var isLastNotationNotShowing = indexFirstNotation + countColumnChildrenMax < getCountNotationsAll(atLeft: atLeft);
    var shouldScrollUp = isPanInLastChildren && isLastNotationNotShowing;

    if (shouldScrollDown || shouldScrollUp) {
      var indexFirstNotation = getIndexFirstNotation(atLeft: atLeft);
      var indexFirstNotationUpdated = indexFirstNotation + (shouldScrollDown ? -1 : 1);
      await Future.delayed(Duration(milliseconds: Const.MILLISECONDS_DELAY_SCROLL));
      setState(() {
        setIndexFirstNotation(indexFirstNotationUpdated, atLeft: atLeft);
      });
    }

  }


  showSnackBar(Widget content) {
    scaffoldKey.currentState.showSnackBar(
        SnackBar(
            content: content
        )
    );
  }


  String getFormattedInterval(double interval) {
    var intervalFloored = interval.ceil();
    var minutes = intervalFloored ~/ 60;
    var seconds = (intervalFloored % 60);
    var minutesPadded = minutes < 10 ? "0$minutes" : minutes;
    var secondsPadded = seconds < 10 ? "0$seconds" : seconds;
    return "$minutesPadded:$secondsPadded";
  }



  // PUSH
  // ...
  // ...
  // ...
  pushHistory() async {
    await Navigator.push(
      context,
      CleanPageRoute(
          builder: (_) => WidgetHistory(completion: (gameHistory) {
            if (gameHistory != null) {
              createGameFromHistory(gameHistory);
            }
          }),
      ),
    );
  }

  
  pushBoard() async {
    await Navigator.push(
      context,
      CleanPageRoute(
          builder: (_) => WidgetDefaults(),
          onPop: () async {
            await defaults.getBoard();
            setState(() {
              defaults = defaults;
            });
          }
      ),
    );
  }
}
 