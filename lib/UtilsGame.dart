

import 'Square.dart';
import 'Piece.dart';
import 'Move.dart';


Map<Square, Piece> getBoardStandard() {

  var board = Map<Square, Piece>();

  var types = [TypePiece.rook, TypePiece.knight, TypePiece.bishop, TypePiece.queen, TypePiece.king];

  var columns = List<int>.generate(8, (i) => 1 + i);
  var row = 1;

  for (int column in columns) {
    var square = Square(column, row);
    var type = column - 1 < types.length ? types[column - 1] : types[columns.length - column];
    board[square] = Piece(type, true, square);
  }

  row = 2;
  for (int column in columns) {
    var square = Square(column, row);
    board[square] = Piece(TypePiece.pawn, true, square);
  }

  row = 7;
  for (int column in columns) {
    var square = Square(column, row);
    board[square] = Piece(TypePiece.pawn, false, square);
  }

  row = 8;
  for (int column in columns) {
    var square = Square(column, row);
    var type = column - 1 < types.length ? types[column - 1] : types[columns.length - column];
    board[square] = Piece(type, false, square);
  }

  return board;
}


Map<Square, Piece> getBoardChess12() {

  var board = Map<Square, Piece>();

  var types = List<TypePiece>();
  var typesEdges = [TypePiece.rook, TypePiece.bishop, TypePiece.knight];
  var typesCenter = [TypePiece.queen, TypePiece.king];

  typesEdges.shuffle();
  types.addAll(typesEdges);
  typesCenter.shuffle();
  types.addAll(typesCenter);

  var columns = List<int>.generate(8, (i) => 1 + i);
  var row = 1;

  for (int column in columns) {
    var square = Square(column, row);
    var type = column - 1 < types.length ? types[column - 1] : types[columns.length - column];
    board[square] = Piece(type, true, square);
  }

  row = 2;
  for (int column in columns) {
    var square = Square(column, row);
    board[square] = Piece(TypePiece.pawn, true, square);
  }

  row = 7;
  for (int column in columns) {
    var square = Square(column, row);
    board[square] = Piece(TypePiece.pawn, false, square);
  }

  row = 8;
  for (int column in columns) {
    var square = Square(column, row);
    var type = column - 1 < types.length ? types[column - 1] : types[columns.length - column];
    board[square] = Piece(type, false, square);
  }

  return board;
}


Map<Square, Piece> getBoardChess12Revolution() {

  var board = Map<Square, Piece>();

  var types = List<TypePiece>();
  var typesEdges = [TypePiece.rook, TypePiece.bishop, TypePiece.knight];
  var typesCenter = [TypePiece.queen, TypePiece.king];

  typesEdges.shuffle();
  types.addAll(typesEdges);
  typesCenter.shuffle();
  types.addAll(typesCenter);

  var columns = List<int>.generate(8, (i) => 1 + i);
  var row = 1;

  for (int column in columns) {
    var square = Square(column, row);
    var type = column - 1 < types.length ? types[column - 1] : types[columns.length - column];
    board[square] = Piece(type, true, square);
  }

  row = 2;
  for (int column in columns) {
    var square = Square(column, row);
    board[square] = Piece(TypePiece.pawn, true, square);
  }

  types.clear();
  typesEdges.shuffle();
  types.addAll(typesEdges);
  typesCenter.shuffle();
  types.addAll(typesCenter);

  row = 7;
  for (int column in columns) {
    var square = Square(column, row);
    board[square] = Piece(TypePiece.pawn, false, square);
  }

  row = 8;
  for (int column in columns) {
    var square = Square(column, row);
    var type = column - 1 < types.length ? types[column - 1] : types[columns.length - column];
    board[square] = Piece(type, false, square);
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