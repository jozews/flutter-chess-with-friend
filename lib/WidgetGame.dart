
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';

import 'Color.dart';
import 'Game.dart';
import 'Timer.dart';

import 'ScrollBehavior.dart';
import 'WidgetPiece.dart';


class WidgetGame extends StatefulWidget {
  WidgetGame({Key key}) : super(key: key);

  @override
  WidgetGameState createState() => WidgetGameState();
}


class WidgetGameState extends State<WidgetGame> {

  static const COLOR_BACKGROUND_1 = Colors.white;
  static const COLOR_BACKGROUND_2 = Colors.black87;
  static const SIZE_TIME = 26.0;
  static const MARGIN_EDGE_TIME = 12.0;

  Game game;
  Timer timer;
  FlutterBlue flutterBlue;

  var timeTotalLight = 600.0;
  var timeTotalDark = 600.0;

  var isLightOrientation = true;
  var showsAlert = false;

  Map<Piece, Offset> offsets = {};

  Square squareSelected;
  Square squareCheck;
  List<Square> squaresValid = [];

  Move moveLast;
  Move movePre;

  get heightSquare => MediaQuery.of(context).size.height/8;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays([]);
    startGame();
//    startScanning();
  }

  Offset offsetFromSquare(Square square) {
    var dx = (square.column - 1.0)*heightSquare;
    var dy = (9.0 - square.row - 1.0)*heightSquare;
    return Offset(dx, dy);
  }

  Square squareFromOffset(Offset offset) {
    var column = (offset.dx/heightSquare + 1.0).round();
    var row = -1*(1.0 + offset.dy/heightSquare - 9.0).round();
    return Square(column, row);
  }

  startScanning() {
    flutterBlue = FlutterBlue.instance;
    flutterBlue.scan().listen((scanResult) {
      print(scanResult.device.name);
      print(scanResult.device.type);
    });
  }


  startGame() async {

    await Future.delayed(Duration(seconds: 1));

    game = Game.standard();
    timer = Timer(timeTotal: 300.0);

    var offsets = Map.fromIterable(game.board.entries, key: (entry) => entry.value as Piece, value: (entry) {
      var square = entry.key;
      var offset = offsetFromSquare(square);
      return offset;
    });

    setState(() {
      this.offsets = offsets;
    });

    setState(() {
      this.timeTotalLight = timer.timeTotal;
      this.timeTotalDark = timer.timeTotal;
    });

  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        children: <Widget>[
          Container(
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    color: COLOR_BACKGROUND_2,
                  ),
                ),
                AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    child: ScrollConfiguration(
                      behavior: ScrollBehaviorClean(),
                      child: Stack(
                        children: <Widget>[
                          GridView.count(
                            scrollDirection: Axis.horizontal,
                            crossAxisCount: 8,
                            children: List.generate(64, (index) {
                              var column = index ~/ 8;
                              var row = 7 - (index % 8);
                              var square = Square(column + 1, row + 1);
                              var color = (index % 2) != (column % 2) ? Color.dark : Color.light;
                              return GestureDetector(
                                child: Container(
                                    color: color
                                ),
                                onTapUp: (tap) {
                                  var move = Move(squareSelected, square);
                                  if (square != squareSelected) {
                                    makeMove(move);
                                    setState(() {
                                      squareSelected = null;
                                    });
                                  }
                                },
                              );
                            }),
                          )
                        ] + offsets.entries.map<Widget>((entry) {
                          var piece = entry.key;
                          return Positioned(
                            left: offsets[entry.key].dx,
                            top: offsets[entry.key].dy,
                            child: GestureDetector(
                              onTapDown: (tap) {
                                var square = game.squareOfPiece(piece);
                                if (squareSelected == null) {
                                  setState(() {
                                    squareSelected = square;
                                  });
                                }
                                else {
                                  // hint new move
                                }
                              },
                              onTapUp: (tap) {
                                var square = game.squareOfPiece(piece);
                                var move = Move(squareSelected, square);
                                if (square != squareSelected) {
                                  makeMove(move);
                                  setState(() {
                                    squareSelected = null;
                                  });
                                }
                              },
                              onPanStart: (pan) {

                              },
                              onPanUpdate: (pan) {
                                var offset = Offset(offsets[piece].dx + pan.delta.dx, offsets[piece].dy + pan.delta.dy);
                                setState(() {
                                  offsets[piece] = offset;
                                });
                              },
                              onPanEnd: (pan) {
                                var offset = offsets[piece];
                                var square1 = game.squareOfPiece(piece);
                                var square2 = squareFromOffset(offset);
                                var move = Move(square1, square2);
                                makeMove(move);
                              },
                              child: Container(
                                child: WidgetPiece.withPiece(piece),
                                height: heightSquare*1,
                                width: heightSquare*1,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    color: COLOR_BACKGROUND_2,
                    child: Stack(
                      children: <Widget>[
                        Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                            child: Text(
                              !isLightOrientation ? getFormattedInterval(timeTotalLight) : getFormattedInterval(timeTotalDark),
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: SIZE_TIME,
                                  fontWeight: FontWeight.w500
                              ),
                            ),
                            margin: EdgeInsets.only(
                                top: MARGIN_EDGE_TIME
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            child: Text(
                              isLightOrientation ? getFormattedInterval(timeTotalLight) : getFormattedInterval(timeTotalDark),
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: SIZE_TIME,
                                  fontWeight: FontWeight.w500
                              ),
                            ),
                            margin: EdgeInsets.only(
                                bottom: MARGIN_EDGE_TIME
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
              mainAxisAlignment: MainAxisAlignment.center,
            ),
            color: COLOR_BACKGROUND_1,
          ),
          GestureDetector(
            child: Container(
              color: showsAlert ? Colors.black45 : Colors.transparent,
            ),
            onTap: () {
              setState(() {
                showsAlert = false;
              });
            },
          ),
          showsAlert ? Center(
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(5.0),
                  topRight: Radius.circular(5.0),
                  bottomRight: Radius.circular(5.0),
                  bottomLeft: Radius.circular(5.0)
              ),
              child: Container(
                child: Text(getAlertTitle()),
                color: Colors.white,
                padding: EdgeInsets.all(25.0),
              ),
            ),
          ) : Container(),
        ],
      ),
    );
  }

  makeMove(Move move) {

    var isValid = game.makeMove(move);

    if (isValid) {
      timer.addTimestampEnd();
      timer.addTimestampStart();
      // start game
      if (game.moves.length == 1) {
        startTimer();
      }
      // update state view
      if (game.state != StateGame.ongoing) {
        timer.stop();
        setState(() {
          showsAlert = true;
        });
      }
    }

    var offsets = calculateOffsets();
    setState(() {
      this.offsets = offsets;
    });
  }

  Map<Piece, Offset> calculateOffsets() {
    return Map.fromIterable(game.board.entries, key: (entry) => entry.value as Piece, value: (entry) {
      var square = entry.key;
      var offset = offsetFromSquare(square);
      return offset;
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
      return "Time us up";
    }
    if (timer.timeDark == 0) {
      return "Time us up";
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