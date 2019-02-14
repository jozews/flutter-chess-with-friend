
import 'dart:core';

import 'package:quiver/core.dart';

enum TypePiece {
  king, queen, bishop, knight, rook, pawn
}


enum ColorPiece {
  white, black
}



class Piece {

  Square squareFirst;
  TypePiece type;
  ColorPiece color;

  Piece(this.type, this.color, this.squareFirst);

  bool operator ==(o) => o is Piece && o.squareFirst == squareFirst;
  int get hashCode => squareFirst.hashCode;
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

  Game.standard() {
    pieces = piecesStandard();
    state = StateGame.ongoing;
    colorToMove = ColorPiece.white;
    moves = [];
  }

  Map<Square, Piece> piecesStandard() {
      
    var pieces = Map<Square, Piece>();
    var columns = List<int>.generate(8, (i) => 1 + i);

    // white pieces
    // ...
    for (int column in columns) {
      var rows = List<int>.generate(2, (i) => 1 + i) + List<int>.generate(2, (i) => 6 + i);
      for (int row in rows) {
        var square = Square(column, row);
        var color = row == 1 || row == 2 ? ColorPiece.white : ColorPiece.black;
        if (row == 1 || row == 8) {
          if (column == 1 || column == 8) {
            pieces[square] = Piece(TypePiece.rook, color, square);
          }
          else if (column == 2 || column == 7) {
            pieces[square] = Piece(TypePiece.knight, color, square);
          }
          else if (column == 3 || column == 6) {
            pieces[square] = Piece(TypePiece.bishop, color, square);
          }
          else if (column == 4) {
            pieces[square] = Piece(TypePiece.queen, color, square);
          }
          else {
            pieces[square] = Piece(TypePiece.king, color, square);
          }
        }
        else {
          pieces[square] = Piece(TypePiece.pawn, color, square);
        }
      }
    }

    return pieces;
  }

  List<Square> getSquaresFinalForMovesValid(Square squareInitial) {

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


  // * CAN BE OPTIMIZED
  bool isMoveValid(Move move) {
    var squaresFinalValid = getSquaresFinalForMovesValid(move.squareInitial);
    var isMoveFinalInSquaresFinalValid = squaresFinalValid.where((squareFinal) => squareFinal == move.squareFinal).isNotEmpty;
    return isMoveFinalInSquaresFinalValid;
  }

  bool makeMovePNG(String png) {
    Square squareInitial;
    Square squareFinal;
    var move = Move(squareInitial, squareFinal);
    return makeMove(move);
  }

  bool makeMove(Move move, {TypePiece typePiecePromotion}) {

    // validate move
    // ...
    if (isMoveValid(move)) {
      return false;
    }

    var isPromotion = isMovePromotion(move);
    if (isPromotion && typePiecePromotion == null) {
      return false;
    }

    // make move
    // ...
    var isCastling = isMoveCastling(move);
    var isEnPassant = isMoveEnPassant(move);
    // * Update board after checking isMoveCastling and isMoveEnPassant because need to review state of the board before move 
    var pieceMoved = pieces.remove(move.squareInitial);
    if (isPromotion) {
      pieceMoved.type = typePiecePromotion;
    }
    else {
      // if castling move rook
      if (isCastling) {
        var columnInitialRook = move.squareFinal.column - move.squareInitial.column > 0 ? 8 : 1;
        var squareInitialRook = Square(columnInitialRook, move.squareInitial.row);
        var columnFinalRook = (move.squareInitial.column + move.squareFinal.column) ~/ 2;
        var squareFinalRook = Square(columnFinalRook, move.squareInitial.row);
        var pieceRook = pieces.remove(squareInitialRook);
        pieces[squareFinalRook] = pieceRook;
      }
      // if en passant remove taken pawn
      else if (isEnPassant) {
        var squareOfCapture = Square(move.squareFinal.column, move.squareInitial.row);
        pieces.remove(squareOfCapture);
      }
    }
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
    var squaresKingFinalValid = getSquaresFinalForMovesValid(squareKing);
    var entryPiecesColorToMoveOpposite = getEntriesPiecesFiltered(null, colorToMoveOpposite);
    var pathsCheckingKing = entryPiecesColorToMoveOpposite.map<List<Square>>((entryPiece) => pathOfPieceToSquare(entryPiece.value, squareKing));

    // checkmate
    // ...
    if (pathsCheckingKing.isNotEmpty && squaresKingFinalValid.isEmpty) {
      if (pathsCheckingKing.length == 1) {
        var canCheckmateBeCovered = false;
        var piecesColorToMove = getEntriesPiecesFiltered(null, colorToMove).where((entry) => entry.value.type != TypePiece.king);
        for (MapEntry<Square, Piece> pieceColorToMove in piecesColorToMove) {
          var squaresPieceFinalValid = getSquaresFinalForMovesValid(pieceColorToMove.key);
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
        if (getSquaresFinalForMovesValid(piece.key).isNotEmpty) {
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

  
  // * DOES NOT VALIDATES MOVE
  bool isMovePromotion(Move move) {
    var piece = pieces[move.squareInitial];
    if (piece == null || piece.type != TypePiece.pawn) {
      return false;
    }
    var promotionRow = piece.color == ColorPiece.white ? 8 : 1;
    var isSquareFinalPromotionRow = move.squareFinal.row == promotionRow;
    return isSquareFinalPromotionRow;
  }


  // * DOES NOT VALIDATES
  bool isMoveCastling(Move move) {
    var piece = pieces[move.squareInitial];
    if (piece == null || piece.type != TypePiece.king) {
      return false;
    }
    var isColumnDeltaAbsoluteMoreThan1 = (move.squareInitial.column - move.squareFinal.column).abs() > 1;
    return isColumnDeltaAbsoluteMoreThan1;
  }


  bool isMoveEnPassant(Move move) {
    if (moves.isEmpty) {
      return false;
    }
    var moveLast = moves[moves.length -1];
    var pieceMoveLast = pieces[moveLast.squareFinal];
    if (pieceMoveLast == null) {
      return false;
    }
    var isPieceMoveLastPawn = pieceMoveLast.type == TypePiece.pawn;
    if (!isPieceMoveLastPawn) {
      return false;
    }
    var isMoveLastDoublePawn = (moveLast.squareInitial.row - moveLast.squareFinal.row).abs() == 2;
    if (!isMoveLastDoublePawn) {
      return false;
    }    
    var arePiecesInSameRow = moveLast.squareFinal.row == move.squareInitial.row;
    if (!arePiecesInSameRow) {
      return false;
    }
    var arePiecesInAdjacentColumns = (moveLast.squareInitial.column - move.squareInitial.column).abs() == 1;
    if (!arePiecesInAdjacentColumns) {
      return false;
    }
    var willPiecesBeInSameColumn = moveLast.squareInitial.column == move.squareFinal.column;
    if (!willPiecesBeInSameColumn) {
      return false;
    }
    return true;
  }


  List<List<Square>> pathsOfPiece(Piece piece, {isChecking = true, withPinning = false}) {

    var square = squareOfPiece(piece);

    List<List<Square>> paths = [];

    switch (piece.type) {

      case TypePiece.king:
        var deltas = [[1, 1], [1, 0], [1, -1], [0, 1], [0, -1], [-1, 1], [-1, 0], [-1, -1], [2, 0], [-2, 0]];
        for (List<int> delta in deltas) {
          List<Square> path = [];
          var squarePath = Square(square.column , square.row);
          if (isChecking) {
            path.add(squarePath);
          }
          squarePath = Square(squarePath.column + delta[0], squarePath.row + delta[1]);
          var pieceAtSquarePath = pieces[squarePath];
          if (delta[0].abs() <= 1 && delta[1].abs() <= 1) {
            if (pieceAtSquarePath == null || pieceAtSquarePath.color != colorToMove) {
              path.add(squarePath);
            }
            paths.add(path);
          }
          else if (!isChecking && isMoveCastling(Move(square, squarePath))) {
            path.add(squarePath);
            paths.add(path);
          }
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
          if (!isChecking && delta[1] == 0) {
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
            var isEnPassant = isMoveEnPassant(Move(square, squarePath));
            if ((pieceAtSquarePath != null && pieceAtSquarePath.color != colorToMove) || isEnPassant) {
              path.add(squarePath);
            }
            paths.add(path);
          }
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