
import 'dart:core';

import 'package:quiver/core.dart';

enum TypePiece {
  king, queen, bishop, knight, rook, pawn
}


enum ColorPiece {
  white, black
}



class Piece {

  Square squareAtStart;
  TypePiece type;
  ColorPiece color;

  Piece(this.type, this.color, this.squareAtStart);

  bool operator ==(o) => o is Piece && o.squareAtStart == squareAtStart;
  int get hashCode => squareAtStart.hashCode;
}



enum StateGame {
  ongoing, checkmateByWhite, checkmateByBlack, stalemate
}



class Square {

  int column;
  int row;

  Square(this.column, this.row);
  
  bool get inBounds => column >= 1 && column <= 8 && row >= 1 && row <= 8;
  
  bool operator ==(o) => o is Square && o.column == column && o.row == row;
  int get hashCode => hash2(column.hashCode, row.hashCode);
}



class Move {

  Square squareInitial;
  Square squareFinal;

  Move(this.squareInitial, this.squareFinal);
}



class Game {

  Map<Square, Piece> pieces;
  StateGame state;
  ColorPiece colorToMove;
  List<Move> moves;


  List<Square> getSquaresFinalValid(Square squareInitial) {

    var pieceAtSquareInitial = pieces[squareInitial];

    // return empty
    // ...
    if (pieceAtSquareInitial != null || pieceAtSquareInitial.color != colorToMove) {
      return [];
    }

    // get checks of king color to move
    // ...
    var entryPieceKingColorToMove = getEntriesPiecesFiltered(TypePiece.king, colorToMove).first;
    var squareKingColorToMove = entryPieceKingColorToMove.key;
    var colorToMoveOpposite = colorToMove == ColorPiece.white ? ColorPiece.black : ColorPiece.white;
    var entryPiecesColorToMoveOpposite = getEntriesPiecesFiltered(null, colorToMoveOpposite);
    var pathsChecking = entryPiecesColorToMoveOpposite.map<List<Square>>((entryPiece) => pathOfPieceToSquare(entryPiece.value, squareKingColorToMove));

    // if double check and king does not move return empty
    // ...
    if (pathsChecking.length == 2 && pieceAtSquareInitial.type != TypePiece.king) {
      return [];
    }

    // adds squares
    // ...
    // ...
    List<Square> squaresFinalValid = pathsOfPiece(pieceAtSquareInitial, isChecking: false).expand((i) => i).toList();

    switch (pieceAtSquareInitial.type) {

      case TypePiece.king:
        var deltas = [[1, 1], [1, 0], [1, -1], [0, 1], [0, -1], [-1, 1], [-1, 0], [-1, -1]];
        var squaresWithDelta = deltas.map<Square>((delta) => Square(squareInitial.column + delta[0], squareInitial.row + delta[1]));
        squaresFinalValid = squaresWithDelta.where((square) => square.inBounds);
        break;

      case TypePiece.queen:
        var deltas = [[1, 1], [1, 0], [1, -1], [0, 1], [0, -1], [-1, 1], [-1, 0], [-1, -1]];
        for (List<int> delta in deltas) {
          var squareWithDelta = Square(squareInitial.column + delta[0], squareInitial.row + delta[1]);
          while (squareWithDelta.inBounds) {
            var pieceAtSquare = pieces[squareWithDelta];
            if (pieceAtSquare != null && pieceAtSquare.color == colorToMove) {
              break;
            }
            squaresFinalValid.add(squareWithDelta);
            squareWithDelta = Square(squareInitial.column + delta[0], squareInitial.row + delta[1]);
            if (pieceAtSquare != null && pieceAtSquare.color != colorToMove) {
              break;
            }
          }
        }
        break;

      case TypePiece.bishop:
        var deltas = [[1, 1], [1, -1], [-1, 1], [-1, -1]];
        for (List<int> delta in deltas) {
          var squareWithDelta = Square(squareInitial.column + delta[0], squareInitial.row + delta[1]);
          while (squareWithDelta.inBounds) {
            var pieceAtSquare = pieces[squareWithDelta];
            if (pieceAtSquare != null && pieceAtSquare.color == colorToMove) {
              break;
            }
            squaresFinalValid.add(squareWithDelta);
            squareWithDelta = Square(squareInitial.column + delta[0], squareInitial.row + delta[1]);
            if (pieceAtSquare != null && pieceAtSquare.color != colorToMove) {
              break;
            }
          }
        }
        break;

      case TypePiece.knight:
        var deltas = [[2, 1], [2, -1], [1, 2], [1, -2], [-1, 2], [-1, -2], [-2, 1], [-2, -1]];
        var squaresWithDelta = deltas.map<Square>((delta) => Square(squareInitial.column + delta[0], squareInitial.row + delta[1]));
        squaresFinalValid = squaresWithDelta.where((square) => square.inBounds);
        break;

      case TypePiece.rook:
        var deltas = [[1, 0], [0, 1], [0, -1], [-1, 0]];
        for (List<int> delta in deltas) {
          var squareWithDelta = Square(squareInitial.column + delta[0], squareInitial.row + delta[1]);
          while (squareWithDelta.inBounds) {
            var pieceAtSquare = pieces[squareWithDelta];
            if (pieceAtSquare != null && pieceAtSquare.color == colorToMove) {
              break;
            }
            squaresFinalValid.add(squareWithDelta);
            squareWithDelta = Square(squareInitial.column + delta[0], squareInitial.row + delta[1]);
            if (pieceAtSquare != null && pieceAtSquare.color != colorToMove) {
              break;
            }
          }
        }
        break;

      case TypePiece.pawn:
        var direction = pieceAtSquareInitial.color == ColorPiece.white ? 1 : -1;
        var deltas = [[-1, direction], [0, direction], [1, direction]];
        for (List<int> delta in deltas) {
          var squareWithDelta = Square(squareInitial.column + delta[0], squareInitial.row + delta[1]);
          var pieceAtSquareWithDelta = pieces[squareWithDelta];
          if (delta[1] == 0 && pieceAtSquareWithDelta == null) {
            squaresFinalValid.add(squareWithDelta);
          }
          else if (delta[1] != 0 && pieceAtSquareWithDelta != null && pieceAtSquareWithDelta.color != pieceAtSquareInitial.color) {
            squaresFinalValid.add(squareWithDelta);
          }
        }
        // TODO: DOUBLE MOVE
        // TODO: EN PASSANT
        break;
    }


    // filter out where square final is not empty or takes piece
    // ...
    squaresFinalValid = squaresFinalValid.where((squareFinal) {
      var pieceAtSquareFinal = pieces[squareFinal];
      return pieceAtSquareFinal == null || pieceAtSquareFinal.color != colorToMove;
    });

    // filter out where king steps into checking path
    // ...
    if (pieceAtSquareInitial.type == TypePiece.king) {
      squaresFinalValid = squaresFinalValid.where((squareFinal) {
        for (MapEntry<Square, Piece> entryPiece in entryPiecesColorToMoveOpposite) {
          var pathCheckingIsNotEmpty = pathOfPieceToSquare(entryPiece.value, squareFinal).isNotEmpty;
          if (!pathCheckingIsNotEmpty) {
            return false;
          }
        }
        return true;
      });
    }

    // if square initial is in pin path filter out where square leaves pinning path
    // ...
    var pathsPinning = entryPiecesColorToMoveOpposite.map<List<Square>>((entryPiece) => pathOfPieceToSquare(entryPiece.value, squareKingColorToMove, withPinning: true));
    for (List<Square> pathPinning in pathsPinning) {
      var isSquareInitialInPathCheck = pathPinning.contains(squareInitial);
      if (isSquareInitialInPathCheck) {
        squaresFinalValid = squaresFinalValid.where((square) => pathPinning.contains(squaresFinalValid));
      }
    }

    // if single check square filter out where square not in checking path
    // ...
    if (pathsChecking.length == 1) {
      squaresFinalValid.where((squareFinal) {
        var pathChecking = pathsChecking.first;
        var isSquareFinalInPathChecking = pathChecking.contains(squareFinal);
        return isSquareFinalInPathChecking;
      });
    }

    return squaresFinalValid;
  }


  // NOTE: COULD BE OPTIMIZED
  bool isMoveValid(Move move) {
    var squaresFinalValid = getSquaresFinalValid(move.squareInitial);
    var isMoveFinalInSquaresFinalValid = squaresFinalValid.where((squareFinal) => squareFinal == move.squareFinal).isNotEmpty;
    return isMoveFinalInSquaresFinalValid;
  }


  bool makeMove(Move move) {

    // validate move
    // ...
    if (isMoveValid(move)) {
      return false;
    }

    // make move
    // ...
    var pieceMoved = pieces.remove(move.squareInitial);
    pieces[move.squareFinal] = pieceMoved;
    moves.add(move);

    // toggle color to move
    // ...
    colorToMove = colorToMove == ColorPiece.black ? ColorPiece.white : ColorPiece.black;

    // get checks of king color to move
    // ...
    var colorToMoveOpposite = colorToMove == ColorPiece.black ? ColorPiece.white : ColorPiece.black;
    var entryKing = getEntriesPiecesFiltered(TypePiece.king, colorToMove).first;
    var squareKing = entryKing.key;
    var squaresKingFinalValid = getSquaresFinalValid(squareKing);
    var entryPiecesColorToMoveOpposite = getEntriesPiecesFiltered(null, colorToMoveOpposite);
    var pathsCheckingKing = entryPiecesColorToMoveOpposite.map<List<Square>>((entryPiece) => pathOfPieceToSquare(entryPiece.value, squareKing));

    // checkmate
    // ...
    if (pathsCheckingKing.isNotEmpty && squaresKingFinalValid.isEmpty) {
      if (pathsCheckingKing.length == 1) {
        var canCheckmateBeCovered = false;
        var piecesColorToMove = getEntriesPiecesFiltered(null, colorToMove).where((entry) => entry.value.type != TypePiece.king);
        for (MapEntry<Square, Piece> pieceColorToMove in piecesColorToMove) {
          var squaresPieceFinalValid = getSquaresFinalValid(pieceColorToMove.key);
          var pieceWithValidMoveInCheckingPath = squaresPieceFinalValid.where((squareFinal) => pathsCheckingKing.first.contains(squareFinal));
          if (pieceWithValidMoveInCheckingPath.isNotEmpty) {
            canCheckmateBeCovered = true;
            break;
          }
        }
        if (canCheckmateBeCovered) {
          state = colorToMove == ColorPiece.white ? StateGame.checkmateByBlack : StateGame.checkmateByWhite;
        }
      }
      else {
        state = colorToMove == ColorPiece.white ? StateGame.checkmateByBlack : StateGame.checkmateByWhite;
      }
    }

    // stalemate
    // ...
    else if (pathsCheckingKing.isEmpty && squaresKingFinalValid.isEmpty) {
      var piecesColorToMove = getEntriesPiecesFiltered(null, colorToMove);
      var isStalemate = true;
      for (MapEntry<Square, Piece> piece in piecesColorToMove) {
        if (getSquaresFinalValid(piece.key).isNotEmpty) {
          isStalemate = false;
          break;
        }
      }
      if (isStalemate) {
        state = StateGame.stalemate;
      }
    }

    return true;
  }


  List<List<Square>> pathsOfPiece(Piece piece, {isChecking = true, withPinning = false}) {

    var square = squareOfPiece(piece);

    List<List<Square>> paths = [];

    switch (piece.type) {

      case TypePiece.king:
        var deltas = [[1, 1], [1, 0], [1, -1], [0, 1], [0, -1], [-1, 1], [-1, 0], [-1, -1]];
        for (List<int> delta in deltas) {
          List<Square> path = [];
          var squarePath = Square(square.column , square.row);
          if (isChecking) {
            path.add(squarePath);
          }
          squarePath = Square(squarePath.column + delta[0], squarePath.row + delta[1]);
          var pieceAtSquarePath = pieces[squarePath];
          if (pieceAtSquarePath == null || pieceAtSquarePath.color != colorToMove) {
            path.add(squarePath);
          }
          paths.add(path);
        }
        break;

      case TypePiece.queen:
        var deltas = [[1, 1], [1, 0], [1, -1], [0, 1], [0, -1], [-1, 1], [-1, 0], [-1, -1]];
        for (List<int> delta in deltas) {
          List<Square> path = [];
          var isPinning = false;
          var squarePath = Square(square.column , square.row);
          if (isChecking) {
            path.add(squarePath);
          }
          while (squarePath.inBounds) {
            squarePath = Square(squarePath.column + delta[0], squarePath.row + delta[1]);
            var pieceAtSquarePath = pieces[squarePath];
            if (pieceAtSquarePath != null && pieceAtSquarePath.color == colorToMove) {
              break;
            }
            path.add(squarePath);
            if (pieceAtSquarePath != null && pieceAtSquarePath.color != colorToMove) {
              if (!withPinning || isPinning) {
                break;
              }
              isPinning = true;
            }
          }
          paths.add(path);
        }
        break;

      case TypePiece.bishop:
        var deltas = [[1, 1], [1, -1], [-1, 1], [-1, -1]];
        for (List<int> delta in deltas) {
          List<Square> path = [];
          var isPinning = false;
          var squarePath = Square(square.column , square.row);
          if (isChecking) {
            path.add(squarePath);
          }
          while (squarePath.inBounds) {
            squarePath = Square(squarePath.column + delta[0], squarePath.row + delta[1]);
            var pieceAtSquarePath = pieces[squarePath];
            if (pieceAtSquarePath != null && pieceAtSquarePath.color == colorToMove) {
              break;
            }
            path.add(squarePath);
            if (pieceAtSquarePath != null && pieceAtSquarePath.color != colorToMove) {
              if (!withPinning || isPinning) {
                break;
              }
              isPinning = true;
            }
          }
          paths.add(path);
        }
        break;

      case TypePiece.knight:
        var deltas = [[2, 1], [2, -1], [1, 2], [1, -2], [-1, 2], [-1, -2], [-2, 1], [-2, -1]];
        for (List<int> delta in deltas) {
          List<Square> path = [];
          var squarePath = Square(square.column , square.row);
          if (isChecking) {
            path.add(squarePath);
          }
          squarePath = Square(squarePath.column + delta[0], squarePath.row + delta[1]);
          var pieceAtSquarePath = pieces[squarePath];
          if (pieceAtSquarePath == null || pieceAtSquarePath.color != colorToMove) {
            path.add(squarePath);
          }
          paths.add(path);
        }
        break;

      case TypePiece.rook:
        var deltas = [[1, 0], [0, 1], [0, -1], [-1, 0]];
        for (List<int> delta in deltas) {
          List<Square> path = [];
          var isPinning = false;
          var squarePath = Square(square.column , square.row);
          if (isChecking) {
            path.add(squarePath);
          }
          while (squarePath.inBounds) {
            squarePath = Square(squarePath.column + delta[0], squarePath.row + delta[1]);
            var pieceAtSquarePath = pieces[squarePath];
            if (pieceAtSquarePath != null && pieceAtSquarePath.color == colorToMove) {
              break;
            }
            path.add(squarePath);
            if (pieceAtSquarePath != null && pieceAtSquarePath.color != colorToMove) {
              if (!withPinning || isPinning) {
                break;
              }
              isPinning = true;
            }
          }
          paths.add(path);
        }
        break;

      case TypePiece.pawn:
        var direction = piece.color == ColorPiece.white ? 1 : -1;
        var deltas = [[-1, direction], [0, direction], [1, direction]];
        for (List<int> delta in deltas) {
          List<Square> path = [];
          var squarePath = Square(square.column , square.row);
          if (isChecking) {
            path.add(squarePath);
          }
          if (delta[1] == 0 && !isChecking) {
            while (squarePath.inBounds) {
              squarePath = Square(squarePath.column + delta[0], squarePath.row + delta[1]);
              var pieceAtSquarePath = pieces[squarePath];
              if (pieceAtSquarePath != null) {
                break;
              }
              path.add(squarePath);
            }
            paths.add(path);
          }
          else if (delta[1] != 0) {
            squarePath = Square(squarePath.column + delta[0], squarePath.row + delta[1]);
            var pieceAtSquarePath = pieces[squarePath];
            if (pieceAtSquarePath != null && pieceAtSquarePath.color != colorToMove) {
              path.add(squarePath);
            }
            paths.add(path);
          }
          // TODO: EN PASSANT
        }
        break;

    }

    return paths;
  }


  List<Square> pathOfPieceToSquare(Piece piece, Square square, {isChecking = true, withPinning = false}) {
    var paths = pathsOfPiece(piece, isChecking: isChecking, withPinning: withPinning);
    var pathToSquare = paths.where((path) => path.contains(square));
    if (pathToSquare.isNotEmpty) {
      return pathToSquare.first;
    }
    return [];
  }


  List<MapEntry<Square, Piece>> getEntriesPiecesFiltered(TypePiece type, ColorPiece color) {
    return pieces.entries.where((entry) {
      var piece = entry.value;
      if ((type == null || piece.type == type) && (color == null && piece.color == color)) {
        return true;
      }
      return false;
    }).toList();
  }


  Square squareOfPiece(Piece piece) {
    return pieces.entries.where((entry) => entry.value == piece).first.key;
  }
}