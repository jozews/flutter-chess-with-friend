
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
    var entryPieceKing = getEntriesPiecesFiltered(TypePiece.king, colorToMove).first;
    var squareKing = entryPieceKing.key;
    var colorChecking = colorToMove == ColorPiece.white ? ColorPiece.black : ColorPiece.white;
    var entryPiecesColorChecking = getEntriesPiecesFiltered(null, colorChecking);
    var pathsChecking = entryPiecesColorChecking.map<List<Square>>((entryPiece) => pathOfPieceToSquare(entryPiece.value, squareKing));

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
        for (MapEntry<Square, Piece> entryPiece in entryPiecesColorChecking) {
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
    var pathsPinning = entryPiecesColorChecking.map<List<Square>>((entryPiece) => pathOfPieceToSquare(entryPiece.value, squareKing, withPinning: true));
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
    var entryKing = getEntriesPiecesFiltered(TypePiece.king, colorToMove).first;
    var squareKing = entryKing.key;
    var squaresKingFinalValid = getSquaresFinalForMovesValid(squareKing);
    var colorChecking = colorToMove == ColorPiece.black ? ColorPiece.white : ColorPiece.black;
    var entryPiecesChecking = getEntriesPiecesFiltered(null, colorChecking);
    var pathsChecking = entryPiecesChecking.map<List<Square>>((entryPiece) => pathOfPieceToSquare(entryPiece.value, squareKing));

    // checkmate
    // ...
    if (pathsChecking.isNotEmpty && squaresKingFinalValid.isEmpty) {
      if (pathsChecking.length == 1) {
        var canCheckmateBeCovered = false;
        var piecesColorToMove = getEntriesPiecesFiltered(null, colorToMove).where((entry) => entry.value.type != TypePiece.king);
        for (MapEntry<Square, Piece> pieceColorToMove in piecesColorToMove) {
          var squaresPieceFinalValid = getSquaresFinalForMovesValid(pieceColorToMove.key);
          var pieceWithValidMoveInCheckingPath = squaresPieceFinalValid.where((squareFinal) => pathsChecking.first.contains(squareFinal));
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
    else if (pathsChecking.isEmpty && squaresKingFinalValid.isEmpty) {
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
    if (piece == null) {
      return false;
    }
    var isPieceKing = piece.type == TypePiece.king;
    if (!isPieceKing) {
      return false;
    }
    var isColumnDelta2 = (move.squareInitial.column - move.squareFinal.column).abs() == 2;
    if (!isColumnDelta2) {
      return false;
    }
    var isRowDelta0 = move.squareInitial.row == move.squareFinal.row;
    if (!isRowDelta0) {
      return false;
    }
    var isKingInStartPosition = piece.squareFirst == move.squareInitial;
    if (!isKingInStartPosition) {
      return false;
    }
    var columnRook = move.squareFinal.column > move.squareInitial.column ? 8 : 1;
    var rowRook = piece.color == ColorPiece.white ? 1 : 8;
    var squareRook = Square(columnRook, rowRook);
    var pieceRook = pieces[squareRook];
    if (pieceRook == null) {
      return false;
    }
    for (Move m in moves) {
      // if king has moved return false
      if (m.squareInitial == piece.squareFirst) {
        return false;
      }
      // if rook has moved return false
      if (m.squareInitial == pieceRook.squareFirst) {
        return false;
      }   
    }
    var countColumnsInBetween = (move.squareInitial.column - columnRook).abs() - 1; // -1 to exclude rook square
    var deltaColumn = columnRook == 8 ? 1 : -1;
    var colorChecking = piece.color == ColorPiece.white ? ColorPiece.black : ColorPiece.white;
    for (int column in List<int>.generate(countColumnsInBetween, (i) => move.squareInitial.column + deltaColumn*i)) {
      var square = Square(column, rowRook);
      var pieceAtSquare = pieces[square];
      if (pieceAtSquare != null && pieceAtSquare != piece) {
        return false;
      }
      var piecesCheck = getEntriesPiecesFiltered(null, colorChecking);
      for (MapEntry<Square, Piece> pieceCheck in piecesCheck) {
        if (pathOfPieceToSquare(pieceCheck.value, square).isNotEmpty) {
          return false;
        }
      }
    }
    return true;
  }


  bool isMoveEnPassant(Move move) {
    var piece = pieces[move.squareInitial];
    if (piece == null) {
      return false;
    }
    var isPiecePawn = piece.type == TypePiece.pawn;
    if (!isPiecePawn) {
      return false;
    }
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