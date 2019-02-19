
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'Color.dart';
import 'ScrollBehavior.dart';
import 'Game.dart';
import 'WidgetPiece.dart';

class WidgetGame extends StatefulWidget {
  WidgetGame({Key key}) : super(key: key);

  @override
  WidgetGameState createState() => WidgetGameState();
}

class WidgetGameState extends State<WidgetGame> {
  Game game;
  var isLightOrientation = true;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays([]);
    game = Game.standard();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          child: ScrollConfiguration(
            behavior: ScrollBehaviorClean(),
            child: GridView.count(
              scrollDirection: Axis.horizontal,
              crossAxisCount: 8,
              children: List.generate(64, (index) {
                var column = index ~/ 8;
                var row = index % 8;
                var rowNormal = 7 - row;
                var square = Square(column + 1, rowNormal + 1);
                var piece = game.pieceAtSquare(square);
                return Container(
                  color: (index % 2) != (column % 2) ? Color.dark : Color.light,
                  child: DragTarget(builder: (context, List<String> candidateData, rejectedData) {
                    if (piece != null) {
                      return Draggable(
                        child: WidgetPiece.withPiece(
                          piece,
                        ),
                        feedback: Container(
                          child: WidgetPiece.withPiece(
                            piece,
                          ),
                          height: MediaQuery.of(context).size.height / 6,
                          width: MediaQuery.of(context).size.height / 6,
                        ),
                        childWhenDragging: Container(),
                        data: square,
                        onDragStarted: () {
                          var movesValid = game.validMoves(square);
                        },
                      );
                    }
                    return Container();
                  },
                    onWillAccept: (data) {
                      var square1 = data as Square;
                      var move = Move(square1, square);
                      return game.isMoveValid(move);
                    },
                    onAccept: (data) {
                      var square1 = data as Square;
                      var move = Move(square1, square);
                      setState(() {
                        game.makeMove(move);
                      });
                    },
                  )
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
