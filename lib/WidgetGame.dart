
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';

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

  static var COLOR_BACKGROUND_1 = Colors.black.withAlpha((0.8*255).toInt());
  static const COLOR_BACKGROUND_2 = Colors.white;
  static const SIZE_TIME = 26.0;
  static const MARGIN_EDGE_TIME = 12.0;

  Game game;
  Timer timer;
  FlutterBlue flutterBlue;

  Color colorBoard = Colors.blueGrey;

  double timeTotalLight;
  double timeTotalDark;

  var isLightOrientation = true;
  var showsAlert = false;

  Map<Piece, Offset> offsets = {};
  Map<Piece, Offset> offsetsPanning = {};

  Square squareSelected;
  Square squareCheck;
  List<Square> squaresValid = [];

  Move moveLast;
  Move movePre;

  get heightSquare => MediaQuery.of(context).size.height/8;

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
  
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays([]);
    startGame();
    getDefaultColorBoard();
//    startScanning();
  }

  getDefaultColorBoard() async {
    var hexColor = await Defaults.getInt(Defaults.COLOR);
    if (hexColor != null) {
      setState(() {
        colorBoard = Color(hexColor);
      });
    }
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
                    color: COLOR_BACKGROUND_1,
                  ),
                ),
                AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    child: ScrollConfiguration(
                      behavior: ScrollBehaviorClean(),
                      child: Stack(
                        children: <Widget>[
                          Container(
                            child: GridView.count(
                              scrollDirection: Axis.horizontal,
                              crossAxisCount: 8,
                              children: List.generate(64, (index) {
                                var column = index ~/ 8;
                                var row = 7 - (index % 8);
                                var square = Square(column + 1, row + 1);
                                var color = (index % 2) != (column % 2) ? colorBoard : colorBoard.withAlpha((0.4*255).toInt());
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
                            ),
                            color: Colors.white,
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
                                setState(() {
                                  var offsetRemoved = offsets.remove(piece);
                                  offsetsPanning[piece] = offsetRemoved;
                                });
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
                        }).toList() + offsetsPanning.entries.map<Widget>((entry) {
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
                                setState(() {
                                  var offsetRemoved = offsetsPanning.remove(piece);
                                  offsets[piece] = offsetRemoved;
                                });
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
                    color: COLOR_BACKGROUND_1,
                    child: Stack(
                      children: <Widget>[
                        timeTotalLight != null ? Align(
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
                        ) : Container(),
                        timeTotalLight != null ? Align(
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
                        ) : Container()
                      ],
                    ),
                  ),
                ),
              ],
              mainAxisAlignment: MainAxisAlignment.center,
            ),
            color: COLOR_BACKGROUND_2,
          ),
          showsAlert ? GestureDetector(
            child: Container(
              color: Colors.black45,
            ),
            onTap: () {
              setState(() {
                showsAlert = false;
              });
            },
          ) : Container(),
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