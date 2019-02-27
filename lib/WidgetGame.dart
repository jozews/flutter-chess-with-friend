
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
  static const NAME_PIECES = [
    "alpha",
    "bases",
    "classic",
    "light",
    "modern",
    "nature",
    "neo",
    "space",
    "wood",
    ""
  ];
  
  static const RADIUS_NOTATION = 5.0;
  static const RADIUS_ALERT = 5.0;
  static const RADIUS_DECORATION_ACCENT = 5.0;
  static const RADIUS_DECORATION_NAME_PIECE = 25.0;
  static const RADIUS_SELECTION_SETTINGS = 10.0;

  static const SIZE_NOTATION = 19.0;
  static const SIZE_TIME = 26.0;
  static const SIZE_SETTINGS_TITLE = 15.0;
  static const SIZE_SETTINGS_SUBTITLE = 14.0;
  static const SIZE_ACCENT = 20.0;
  static const SIZE_PIECE = 26.0;

  static const INSET_VERTICAL_TIME = 12.0;
  static const INSET_NOTATION = 5.0;
  static const INSET_ALERT_TEXT = 25.0;
  static const INSET_NOTATION_START = 50.0;
  static const INSET_NOTATIONS_END = 5.0;
  static const INSET_SETTINGS = 10.0;
  static const INSET_VERTICAL_SETTINGS = 14.0;
  static const INSET_VERTICAL_SHORT_SETTINGS = 7.0;
  static const INSET_HORIZONTAL_SETTINGS = 6.0;
  static const INSET_HORIZONTAL_SELECTION_SETTING = 6.0;
  static const INSET_VERTICAL_SELECTION_SETTING = 3.0;

  static const MILLISECONDS_DELAY_SCROLL = 1000;

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

  // NOTATIONS
  // ...
  List<String> notations;
  int indexFirstNotationLeft;
  int indexFirstNotationRight;
  int countColumnChildrenMax;

  // BOOL
  // ...
  var isAlertShowing = false;
  var isGameSetup = false;
  var isGameOngoing = false;
  var isSettingsShowing = false;
  var isOrientationLight = true;

  // SETTINGS
  // ...
  MaterialAccentColor accentBoard;
  Color get colorBoardDark => accentBoard.shade200.withAlpha((0.8 * 255).toInt());
  Color get colorBoardLight => accentBoard.shade200.withAlpha((0.3 * 255).toInt());
  var showsValidMoves = true;
  int indexNamePieces;

  // UTIL
  // ...
  // ...
  double get heightSquare => min(MediaQuery.of(context).size.height, MediaQuery.of(context).size.width) / 8;
  double get heightNotation => SIZE_NOTATION + INSET_NOTATION*2;
  double get darkSpace => MediaQuery.of(context).size.width - MediaQuery.of(context).size.height;

  bool get isLeftToMove => (isOrientationLight && game.isLightToMove);

  // STATE
  // ...
  // ...
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays([]);
    setup();
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
                widgetSide(atLeft: false),
              ],
              mainAxisAlignment: MainAxisAlignment.center,
            ),
            color: colorBackground2,
          ),
          isAlertShowing || isSettingsShowing ? widgetDim() : Container(),
          isAlertShowing ? widgetAlert() : Container(),
          isSettingsShowing ? widgetSettings() : Container(),
          widgetIconSettings(),
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
            !isSettingsShowing ? Icons.settings : Icons.close,
            color: Colors.white,
          ),
          padding: EdgeInsets.only(
            top: INSET_SETTINGS,
            left: INSET_SETTINGS
          ),
        ),
        onTap: () {
          setState(() {
            isSettingsShowing = !isSettingsShowing;
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
          child: ListView(
            children: <Widget>[
              isGameOngoing || !isGameSetup ? GestureDetector(
                child: Center(
                  child: Container(
                      child: widgetTitle(
                          isGameOngoing ? "End Game" : "New Game"
                      ),
                    margin: EdgeInsets.only(
                      top: INSET_VERTICAL_SHORT_SETTINGS,
                    ),
                  ),
                ),
                onTap: () {
                  if (isGameOngoing) {
                    endGame();
                  }
                  else {
                    setupGame();
                  }
                },
              ) : Container(),
              Center(
                  child: widgetTitle(
                      "Orientation"
                  )
              ),
              Center(
                child: Container(
                  child: Wrap(
                    children: <Widget>[
                      GestureDetector(
                        child: widgetSettingSelection(
                            title: "light",
                            isSelected: isOrientationLight
                        ),
                        onTap: () {
                          this.isOrientationLight = true;
                          displayPosition();
                        },
                      ),
                      GestureDetector(
                        child: widgetSettingSelection(
                            title: "dark",
                            isSelected: !isOrientationLight
                        ),
                        onTap: () {
                          this.isOrientationLight = false;
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
              ),
              !isGameOngoing ? Center(
                  child: widgetTitle(
                      "Time"
                  )
              ) : Container(),
              !isGameOngoing ? Center(
                child: Container(
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
              ) : Container(),
              Center(
                  child: widgetTitle(
                      "Show valid moves"
                  )
              ),
              Center(
                child: Container(
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
              ),
              Center(
                  child: widgetTitle(
                      "Color"
                  )
              ),
              Center(
                child: Container(
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
              ),
              Center(
                  child: widgetTitle(
                      "Pieces"
                  )
              ),
              Center(
                child: Container(
                  child: Wrap(
                    children: NAME_PIECES.map<Widget>((namePiece) {
                      return GestureDetector(
                        child: widgetSetPiece(
                          namePiece,
                          isSelected: NAME_PIECES.indexOf(namePiece) == indexNamePieces,
                        ),
                        onTap: () {
                          setState(() {
                            indexNamePieces = NAME_PIECES.indexOf(namePiece);
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
                    bottom: INSET_VERTICAL_SHORT_SETTINGS
                  ),
                ),
              )
            ],
          ),
          color: colorBackground1,
        ),
        color: Colors.white,
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
//        width: darkSpace/2,
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
                RADIUS_SELECTION_SETTINGS
            )
        ),
        color: isSelected ? colorPNGSelected : Colors.transparent,
      ),
      padding: EdgeInsets.symmetric(
          horizontal: INSET_HORIZONTAL_SELECTION_SETTING,
          vertical: INSET_VERTICAL_SELECTION_SETTING
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
                RADIUS_DECORATION_ACCENT
            )
        ),
        color: accent.shade200,
      ),
      height: SIZE_ACCENT,
      width: SIZE_ACCENT,
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
            fontSize: 20.0
          ),
        ),
      ),
      decoration: BoxDecoration(
        border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent
        ),
        borderRadius: BorderRadius.all(
            Radius.circular(
                RADIUS_DECORATION_NAME_PIECE
            )
        ),
      ),
      height: SIZE_PIECE,
      width: SIZE_PIECE,
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

  Widget widgetSide({bool atLeft = true}) {
    return Expanded(
      child: Container(
        color: colorBackground1,
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
                          fontSize: SIZE_TIME,
                          fontWeight: FontWeight.w500
                      ),
                    ),
                    margin: EdgeInsets.symmetric(
                        vertical: INSET_VERTICAL_TIME
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
                    onPanEnd: (pan) {

                    }),
                margin: EdgeInsets.only(
                  top: !atLeft ? INSET_NOTATION_START : INSET_NOTATIONS_END,
                  bottom: atLeft ? INSET_NOTATION_START : INSET_NOTATIONS_END,
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
    var nameTypePiece = piece.type.toString().replaceFirst("TypePiece.", "");
    var nameIsLight = piece.isLight ? "light" : "dark";
    var namePiece = "$nameTypePiece-$nameIsLight";
    var nameSet = NAME_PIECES[indexNamePieces];
    return Positioned(
      left: offsets[piece].dx,
      top: offsets[piece].dy,
      child: IgnorePointer(
        child: Container(
          child: nameSet.isNotEmpty ? Image.asset(
              "sets/$nameSet/$namePiece.png"
          ) : Container(),
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
              fontSize: SIZE_NOTATION,
              fontWeight: FontWeight.normal,
            ),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(
                Radius.circular(
                    RADIUS_NOTATION
                )
            ),
            color: isSelected ? colorPNGSelected : Colors.transparent,
          ),
          padding: EdgeInsets.all(
              INSET_NOTATION
          ),
        ),
      ),
    );
  }

  Widget widgetAlert() {
    return Center(
      child: Container(
        child: Text(getAlertTitle()),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(
              Radius.circular(
                  RADIUS_ALERT
              )
          ),
          color: Colors.white,
        ),
        padding: EdgeInsets.all(INSET_ALERT_TEXT),
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
    var dy = isOrientationLight ? (8 - square.row) * heightSquare : (square.row - 1) * heightSquare;
    return Offset(dx, dy);
  }

  Square squareFromOffset(Offset offset) {
    var column = (offset.dx / heightSquare + 1);
    var row = (isOrientationLight ? -offset.dy / heightSquare + 9 : offset.dy / heightSquare + 1);
    return Square(column.floor(), row.floor());
  }

  setup() async {
    await getDefaults();
    setupGame();
  }

  getDefaults() async {
    var showsValidMoves = await Defaults.getBool(Defaults.SHOWS_VALID_MOVES) ?? true;
    var indexAccent = await Defaults.getInt(Defaults.INDEX_ACCENT) ?? Random().nextInt(ACCENTS.length - 1);
    var indexNamePieces = await Defaults.getInt(Defaults.INDEX_NAME_PIECES) ?? 0;
    setState(() {
      this.showsValidMoves = showsValidMoves;
      accentBoard = ACCENTS[indexAccent];
      this.indexNamePieces = indexNamePieces;
    });
  }

  setDefaults() async {
    await Defaults.setBool(Defaults.SHOWS_VALID_MOVES, showsValidMoves);
    await Defaults.setInt(Defaults.INDEX_ACCENT, ACCENTS.indexOf(accentBoard));
    await Defaults.setInt(Defaults.INDEX_NAME_PIECES, indexNamePieces);
  }

  setupGame() async {

    game = Game.standard();
    timer = Timer.control(controlTimer);

    positions = [game.board];
    displayPosition();

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

//    automateGame(animated: false);
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
      if (this.isAlertShowing != isTimeOver) {
        endGame();
        setState(() {
          this.isAlertShowing = isTimeOver;
        });
      }
    });
  }

  automateGame({bool animated, bool fast = true}) async {

    await Future.delayed(Duration(seconds: 1));

    var notations = "e4;d6;d4;Nf6;Nc3;g6;Be3;Bg7;Qd2;c6;f3;b5;Nge2;Nbd7;Bh6;Bxh6;Qxh6;Bb7;a3;e5;O-O-O;Qe7;Kb1;a6;Nc1;O-O-O;Nb3;exd4;Rxd4;c5;Rd1;Nb6;g3;Kb8;Na5;Ba8;Bh3;d5;Qf4;Ka7;Rhe1;d4;Nd5;Nbxd5;exd5;Qd6;Rxd4;cxd4;Re7;Kb6;Qxd4;Kxa5;b4;Ka4;Qc3;Qxd5;Ra7;Bb7;Rxb7;Qc4;Qxf6;Kxa3;Qxa6;Kxb4;c3;Kxc3;Qa1;Kd2;Qb2;Kd1;Bf1;Rd2;Rd7;Rxd7;Bxc4;bxc4;Qxh8;Rd3;Qa8;c3;Qa4;Ke1;f4;f5;Kc1;Rd2;Qa7";

    for (String notation in notations.split(";")) {
      var move = game.moveFromNotation(notation);
      notation = makeMove(move,);
      await Future.delayed(Duration(milliseconds: !animated ? 0 : fast ? 200 : 500));
    }
  }

  endGame() async  {
    displayPosition();
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

    displayPosition();

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

  int getIndexChildrenFromYPosition(double yPosition, {bool atLeft}) {
    var yPositionNormal = atLeft ? -1*(yPosition + INSET_NOTATION_START - MediaQuery.of(context).size.height) : yPosition - INSET_NOTATION_START;
    var indexChildren = min(countColumnChildrenMax - 1, max(0, yPositionNormal/heightNotation)).floor();
    return indexChildren;
  }

  int getIndexNotationFromIndexChildren(int indexChildren, {bool atLeft}) {
    return (getIndexFirstNotation(atLeft: atLeft) + indexChildren)*2 + (atLeft ? 0 : 1);
  }

  int getIndexPositionFromIndexChildren(int indexChildren, {bool atLeft}) {
    return (getIndexFirstNotation(atLeft: atLeft) + indexChildren)*2 + (atLeft ? 1 : 2);
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
      displayPosition(index: indexPosition);
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
      setState(() {
        setIndexFirstNotation(indexFirstNotationUpdated, atLeft: atLeft);
      });
    }

  }

//  startScrollingNotations({bool isDown, int indexChildren, bool atLeft}) async {
//
//    var indexFirstNotation = getIndexFirstNotation(atLeft: atLeft);
//    var indexFirstNotationUpdated = indexFirstNotation + (isDown ? -1 : 1);
//    var indexPosition = this.indexPosition + (isDown ? -1 : 1);
//
//    var isFirstNotationShowing = indexFirstNotation == 0;
//    var isLastNotationShowing = indexFirstNotation + countColumnChildrenMax >= getCountNotationsAll(atLeft: atLeft);
//
//    if ((isDown && isFirstNotationShowing) || (!isDown && isLastNotationShowing)) {
//      indexChildrenScrolling = null;
//    }
//
//    if (indexChildrenScrolling == null) {
//      return;
//    }
//
//    setState(() {
//      setIndexFirstNotation(indexFirstNotationUpdated, atLeft: atLeft);
//    });
//
//    await Future.delayed(Duration(milliseconds: MILLISECONDS_DELAY_SCROLL));
//
//    displayPosition(index: indexPosition);
//
//    startScrollingNotations(isDown: isDown, indexChildren: indexChildrenScrolling, atLeft: atLeft);
//  }

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
