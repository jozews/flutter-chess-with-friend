
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
        return deltasPawn(isWhite: piece.isWhite, isCheck: isCheck);
    }

    throw Exception("Non exhaustive switch");
}

List<Square> deltasPawn({bool isWhite, bool isCheck}) {
  var deltaRow = isWhite ? 1 : -1;
  return isCheck ? [Square(1, deltaRow), Square(-1, deltaRow)] : [Square(0, deltaRow)];
}

bool isDeltaContinuous(Square delta) {
  return deltasQueen().contains(delta);
}

Square deltaReducedFromMove(Move move) {
  int columnDelta = move.square2.column == move.square1.column ? 0 : move.square2.column > move.square1.column ? 1 : -1;
  int rowDelta = move.square2.row == move.square1.row ? 0 : move.square2.row > move.square1.row ? 1 : -1;
  return Square(columnDelta, rowDelta);
}

bool isDeltaValidForKingMove(Move move, {bool isCastle, bool isShort}) {
  var difsColumns = move.square2.column - move.square1.column;
  var diffRows = move.square2.row - move.square1.row;
  if (!isCastle) {
    return difsColumns.abs() <= 1 && diffRows.abs() <= 1;
  }
  return difsColumns == (isShort ? 2 : -3) && diffRows == 0;
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
  return difsColumns == diffRows;
}

bool isDeltaForKnightMove(Move move) {
  var difsColumns = move.square2.column - move.square1.column;
  var diffRows = move.square2.row - move.square1.row;
  return (difsColumns.abs() == 2 && diffRows.abs() == 1) || (difsColumns.abs() == 1 && diffRows.abs() == 2);
}

bool isDeltaValidForPawnMove(Move move, {bool isWhite, bool isCapture}) {
  var difsColumns = move.square2.column - move.square1.column;
  var diffRows = move.square2.row - move.square1.row;
  return isCapture ? difsColumns.abs() == 1 && diffRows.abs() == 1 : difsColumns == 0 && diffRows <= (isWhite ? 2 : 1); 
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

  bool makeMovePNG(String movePNG) {

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
        throw Exception("Ambiguous move PNG");
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

  List<Square> pathWithDelta(Square square1, Square delta, {int limit, bool untilPieceIsWhite, bool isKingSquare = false}) {
    List<Square> path = [];
    var squarePath = square1;
    while (squarePath.inBounds && (limit == null || path.length < limit)) {
      squarePath = Square(square1.column + delta.column, square1.row + delta.row);
      path.add(squarePath);
      var pieceAtSquarePath = pieces[squarePath];
      if (untilPieceIsWhite != null && pieceAtSquarePath != null && pieceAtSquarePath.isWhite == untilPieceIsWhite) {
        break;
      }
    }
    if (path.isNotEmpty && isKingSquare) {
      if (limit == null) {
        var squareOneBefore = squarePath = Square(squarePath.column - delta.column, squarePath.row - delta.row);
        path.insert(0, squareOneBefore);
      }
      path.insert(0, square1);
    }
    return path;
  }

  bool isPathEmpty(List<Square> path) {
    for (Square square in path) {
      if (pieces[square] != null) {
        return false;
      }
    }
    return true;
  }

  List<Piece> piecesInPath(List<Square> path) {
    return path.map<Piece>((square) => pieces[square]).where((piece) => piece != null).toList();
  }


  List<List<Square>> getPathsCheck(Piece king, {Square squareToMove}) {

    var squareOfKing = squareOfPiece(king);
    if (squareToMove != null) {
      squareOfKing = squareToMove;
    }
    var isKingSquare = squareToMove != null;
    
    List<List<Square>> pathsCheck = [];

    for (Square deltaCheck in deltasCheck()) {
      var isContinuous = isDeltaContinuous(deltaCheck);
      var limit = isContinuous ? 1 : null;
      var path = pathWithDelta(squareOfKing, deltaCheck, isKingSquare: isKingSquare, limit: limit, untilPieceIsWhite: !king.isWhite);
      if (path.isEmpty) {
        continue;
      }
      var pieceAtPathEnd = pieces[pieces.length];
      if (pieceAtPathEnd == null || pieceAtPathEnd.isWhite != !isWhiteToMove) {
        continue;
      }
      var doesPieceCanCheck = deltasForPiece(pieceAtPathEnd, isCheck: true).contains(deltaCheck);
      if (!doesPieceCanCheck) {
        continue;
      }
      var piecesOtherInPath = piecesInPath(path).where((piece) => piece != king && piece != pieceAtPathEnd);
      if (!piecesOtherInPath.isNotEmpty) {
        continue;
      }
      pathsCheck.add(path);
    }

    return pathsCheck;
  }


  List<Square> getPathPin(Piece piece) {

    var squarePiece = squareOfPiece(piece);
    var squareKing = getEntriesPiecesFiltered(TypePiece.king, piece.isWhite).first.key;

    var movePieceToKing = Move(squarePiece, squareKing);
    var deltaPieceToKing = deltaReducedFromMove(movePieceToKing);
    var isDeltaPieceToKingContinuous = isDeltaContinuous(deltaPieceToKing);

    if (!isDeltaPieceToKingContinuous) {
      return null;
    }

    var pathPieceToKing = pathWithDelta(squarePiece, deltaPieceToKing);
    if (!isPathEmpty(pathPieceToKing)) {
      return null;
    }

    var deltaPieceToKingReversed = Square(-deltaPieceToKing.column, -deltaPieceToKing.row);
    var pathPieceToKingReversed = pathWithDelta(squarePiece, deltaPieceToKingReversed, untilPieceIsWhite: !piece.isWhite);
    if (pathPieceToKingReversed.isEmpty) {
      return null;
    }

    var pieceAtEndOfPath = pieces[pathPieceToKingReversed[pathPieceToKingReversed.length - 1]];
    if (pieceAtEndOfPath == null) {
      return null;
    }

    var piecesOtherInPath = piecesInPath(pathPieceToKingReversed).where((piece) => piece != pieceAtEndOfPath);
    if (piecesOtherInPath.isNotEmpty) {
      return null;
    }
      
    var doesPieceCanCheck = deltasForPiece(pieceAtEndOfPath, isCheck: true).contains(deltaPieceToKing);
    if (!doesPieceCanCheck) {
      return null;
    }

    return pathPieceToKing + pathPieceToKingReversed;
  }


  bool isMoveValid(Move move) {

    var pieceToMove = pieces[move.square1];

    if (pieceToMove == null || pieceToMove.isWhite != isWhiteToMove) {
      return false;
    }

    var pieceAtSquare2 = pieces[move.square2];
    if (pieceAtSquare2 != null && pieceAtSquare2.isWhite != pieceToMove.isWhite) {
      return false;
    }
        
    var entriesKingToMove = getEntriesPiecesFiltered(TypePiece.king, isWhiteToMove);

    var pathsCheck = getPathsCheck(entriesKingToMove.first.value);

    // king must step out of double check
    if (pathsCheck.length == 2 && pieceToMove.type != TypePiece.king) {
      return false;
    }

    // check must be covered
    if (pathsCheck.length == 1 && pieceToMove.type != TypePiece.king && !pathsCheck.contains(pieceAtSquare2)) {
      return false;
    }

    switch (pieceToMove.type) {

      case TypePiece.king:
        if (isDeltaValidForKingMove(move, isCastle: false)) {
          var pathsCheck = getPathsCheck(pieceToMove, squareToMove: move.square2);
          if (pathsCheck.isNotEmpty) {
            return false;
          }
        }
        else if (isDeltaValidForKingMove(move, isCastle: true, isShort: false)) {
          if (!canCastle(isWhite: pieceToMove.isWhite, isShort: false)) {
            return false;
          }

        }
        else if (isDeltaValidForKingMove(move, isCastle: true, isShort: true)) {
          if (!canCastle(isWhite: pieceToMove.isWhite, isShort: true)) {
            return false;
          }
        }
        break;

      case TypePiece.queen:
        if (!isDeltaValidForQueenMove(move)) {
          return false;
        }
        var delta = deltaReducedFromMove(move);
        var path = pathWithDelta(move.square1, delta);
        var piecesPathWoCapture = piecesInPath(path).where((piece) => piece != pieceAtSquare2);
        if (piecesPathWoCapture.isNotEmpty) {
          return false;
        }
        break;

      case TypePiece.rook:
        if (!isDeltaValidForRookMove(move)) {
          return false;
        }
        var delta = deltaReducedFromMove(move);
        var path = pathWithDelta(move.square1, delta);
        var piecesPathWoCapture = piecesInPath(path).where((piece) => piece != pieceAtSquare2);
        if (piecesPathWoCapture.isNotEmpty) {
          return false;
        }
        break;

      case TypePiece.bishop:
        if (!isDeltaValidForBishopMove(move)) {
          return false;
        }
        var delta = deltaReducedFromMove(move);
        var path = pathWithDelta(move.square1, delta);
        var piecesPathWoCapture = piecesInPath(path).where((piece) => piece != pieceAtSquare2);
        if (piecesPathWoCapture.isNotEmpty) {
          return false;
        }
        break;

      case TypePiece.knight:
        if (!isDeltaForKnightMove(move)) {
          return false;
        }
        break;

      case TypePiece.pawn:
        if (isDeltaValidForPawnMove(move, isWhite: pieceToMove.isWhite, isCapture: false)) {
          var delta = deltaReducedFromMove(move);
          var limit = (move.square1.row - move.square2.row).abs();
          var path = pathWithDelta(move.square1, delta, limit:limit);
          if (!isPathEmpty(path)) {
            return false;
          }
        }
        if (isDeltaValidForPawnMove(move, isWhite: pieceToMove.isWhite, isCapture: true)) {
          var isEnPassant = canCaptureEnPassant(move);
          if (pieceAtSquare2 == null && !isEnPassant) {
            return false;
          }
        }
        break;
    }

    // move must not leave pin path
    if (pieceToMove.type != TypePiece.king) {
      var pathPin = getPathPin(pieceToMove);
      if (pathPin != null && !pathPin.contains(move.square2)) {
        return false;
      }
    }

    return true;
  }


  List<Move> validMoves(Square square1) {

    List<Move> moves = [];
    var pieceToMove = pieces[square1];

    if (pieceToMove == null || pieceToMove.isWhite != isWhiteToMove) {
      return moves;
    }

    // TODO: SUGGEST ALL LEGAL DELTAS MOVES
    switch (pieceToMove.type) {

      case TypePiece.king:

        break;

      case TypePiece.queen:

        break;

      case TypePiece.rook:

        break;

      case TypePiece.bishop:

        break;

      case TypePiece.knight:

        break;

      case TypePiece.pawn:

        break;
    }

    var validMoves = moves.where((move) => isMoveValid(move)).toList();
    return validMoves;
  }


  bool makeMove(Move move, {TypePiece typePiecePromotion}) {

    // validate move
    if (!isMoveValid(move)) {
      return false;
    }
        
    var isPromotion = isMovePromotion(move);
    if (isPromotion && typePiecePromotion == null) {
      return false;
    }

    // make move
    var pieceToMove = pieces[move.square1];
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
        var pieceRook = pieces.remove(squareInitialRook);
        pieces[squareFinalRook] = pieceRook;
      }
      // if en passant remove taken pawn
      else if (isMoveEnPassant(move)) {
        var squareOfCapture = Square(move.square2.column, move.square1.row);
        pieces.remove(squareOfCapture);
      }
    }

    // * UPDATE PIECES AFTER CHECKING isMoveCastling isMoveEnPassant AS THEY READ pieces
    pieces.remove(move.square1);
    pieces[move.square2] = pieceToMove;
    moves.add(move);

    // toggle isWhiteToMove
    isWhiteToMove = !isWhiteToMove;

    // TODO: update state of the game

    return true;
  }

  // * DOES NOT VALIDATES MOVE
  bool isMovePromotion(Move move) {
    var piece = pieces[move.square1];
    var isPiecePawn = piece.type == TypePiece.pawn;
    var promotionRow = piece.isWhite ? 8 : 1;
    var isSquareFinalPromotionRow = move.square2.row == promotionRow;
    return isPiecePawn && isSquareFinalPromotionRow;
  }

  // * DOES NOT VALIDATES MOVE
  bool isMoveCastling(Move move) {
    var piece = pieces[move.square1];
    var isColumnDelta2 = (move.square1.column - move.square2.column).abs() == 2;
    return piece.type == TypePiece.king && isColumnDelta2;
  }

  // * DOES NOT VALIDATES MOVE
  bool isMoveEnPassant(Move move) {
    var piece = pieces[move.square1];
    var pieceCapture = pieces[move.square2];
    var isColumnDelta1 = (move.square1.column - move.square2.column).abs() == 1;
    return piece.type == TypePiece.pawn && pieceCapture == null && isColumnDelta1;
  }

  bool canCastle({bool isWhite, bool isShort}) {
    var pieceKing = getEntriesPiecesFiltered(TypePiece.king, isWhite).first.value;
    var squareRook = Square(isShort ? 8 : 1, isWhite ? 1 : 8);
    var pieceRook = pieces[squareRook];
    if (pieceRook == null) {
      return false;
    }
    for (Move m in moves) {
      // if king or rook has moved return false
      if (pieceKing.squareFirst == m.square1 || pieceRook.squareFirst == m.square1) {
        return false;
      }
    }
    return true;
  }

  bool canCaptureEnPassant(Move move) {
    if (moves.isEmpty) {
      return false;
    }
    var moveLast = moves[moves.length -1];
    var pieceMoveLast = pieces[moveLast.square2];
    if (pieceMoveLast == null) {
      return false;
    }
    var isPieceMoveLastPawn = pieceMoveLast.type == TypePiece.pawn;
    if (!isPieceMoveLastPawn) {
      return false;
    }
    var isMoveLastDoublePawn = (moveLast.square1.row - moveLast.square2.row).abs() == 2;
    if (!isMoveLastDoublePawn) {
      return false;
    }    
    var arePiecesInSameRow = move.square1.row == moveLast.square2.row;
    if (!arePiecesInSameRow) {
      return false;
    }
    var willPiecesBeInSameColumn = moveLast.square1.column == move.square2.column;
    if (!willPiecesBeInSameColumn) {
      return false;
    }
    return true;
  }
}