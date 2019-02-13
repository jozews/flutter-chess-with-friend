
import 'dart:core';

import 'package:quiver/core.dart';
import 'package:tuple/tuple.dart';

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
    var tuplesCheckingKing = tuplePiecesAndPathCheckingSquare(squareKingColorToMove, colorToMoveOpposite);

    // if square initial covers a check return empty
    // ...
    for (Tuple2<Piece, List<Square>> tupleCheckingKingColorToMove in tuplesCheckingKing) {
      var squaresToCoverCheck = tupleCheckingKingColorToMove.item2;
      var doesSquareInitialCoversCheck = !squaresToCoverCheck.contains(squareInitial);
      if (doesSquareInitialCoversCheck) {
        return [];
      }
    }

    // if double check and king does not move return empty
    // ...
    if (tuplesCheckingKing.length > 1 && pieceAtSquareInitial.type != TypePiece.king) {
      return [];
    }

    // adds squares
    // ...
    List<Square> squaresFinalValid = [];
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
            squaresFinalValid.add(squareWithDelta);
            squareWithDelta = Square(squareInitial.column + delta[0], squareInitial.row + delta[1]);
          }
        }
        break;
      case TypePiece.bishop:
        var deltas = [[1, 1], [1, -1], [-1, 1], [-1, -1]];
        for (List<int> delta in deltas) {
          var squareWithDelta = Square(squareInitial.column + delta[0], squareInitial.row + delta[1]);
          while (squareWithDelta.inBounds) {
            squaresFinalValid.add(squareWithDelta);
            squareWithDelta = Square(squareInitial.column + delta[0], squareInitial.row + delta[1]);
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
            squaresFinalValid.add(squareWithDelta);
            squareWithDelta = Square(squareInitial.column + delta[0], squareInitial.row + delta[1]);
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
        // TODO: EN PASSANT
        break;
    }

    // filter where king moves out of check or other piece covers check
    // ...
    if (pieceAtSquareInitial.type == TypePiece.king) {
      var colorPieceAtSquareInitialOpposite = pieceAtSquareInitial.color == ColorPiece.black ? ColorPiece.white : ColorPiece.black;
      squaresFinalValid = squaresFinalValid.where((squareFinal) => tuplePiecesAndPathCheckingSquare(squareFinal, colorPieceAtSquareInitialOpposite).isEmpty);
    }
    else if (tuplesCheckingKing.length == 1) {
      squaresFinalValid.where((squareFinal) {
        var squaresToCoverCheck = tuplesCheckingKing.first.item2;
        var doesSquareFinalCoversCheck = squaresToCoverCheck.contains(squareFinal);
        return doesSquareFinalCoversCheck;
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
    var entryKingColorToMove = getEntriesPiecesFiltered(TypePiece.king, colorToMove).first;
    var squareOfKingColorToMove = entryKingColorToMove.key;
    var squaresFinalValidForKingColorToMove = getSquaresFinalValid(squareOfKingColorToMove);
    var colorToMoveOpposite = colorToMove == ColorPiece.black ? ColorPiece.white : ColorPiece.black;
    var tuplesPiecesCheckingKing = tuplePiecesAndPathCheckingSquare(squareOfKingColorToMove, colorToMoveOpposite);

    // checkmate
    // ...
    if (tuplesPiecesCheckingKing.isNotEmpty && squaresFinalValidForKingColorToMove.isEmpty) {
      if (tuplesPiecesCheckingKing.length == 1) {
        var canCheckmateBeCovered = false;
        var piecesColorToMove = getEntriesPiecesFiltered(null, colorToMove).where((entry) => entry.value.type != TypePiece.king);
        for (MapEntry<Square, Piece> pieceColorToMove in piecesColorToMove) {
          var squaresPieceFinalValid = getSquaresFinalValid(pieceColorToMove.key);
          var squaresToCoverCheckmate = tuplesPiecesCheckingKing.first.item2;
          var pieceSquaresFinalValidCoveringCheckmate = squaresPieceFinalValid.where((squareFinal) => squaresToCoverCheckmate.contains(squareFinal));
          if (pieceSquaresFinalValidCoveringCheckmate.isNotEmpty) {
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
    else if (tuplesPiecesCheckingKing.isEmpty && squaresFinalValidForKingColorToMove.isEmpty) {
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


  List<Tuple2<Piece, List<Square>>> tuplePiecesAndPathCheckingSquare(Square square, ColorPiece color) {
    var entryPiecesColor = getEntriesPiecesFiltered(null, color);
    List<Tuple2<Piece, List<Square>>> tuples = [];
    for (MapEntry<Square, Piece> entryPiece in entryPiecesColor) {
      var squarePieceColor = entryPiece.key;
      var squaresFinalValid = getSquaresFinalValid(squarePieceColor);
      var diffColumnSquareAndSquarePieceColor = square.column - squarePieceColor.column;
      var diffRowSquareAndSquarePieceColor = square.row - squarePieceColor.row;
      if (squaresFinalValid.contains(square)) {
        var pathCheck = squaresFinalValid.where((squareFinalValid) {
          var diffColumnSquareAndSquareFinalValid = square.column - squareFinalValid.column;
          var diffRowSquareAndSquareFinalValid = square.row - squareFinalValid.row;
          var areDiffsColumnEqual = diffColumnSquareAndSquarePieceColor == diffColumnSquareAndSquarePieceColor;
          var areDiffsRowEqual = diffRowSquareAndSquarePieceColor == diffRowSquareAndSquarePieceColor;
          var areAbsoluteDiffsColumnSmaller = diffColumnSquareAndSquareFinalValid.abs() < diffColumnSquareAndSquarePieceColor.abs();
          var areAbsoluteDiffsRowSmaller = diffRowSquareAndSquareFinalValid.abs() < diffRowSquareAndSquarePieceColor.abs();
          return (areDiffsColumnEqual || areAbsoluteDiffsColumnSmaller) && (areDiffsRowEqual || areAbsoluteDiffsRowSmaller);
        });
        var tuple = Tuple2(entryPiece.value, pathCheck);
        tuples.add(tuple);
      }
    }
    return tuples;
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