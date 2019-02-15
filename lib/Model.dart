
import 'dart:core';
import 'package:quiver/core.dart';


enum TypePiece {
  king, queen, bishop, knight, rook, pawn
}


class Piece {

  Square squareFirst;
  TypePiece type;
  bool isWhite;

  Piece(this.type, this.isWhite, this.squareFirst);

  @override
  String toString() {
    return "${isWhite ? 'white' : 'black'} $type";
  }

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
  
  @override
  String toString() {
    return "($column, $row)";
  }

  bool get inBounds => column >= 1 && column <= 8 && row >= 1 && row <= 8;
  bool operator ==(o) => o is Square && o.column == column && o.row == row;
  int get hashCode => hash2(column.hashCode, row.hashCode);
}



class Move {

  Square squareInitial;
  Square squareFinal;

  Move(this.squareInitial, this.squareFinal);

  @override
  String toString() {
    return "$squareInitial to $squareFinal";
  }
}



class Game {

  Map<Square, Piece> pieces;
  StateGame state;
  bool isWhiteToMove;
  List<Move> moves;

  Game.standard() {
    pieces = piecesStandard();
    state = StateGame.ongoing;
    isWhiteToMove = true;
    moves = [];
  }

  Map<Square, Piece> piecesStandard() {
      
    var pieces = Map<Square, Piece>();
    var columns = List<int>.generate(8, (i) => 1 + i);

    // pieces
    // ...
    for (int column in columns) {
      var rows = List<int>.generate(2, (i) => 1 + i) + List<int>.generate(2, (i) => 7 + i);
      for (int row in rows) {
        var square = Square(column, row);
        var isWhite = row == 1 || row == 2 ? true : false;
        if (row == 1 || row == 8) {
          if (column == 1 || column == 8) {
            pieces[square] = Piece(TypePiece.rook, isWhite, square);
          }
          else if (column == 2 || column == 7) {
            pieces[square] = Piece(TypePiece.knight, isWhite, square);
          }
          else if (column == 3 || column == 6) {
            pieces[square] = Piece(TypePiece.bishop, isWhite, square);
          }
          else if (column == 4) {
            pieces[square] = Piece(TypePiece.queen, isWhite, square);
          }
          else {
            pieces[square] = Piece(TypePiece.king, isWhite, square);
          }
        }
        else {
          pieces[square] = Piece(TypePiece.pawn, isWhite, square);
        }
      }
    }

    return pieces;
  }

  List<Square> getSquaresFinalValid(Square squareInitial) {

    var pieceAtSquareInitial = pieces[squareInitial];

    // return empty
    // ...
    if (pieceAtSquareInitial == null || pieceAtSquareInitial.isWhite != isWhiteToMove) {
      return [];
    }

    // get checks of king color to move
    // ...
    var entryPieceKing = getEntriesPiecesFiltered(TypePiece.king, isWhiteToMove).first;
    var squareKing = entryPieceKing.key;
    var colorChecking = !isWhiteToMove;
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
    List<List<Square>> paths = pathsOfPiece(pieceAtSquareInitial, isChecking: false);
    
    // filter out where king steps into checking path
    // ...
    if (pieceAtSquareInitial.type == TypePiece.king) {
      List<List<Square>> pathsNotChecked = [];
      for (List<Square> path in paths) {
        List<Square> pathNotChecked = [];
        for (Square square in path) {
          var isSquareNotChecked = true;
          for (MapEntry<Square, Piece> entryPiece in entryPiecesColorChecking) {
            // if king will capture piece continue
            if (entryPiece.key == square) {
              continue;
            }
            var pathChecking = pathOfPieceToSquare(entryPiece.value, square);
            if (pathChecking.isNotEmpty) {
              isSquareNotChecked = false;
              break;
            }
          }
          if (isSquareNotChecked) {
            pathNotChecked.add(square);
          }
          else {
            break;
          }
        }
        pathsNotChecked.add(pathNotChecked);
      }
      paths = pathsNotChecked;
    }

    List<Square> squaresFinalValid = paths.expand((i) => i).toList();

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
      squaresFinalValid = squaresFinalValid.where((squareFinal) {
        var pathChecking = pathsChecking.first;
        var isSquareFinalInPathChecking = pathChecking.contains(squareFinal);
        return isSquareFinalInPathChecking;
      }).toList();
    }

    return squaresFinalValid;
  }


  // * CAN BE OPTIMIZED
  bool isMoveValid(Move move) {
    var squaresFinalValid = getSquaresFinalValid(move.squareInitial);
    var isMoveFinalInSquaresFinalValid = squaresFinalValid.where((squareFinal) => squareFinal == move.squareFinal).isNotEmpty;
    return isMoveFinalInSquaresFinalValid;
  }

  bool makeMovePNG(String movePNG) {

    var movePNGReduced = movePNG.replaceAll("+", "").replaceAll("x", ""); // remove checks and captures

    Square squareInitial;
    Square squareFinal;

    var isShortCastle = movePNGReduced == "O-O";
    var isLongCastle = movePNGReduced == "O-O-O";

    // if not castle
    // ...
    // ...
    if (!isShortCastle && !isLongCastle) {

      var charsPNG = movePNGReduced.split("");
      
      // get type piece
      // ...
      var typePiece = movePNGReduced.contains("K") ? TypePiece.king 
      : movePNGReduced.contains("Q") ? TypePiece.queen 
      : movePNGReduced.contains("B") ? TypePiece.bishop
      : movePNGReduced.contains("N") ? TypePiece.knight
      : movePNGReduced.contains("R") ? TypePiece.rook
      : TypePiece.pawn; 

      // get square final
      // ...
      var columns = charsPNG.map<int>((c) => "_abcdefgh".split("").indexOf(c)).where((index) => index != -1).toList();
      var columnFinal = columns[columns.length - 1];
      var rowFinal = int.parse(movePNGReduced.substring(movePNGReduced.length - 1));
      squareFinal = Square(columnFinal, rowFinal);

      // get square initial
      // ...

      // get column and row inital
      var entryPieces = getEntriesPiecesFiltered(typePiece, isWhiteToMove);
      if (entryPieces.length > 1) {
        int columnInitial = columns[0] != columnFinal ? columns[0] : null;
        if (columnInitial != null) {
          entryPieces = entryPieces.where((entryPiece) => entryPiece.key.column == columnInitial).toList();
        }
      }
      if (entryPieces.length > 1) {
        entryPieces = entryPieces.where((entryPiece) => isMoveValid(Move(entryPiece.key, squareFinal))).toList();
      }
      if (entryPieces.length > 1) {
        throw Exception("Ambiguous move PNG");
      }
      squareInitial = entryPieces.first.key;
    }


    // castle
    // ...
    else {
      var entryKingColorToMove = getEntriesPiecesFiltered(TypePiece.king, isWhiteToMove).first;
      squareInitial = entryKingColorToMove.key;
      var deltaColumns = isShortCastle ? 2 : -2;
      squareFinal = Square(squareInitial.column + deltaColumns, squareInitial.row);
    }

    var move = Move(squareInitial, squareFinal);
    return makeMove(move);
  }

  bool makeMove(Move move, {TypePiece typePiecePromotion}) {

    // validate move
    // ...
    if (!isMoveValid(move)) {
      return false;
    }
        
    var isPromotion = isMovePromotion(move);
    if (isPromotion && typePiecePromotion == null) {
      return false;
    }

    // make move
    // ...
    var pieceToMove = pieces[move.squareInitial];
    if (isPromotion) {
      pieceToMove.type = typePiecePromotion;
    }
    else {
      // if castling move rook
      if (isMoveCastling(move)) {
        var columnInitialRook = move.squareFinal.column - move.squareInitial.column > 0 ? 8 : 1;
        var squareInitialRook = Square(columnInitialRook, move.squareInitial.row);
        var columnFinalRook = (move.squareInitial.column + move.squareFinal.column) ~/ 2;
        var squareFinalRook = Square(columnFinalRook, move.squareInitial.row);
        var pieceRook = pieces.remove(squareInitialRook);
        pieces[squareFinalRook] = pieceRook;
      }
      // if en passant remove taken pawn
      else if (isMoveEnPassant(move)) {
        var squareOfCapture = Square(move.squareFinal.column, move.squareInitial.row);
        pieces.remove(squareOfCapture);
      }
    }
    // * UPDATE PIECES AFTER CHECKING isMoveCastling isMoveEnPassant AS THEY READ pieces
    pieces.remove(move.squareInitial);
    pieces[move.squareFinal] = pieceToMove;
    moves.add(move);

    // toggle color to move
    // ...
    isWhiteToMove = !isWhiteToMove;

    // get checks of king color to move
    // ...
    var entryKing = getEntriesPiecesFiltered(TypePiece.king, isWhiteToMove).first;
    var squareKing = entryKing.key;
    var squaresKingFinalValid = getSquaresFinalValid(squareKing);
    var colorChecking = !isWhiteToMove;
    var entryPiecesChecking = getEntriesPiecesFiltered(null, colorChecking);
    var pathsChecking = entryPiecesChecking.map<List<Square>>((entryPiece) => pathOfPieceToSquare(entryPiece.value, squareKing));

    // checkmate
    // ...
    if (pathsChecking.isNotEmpty && squaresKingFinalValid.isEmpty) {
      if (pathsChecking.length == 1) {
        var canCheckmateBeCovered = false;
        var piecesColorToMove = getEntriesPiecesFiltered(null, isWhiteToMove).where((entry) => entry.value.type != TypePiece.king);
        for (MapEntry<Square, Piece> pieceColorToMove in piecesColorToMove) {
          var squaresPieceFinalValid = getSquaresFinalValid(pieceColorToMove.key);
          var pieceWithValidMoveInCheckingPath = squaresPieceFinalValid.where((squareFinal) => pathsChecking.first.contains(squareFinal));
          if (pieceWithValidMoveInCheckingPath.isNotEmpty) {
            canCheckmateBeCovered = true;
            break;
          }
        }
        if (canCheckmateBeCovered) {
          state = isWhiteToMove ? StateGame.checkmateByBlack : StateGame.checkmateByWhite;
        }
      }
      else {
        state = isWhiteToMove ? StateGame.checkmateByBlack : StateGame.checkmateByWhite;
      }
    }

    // stalemate
    // ...
    else if (pathsChecking.isEmpty && squaresKingFinalValid.isEmpty) {
      var piecesColorToMove = getEntriesPiecesFiltered(null, isWhiteToMove);
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

  
  // * DOES NOT VALIDATES MOVE
  bool isMovePromotion(Move move) {
    var piece = pieces[move.squareInitial];
    var isPiecePawn = piece.type == TypePiece.pawn;
    var promotionRow = piece.isWhite ? 8 : 1;
    var isSquareFinalPromotionRow = move.squareFinal.row == promotionRow;
    return isPiecePawn && isSquareFinalPromotionRow;
  }


  // * DOES NOT VALIDATES MOVE
  bool isMoveCastling(Move move) {
    var piece = pieces[move.squareInitial];
    var isColumnDelta2 = (move.squareInitial.column - move.squareFinal.column).abs() == 2;
    return piece.type == TypePiece.king && isColumnDelta2;
  }


  // * DOES NOT VALIDATES MOVE
  bool isMoveEnPassant(Move move) {
    var piece = pieces[move.squareInitial];
    var pieceCapture = pieces[move.squareFinal];
    var isColumnDelta1 = (move.squareInitial.column - move.squareFinal.column).abs() == 1;
    return piece.type == TypePiece.pawn && pieceCapture == null && isColumnDelta1;
  }


  bool isCastleAllowed(bool isWhiteCastling, bool isShort) {
    var pieceKing = getEntriesPiecesFiltered(TypePiece.king, isWhiteCastling).first.value;
    var squareRook = Square(isShort ? 8 : 1, isWhiteCastling ? 1 : 8);
    var pieceRook = pieces[squareRook];
    if (pieceRook == null) {
      return false;
    }
    for (Move m in moves) {
      // if king or rook has moved return false
      if (pieceKing.squareFirst == m.squareInitial || pieceRook.squareFirst == m.squareInitial) {
        return false;
      }
    }
    return true;
  }


  bool isEnPassantAllowed(Square squareFinal) {
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
    var willPiecesBeInAdjacentRows = (moveLast.squareFinal.row - squareFinal.row).abs() == 1;
    if (!willPiecesBeInAdjacentRows) {
      return false;
    }
    var willPiecesBeInSameColumn = moveLast.squareInitial.column == squareFinal.column;
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
        var deltas = [[1, 1], [1, 0], [1, -1], [0, 1], [0, -1], [-1, 1], [-1, 0], [-1, -1]];
        for (List<int> delta in deltas) {
          var isPathCastling = delta[0].abs() == 1 && delta[1] == 0;
          List<Square> path = [];
          if (isChecking) {
            path.add(square);
          }
          var squarePath = Square(square.column + delta[0], square.row + delta[1]);
          while (squarePath.inBounds) {
            var pieceAtSquarePath = pieces[squarePath];
            if (pieceAtSquarePath != null && pieceAtSquarePath.isWhite == isWhiteToMove) {
              break;
            }
            path.add(squarePath);
            if ((pieceAtSquarePath != null && pieceAtSquarePath.isWhite != isWhiteToMove)) {
              break;
            }
            if (isChecking || !isPathCastling) {
              break;
            }
            // if long castle
            if ((squarePath.column == 1 && square.row == 1) || (squarePath.column == 1 && square.row == 8) && isCastleAllowed(isWhiteToMove, false)) {
              var squareLongCastle = Square(squarePath.column + 1, squarePath.row);
              path.add(squareLongCastle);
              break;
            }
            // if short castle
            if ((squarePath.column == 8 && square.row == 1) || (squarePath.column == 8 && square.row == 8) && isCastleAllowed(isWhiteToMove, true)) {
              path.add(squarePath);
              break;
            }
            squarePath = Square(squarePath.column + delta[0], squarePath.row + delta[1]);
          }
          paths.add(path);
        }
        break;

      case TypePiece.queen:
        var deltas = [[1, 1], [1, 0], [1, -1], [0, 1], [0, -1], [-1, 1], [-1, 0], [-1, -1]];
        for (List<int> delta in deltas) {
          List<Square> path = [];
          var isPinning = false;
          if (isChecking) {
            path.add(square);
          }
          var squarePath = Square(square.column + delta[0], square.row + delta[1]);
          while (squarePath.inBounds) {
            var pieceAtSquarePath = pieces[squarePath];
            if (pieceAtSquarePath != null && pieceAtSquarePath.isWhite == isWhiteToMove) {
              break;
            }
            path.add(squarePath);
            if (pieceAtSquarePath != null && pieceAtSquarePath.isWhite != isWhiteToMove) {
              if (!withPinning || isPinning) {
                break;
              }
              isPinning = true;
            }
            squarePath = Square(squarePath.column + delta[0], squarePath.row + delta[1]);
          }
          paths.add(path);
        }
        break;

      case TypePiece.bishop:
        var deltas = [[1, 1], [1, -1], [-1, 1], [-1, -1]];
        for (List<int> delta in deltas) {
          List<Square> path = [];
          var isPinning = false;
          if (isChecking) {
            path.add(square);
          }
          var squarePath = Square(square.column + delta[0], square.row + delta[1]);
          while (squarePath.inBounds) {
            var pieceAtSquarePath = pieces[squarePath];
            if (pieceAtSquarePath != null && pieceAtSquarePath.isWhite == isWhiteToMove) {
              break;
            }
            path.add(squarePath);
            if (pieceAtSquarePath != null && pieceAtSquarePath.isWhite != isWhiteToMove) {
              if (!withPinning || isPinning) {
                break;
              }
              isPinning = true;
            }
            squarePath = Square(squarePath.column + delta[0], squarePath.row + delta[1]);
          }
          paths.add(path);
        }
        break;

      case TypePiece.knight:
        var deltas = [[2, 1], [2, -1], [1, 2], [1, -2], [-1, 2], [-1, -2], [-2, 1], [-2, -1]];
        for (List<int> delta in deltas) {
          List<Square> path = [];
          if (isChecking) {
            path.add(square);
          }
          var squarePath = Square(square.column + delta[0], square.row + delta[1]);
          if (!squarePath.inBounds) {
            continue;
          }
          var pieceAtSquarePath = pieces[squarePath];
          if (pieceAtSquarePath == null || pieceAtSquarePath.isWhite != isWhiteToMove) {
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
          if (isChecking) {
            path.add(square);
          }
          var squarePath = Square(square.column + delta[0], square.row + delta[1]);
          while (squarePath.inBounds) {
            var pieceAtSquarePath = pieces[squarePath];
            if (pieceAtSquarePath != null && pieceAtSquarePath.isWhite == isWhiteToMove) {
              break;
            }
            path.add(squarePath);
            if (pieceAtSquarePath != null && pieceAtSquarePath.isWhite != isWhiteToMove) {
              if (!withPinning || isPinning) {
                break;
              }
              isPinning = true;
            }
            squarePath = Square(squarePath.column + delta[0], squarePath.row + delta[1]);
          }
          paths.add(path);
        }
        break;

      case TypePiece.pawn:
        var direction = piece.isWhite ? 1 : -1;
        var deltas = [[-1, direction], [0, direction], [1, direction]];
        for (List<int> delta in deltas) {
          List<Square> path = [];
          if (isChecking) {
            path.add(square);
          }
          var squarePath = Square(square.column + delta[0], square.row + delta[1]);
          if (!isChecking && delta[0] == 0) {
            var pieceAtSquarePath = pieces[squarePath];
            if (pieceAtSquarePath == null) {
              path.add(squarePath);
              squarePath = Square(squarePath.column + delta[0], squarePath.row + delta[1]);
              pieceAtSquarePath = pieces[squarePath];
              if (piece.squareFirst == square && pieceAtSquarePath == null) {
                path.add(squarePath);
              }
            }
            paths.add(path);
          }
          else if (delta[1] != 0) {
            var pieceAtSquarePath = pieces[squarePath];
            var isEnPassantCapture = isEnPassantAllowed(squarePath);
            var isCapture = pieceAtSquarePath != null && pieceAtSquarePath.isWhite != isWhiteToMove;
            if (isCapture || isEnPassantCapture) {
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
    var pathToSquare = paths.where((path) => path.contains(square)).toList();
    if (pathToSquare.isNotEmpty) {
      return pathToSquare.first;
    }
    return [];
  }


  List<MapEntry<Square, Piece>> getEntriesPiecesFiltered(TypePiece type, bool isWhite) {
    return pieces.entries.where((entry) {
      var piece = entry.value;
      if ((type == null || piece.type == type) && (isWhite == null || piece.isWhite == isWhite)) {
        return true;
      }
      return false;
    }).toList();
  }


  Square squareOfPiece(Piece piece) {
    return pieces.entries.where((entry) => entry.value == piece).toList().first.key;
  }
}