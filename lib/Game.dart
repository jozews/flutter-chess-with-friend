
import 'dart:core';
import 'package:quiver/core.dart';

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

List<Square> deltasPin() {
  return deltasQueen();
}

List<Square> deltasCheck() {
  return deltasQueen() + deltasKnight();
}

List<Square> deltasKing() {
  return [Square(1, 1), Square(1, 0), Square(1, -1), Square(0, 1), Square(0, -1), Square(-1, 1), Square(-1, 0), Square(-1, -1)];
}

List<Square> deltasKingCastle() {
  return [Square(1, 0), Square(-1, 0)];
}

List<Square> deltasQueen() {
  return [Square(1, 1), Square(1, 0), Square(1, -1), Square(0, 1), Square(0, -1), Square(-1, 1), Square(-1, 0), Square(-1, -1)];
}

List<Square> deltasRook() {
  return [Square(1, 0), Square(0, 1), Square(0, -1), Square(-1, 0)];
}

List<Square> deltasBishop() {
  return [Square(1, 1), Square(1, -1), Square(-1, 1), Square(-1, -1)];
}

List<Square> deltasKnight() {
  return [Square(2, 1), Square(2, -1), Square(1, 2), Square(1, -2), Square(-1, 2), Square(-1, -2), Square(-2, 1), Square(-2, -1)];
}

List<Square> deltasPawn({bool isWhite}) {
  var deltaRow = isWhite? 1 : -1;
  return [Square(1, deltaRow), Square(-1, deltaRow), Square(0, deltaRow)];
}

List<Square> deltasPawnCapture({bool isWhite}) {
  var deltaRow = isWhite ? 1 : -1;
  return [Square(1, deltaRow), Square(-1, deltaRow)];
}

List<Square> deltasForPiece(Piece piece, {bool isCheck}) {

      switch (piece.type) {

      case TypePiece.king:
        return deltasKing();

      case TypePiece.queen:
        return deltasQueen();

      case TypePiece.rook:
        return deltasRook();

      case TypePiece.bishop:
        return deltasBishop();

      case TypePiece.knight:
        return deltasKnight();

      case TypePiece.pawn:
        return deltasPawn(isWhite: piece.isWhite);
    }

    throw Exception("Non exhaustive switch");
}


Square deltaReducedFromMove(Move move) {
  int columnDelta = move.square2.column == move.square1.column ? 0 : move.square2.column > move.square1.column ? 1 : -1;
  int rowDelta = move.square2.row == move.square1.row ? 0 : move.square2.row > move.square1.row ? 1 : -1;
  return Square(columnDelta, rowDelta);
}

bool isDeltaValidForKingMove(Move move, {bool isCastle = false}) {
  var difsColumns = move.square2.column - move.square1.column;
  var diffRows = move.square2.row - move.square1.row;
  if (isCastle) {
    return difsColumns.abs() == 2 && diffRows == 0;
  }
  return difsColumns.abs() <= 1 && diffRows.abs() <= 1;
}

bool isDeltaValidForQueenMove(Move move) {
  return isDeltaValidForRookMove(move) || isDeltaValidForBishopMove(move);
}

bool isDeltaValidForRookMove(Move move) {
  var difsColumns = move.square2.column - move.square1.column;
  var diffRows = move.square2.row - move.square1.row;
  return (difsColumns.abs() > 0 && diffRows == 0) || (difsColumns == 0 && diffRows.abs() > 0);
}

bool isDeltaValidForBishopMove(Move move) {
  var difsColumns = move.square2.column - move.square1.column;
  var diffRows = move.square2.row - move.square1.row;
  return difsColumns.abs() == diffRows.abs();
}

bool isDeltaValidForKnightMove(Move move) {
  var difsColumns = move.square2.column - move.square1.column;
  var diffRows = move.square2.row - move.square1.row;
  return (difsColumns.abs() == 2 && diffRows.abs() == 1) || (difsColumns.abs() == 1 && diffRows.abs() == 2);
}

bool isDeltaValidForPawnMove(Move move, {bool isWhite, bool isCapture, Square squareEnPassant}) {
  var difsColumns = move.square2.column - move.square1.column;
  var diffRows = move.square2.row - move.square1.row;
  var direction = isWhite ? 1 : -1;
  if (squareEnPassant != null) {
    return difsColumns == 0 && diffRows == 1*direction;
  }
  if (isCapture) {
    return difsColumns.abs() == 1 && diffRows == 1*direction;
  }
  return difsColumns == 0 && (diffRows == 1*direction || diffRows == 2*direction); 
}

bool isDeltaValidForPieceMove(Piece piece, Move move, {bool isCastle = false, bool isCapture, Square squareEnPassant}) {

      switch (piece.type) {

      case TypePiece.king:
        return isDeltaValidForKingMove(move, isCastle: isCastle);

      case TypePiece.queen:
        return isDeltaValidForQueenMove(move);

      case TypePiece.rook:
        return isDeltaValidForRookMove(move);

      case TypePiece.bishop:
        return isDeltaValidForBishopMove(move);

      case TypePiece.knight:
        return isDeltaValidForKnightMove(move);

      case TypePiece.pawn:
        return isDeltaValidForPawnMove(move, isWhite: piece.isWhite, isCapture: isCapture, squareEnPassant: squareEnPassant);
    }

    throw Exception("Non exhaustive switch");
}

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

  Square square1;
  Square square2;

  Move(this.square1, this.square2);

  @override
  String toString() {
    return "$square1 to $square2";
  }
}


class Game {

  Map<Square, Piece> board;
  StateGame state;
  bool isWhiteToMove;
  List<Move> moves;

  Game.standard() {
    board = piecesStandard();
    state = StateGame.ongoing;
    isWhiteToMove = true;
    moves = [];
  }


  List<MapEntry<Square, Piece>> getEntriesPiecesFiltered(TypePiece type, bool isWhite) {
    return board.entries.where((entry) {
      var piece = entry.value;
      if ((type == null || piece.type == type) && (isWhite == null || piece.isWhite == isWhite)) {
        return true;
      }
      return false;
    }).toList();
  }

  Piece pieceAtSquare(Square square) {
    return board[square];
  }
  
  Square squareOfPiece(Piece piece) {
    return board.entries.where((entry) => entry.value == piece).toList().first.key;
  }

  List<Square> squaresFromSquareWithDelta(Square square1, Square delta, {int limit = -1, Square stopBeforeSquare, bool stopBeforePiece = false, bool stopBeforePieceIsWhite, bool stopAfterPiece = false, bool stopAfterPieceIsWhite, bool addTrailingSquare1 = false, bool addSquare1 = false}) {
    List<Square> squares = [];
    var square = Square(square1.column + delta.column, square1.row + delta.row);
    while (square.inBounds && (limit == -1 || squares.length < limit)) {
      if (stopBeforeSquare != null && square == stopBeforeSquare) {
        break;
      }
      var pieceAtSquare = board[square];
      if (stopBeforePiece && pieceAtSquare != null) {
        break;
      }
      if (stopBeforePieceIsWhite != null && pieceAtSquare != null && pieceAtSquare.isWhite == stopBeforePieceIsWhite) {
        break;
      }
      squares.add(square);
      if (stopAfterPiece && pieceAtSquare != null) {
        break;
      }
      if (stopAfterPieceIsWhite != null && pieceAtSquare != null && pieceAtSquare.isWhite == stopAfterPieceIsWhite) {
        break;
      }
      square = Square(square.column + delta.column, square.row + delta.row);
    }
    if (squares.isNotEmpty) {
      if (addTrailingSquare1) {
        var squareOneBefore = square = Square(square.column - delta.column, square.row - delta.row);
        squares.insert(0, squareOneBefore);
      }
      if (addSquare1) {
        squares.insert(0, square1);
      }
    }
    return squares;
  }

  bool areSquaresEmpty(List<Square> squares) {
    for (Square square in squares) {
      if (board[square] != null) {
        return false;
      }
    }
    return true;
  }

  List<Piece> piecesInSquares(List<Square> squares) {
    return squares.map<Piece>((square) => board[square]).where((piece) => piece != null).toList();
  }


  List<List<Square>> getChecks(Piece king, {Square squareToMove}) {

    var squareOfKing = squareOfPiece(king);
    if (squareToMove != null) {
      squareOfKing = squareToMove;
    }
    var isKingSquare = squareToMove != null;
    
    List<List<Square>> checks = [];

    for (Square deltaCheck in deltasCheck()) {
      var squares = squaresFromSquareWithDelta(squareOfKing, deltaCheck, addTrailingSquare1: isKingSquare, stopAfterPiece: true, addSquare1: true);
      if (squares.isEmpty) {
        continue;
      }
      var squareLast = squares[squares.length - 1];
      var pieceLast = board[squareLast];
      if (pieceLast == null || pieceLast.isWhite != !isWhiteToMove) {
        continue;
      }
      var moveLastToKing = Move(squareLast, squareOfKing);
      var isDeltaMoveLastToKingValid = isDeltaValidForPieceMove(pieceLast, moveLastToKing, isCapture: true);
      if (!isDeltaMoveLastToKingValid) {
        continue;
      }
      checks.add(squares);
    }

    return checks;
  }


  List<Square> getPin(Piece piece) {

    var squarePiece = squareOfPiece(piece);
    var squareKing = getEntriesPiecesFiltered(TypePiece.king, piece.isWhite).first.key;

    var moveToKing = Move(squarePiece, squareKing);
    var deltaToKing = deltaReducedFromMove(moveToKing);

    var squaresToKing = squaresFromSquareWithDelta(squarePiece, deltaToKing, stopAfterPiece: true, addSquare1: true);
    var pieceLastSquaresToKing = board[squaresToKing[squaresToKing.length - 1]];
    if (pieceLastSquaresToKing == null || pieceLastSquaresToKing.type != TypePiece.king || pieceLastSquaresToKing.isWhite != piece.isWhite) {
      return null;
    }

    var deltaToKingReversed = Square(-deltaToKing.column, -deltaToKing.row);
    var squaresToKingReversed = squaresFromSquareWithDelta(squarePiece, deltaToKingReversed, stopAfterPiece: true);
    if (squaresToKingReversed.isEmpty) {
      return null;
    }

    var squareLastSquaresToKingReversed = squaresToKingReversed[squaresToKingReversed.length - 1];
    var pieceLastSquaresToKingReversed = board[squareLastSquaresToKingReversed];
    if (pieceLastSquaresToKingReversed == null || pieceLastSquaresToKing.isWhite != !piece.isWhite) {
      return null;
    }

    var moveLastSquaresToKingReversedToPiece = Move(squareLastSquaresToKingReversed, squarePiece);
    var isDeltaMoveLastSquaresToKingReversedToPieceValid = isDeltaValidForPieceMove(pieceLastSquaresToKingReversed, moveLastSquaresToKingReversedToPiece, isCapture: true);
    if (!isDeltaMoveLastSquaresToKingReversedToPieceValid) {
      return null;
    }

    return squaresToKing + squaresToKingReversed;
  }


  bool canCastleKing(Piece kingToMove, {bool isShort}) {
    var isWhite = kingToMove.isWhite;
    var squareRook = Square(isShort ? 8 : 1, isWhite ? 1 : 8);
    var rook = board[squareRook];
    if (rook == null) {
      return false;
    }
    for (Move m in moves) {
      // if king or rook has moved return false
      if (kingToMove.squareFirst == m.square1 || rook.squareFirst == m.square1) {
        return false;
      }
    }
    return true;
  }

  Piece canCaptureEnPassant() {

    if (moves.isEmpty) {
      return null;
    }
    var moveLast = moves[moves.length -1];
    var pieceMoveLast = board[moveLast.square2];
    if (pieceMoveLast == null) {
      return null;
    }
    var isPieceMoveLastPawn = pieceMoveLast.type == TypePiece.pawn;
    if (!isPieceMoveLastPawn) {
      return null;
    }
    var isMoveLastDoublePawn = (moveLast.square1.row - moveLast.square2.row).abs() == 2;
    if (!isMoveLastDoublePawn) {
      return null;
    }
    return pieceMoveLast;
  }

  bool canDoubleMove(Square square1) {
    var pieceToMove = board[square1];
    return pieceToMove.squareFirst == square1;
  }

  bool isMoveValid(Move move) {

    var pieceToMove = board[move.square1];

    if (pieceToMove == null || pieceToMove.isWhite != isWhiteToMove) {
      return false;
    }

    var pieceAtSquare2 = board[move.square2];
    if (pieceAtSquare2 != null && pieceAtSquare2.isWhite == pieceToMove.isWhite) {
      return false;
    }
        
    var entriesKingToMove = getEntriesPiecesFiltered(TypePiece.king, isWhiteToMove);

    var checks = getChecks(entriesKingToMove.first.value);

    // king must step out of double check
    if (checks.length == 2 && pieceToMove.type != TypePiece.king) {
      return false;
    }

    // check must be covered
    if (checks.length == 1 && pieceToMove.type != TypePiece.king && !checks.first.contains(move.square2)) {
      return false;
    }

    switch (pieceToMove.type) {

      case TypePiece.king:
        if (isDeltaValidForKingMove(move)) {
          var checks = getChecks(pieceToMove, squareToMove: move.square2);
          if (checks.isNotEmpty) {
            return false;
          }
        }
        else if (isDeltaValidForKingMove(move, isCastle: true)) {
          var deltaCastle = deltaReducedFromMove(move);
          var isShort = deltaCastle.column < 0 ? false : true;
          if (!canCastleKing(pieceToMove, isShort: isShort)) {
            return false;
          }
          var countSquaresToCastle = isShort ? 2 : 3;
          var squaresToCastle = squaresFromSquareWithDelta(move.square1, deltaCastle, limit: countSquaresToCastle, stopBeforePiece: true);
          if (squaresToCastle.length != countSquaresToCastle) {
            return false;
          }
          for (Square square in squaresToCastle) {
            var checks = getChecks(pieceToMove, squareToMove: square);
            if (checks.isNotEmpty) {
              return false;
            }
          }
        }
        else  {
          return false;
        }
        break;

      case TypePiece.queen:
        if (!isDeltaValidForQueenMove(move)) {
          return false;
        }
        var delta = deltaReducedFromMove(move);
        var squares = squaresFromSquareWithDelta(move.square1, delta, stopBeforeSquare: move.square2);
        var pieceInBetween = piecesInSquares(squares);
        if (pieceInBetween.isNotEmpty) {
          return false;
        }
        break;

      case TypePiece.rook:
        if (!isDeltaValidForRookMove(move)) {
          return false;
        }
        var delta = deltaReducedFromMove(move);
        var squares = squaresFromSquareWithDelta(move.square1, delta, stopBeforeSquare: move.square2);
        var pieceInBetween = piecesInSquares(squares);
        if (pieceInBetween.isNotEmpty) {
          return false;
        }
        break;

      case TypePiece.bishop:
        if (!isDeltaValidForBishopMove(move)) {
          return false;
        }
        var delta = deltaReducedFromMove(move);
        var squares = squaresFromSquareWithDelta(move.square1, delta, stopBeforeSquare: move.square2);
        var pieceInBetween = piecesInSquares(squares);
        if (pieceInBetween.isNotEmpty) {
          return false;
        }
        break;

      case TypePiece.knight:
        if (!isDeltaValidForKnightMove(move)) {
          return false;
        }
        break;

      case TypePiece.pawn:
        if (isDeltaValidForPawnMove(move, isWhite: pieceToMove.isWhite, isCapture: false)) {
          var delta = deltaReducedFromMove(move);
          var limit = (move.square1.row - move.square2.row).abs();
          if (limit == 2 && !canDoubleMove(move.square1)) {
            return false;
          }
          var squares = squaresFromSquareWithDelta(move.square1, delta, limit:limit);
          if (!areSquaresEmpty(squares)) {
            return false;
          }
        }
        else if (isDeltaValidForPawnMove(move, isWhite: pieceToMove.isWhite, isCapture: true)) {
          var captureEnPassant = canCaptureEnPassant();
          if (captureEnPassant != null) {
            var squareEnPassant = squareOfPiece(captureEnPassant);
            var isValid = isDeltaValidForPawnMove(move, isWhite:pieceToMove.isWhite, squareEnPassant: squareEnPassant);
            if (!isValid) {
              return false;
            }
          }
          else if (pieceAtSquare2 == null) {
            return false;
          }
        }
        else {
          return false ;
        }
        break;
    }


    // move must not leave pin
    if (pieceToMove.type != TypePiece.king) {
      var pin = getPin(pieceToMove);
      if (pin != null && !pin.contains(move.square2)) {
        return false;
      }
    }

    return true;
  }


  List<Move> validMoves(Square square1) {

    var pieceToMove = board[square1];

    if (pieceToMove == null || pieceToMove.isWhite != isWhiteToMove) {
      return [];
    }

    List<Square> squares2 = [];
    var deltas = deltasForPiece(pieceToMove);

    switch (pieceToMove.type) {

      case TypePiece.king:
        for (Square delta in deltas) {
          var isCastleDelta = deltasKingCastle().contains(delta);
          var squares = squaresFromSquareWithDelta(square1, delta, limit: isCastleDelta ? 2 : 1, stopBeforePieceIsWhite: pieceToMove.isWhite, stopAfterPiece: isCastleDelta);
          squares2.addAll(squares);
        }
        break;

      case TypePiece.queen:
        for (Square delta in deltas) {
          var squares = squaresFromSquareWithDelta(square1, delta, stopBeforePieceIsWhite: pieceToMove.isWhite, stopAfterPieceIsWhite: !pieceToMove.isWhite);
          squares2.addAll(squares);
        }
        break;

      case TypePiece.rook:
        for (Square delta in deltas) {
          var squares = squaresFromSquareWithDelta(square1, delta, stopBeforePieceIsWhite: pieceToMove.isWhite, stopAfterPieceIsWhite: !pieceToMove.isWhite);
          squares2.addAll(squares);
        }
        break;

      case TypePiece.bishop:
        for (Square delta in deltas) {
          var squares = squaresFromSquareWithDelta(square1, delta, stopBeforePieceIsWhite: pieceToMove.isWhite, stopAfterPieceIsWhite: !pieceToMove.isWhite);
          squares2.addAll(squares);
        }
        break;

      case TypePiece.knight:
        for (Square delta in deltas) {
          var squares = squaresFromSquareWithDelta(square1, delta, addSquare1: false, limit: 1, stopBeforePieceIsWhite: pieceToMove.isWhite);
          squares2.addAll(squares);
        }
        break;

      case TypePiece.pawn:
        for (Square delta in deltas) {
          var isCastleCapture = deltasPawnCapture(isWhite: pieceToMove.isWhite).contains(delta);
          var squares = squaresFromSquareWithDelta(square1, delta, limit: isCastleCapture ? 1 : 2, stopBeforePieceIsWhite: pieceToMove.isWhite, stopBeforePiece: !isCastleCapture, addSquare1: false);
          squares2.addAll(squares);
        }
        break;
    }

    var moves = squares2.map((square) => Move(square1, square)).toList();
    var movesValid = moves.where((move) => isMoveValid(move)).toList();
    return movesValid;
  }


  // * does not validates
  bool isMovePromotion(Move move) {
    var piece = board[move.square1];
    var isPiecePawn = piece.type == TypePiece.pawn;
    var promotionRow = piece.isWhite ? 8 : 1;
    var isSquareFinalPromotionRow = move.square2.row == promotionRow;
    return isPiecePawn && isSquareFinalPromotionRow;
  }

  // * does not validates
  bool isMoveCastling(Move move) {
    var piece = board[move.square1];
    var isColumnDelta2 = (move.square1.column - move.square2.column).abs() == 2;
    return piece.type == TypePiece.king && isColumnDelta2;
  }

  // * does not validates
  bool isMoveEnPassant(Move move) {
    var piece = board[move.square1];
    var pieceCapture = board[move.square2];
    var isColumnDelta1 = (move.square1.column - move.square2.column).abs() == 1;
    return piece.type == TypePiece.pawn && pieceCapture == null && isColumnDelta1;
  }

  bool makeMove(Move move, {TypePiece typePiecePromotion}) {

    // validate move
    if (!isMoveValid(move)) {
      return false;
    }
        
    var isPromotion = isMovePromotion(move);
    if (isPromotion && typePiecePromotion == null) {
      print("PROMOTE PIECE REQUIRED");
      return false;
    }

    // make move
    var pieceToMove = board[move.square1];
    if (isPromotion) {
      pieceToMove.type = typePiecePromotion;
    }
    else {
      // if castling move rook
      if (isMoveCastling(move)) {
        var columnInitialRook = move.square2.column - move.square1.column > 0 ? 8 : 1;
        var squareInitialRook = Square(columnInitialRook, move.square1.row);
        var columnFinalRook = (move.square1.column + move.square2.column) ~/ 2;
        var squareFinalRook = Square(columnFinalRook, move.square1.row);
        var pieceRook = board.remove(squareInitialRook);
        board[squareFinalRook] = pieceRook;
      }
      // if en passant remove taken pawn
      else if (isMoveEnPassant(move)) {
        var squareOfCapture = Square(move.square2.column, move.square1.row);
        board.remove(squareOfCapture);
      }
    }

    // * update board after checking isMoveCastling isMoveEnPassant as they read the board
    board.remove(move.square1);
    board[move.square2] = pieceToMove;
    moves.add(move);

    // toggle isWhiteToMove
    isWhiteToMove = !isWhiteToMove;
    
    var entryKingToMove = getEntriesPiecesFiltered(TypePiece.king, isWhiteToMove).first;
    var entriesPiecesToMove = getEntriesPiecesFiltered(null, isWhiteToMove);
    var checks = getChecks(entryKingToMove.value);

    var areThereValidMoves = false;
    for (MapEntry<Square, Piece> entryPiece in entriesPiecesToMove) {
      if (validMoves(entryPiece.key).isNotEmpty) {
        areThereValidMoves = true;
        break;
      }
    }

    if (!areThereValidMoves) {
      if (checks.isNotEmpty) {
        state = isWhiteToMove ? StateGame.checkmateByBlack :StateGame.checkmateByWhite;
      }
      else {
        state = StateGame.ongoing;
      }
    }
    
    return true;
  }


  bool makeMovePNG(String movePNG) {

    if (movePNG == "Rc2#") {
      bool breakme;
    }

    Square squareInitial;
    Square squareFinal;

    var isShortCastle = movePNG == "O-O";
    var isLongCastle = movePNG == "O-O-O";

    // if not castle
    // ...
    // ...
    if (!isShortCastle && !isLongCastle) {

      var charsPNG = movePNG.split("");
      
      // get type piece
      // ...
      var typePiece = movePNG.contains("K") ? TypePiece.king 
      : movePNG.contains("Q") ? TypePiece.queen 
      : movePNG.contains("B") ? TypePiece.bishop
      : movePNG.contains("N") ? TypePiece.knight
      : movePNG.contains("R") ? TypePiece.rook
      : TypePiece.pawn; 

      // get square final
      // ...
      var columns = charsPNG.map<int>((c) => "_abcdefgh".split("").indexOf(c)).where((index) => index != -1).toList();
      var columnFinal = columns[columns.length - 1];
      var rows = charsPNG.map<int>((c) => "_12345678".split("").indexOf(c)).where((index) => index != -1).toList();
      var rowFinal = rows[rows.length - 1];
      squareFinal = Square(columnFinal, rowFinal);

      // get square initial
      // ...

      // get column and row inital
      var entryPieces = getEntriesPiecesFiltered(typePiece, isWhiteToMove);
      if (entryPieces.isEmpty) {
        print(entryPieces);
        throw Exception("Invalid PNG move");
      }
      if (entryPieces.length > 1) {
        int columnInitial = columns[0] != columnFinal ? columns[0] : null;
        if (columnInitial != null) {
          entryPieces = entryPieces.where((entryPiece) => entryPiece.key.column == columnInitial).toList();
        }
        int rowInitial = rows[0] != rowFinal ? rows[0] : null;
        if (rowInitial != null) {
          entryPieces = entryPieces.where((entryPiece) => entryPiece.key.row == rowInitial).toList();
        }
      }
      if (entryPieces.length > 1) {
        entryPieces = entryPieces.where((entryPiece) => isMoveValid(Move(entryPiece.key, squareFinal))).toList();
      }
      if (entryPieces.length > 1) {
        print(entryPieces);
        throw Exception("Ambiguous PNG move");
      }
      squareInitial = entryPieces.first.key;
    }
    
    // castle
    else {
      var entryKing = getEntriesPiecesFiltered(TypePiece.king, isWhiteToMove).first;
      squareInitial = entryKing.key;
      var deltaColumns = isShortCastle ? 2 : -2;
      squareFinal = Square(squareInitial.column + deltaColumns, squareInitial.row);
    }

    var move = Move(squareInitial, squareFinal);
    return makeMove(move);
  }


}