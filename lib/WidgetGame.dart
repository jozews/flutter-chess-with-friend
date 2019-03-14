
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:device_info/device_info.dart';
import 'package:simple_permissions/simple_permissions.dart';

import 'Game.dart';
import 'Timer.dart';
import 'Defaults.dart';
import 'Const.dart';
import 'Utils.dart';
import 'Nearby.dart';
import 'Connecton.dart';
import 'PayloadGame.dart';

import 'WidgetHistory.dart';
import 'WidgetDefaults.dart';


class WidgetGame extends StatefulWidget {
  WidgetGame({Key key}) : super(key: key);

  @override
  StateWidgetGame createState() => StateWidgetGame();
}


class StateWidgetGame extends State<WidgetGame> {

  get colorBackground1 => Colors.black.withAlpha((0.75 * 255).toInt());
  get colorBackground2 => Colors.white;
  get colorSelection => accentBoard.shade700.withAlpha((0.75 * 255).toInt());
  get colorSquareValid => accentBoard.shade400.withAlpha((0.95 * 255).toInt());
  get colorLastMove => colorSquareValid;
  get colorSquareCheck => Colors.red.withAlpha((0.75 * 255).toInt());
  get colorTagSquare => accentBoard.shade700;

  // MODEL
  // ...
  Game game;
  Timer timer;

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
  double timeTotalLight;
  double timeTotalDark;

  // CONNECTION
  Connection connection;
  AndroidDeviceInfo infoDeviceAndroid;

  // NOTATIONS
  // ...
  List<String> notations;
  int indexFirstNotationLeft;
  int indexFirstNotationRight;
  int countColumnChildrenMax;

  // BOOL
  // ...
  var isAlertShowing = false;
  var isTimeShowing = false;
  var isGameSetup = false;
  var isGameOngoing = false;
  var isMenuShowing = false;
  var isOrientationLight = true;

  // DEFAULTS
  // ...
  Defaults defaults;

  // UTIL
  // ...
  // ...

  MaterialAccentColor get accentBoard => defaults.indexAccent != null ?Const.ACCENTS[defaults.indexAccent] : null;

  bool get isConnected => connection != null;

  Color get colorBoardDark => accentBoard.shade200.withAlpha((0.8 * 255).toInt());
  Color get colorBoardLight => accentBoard.shade200.withAlpha((0.3 * 255).toInt());

  double get heightScreen => (MediaQuery.of(context).size.height - MediaQuery.of(context).padding.vertical);
  double get heightSquare => heightScreen / 8;
  double get heightNotation => Const.SIZE_NOTATION + Const.INSET_NOTATION*2;
  double get heightItemMenu => heightSquare;
  double get heightWidgetTimeItem => heightSquare*2/3;

  double get widthScreen => (MediaQuery.of(context).size.width - MediaQuery.of(context).padding.horizontal);
  double get widthDark => widthScreen - heightScreen;
  double get widthSide => widthDark/2;
  double get widthWidgetTime => heightSquare*2;
  double get widthWidgetTimeItem => widthSide;

  double get sizePiece => heightSquare * 9/10;
  double get sizeDotSquareValid => heightSquare / 4;

  bool get isLeftToMove => (isOrientationLight && game.isLightToMove);

  bool get shouldMenuShowItemNew => !isGameSetup && !isConnected;
  bool get shouldMenuShowItemEnd => isGameOngoing && !isConnected;
  bool get shouldMenuShowItemResign => isGameOngoing && isConnected;
  bool get shouldMenuShowItemDraw => isGameOngoing && isConnected;
  bool get shouldMenuShowItemTime => !isGameOngoing;
  bool get shouldMenuShowItemHistory => !isGameOngoing && !isConnected;
  bool get shouldShowDim => isAlertShowing || isMenuShowing || isTimeShowing;

  // STATE
  // ...
  // ...
  @override
  void initState() {
    super.initState();
    setupBoard();
    setupConnection();
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
                Row(
                  children: <Widget>[
                    widgetSide(),
                    defaults.indexAccent != null ? widgetCenter() : Container(),
                    widgetSide(atLeft: false),
                  ],
                  mainAxisAlignment: MainAxisAlignment.center,
                ),
                shouldShowDim ? widgetDim() : Container(),
                isMenuShowing ? widgetMenu() : Container(),
                isAlertShowing ? widgetAlert() : Container(),
                isTimeShowing ? widgetTime() : Container(),
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
            top: Const.INSET_ICON_MENU,
            left: Const.INSET_ICON_MENU
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
    return Expanded(
      child: Container(
        child: Stack(
          children: <Widget>[
            timeTotalLight != null ? Align(
              alignment: atLeft ? Alignment.bottomCenter : Alignment.topCenter,
                  child: Container(
                    child: Text(
                      atLeft ? (isOrientationLight
                          ? getFormattedInterval(timeTotalLight)
                          : getFormattedInterval(timeTotalDark))
                          : (!isOrientationLight ? getFormattedInterval(timeTotalLight)
                          : getFormattedInterval(timeTotalDark)),
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: Const.SIZE_TIME,
                          fontWeight: FontWeight.w500
                      ),
                    ),
                    margin: EdgeInsets.symmetric(
                        vertical: Const.INSET_VERTICAL_TIME
                    ),
                  ),
            ) : Container(),
            notations != null ? Align(
              alignment: atLeft ? Alignment.bottomCenter : Alignment.topCenter,
              child: Container(
                child: GestureDetector(
                    child: LayoutBuilder(
                        builder: (context, constraints) {
                          // set count notations
                          if (countColumnChildrenMax == null) {
                            countColumnChildrenMax = (constraints.maxHeight / heightNotation).floor() - 2;
                          }
                          var countNotations = getCountNotationsAll(atLeft: atLeft);
                          var countNotationsMin = min(countColumnChildrenMax, countNotations);
                          return Column(
                            children: List.generate(countNotationsMin, (index) => widgetNotation(index, atLeft)),
                            verticalDirection: atLeft ? VerticalDirection.up : VerticalDirection.down,
                          );
                        }),
                    onPanStart: (pan) {
                      var indexChildren = getIndexChildrenFromYPosition(pan.globalPosition.dy, atLeft: atLeft);
                      panOnIndexChildren(indexChildren: indexChildren, atLeft: atLeft);
                    },
                    onPanUpdate: (pan) {
                      var indexChildren = getIndexChildrenFromYPosition(pan.globalPosition.dy, atLeft: atLeft);
                      panOnIndexChildren(indexChildren: indexChildren, atLeft: atLeft);
                    },
                ),
                margin: EdgeInsets.only(
                  top: !atLeft ? Const.INSET_NOTATION_START : Const.INSET_NOTATIONS_END,
                  bottom: atLeft ? Const.INSET_NOTATION_START : Const.INSET_NOTATIONS_END,
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
    var notation = notations[indexNotation];
    var isSelected = indexPosition == this.indexPosition;
    return GestureDetector(
      child: Center(
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
          padding: EdgeInsets.all(
              Const.INSET_NOTATION
          ),
        ),
      ),
    );
  }

  Widget widgetMenu() {
    return Container(
      child: Container(
        child: ListView(
          children: <Widget>[
            shouldMenuShowItemNew ? GestureDetector(
              child: widgetItemMenu(
                  title: "new"
              ),
              onTap: () {
                onTapItemMenuNew();
              },
            ) : Container(),
            shouldMenuShowItemEnd ? GestureDetector(
              child: widgetItemMenu(
                  title: "end"
              ),
              onTap: () {
                onTapItemMenuEnd();
              },
            ) : Container(),
            shouldMenuShowItemResign ? GestureDetector(
              child: widgetItemMenu(
                  title: "resign"
              ),
              onTap: () {
                onTapItemMenuResign();
              },
            ) : Container(),
            shouldMenuShowItemDraw ? GestureDetector(
              child: widgetItemMenu(
                  title: "draw"
              ),
              onTap: () {
                onTapItemMenuDraw();
              },
            ) : Container(),
            shouldMenuShowItemTime ? GestureDetector(
              child: widgetItemMenu(
                  title: "time"
              ),
              onTap: () {
                onTapItemMenuTime();
                },
            ) : Container(),
            shouldMenuShowItemHistory ? GestureDetector(
              child: widgetItemMenu(
                  title: "history"
              ),
              onTap: () {
                onTapItemMenuHistory();
              },
            ) : Container(),
            GestureDetector(
              child: widgetItemMenu(
                  title: "flip"
              ),
              onTap: () {
                onTapItemMenuOrientation();
              },
            ),
            GestureDetector(
              child: widgetItemMenu(
                  title: "board"
              ),
              onTap: () {
                onTapItemMenuBoard();
              },
            ),
          ],
        ),
        color: colorBackground1,
        height: heightScreen,
        width: widthSide,
      ),
      color: colorBackground2,
      height: heightScreen,
      width: widthSide,
    );
  }

  Widget widgetItemMenu({String title}) {
    return Container(
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
              width: widthSide - Const.INSET_DIVISOR_ITEM_MENU,
            ),
          ),
        ],
      ),
      height: heightItemMenu,
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
            child: Text(
              getAlertTitle(),
              style: TextStyle(
                  color: Colors.white
              ),
            ),
            color: colorBackground1,
            padding: EdgeInsets.all(Const.INSET_ALERT_TEXT),
          ),
          color: colorBackground2,
        ),
      ),
    );
  }

  Widget widgetTime() {
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
              children: ControlTimer.values.map<Widget>((control) {
                return GestureDetector(
                  child: Container(
                    child: widgetItemTime(
                        control
                    ),
                    height: heightWidgetTimeItem,
                  ),
                  onTap: () {
                    onTapItemTimeControl(control);
                  },
                );
              }).toList(),
              mainAxisSize: MainAxisSize.min,
            ),
            color: colorBackground1,
          ),
          color: colorBackground2,
          width: widthWidgetTimeItem,
        ),
      ),
    );
  }

  Widget widgetItemTime(ControlTimer control) {
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
    return Stack(
      children: <Widget>[
        Align(
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
                color: Colors.white,
                fontSize: Const.SIZE_SUBTITLE,
                fontWeight: FontWeight.w400
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            color: Colors.white,
            height: Const.SIZE_DIVISOR,
            width: widthSide - Const.INSET_DIVISOR_ITEM_MENU,
          ),
        ),
      ],
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

  // ACTIONS
  // ...
  // ...
  onTapDownBoard(TapDownDetails tap) {
    var isLastPosition = indexPosition == positions.length - 1;
    if (!isLastPosition || !isGameSetup) {
      return;
    }
    var offset = offsetFromGlobalPosition(tap.globalPosition);
    var square = squareFromOffset(offset);
    var piece = positions.last[square];
    if (squaresSelected.isEmpty && piece != null) {
      var squaresValid = game.getValidMoves(square).map((move) => move.square2).toList();
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
        var squaresValid = game.getValidMoves(square).map((move) => move.square2).toList();
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
    if (!isLastPosition || !isGameSetup) {
      return;
    }
    if (squaresSelected.length == 2) {
      var move = Move(squaresSelected.first, squaresSelected.last);
      var _ = makeMove(move);
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
    if (!isLastPosition || !isGameSetup) {
      return;
    }
    var offset = offsetFromGlobalPosition(pan.globalPosition);
    var square = squareFromOffset(offset);
    var piece = positions.last[square];
    if (piece != null) {
      var squaresValid = game.getValidMoves(square).map((move) => move.square2).toList();
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
    if (!isLastPosition || !isGameSetup) {
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
    if (!isLastPosition || !isGameSetup) {
      return;
    }
    if (squaresSelected.isNotEmpty && piecePanning != null) {
      var offset = offsets[piecePanning];
      var offsetCentered = Offset(offset.dx + heightSquare/2, offset.dy + heightSquare/2);
      var square2 = squareFromOffset(offsetCentered);
      var move = Move(squaresSelected.first, square2);
      var _ = makeMove(move);
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
      var _ = makeMove(move);
      if (_ != null) {
        setState(() {
          squaresSelected = [];
          squaresValid = [];
        });
      }
    }
  }

  onTapDim() {
    setState(() {
      if (isAlertShowing) {
        isAlertShowing = false;
      }
      else if (isTimeShowing) {
        isTimeShowing = false;
      }
      else if (isMenuShowing) {
        isMenuShowing = false;
      }
    });
  }

  onTapIconMenu() {
    setState(() {
      isTimeShowing = false;
      isMenuShowing = !isMenuShowing;
    });
  }

  onTapItemMenuNew() {
    setupGame();
    setState(() {
      isMenuShowing = false;
    });
  }

  onTapItemMenuEnd() {
    endGame();
    setState(() {
      isMenuShowing = false;
    });
  }

  onTapItemMenuResign() {
//    resignGame();
    setState(() {
      isMenuShowing = false;
    });
  }

  onTapItemMenuDraw() {
//    drawGame();
    setState(() {
      isMenuShowing = false;
    });
  }

  onTapItemMenuTime() {
    setState(() {
      this.isMenuShowing = false;
      this.isTimeShowing = true;
    });
  }

  onTapItemMenuHistory() {
    pushHistory();
    setState(() {
      isMenuShowing = false;
    });
  }

  onTapItemMenuOrientation() {
    isOrientationLight = !isOrientationLight;
    setOffsetsOfPositionAt();
    setState(() {
      isMenuShowing = false;
    });
  }

  onTapItemMenuBoard() async {
    await pushBoard();
    setState(() {
      isMenuShowing = false;
    });
  }

  onTapItemTimeControl(ControlTimer controlTimer) {
    this.controlTimer = controlTimer;
    this.timer = Timer.control(this.controlTimer);
    setState(() {
      this.isTimeShowing = false;
      timeTotalLight = timer.timeLight;
      timeTotalDark = timer.timeDark;
    });
  }
  
  // CONNECTION
  // ...
  // ...
  setupConnection() async {
    await SimplePermissions.requestPermission(Permission.AccessCoarseLocation);
    infoDeviceAndroid = await DeviceInfoPlugin().androidInfo;
    startAdvertising();
    // NOTE: MIGHT BE GOOD TO ADD DELAY HERE
    startDiscovering();
  }

  startAdvertising() {
    Nearby.startAdvertising(name: infoDeviceAndroid.model, idService: Const.ID_SERVICE).listen((advertise) {
      switch (advertise.type) {
        case TypeLifecycle.initiated:
          acceptConnection(advertise);
          break;
        case TypeLifecycle.result:
          break;
        case TypeLifecycle.disconnected:
          break;
      }
    });
  }

  startDiscovering() {
    Nearby.startDiscovering(idService: Const.ID_SERVICE).listen((discovery) {
      switch (discovery.type) {
        case TypeDiscovery.found:
          if (!isConnected) {
            return;
          }
          requestConnection(discovery);
          break;
        case TypeDiscovery.lost:
          break;
      }
    });
  }

  requestConnection(Discovery discovery) {
    Nearby.requestConnection(idEndpoint: discovery.idEndpoint).listen((lifecycle) {
      switch (lifecycle.type) {
        case TypeLifecycle.initiated:
          acceptConnection(lifecycle);
          break;
        case TypeLifecycle.result:
          break;
        case TypeLifecycle.disconnected:
          setDisconnected();
          break;
      }
    });
  }

  acceptConnection(Lifecycle advertise) {
    Nearby.acceptConnection(idEndpoint: advertise.idEndpoint).listen((payload) {
      switch (payload.type) {
        case TypePayload.received:
          handlePayload(payload);
          break;
        case TypePayload.transferred:
          break;
      }
    });

    setConnected(idEndpoint: advertise.idEndpoint, nameEndpoint: advertise.nameEndpoint);
    var payloadGame = PayloadGame.idDevice(infoDeviceAndroid.androidId);
    sendPayload(payloadGame);
  }

  setConnected({String idEndpoint, String nameEndpoint}) {
    var connection = Connection(idEndpoint, nameEndpoint, null);
    setState(() {
      this.connection = connection;
    });
  }


  setDisconnected() {
    setState(() {
      connection = null;
    });
  }

  sendPayload(PayloadGame payload) {
    var bytesPayload = payload.toBytes();
    Nearby.sendPayloadBytes(idEndpoint: connection.idEndpoint, bytes: bytesPayload);
  }

  handlePayload(Payload payload) {
    var payloadGame = PayloadGame.fromBytes(payload.bytes);
    switch (payloadGame.type) {
      case TypePayloadGame.idDevice:
        connection.idDevice = payloadGame.idDevice;
        getScore();
        break;
      case TypePayloadGame.timer:
        if (canUpdateControlTime) {

        }
        break;
      case TypePayloadGame.start:
        break;
      case TypePayloadGame.moveStart:
        break;
      case TypePayloadGame.moveEnd:
        break;
      case TypePayloadGame.resign:
        break;
      case TypePayloadGame.draw:
        break;
    }
  }

  getScore() async {
    var score = await Defaults.getInt(connection.idDevice);
    setState(() {
      connection.score = score;
    });
  }

  setScore(int score) async {
    await Defaults.setInt(connection.idDevice, score);
  }

  // UTIL
  // ...
  // ...
  Offset offsetFromGlobalPosition(Offset position) {
    return Offset(position.dx - (widthDark/2), position.dy);
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

  setupBoard() async {
    defaults = Defaults();
    await defaults.getBoard();
    setState(() { });
    await Future.delayed(Duration(milliseconds: 100)); // wait a bit to make proper layout
    setupGame();
  }

  setupGame() async {

    game = Game.standard();
    timer = Timer.control(controlTimer);

    positions = [game.board];
    setOffsetsOfPositionAt();

    setState(() {
      squaresSelected = [];
      squaresValid = [];
      indexFirstNotationLeft = 0;
      indexFirstNotationRight = 0;
      isGameSetup = true;
      this.offsets = offsets;
      notations = [];
      timeTotalLight = timer.timeTotal;
      timeTotalDark = timer.timeTotal;
    });

//    automateGame();
  }
  
  startGame() {
    setState(() {
      isGameOngoing = true;
    });
    timer.addTimestampStart();
    timer.start().listen((time) {
      setState(() {
        timeTotalLight = timer.timeLight;
        timeTotalDark = timer.timeDark;
      });
      var isTimeOver = timeTotalLight == 0 || timeTotalDark == 0;
      if (game.state == StateGame.ongoing && isAlertShowing != isTimeOver) {
        endGame();
        setState(() {
          this.isAlertShowing = isTimeOver;
        });
      }
    });
  }

  automateGame({bool animated = false, bool fast = true}) async {

    await Future.delayed(Duration(seconds: 1));

    var notations = "Nf3;Nf6;c4;g6;Nc3;Bg7;d4;O-O;Bf4;d5;Qb3;dxc4;Qxc4;c6;e4;Nbd7;Rd1;Nb6;Qc5;Bg4;Bg5;Na4;Qa3;Nxc3;bxc3;Nxe4;Bxe7;Qb6;Bc4;Nxc3;Bc5;Rfe8+;Kf1;Be6;Bxb6;Bxc4+;Kg1;Ne2+;Kf1;Nxd4+;Kg1;Ne2+;Kf1;Nc3+;Kg1;axb6;Qb4;Ra4;Qxb6;Nxd1;h3;Rxa2;Kh2;Nxf2;Re1;Rxe1;Qd8+;Bf8;Nxe1;Bd5;Nf3;Ne4;Qb8;b5;h4;h5;Ne5;Kg7;Kg1;Bc5+;Kf1;Ng3+;Ke1;Bb4+;Kd1;Bb3+;Kc1;Ne2+;Kb1;Nc3+;Kc1;Rc2#";

    for (String notation in notations.split(";")) {
      var move = game.defineMoveFromNotation(notation);
      notation = makeMove(move,);
      await Future.delayed(Duration(milliseconds: !animated ? 0 : fast ? 200 : 500));
    }
  }

  endGame() async  {
    setOffsetsOfPositionAt();
    timer.stop();
    setState(() {
      isGameSetup = false;
      isGameOngoing = false;
      squaresSelected = [];
      squaresValid = [];
    });
  }

  String makeMove(Move move) {

    var isLastPosition = indexPosition == positions.length - 1;
    if (!isLastPosition) {
      return null;
    }

    String movePNG = game.makeMove(move);

    if (movePNG != null) {

      var didLeftMoved = !isLeftToMove;
      var indexFirstAtSide = getIndexFirstNotation(atLeft: didLeftMoved);

      setState(() {
        autoRotateIfNeeded();
        notations.add(movePNG);
        var countCodesAll = getCountNotationsAll(atLeft: didLeftMoved);
        if (indexFirstAtSide + countColumnChildrenMax < countCodesAll) {
          setIndexFirstNotation(indexFirstAtSide + 1, atLeft: didLeftMoved);
        }
      });

      var position = Map<Square, Piece>.from(game.board);
      positions.add(position);

      // start game
      if (game.moves.length == 1) {
        startGame();
      }

      timer.addTimestampEnd();
      timer.addTimestampStart();

      // show alert: CHECKMATE! or stalemate
      if (game.state != StateGame.ongoing) {
        endGame();
        setState(() {
          isAlertShowing = true;
        });
      }
    }

    setOffsetsOfPositionAt();

    return movePNG;
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

  setOffsetsOfPositionAt({int index}) {
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
    if (defaults.autoRotates && !isConnected) {
      isOrientationLight = !isOrientationLight;
    }
  }

  int getIndexChildrenFromYPosition(double yPosition, {bool atLeft}) {
    var yPositionNormal = atLeft ? -1*(yPosition + Const.INSET_NOTATION_START - heightScreen) : yPosition - Const.INSET_NOTATION_START;
    var indexChildren = min(countColumnChildrenMax - 1, max(0, yPositionNormal/heightNotation)).floor();
    return indexChildren;
  }

  int getIndexNotationFromIndexChildren(int indexChildren, {bool atLeft}) {
    return (getIndexFirstNotation(atLeft: atLeft) + indexChildren)*2 + (atLeft ? (isOrientationLight ? 0 : 1) : (isOrientationLight ? 1 : 0));
  }

  int getIndexPositionFromIndexChildren(int indexChildren, {bool atLeft}) {
    return (getIndexFirstNotation(atLeft: atLeft) + indexChildren)*2 + (atLeft ? (isOrientationLight ? 1 : 2) : (isOrientationLight ? 2 : 1));
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
    var doubleCountNotation = (notations ?? []).length / 2;
    int countNotations;
    if ((atLeft && isOrientationLight) || (!atLeft && !isOrientationLight)) {
      countNotations = doubleCountNotation.ceil();
    }
    else {
      countNotations = doubleCountNotation.floor();
    }
    return countNotations;
  }

  panOnIndexChildren({int indexChildren, bool atLeft}) {
    var indexPosition = getIndexPositionFromIndexChildren(indexChildren, atLeft: atLeft);
    if (indexPosition != this.indexPosition) {
      setOffsetsOfPositionAt(index: indexPosition);
      scrollNotationsIfNeeded(indexChildren: indexChildren, atLeft: atLeft);
    }
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

  String getAlertTitle() {
    if (game.state == StateGame.checkmateByBlack) {
      return "Checkmate!";
    }
    if (game.state == StateGame.checkmateByLight) {
      return "Checkmate!";
    }
    if (game.state == StateGame.stalemate) {
      return "Stalemate";
    }
    if (timer.timeLight == 0) {
      return "Time over";
    }
    if (timer.timeDark == 0) {
      return "Time over";
    }
    return "Nothing to see here";
  }

  showTimes() {

  }

  pushHistory() async {
    await Navigator.push(
      context,
      CleanPageRoute(
          builder: (_) => WidgetHistory(),
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
            setState(() { });
          }
      ),
    );
  }

  // should be moved in diff file
  String getFormattedInterval(double interval) {
    var intervalFloored = interval.ceil();
    var minutes = intervalFloored ~/ 60;
    var seconds = (intervalFloored % 60);
    var minutesPadded = minutes < 10 ? "0$minutes" : minutes;
    var secondsPadded = seconds < 10 ? "0$seconds" : seconds;
    return "$minutesPadded:$secondsPadded";
  }
}
