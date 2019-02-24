import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'Game.dart';
import 'Timer.dart';
import 'Defaults.dart';

import 'ScrollBehavior.dart';
import 'WidgetPiece.dart';

class WidgetGame extends StatefulWidget {
  WidgetGame({Key key}) : super(key: key);

  @override
  WidgetGameState createState() => WidgetGameState();
}

class WidgetGameState extends State<WidgetGame> {
  static const RADIUS_PNG = 5.0;
  static const RADIUS_ALERT = 5.0;

  static const SIZE_PNG = 20.0;
  static const SIZE_TIME = 26.0;

  static const INSET_TIME_VERTICAL = 12.0;
  static const INSET_CONTAINER_PNG = 5.0;
  static const INSET_ALERT_TEXT = 25.0;

  get colorPNGSelected => Colors.white54;
  get colorBackground1 => Colors.black.withAlpha((0.75 * 255).toInt());
  get colorBackground2 => Colors.white;
  get colorSelection => colorBoard.shade700.withAlpha((0.75 * 255).toInt());
  get colorSquareValid => colorBoard.shade400.withAlpha((0.95 * 255).toInt());
  get colorLastMove => colorSquareValid;
  get colorSquareCheck => Colors.red.withAlpha((0.75 * 255).toInt());

  // MODEL
  // ...
  Game game;
  Timer timer;

  // BOARD
  // ...
  List<Map<Square, Piece>> listPositions;
  int indexPosition;
  Map<Piece, Offset> offsets;

  Square squareSelected;
  Square squareCheck;
  List<Square> squaresValid;
  Move moveLast;
  Move movePre;

  // TIME
  // ...
  double timeTotalLight;
  double timeTotalDark;

  // CODES
  // ...
  List<String> codesMoves;

  // ALERT
  // ...
  var showsAlert = false;

  // CONFIGURATION
  // ...
  // ...
  MaterialAccentColor colorBoard;
  Color get colorBoardDark => colorBoard.shade200.withAlpha((0.8 * 255).toInt());
  Color get colorBoardLight => colorBoard.shade200.withAlpha((0.3 * 255).toInt());

  var isLightOrientation = true;
  var showsValidMoves = true;

  // UTIL
  // ...

  // STATE
  // ...
  // ...
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays([]);
    getColorBoard();
    startGame();
//    startScanning();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        children: <Widget>[
          Container(
            child: Row(
              children: <Widget>[
                widgetLeft(),
                colorBoard != null ? widgetCenter() : Container(),
                widgetRight(),
              ],
              mainAxisAlignment: MainAxisAlignment.center,
            ),
            color: colorBackground2,
          ),
          showsAlert ? widgetDim() : Container(),
          showsAlert ? widgetAlert() : Container(),
        ],
      ),
    );
  }

  // WIDGETS
  // ...
  // ...
  Widget widgetCenter() {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        child: ScrollConfiguration(
          behavior: ScrollBehaviorClean(),
          child: Stack(
            children: [widgetBoard()]
                + (squareSelected != null ? [widgetSquareSelection(squareSelected)] : [])
                + (moveLast != null ? [widgetSquareLast(moveLast.square1), widgetSquareLast(moveLast.square2)] : [])
                + (offsets != null ? offsets.entries.map<Widget>((entry) {
                        var piece = entry.key;
                        return widgetPiece(piece);
                      }).toList()
                    : [])
                + (squaresValid ?? []).map<Widget>((square) {
                  return widgetSquareValid(square);
                }).toList(),
          ),
        ),
      ),
    );
  }

  Widget widgetLeft() {
    return Expanded(
      child: Container(
        color: colorBackground1,
        child: Column(
          children: <Widget>[
                timeTotalLight != null
                    ? Center(
                        child: Container(
                          child: Text(
                            isLightOrientation
                                ? getFormattedInterval(timeTotalLight)
                                : getFormattedInterval(timeTotalDark),
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: SIZE_TIME,
                                fontWeight: FontWeight.w500),
                          ),
                          margin: EdgeInsets.symmetric(
                              vertical: INSET_TIME_VERTICAL),
                        ),
                      )
                    : Container()
              ] +
              (codesMoves ?? [])
                  .asMap()
                  .entries
                  .where(
                      (entry) => entry.key % 2 == (isLightOrientation ? 0 : 1))
                  .map<Widget>((entry) {
                var code = entry.value;
                var index = entry.key;
                return widgetCode(code, index);
              }).toList(),
          verticalDirection: VerticalDirection.up,
        ),
      ),
    );
  }

  Widget widgetRight() {
    return Expanded(
      child: Container(
        color: colorBackground1,
        child: Column(
            children: [
                  timeTotalLight != null
                      ? Center(
                          child: Container(
                            child: Text(
                              !isLightOrientation
                                  ? getFormattedInterval(timeTotalLight)
                                  : getFormattedInterval(timeTotalDark),
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: SIZE_TIME,
                                  fontWeight: FontWeight.w500),
                            ),
                            margin: EdgeInsets.symmetric(
                                vertical: INSET_TIME_VERTICAL),
                          ),
                        )
                      : Container()
                ] +
                (codesMoves ?? [])
                    .asMap()
                    .entries
                    .where((entry) =>
                        entry.key % 2 == (!isLightOrientation ? 0 : 1))
                    .map<Widget>((entry) {
                  var code = entry.value;
                  var index = entry.key;
                  return widgetCode(code, index);
                }).toList()),
      ),
    );
  }

  Widget widgetBoard() {
    return Container(
      child: GridView.count(
        scrollDirection: Axis.horizontal,
        crossAxisCount: 8,
        children: List.generate(64, (index) {
          var column = index ~/ 8;
          var row = 7 - (index % 8);
          var square = Square(column + 1, row + 1);
          var color =
              (index % 2) != (column % 2) ? colorBoardDark : colorBoardLight;
          return GestureDetector(
            child: Container(color: color),
            onTapUp: (tap) {
              var move = Move(squareSelected, square);
              if (square != squareSelected) {
                makeMove(move);
                setState(() {
                  squareSelected = null;
                  squaresValid = [];
                });
              }
            },
          );
        }),
      ),
      color: Colors.white,
    );
  }

  Widget widgetPiece(Piece piece) {
    return Positioned(
      left: offsets[piece].dx,
      top: offsets[piece].dy,
      child: GestureDetector(
        onTapUp: (tap) {
          var square = game.squareOfPiece(piece);
          if (square == null) {
            selectSquare(square);
          }
          else if (square != squareSelected) {
            var move = Move(squareSelected, square);
            var codePNG = makeMove(move);
            if (codePNG == null) {
              selectSquare(square);
            }
            else {
              setState(() {
                squareSelected = null;
                squaresValid = [];
              });
            }
          }
        },
        onPanStart: (pan) {
          var square = game.squareOfPiece(piece);
          selectSquare(square);
        },
        onPanUpdate: (pan) {
          var offset = Offset(offsets[piece].dx + pan.delta.dx, offsets[piece].dy + pan.delta.dy);
          setState(() {
            offsets[piece] = offset;
          });
        },
        onPanEnd: (pan) {
//          setState(() {
//            squareSelected = null;
//            squaresValid = [];
//          });
          var offset = offsets[piece];
          var square1 = game.squareOfPiece(piece);
          var square2 = squareFromOffset(offset);
          var move = Move(square1, square2);
          makeMove(move);
        },
        child: Container(
          child: WidgetPiece.withPiece(piece),
          height: MediaQuery.of(context).size.height / 8 * 1,
          width: MediaQuery.of(context).size.height / 8 * 1,
        ),
      ),
    );
  }

  Widget widgetSquareSelection(Square square) {
    var offset = offsetFromSquare(square);
    return Positioned(
      left: offset.dx,
      top: offset.dy,
      child: Container(
        color: colorSelection,
        height: MediaQuery.of(context).size.height / 8 * 1,
        width: MediaQuery.of(context).size.height / 8 * 1,
      ),
    );
  }

  Widget widgetSquareLast(Square square) {
    var offset = offsetFromSquare(square);
    return Positioned(
      left: offset.dx,
      top: offset.dy,
      child: Container(
        color: colorSelection,
        height: MediaQuery.of(context).size.height / 8 * 1,
        width: MediaQuery.of(context).size.height / 8 * 1,
      ),
    );
  }

  Widget widgetSquareValid(Square square) {
    var offset = offsetFromSquare(square);
    return Positioned(
      left: offset.dx + MediaQuery.of(context).size.height / 8*3/4/2,
      top: offset.dy + MediaQuery.of(context).size.height / 8*3/4/2,
      child: ClipOval(
          child: Container(
            color: colorSquareValid,
            height: MediaQuery.of(context).size.height / 8 / 4,
            width: MediaQuery.of(context).size.height / 8 / 4,
          )
      ),
    );
  }

  Widget widgetCode(String code, int index) {
    var isLast = index == codesMoves.length - 1;
    return GestureDetector(
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
                fontSize: SIZE_PNG,
                fontWeight: FontWeight.normal,
              ),
            ),
            color: isLast ? colorPNGSelected : Colors.transparent,
            padding: EdgeInsets.symmetric(
                horizontal: isLast ? INSET_CONTAINER_PNG : 0.0),
          )
      ),
      onTapDown: (_) {
//        if (index != indexPosition) {
//          print(indexPosition);
//          indexPosition = index;
//          var offsets = calculateOffsets();
//          setState(() {
//            this.offsets = offsets;
//          });
//        }
      },
      onPanUpdate: (_) {
//        if (index != indexPosition) {
//          print(index);
//          indexPosition = index;
//          var offsets = calculateOffsets();
//          setState(() {
//            this.offsets = offsets;
//          });
//        }
      },
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
        setState(() {
          showsAlert = false;
        });
      },
    );
  }

  // UTIL
  // ...
  // ...
  Offset offsetFromSquare(Square square) {
    var dx = (square.column - 1.0) * MediaQuery.of(context).size.height / 8;
    var dy = (9.0 - square.row - 1.0) * MediaQuery.of(context).size.height / 8;
    return Offset(dx, dy);
  }

  Square squareFromOffset(Offset offset) {
    var column = (offset.dx / MediaQuery.of(context).size.height / 8 + 1.0).round();
    var row = -1 * (1.0 + offset.dy / MediaQuery.of(context).size.height / 8 - 9.0).round();
    return Square(column, row);
  }

  getColorBoard() async {
    var indexAccent = await Defaults.getInt(Defaults.INDEX_ACCENT);
    if (indexAccent != null) {
      setState(() {
        colorBoard = Colors.accents[indexAccent];
      });
    } else {
      setState(() {
        var indexRandom = Random().nextInt(Colors.accents.length - 1);
        colorBoard = Colors.accents[indexRandom];
      });
    }
  }

  startGame() async {

    await Future.delayed(Duration(seconds: 2));

    game = Game.standard();
    timer = Timer(timeTotal: 300.0);

    listPositions = [game.board];
    displayPositionAtIndex(listPositions.length - 1);

    setState(() {
      this.offsets = offsets;
      codesMoves = [];
      this.timeTotalLight = timer.timeTotal;
      this.timeTotalDark = timer.timeTotal;
    });
  }

  makeMove(Move move) {

    // TODO: return if not in last position

    var movePNG = game.makeMove(move);

    if (movePNG != null) {

      listPositions.add(game.board);

      setState(() {
        codesMoves.add(movePNG);
      });

      timer.addTimestampEnd();
      timer.addTimestampStart();

      // start game
      if (game.moves.length == 1) {
        startTimer();
      }

      // show alert: CHECKMATE! or stalemate
      if (game.state != StateGame.ongoing) {
        timer.stop();
        setState(() {
          showsAlert = true;
        });
      }
    }

    displayPositionAtIndex(listPositions.length - 1);
  }

  displayPositionAtIndex(int index) {
    var position = listPositions[index];
    var offsets = calculateOffsets(position);
    print(game.moves.length);
    var moveLast = max(0, index - 1) < game.moves.length ? game.moves[index - 1] : null;
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

  selectSquare(Square square) {
    var squaresValid = game.validMoves(square).map((move) => move.square2).toList();
    setState(() {
      squareSelected = square;
      this.squaresValid = squaresValid;
    });
  }

  startTimer() {
    timer.start().listen((time) {
      setState(() {
        timeTotalLight = timer.timeLight;
        timeTotalDark = timer.timeDark;
        showsAlert = timeTotalLight == 0 || timeTotalDark == 0;
      });
    });
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
    var intInterval = interval.toInt();
    var minutes = intInterval ~/ 60;
    var seconds = (intInterval % 60);
    var minutesPadded = minutes < 10 ? "0$minutes" : minutes;
    var secondsPadded = seconds < 10 ? "0$seconds" : seconds;
    return "$minutesPadded:$secondsPadded";
  }
}
