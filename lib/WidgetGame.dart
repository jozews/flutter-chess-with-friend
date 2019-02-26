import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'Game.dart';
import 'Timer.dart';
import 'Defaults.dart';

import 'ScrollBehavior.dart';


class WidgetGame extends StatefulWidget {
  WidgetGame({Key key}) : super(key: key);

  @override
  WidgetGameState createState() => WidgetGameState();
}


class WidgetGameState extends State<WidgetGame> {

  static const ACCENTS = [
    Colors.redAccent,
    Colors.pinkAccent,
    Colors.deepOrangeAccent,
    Colors.orangeAccent,
    Colors.amberAccent,
    Colors.blueAccent,
    Colors.deepPurpleAccent,
    Colors.purpleAccent,
    Colors.lightBlueAccent,
    Colors.indigoAccent,
    Colors.greenAccent,
    Colors.lightGreenAccent,
    Colors.tealAccent,
    Colors.limeAccent,
  ];

  static const RADIUS_PNG = 5.0;
  static const RADIUS_ALERT = 5.0;

  static const SIZE_CODE = 19.0;
  static const SIZE_TIME = 26.0;
  static const SIZE_SETTINGS_TITLE = 15.0;
  static const SIZE_SETTINGS_SUBTITLE = 14.0;
  static const SIZE_ACCENT = 20.0;

  static const INSET_VERTICAL_TIME = 12.0;
  static const INSET_CONTAINER_CODE = 2.0;
  static const INSET_ALERT_TEXT = 25.0;
  static const INSET_CODES_START = 50.0;
  static const INSET_CODES_END = 5.0;
  static const INSET_SETTINGS = 10.0;
  static const INSET_VERTICAL_SETTINGS = 12.0;
  static const INSET_VERTICAL_SHORT_SETTINGS = 6.0;
  static const INSET_HORIZONTAL_SETTINGS = 6.0;

  get colorPNGSelected => Colors.white54;
  get colorBackground1 => Colors.black.withAlpha((0.75 * 255).toInt());
  get colorBackground2 => Colors.white;
  get colorSelection => accentBoard.shade700.withAlpha((0.75 * 255).toInt());
  get colorSquareValid => accentBoard.shade400.withAlpha((0.95 * 255).toInt());
  get colorLastMove => colorSquareValid;
  get colorSquareCheck => Colors.red.withAlpha((0.75 * 255).toInt());

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

  // CODES
  // ...
  List<String> codes;
  int indexFirstCodeLeft;
  int indexFirstCodeRight;
  int countMaxCodes;

  // STATES
  // ...
  var isAlertShowing = false;
  var isGameSetup = false;
  var isGameOngoing = false;
  var isSettingsShowing = false;

  // CONFIGURATION
  // ...
  // ...
  MaterialAccentColor accentBoard;
  Color get colorBoardDark => accentBoard.shade200.withAlpha((0.8 * 255).toInt());
  Color get colorBoardLight => accentBoard.shade200.withAlpha((0.3 * 255).toInt());

  var isLightOrientation = true;
  var showsValidMoves = true;

  // UTIL
  // ...
  get heightSquare => min(MediaQuery.of(context).size.height, MediaQuery.of(context).size.width) / 8;
  get heightCode => SIZE_CODE + INSET_CONTAINER_CODE*2;
  get darkSpace => MediaQuery.of(context).size.width - MediaQuery.of(context).size.height;

  // STATE
  // ...
  // ...
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays([]);
    setupOnInit();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        children: <Widget>[
          Container(
            child: Row(
              children: <Widget>[
                widgetSide(),
                accentBoard != null ? widgetCenter() : Container(),
                widgetSide(isLeft: false),
              ],
              mainAxisAlignment: MainAxisAlignment.center,
            ),
            color: colorBackground2,
          ),
          isAlertShowing || isSettingsShowing ? widgetDim() : Container(),
          isAlertShowing ? widgetAlert() : Container(),
          !isGameOngoing ? widgetIconSettings() : Container(),
          isSettingsShowing ? widgetSettings() : Container()
        ],
      ),
    );
  }

  // WIDGETS
  // ...
  // ...
  Widget widgetIconSettings() {
    return Align(
      alignment: Alignment.topLeft,
      child: GestureDetector(
        child: Container(
          child: Icon(
            Icons.settings,
            color: Colors.white,
          ),
          padding: EdgeInsets.only(
            top: INSET_SETTINGS,
            left: INSET_SETTINGS
          ),
        ),
        onTap: () {
          setState(() {
            isSettingsShowing = true;
          });
        },
      ),
    );
  }

  Widget widgetSettings() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        child: Container(
          child: Column(
            children: <Widget>[
              widgetTitle("Time"),
              Container(
                child: Wrap(
                  children: <Widget>[
                    GestureDetector(
                      child: widgetSettingSelection(
                          title: "3 min",
                          isSelected: controlTimer == ControlTimer.min3
                      ),
                      onTap: () {
                        controlTimer = ControlTimer.min3;
                        timer = Timer.control(controlTimer);
                        setState(() {
                          timeTotalLight = timer.timeTotal;
                          timeTotalDark = timer.timeTotal;
                        });
                      },
                    ),
                    GestureDetector(
                      child: widgetSettingSelection(
                          title: "5 min",
                          isSelected: controlTimer == ControlTimer.min5
                      ),
                      onTap: () {
                        controlTimer = ControlTimer.min5;
                        timer = Timer.control(controlTimer);
                        setState(() {
                          timeTotalLight = timer.timeTotal;
                          timeTotalDark = timer.timeTotal;
                        });
                      },
                    ),
                    GestureDetector(
                      child: widgetSettingSelection(
                          title: "10 min",
                          isSelected: controlTimer == ControlTimer.min10
                      ),
                      onTap: () {
                        controlTimer = ControlTimer.min10;
                        timer = Timer.control(controlTimer);
                        setState(() {
                          timeTotalLight = timer.timeTotal;
                          timeTotalDark = timer.timeTotal;
                        });
                      },
                    ),
                  ],
                  spacing: 0,
                ),
                margin: EdgeInsets.only(
                  top: INSET_VERTICAL_SHORT_SETTINGS,
                ),
              ),
              widgetTitle("Orientation"),
              Container(
                child: Wrap(
                  children: <Widget>[
                    GestureDetector(
                      child: widgetSettingSelection(
                          title: "light",
                          isSelected: isLightOrientation
                      ),
                      onTap: () {
                        this.isLightOrientation = true;
                        displayPosition();
                      },
                    ),
                    GestureDetector(
                      child: widgetSettingSelection(
                          title: "dark",
                          isSelected: !isLightOrientation
                      ),
                      onTap: () {
                        this.isLightOrientation = false;
                        displayPosition();
                      },
                    ),
                  ],
                  spacing: 0,
                ),
                margin: EdgeInsets.only(
                  top: INSET_VERTICAL_SHORT_SETTINGS,
                ),
              ),
              widgetTitle("Show valid moves"),
              Container(
                child: Wrap(
                  children: <Widget>[
                    GestureDetector(
                      child: widgetSettingSelection(
                          title: "yes",
                          isSelected: showsValidMoves
                      ),
                      onTap: () {
                        this.showsValidMoves = true;
                        displayPosition();
                      },
                    ),
                    GestureDetector(
                      child: widgetSettingSelection(
                          title: "no",
                          isSelected: !showsValidMoves
                      ),
                      onTap: () {
                        this.showsValidMoves = false;
                        displayPosition();
                      },
                    ),
                  ],
                  spacing: 0,
                ),
                margin: EdgeInsets.only(
                  top: INSET_VERTICAL_SHORT_SETTINGS,
                ),
              ),
              widgetTitle("Color"),
              Container(
                child: Wrap(
                  children: ACCENTS.map<Widget>((accent) {
                    return GestureDetector(
                      child: widgetAccent(
                        accent,
                        isSelected: accent == accentBoard,
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
                  top: INSET_VERTICAL_SHORT_SETTINGS,
                  left: INSET_HORIZONTAL_SETTINGS,
                  right: INSET_HORIZONTAL_SETTINGS,
                ),
              ),
              widgetTitle("Pieces"),
            ],
          ),
          color: colorBackground1,
        ),
        color: Colors.white,
        height: MediaQuery.of(context).size.height,
        width: darkSpace/2,
      ),
    );
  }

  Widget widgetTitle(String title) {
    return Container(
      child: Text(
        title,
        style: TextStyle(
            color: Colors.white,
            fontSize: SIZE_SETTINGS_TITLE
        ),
      ),
      margin: EdgeInsets.only(
          top: INSET_VERTICAL_SETTINGS
      ),
    );
  }

  Widget widgetSettingSelection({String title, bool isSelected}) {
    return Container(
      child: Text(
        title,
        style: TextStyle(
            color: Colors.white,
            fontSize: SIZE_SETTINGS_SUBTITLE
        ),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
            Radius.circular(
                SIZE_SETTINGS_SUBTITLE/2
            )
        ),
        color: isSelected ? colorPNGSelected : Colors.transparent,
      ),
      padding: EdgeInsets.symmetric(
          horizontal: 4,
          vertical: 2
      ),
    );
  }

  Widget widgetAccent(MaterialAccentColor accent, {bool isSelected}) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(
              color: isSelected ? Colors.white : Colors.transparent
          ),
          borderRadius: BorderRadius.all(
            Radius.circular(
                5.0
            )
        ),
        color: accent.shade200,
      ),
      height: SIZE_ACCENT,
      width: SIZE_ACCENT,
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
                  return widgetSquareSelected(square);
                }).toList()
                + (moveLast != null ? [widgetSquareLast(moveLast.square1), widgetSquareLast(moveLast.square2)] : [])
                + (offsets != null ? offsets.entries.map<Widget>((entry) {
                        var piece = entry.key;
                        return widgetPiece(piece);
                      }).toList()
                    : [])
                + (showsValidMoves ? (squaresValid ?? []).map<Widget>((square) {
                  return widgetSquareValid(square);
                }).toList() : []),
          ),
        ),
      ),
    );
  }

  Widget widgetSide({bool isLeft = true}) {
    return Expanded(
      child: Container(
        color: colorBackground1,
        child: Stack(
          children: <Widget>[
            timeTotalLight != null ? Align(
              alignment: isLeft ? Alignment.bottomCenter : Alignment.topCenter,
                  child: Container(
                    child: Text(
                      isLeft ? (isLightOrientation
                          ? getFormattedInterval(timeTotalLight)
                          : getFormattedInterval(timeTotalDark))
                          : (!isLightOrientation ? getFormattedInterval(timeTotalLight)
                          : getFormattedInterval(timeTotalDark)),
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: SIZE_TIME,
                          fontWeight: FontWeight.w500
                      ),
                    ),
                    margin: EdgeInsets.symmetric(
                        vertical: INSET_VERTICAL_TIME
                    ),
                  ),
            ) : Container(),
            codes != null ? Align(
              alignment: isLeft ? Alignment.bottomCenter : Alignment.topCenter,
              child: Container(
                child: GestureDetector(
                    child: LayoutBuilder(
                        builder: (context, constraints) {
                          countMaxCodes = (constraints.maxHeight / heightCode).floor() - 2;
                          var codesSideAll = (codes ?? []).asMap().entries.where((entry) {
                            return isLeft ? (entry.key % 2 == (isLightOrientation ? 0 : 1))
                                : entry.key % 2 == (!isLightOrientation ? 0 : 1);
                          }).toList();
                          var indexFirstCode = isLeft ? indexFirstCodeLeft : indexFirstCodeRight;
                          var count = indexFirstCode + countMaxCodes - (indexFirstCode > 0 ? 1 : 0);
                          var countLastCode = min(codesSideAll.length, count - (count < codesSideAll.length ? 1 : 0));
                          var codesSideShown = codesSideAll.sublist(indexFirstCode, countLastCode);
                          return Column(
                            children: <Widget>[(indexFirstCode > 0 ? widgetCodeMore() : Container())]
                                + codesSideShown.map<Widget>((entry) {
                                  var code = entry.value;
                                  var index = entry.key;
                                  return widgetCode(code, index);
                                }).toList()
                                + <Widget>[countLastCode < codesSideAll.length ? widgetCodeMore() : Container()],
                            verticalDirection: isLeft ? VerticalDirection.up : VerticalDirection.down,
                          );
                        }),
                    onTapUp: (tap) {
                      var yPosition = tap.globalPosition.dy;
                      var yPositionNormal = isLeft ? -1*(yPosition + INSET_CODES_START - MediaQuery.of(context).size.height) : yPosition - INSET_CODES_START;
                      var indexChildren = max(0, yPositionNormal/heightCode).floor();
                      var indexPosition = indexChildren*2 + (isLeft ? 1 : 2);
                      if (indexPosition != this.indexPosition && indexPosition < positions.length) {
                        displayPosition(index: indexPosition);
                        setState(() {
                          this.indexPosition = indexPosition;
                        });
                      }},
                    onPanUpdate: (pan) {
                      var yPosition = pan.globalPosition.dy;
                      var yPositionNormal = isLeft ? -1*(yPosition + INSET_CODES_START - MediaQuery.of(context).size.height) : yPosition - INSET_CODES_START;
                      var heightChildren = SIZE_CODE + INSET_CONTAINER_CODE*2;
                      var indexChildren = max(0, yPositionNormal/heightChildren).floor();
                      var indexPosition = indexChildren*2 + (isLeft ? 1 : 2);
                      if (indexPosition != this.indexPosition && indexPosition < positions.length) {
                        displayPosition(index: indexPosition);
                        setState(() {
                          this.indexPosition = indexPosition;
                        });
                      }
                    }),
                margin: EdgeInsets.only(
                  top: !isLeft ? INSET_CODES_START : INSET_CODES_END,
                  bottom: isLeft ? INSET_CODES_START : INSET_CODES_END,
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
//              var row = 7 - (index % 8);
//              var square = Square(column + 1, row + 1);
              var color = (index % 2) != (column % 2) ? colorBoardDark : colorBoardLight;
              return Container(
                  color: color
              );
            }),
          ),
          onTapCancel: () {

          },
          onTapDown: (tap) {
            var isLastPosition = indexPosition == positions.length - 1;
            if (!isLastPosition || !isGameSetup) {
              return;
            }
            var offset = offsetFromGlobalPosition(tap.globalPosition);
            var square = squareFromOffset(offset);
            var piece = positions.last[square];
            if (squaresSelected.isEmpty && piece != null) {
              var squaresValid = game.validMoves(square).map((move) => move.square2).toList();
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
                var squaresValid = game.validMoves(square).map((move) => move.square2).toList();
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
          },
          onTapUp: (tap) {
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
          },
          onPanStart: (pan) {
            var isLastPosition = indexPosition == positions.length - 1;
            if (!isLastPosition || !isGameSetup) {
              return;
            }
            var offset = offsetFromGlobalPosition(pan.globalPosition);
            var square = squareFromOffset(offset);
            var piece = positions.last[square];
            if (piece != null) {
              var squaresValid = game.validMoves(square).map((move) => move.square2).toList();
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
          },
          onPanUpdate: (pan) {
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
          },
          onPanEnd: (pan) {
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
      ),
      color: Colors.white,
    );
  }

  Widget widgetPiece(Piece piece) {
    var namePiece = piece.type.toString().replaceFirst("TypePiece.", "");
    var nameIsLight = piece.isLight ? "light" : "dark";
    var name = "$namePiece-$nameIsLight";
    return Positioned(
      left: offsets[piece].dx,
      top: offsets[piece].dy,
      child: IgnorePointer(
        child: Container(
          child: Image.asset(
              "sets/default/$name.png"
          ),
          height: heightSquare * 1,
          width: heightSquare * 1,
        ),
      ),
    );
  }

  Widget widgetSquareSelected(Square square) {
    var offset = offsetFromSquare(square);
    return Positioned(
      left: offset.dx,
      top: offset.dy,
      child: IgnorePointer(
        child: Container(
          color: colorSelection,
          height: heightSquare * 1,
          width: heightSquare * 1,
        ),
      ),
    );
  }

  Widget widgetSquareLast(Square square) {
    var offset = offsetFromSquare(square);
    return Positioned(
      left: offset.dx,
      top: offset.dy,
      child: IgnorePointer(
        child: Container(
          color: colorSelection,
          height: heightSquare * 1,
          width: heightSquare * 1,
        ),
      ),
    );
  }

  Widget widgetSquareValid(Square square) {
    var offset = offsetFromSquare(square);
    return Positioned(
      left: offset.dx + heightSquare*3/4/2,
      top: offset.dy + heightSquare*3/4/2,
      child: ClipOval(
          child: IgnorePointer(
            child: Container(
              color: colorSquareValid,
              height: heightSquare / 4,
              width: heightSquare / 4,
            ),
          ),
      ),
    );
  }

  Widget widgetCode(String code, int index) {
    var indexPosition = index + 1;
    var isSelected = indexPosition == this.indexPosition;
    return GestureDetector(
      child: Center(
        child: ClipRRect(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(RADIUS_PNG),
                topRight: Radius.circular(RADIUS_PNG),
                bottomRight: Radius.circular(RADIUS_PNG),
                bottomLeft: Radius.circular(RADIUS_PNG)),
            child: Container(
              child: Text(
                code,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: SIZE_CODE,
                  fontWeight: FontWeight.normal,
                ),
              ),
              color: isSelected ? colorPNGSelected : Colors.transparent,
              padding: EdgeInsets.all(
                  INSET_CONTAINER_CODE
              ),
            )
        ),
      ),
    );
  }

  Widget widgetCodeMore() {
    return Container(
      child: Text(
        "···",
        style: TextStyle(
          color: Colors.white,
          fontSize: SIZE_CODE
        ),
      ),
      padding: EdgeInsets.all(
          INSET_CONTAINER_CODE
      ),
    );
  }

  Widget widgetAlert() {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(RADIUS_ALERT),
            topRight: Radius.circular(RADIUS_ALERT),
            bottomRight: Radius.circular(RADIUS_ALERT),
            bottomLeft: Radius.circular(RADIUS_ALERT)),
        child: Container(
          child: Text(getAlertTitle()),
          color: Colors.white,
          padding: EdgeInsets.all(INSET_ALERT_TEXT),
        ),
      ),
    );
  }

  Widget widgetDim() {
    return GestureDetector(
      child: Container(
        color: Colors.black45,
      ),
      onTap: () {
        // set defaults upon closing settings
        if (isSettingsShowing) {
          setDefaults();
        }
        setState(() {
          isSettingsShowing = false;
          isAlertShowing = false;
        });
      },
    );
  }

  // UTIL
  // ...
  // ...
  Offset offsetFromGlobalPosition(Offset position) {
    return Offset(position.dx - (darkSpace/2), position.dy);
  }

  Offset offsetFromSquare(Square square) {
    var dx = (square.column - 1) * heightSquare;
    var dy = isLightOrientation ? (8 - square.row) * heightSquare : (square.row - 1) * heightSquare;
    return Offset(dx, dy);
  }

  Square squareFromOffset(Offset offset) {
    var column = (offset.dx / heightSquare + 1);
    var row = (isLightOrientation ? -offset.dy / heightSquare + 9 : offset.dy / heightSquare + 1);
    return Square(column.floor(), row.floor());
  }

  setupOnInit() async {
    await getDefaults();
    setupGame();
  }

  getDefaults() async {
    var showsValidMoves = await Defaults.getBool(Defaults.SHOWS_VALID_MOVES) ?? true;
    var indexAccent = await Defaults.getInt(Defaults.INDEX_ACCENT) ?? Random().nextInt(ACCENTS.length - 1);
    setState(() {
      this.showsValidMoves = showsValidMoves;
      accentBoard = ACCENTS[indexAccent];
    });
  }

  setDefaults() async {
    await Defaults.setBool(Defaults.SHOWS_VALID_MOVES, showsValidMoves);
    await Defaults.setInt(Defaults.INDEX_ACCENT, ACCENTS.indexOf(accentBoard));
  }

  setupGame() async {

    await Future.delayed(Duration(seconds: 2));

    game = Game.standard();
    timer = Timer.control(controlTimer);

    positions = [game.board];
    displayPosition();

    squaresSelected = [];
    squaresValid = [];
    indexFirstCodeLeft = 0;
    indexFirstCodeRight = 0;

    setState(() {
      isGameSetup = true;
      this.offsets = offsets;
      codes = [];
      timeTotalLight = timer.timeTotal;
      timeTotalDark = timer.timeTotal;
    });
  }
  
  startGame() {
    setState(() {
      isGameOngoing = true;
    });
    timer.start().listen((time) {
      setState(() {
        timeTotalLight = timer.timeLight;
        timeTotalDark = timer.timeDark;
      });
      var isTimeOver = timeTotalLight == 0 || timeTotalDark == 0;
      if (this.isAlertShowing != isTimeOver) {
        endGame();
        setState(() {
          this.isAlertShowing = isTimeOver;
        });
      }
    });
  }

  endGame() async  {
    displayPosition();
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

    var movePNG = game.makeMove(move);

    if (movePNG != null) {

      setState(() {
        codes.add(movePNG);
      });

      var position = Map<Square, Piece>.from(game.board);
      positions.add(position);

      timer.addTimestampEnd();
      timer.addTimestampStart();

      // start game
      if (game.moves.length == 1) {
        startGame();
      }

      // show alert: CHECKMATE! or stalemate
      if (game.state != StateGame.ongoing) {
        endGame();
        timer.stop();
        setState(() {
          isAlertShowing = true;
        });
      }
    }

    displayPosition();

    return movePNG;
  }

  displayPosition({int index}) {
    index = index == null ? positions.length - 1 : index; // defaults to last position
    indexPosition = index;
    var position = positions[index];
    var offsets = calculateOffsets(position);
    var moveLast = index > 0 && index - 1 < game.moves.length ? game.moves[index - 1] : null;
    setState(() {
      this.moveLast = moveLast;
      this.offsets = offsets;
    });
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
    return "";
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
