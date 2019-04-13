

import 'dart:math';
import 'Game.dart';


Map<Square, Piece> getBoardStandard() {

  var board = Map<Square, Piece>();

  var columns = List<int>.generate(8, (i) => 1 + i);
  for (int column in columns) {
    var rows = List<int>.generate(2, (i) => 1 + i) + List<int>.generate(2, (i) => 7 + i);
    for (int row in rows) {
      var square = Square(column, row);
      var isLight = row == 1 || row == 2 ? true : false;
      if (row == 1 || row == 8) {
        if (column == 1 || column == 8) {
          board[square] = Piece(TypePiece.rook, isLight, square);
        }
        else if (column == 2 || column == 7) {
          board[square] = Piece(TypePiece.knight, isLight, square);
        }
        else if (column == 3 || column == 6) {
          board[square] = Piece(TypePiece.bishop, isLight, square);
        }
        else if (column == 4) {
          board[square] = Piece(TypePiece.queen, isLight, square);
        }
        else {
          board[square] = Piece(TypePiece.king, isLight, square);
        }
      }
      else {
        board[square] = Piece(TypePiece.pawn, isLight, square);
      }
    }
  }

  return board;
}


Map<Square, Piece> getBoardChess12() {

  // 0 = rook, bishop, knight
  // 1 = rook, knight, bishop
  // 2 = bishop, rook, knight
  // 3 = bishop, knight, rook
  // 4 = knight, rook, bishop
  // 5 = knight, bishop, rook
  var random = new Random();
  var orderEdge = random.nextInt(6);
  // 0 = king, queen
  // 1 = queen, king
  var orderCenter = random.nextInt(2);

  var board = Map<Square, Piece>();

  var columns = List<int>.generate(8, (i) => 1 + i);
  for (int column in columns) {
    var rows = List<int>.generate(2, (i) => 1 + i) + List<int>.generate(2, (i) => 7 + i);
    for (int row in rows) {
      var square = Square(column, row);
      var isLight = row == 1 || row == 2 ? true : false;
      if (row == 1 || row == 8) {
        // edge 1
        if (column == 1 || column == 8) {
          var typePiece = orderEdge < 2 ? TypePiece.rook : orderEdge < 4 ? TypePiece.bishop : TypePiece.knight;
          board[square] = Piece(typePiece, isLight, square);
        }
        // edge 2
        else if (column == 2 || column == 7) {
          var typePiece = orderEdge == 2 || orderEdge == 4 ? TypePiece.rook : orderEdge % 5 == 0 ? TypePiece.bishop : TypePiece.knight;
          board[square] = Piece(typePiece, isLight, square);
        }
        // edge 3
        else if (column == 3 || column == 6) {
          var typePiece = orderEdge == 3 || orderEdge == 5 ? TypePiece.rook : orderEdge % 3 == 1 ? TypePiece.bishop : TypePiece.knight;
          board[square] = Piece(typePiece, isLight, square);
        }
        // center
        else if (column == 4) {
          var typePiece = orderCenter == 0 ? TypePiece.king : TypePiece.queen;
          board[square] = Piece(typePiece, isLight, square);
        }
        // center
        else {
          var typePiece = orderCenter == 0 ? TypePiece.queen : TypePiece.king;
          board[square] = Piece(typePiece, isLight, square);
        }
      }
      else {
        board[square] = Piece(TypePiece.pawn, isLight, square);
      }
    }
  }

  return board;
}


List<Square> getDeltasPin() {
  return getDeltasQueen();
}


List<Square> getDeltasCheck() {
  return getDeltasQueen() + getDeltasKnight();
}


List<Square> getDeltasKing() {
  return [Square(1, 1), Square(1, 0), Square(1, -1), Square(0, 1), Square(0, -1), Square(-1, 1), Square(-1, 0), Square(-1, -1)];
}


List<Square> getDeltasKingCastle() {
  return [Square(1, 0), Square(-1, 0)];
}


List<Square> getDeltasQueen() {
  return [Square(1, 1), Square(1, 0), Square(1, -1), Square(0, 1), Square(0, -1), Square(-1, 1), Square(-1, 0), Square(-1, -1)];
}


List<Square> getDeltasRook() {
  return [Square(1, 0), Square(0, 1), Square(0, -1), Square(-1, 0)];
}


List<Square> getDeltasBishop() {
  return [Square(1, 1), Square(1, -1), Square(-1, 1), Square(-1, -1)];
}


List<Square> getDeltasKnight() {
  return [Square(2, 1), Square(2, -1), Square(1, 2), Square(1, -2), Square(-1, 2), Square(-1, -2), Square(-2, 1), Square(-2, -1)];
}


List<Square> getDeltasPawn({bool isLight}) {
  var deltaRow = isLight? 1 : -1;
  return [Square(1, deltaRow), Square(-1, deltaRow), Square(0, deltaRow)];
}


List<Square> getDeltasPawnCapture({bool isLight}) {
  var deltaRow = isLight ? 1 : -1;
  return [Square(1, deltaRow), Square(-1, deltaRow)];
}


List<Square> getDeltasForPiece(Piece piece, {bool isCheck}) {

  switch (piece.type) {

    case TypePiece.king:
      return getDeltasKing();

    case TypePiece.queen:
      return getDeltasQueen();

    case TypePiece.rook:
      return getDeltasRook();

    case TypePiece.bishop:
      return getDeltasBishop();

    case TypePiece.knight:
      return getDeltasKnight();

    case TypePiece.pawn:
      return getDeltasPawn(isLight: piece.isLight);
  }

  throw Exception("Non exhaustive switch");
}


Square getDeltaReducedFromMove(Move move) {
  int columnDelta = move.square2.column == move.square1.column ? 0 : move.square2.column > move.square1.column ? 1 : -1;
  int rowDelta = move.square2.row == move.square1.row ? 0 : move.square2.row > move.square1.row ? 1 : -1;
  return Square(columnDelta, rowDelta);
}


bool isDeltaValidForKingMove(Move move, {bool isCastle = false}) {
  var diffsColumns = move.square2.column - move.square1.column;
  var diffRows = move.square2.row - move.square1.row;
  if (isCastle) {
    return diffsColumns.abs() == 2 && diffRows == 0;
  }
  return diffsColumns.abs() <= 1 && diffRows.abs() <= 1;
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


bool isDeltaValidForPawnMove(Move move, {bool isLight, bool isCapture}) {
  var diffsColumns = move.square2.column - move.square1.column;
  var diffRows = move.square2.row - move.square1.row;
  var direction = isLight ? 1 : -1;
  if (isCapture) {
    return diffsColumns.abs() == 1 && diffRows == 1*direction;
  }
  return diffsColumns == 0 && (diffRows == 1*direction || diffRows == 2*direction);
}


bool isDeltaValidForCaptureEnPassant(Square square2, Square squareEnPassant, {bool isLight}) {
  var direction = isLight ? 1 : -1;
  return square2.column - squareEnPassant.column == 0 && (square2.row - squareEnPassant.row) == 1*direction;
}


bool isDeltaValidForPieceMove(Piece piece, Move move, {bool isCastle = false, bool isCapture}) {

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
      return isDeltaValidForPawnMove(move, isLight: piece.isLight, isCapture: isCapture);
  }

  throw Exception("Non exhaustive switch");
}