

import 'dart:core';

import 'Piece.dart';
import 'Square.dart';
import 'Move.dart';



enum StateGame {
  ongoing, checkmate, stalemate, insufficientMaterial
}


enum TypeGame {
  standard, chess12, chess12Revolution
}


class Game {


  static const STRING_CASTLE_SHORT = "O-O";
  static const STRING_CASTLE_LONG = "O-O-O";

  Map<Square, Piece> board;
  StateGame state;
  bool isLightToMove;
  List<Move> moves;
  List<String> notations;

  TypeGame type;

  static Map<Square, Piece> getBoardStandard() {

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


  static Map<Square, Piece> getBoardChess12() {

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


  static Map<Square, Piece> getBoardChess12Revolution() {

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


  static List<Square> getVectorsPin() {
    return getVectorsQueen();
  }


  static List<Square> getVectorsCheck() {
    return getVectorsQueen() + getVectorsKnight();
  }


  static List<Square> getVectorsKing() {
    return [Square(1, 1), Square(1, 0), Square(1, -1), Square(0, 1), Square(0, -1), Square(-1, 1), Square(-1, 0), Square(-1, -1)];
  }


  static List<Square> getVectorsKingCastle() {
    return [Square(1, 0), Square(-1, 0)];
  }


  static List<Square> getVectorsQueen() {
    return [Square(1, 1), Square(1, 0), Square(1, -1), Square(0, 1), Square(0, -1), Square(-1, 1), Square(-1, 0), Square(-1, -1)];
  }


  static List<Square> getVectorsRook() {
    return [Square(1, 0), Square(0, 1), Square(0, -1), Square(-1, 0)];
  }


  static List<Square> getVectorsBishop() {
    return [Square(1, 1), Square(1, -1), Square(-1, 1), Square(-1, -1)];
  }


  static List<Square> getVectorsKnight() {
    return [Square(2, 1), Square(2, -1), Square(1, 2), Square(1, -2), Square(-1, 2), Square(-1, -2), Square(-2, 1), Square(-2, -1)];
  }


  static List<Square> getVectorsPawn({bool isLight}) {
    var vectorRow = isLight? 1 : -1;
    return [Square(1, vectorRow), Square(-1, vectorRow), Square(0, vectorRow)];
  }


  static List<Square> getVectorsPawnCapture({bool isLight}) {
    var vectorRow = isLight ? 1 : -1;
    return [Square(1, vectorRow), Square(-1, vectorRow)];
  }


  static List<Square> getVectorsForPiece(Piece piece, {bool isCheck}) {

    switch (piece.type) {

      case TypePiece.king:
        return getVectorsKing();

      case TypePiece.queen:
        return getVectorsQueen();

      case TypePiece.rook:
        return getVectorsRook();

      case TypePiece.bishop:
        return getVectorsBishop();

      case TypePiece.knight:
        return getVectorsKnight();

      case TypePiece.pawn:
        return getVectorsPawn(isLight: piece.isLight);
    }

    throw Exception("Non exhaustive switch");
  }


  static Square getDeltaReducedFromMove(Move move) {
    int columnDelta = move.square2.column == move.square1.column ? 0 : move.square2.column > move.square1.column ? 1 : -1;
    int rowDelta = move.square2.row == move.square1.row ? 0 : move.square2.row > move.square1.row ? 1 : -1;
    return Square(columnDelta, rowDelta);
  }


  static bool isDeltaValidForKingMove(Move move, {bool isCastle = false}) {
    var diffsColumns = move.square2.column - move.square1.column;
    var diffRows = move.square2.row - move.square1.row;
    if (isCastle) {
      return diffsColumns.abs() == 2 && diffRows == 0;
    }
    return diffsColumns.abs() <= 1 && diffRows.abs() <= 1;
  }


  static bool isDeltaValidForQueenMove(Move move) {
    return isDeltaValidForRookMove(move) || isDeltaValidForBishopMove(move);
  }


  static bool isDeltaValidForRookMove(Move move) {
    var difsColumns = move.square2.column - move.square1.column;
    var diffRows = move.square2.row - move.square1.row;
    return (difsColumns.abs() > 0 && diffRows == 0) || (difsColumns == 0 && diffRows.abs() > 0);
  }


  static bool isDeltaValidForBishopMove(Move move) {
    var difsColumns = move.square2.column - move.square1.column;
    var diffRows = move.square2.row - move.square1.row;
    return difsColumns.abs() == diffRows.abs();
  }


  static bool isDeltaValidForKnightMove(Move move) {
    var difsColumns = move.square2.column - move.square1.column;
    var diffRows = move.square2.row - move.square1.row;
    return (difsColumns.abs() == 2 && diffRows.abs() == 1) || (difsColumns.abs() == 1 && diffRows.abs() == 2);
  }


  static bool isDeltaValidForPawnMove(Move move, {bool isLight, bool isCapture}) {
    var diffsColumns = move.square2.column - move.square1.column;
    var diffRows = move.square2.row - move.square1.row;
    var direction = isLight ? 1 : -1;
    if (isCapture) {
      return diffsColumns.abs() == 1 && diffRows == 1*direction;
    }
    return diffsColumns == 0 && (diffRows == 1*direction || diffRows == 2*direction);
  }


  static bool isDeltaValidForCaptureEnPassant(Square square2, Square squareEnPassant, {bool isLight}) {
    var direction = isLight ? 1 : -1;
    return square2.column - squareEnPassant.column == 0 && (square2.row - squareEnPassant.row) == 1*direction;
  }


  static bool isDeltaValidForPieceMove(Piece piece, Move move, {bool isCastle = false, bool isCapture}) {

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
  
  
  Game.type(TypeGame type) {
    state = StateGame.ongoing;
    isLightToMove = true;
    moves = [];
    notations = [];
    switch (type) {
      case TypeGame.standard:
        board = getBoardStandard();
        break;
      case TypeGame.chess12:
        board = getBoardChess12();
        break;
      case TypeGame.chess12Revolution:
        board = getBoardChess12Revolution();
        break;
    }
  }


  List<MapEntry<Square, Piece>> getEntriesFiltered({TypePiece type, bool isLight}) {
    return board.entries.where((entry) {
      var piece = entry.value;
      if ((type == null || piece.type == type) && (isLight == null || piece.isLight == isLight)) {
        return true;
      }
      return false;
    }).toList();
  }


  Piece getPieceAtSquare(Square square) {
    return board[square];
  }


  Square getSquareOfPiece(Piece piece) {
    var entriesFiltered = board.entries.where((entry) => entry.value == piece).toList();
    return entriesFiltered.isNotEmpty ? entriesFiltered.first.key : null;
  }


  List<Square> getSquaresFromSquareWithVector(Square square1, Square vector, {int limit = -1, Square stopBeforeSquare, bool stopBeforePiece = false, bool stopBeforePieceIsLight, bool stopAfterPiece = false, bool stopAfterPieceIsLight, Piece ignorePiece, bool addSquare1 = false}) {
    var squares = List<Square>();
    var square = Square(square1.column + vector.column, square1.row + vector.row);
    while (square.isInBounds && (limit == -1 || squares.length < limit)) {
      if (stopBeforeSquare != null && square == stopBeforeSquare) {
        break;
      }
      var pieceAtSquare = board[square];
      if (stopBeforePiece && pieceAtSquare != null && pieceAtSquare != ignorePiece) {
        break;
      }
      if (stopBeforePieceIsLight != null && pieceAtSquare != null && pieceAtSquare.isLight == stopBeforePieceIsLight) {
        break;
      }
      squares.add(square);
      if (stopAfterPiece && pieceAtSquare != null && pieceAtSquare != ignorePiece) {
        break;
      }
      if (stopAfterPieceIsLight != null && pieceAtSquare != null && pieceAtSquare.isLight == stopAfterPieceIsLight) {
        break;
      }
      square = Square(square.column + vector.column, square.row + vector.row);
    }
    if (squares.isNotEmpty && addSquare1) {
      squares.insert(0, square1);
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


  List<Piece> getPiecesInSquares(List<Square> squares) {
    return squares.map<Piece>((square) => board[square]).where((piece) => piece != null).toList();
  }


  List<List<Square>> getChecks(Square square, bool isLight) {

    var king = getEntriesFiltered(type: TypePiece.king, isLight: isLight).first.value;

    var checks = List<List<Square>>();

    for (Square vectorCheck in getVectorsCheck()) {
      var squares = getSquaresFromSquareWithVector(square, vectorCheck, stopAfterPiece: true, ignorePiece: king);
      if (squares.isEmpty) {
        continue;
      }
      var squareLast = squares.last;
      var pieceLast = board[squareLast];
      if (pieceLast == null || pieceLast.isLight != !isLightToMove) {
        continue;
      }
      var moveLastToKing = Move(squareLast, square);
      var isDeltaMoveLastToKingValid = isDeltaValidForPieceMove(pieceLast, moveLastToKing, isCapture: true);
      if (!isDeltaMoveLastToKingValid) {
        continue;
      }
      checks.add(squares);
    }

    return checks;
  }


  List<Square> getPin(Piece piece) {

    var squarePiece = getSquareOfPiece(piece);
    var squareKing = getEntriesFiltered(type: TypePiece.king, isLight: piece.isLight).first.key;

    var moveToKing = Move(squarePiece, squareKing);
    var vectorToKing = getDeltaReducedFromMove(moveToKing);

    var squaresToKing = getSquaresFromSquareWithVector(squarePiece, vectorToKing, stopAfterPiece: true, addSquare1: true);
    var pieceLastSquaresToKing = board[squaresToKing.last];
    if (pieceLastSquaresToKing == null || pieceLastSquaresToKing.type != TypePiece.king || pieceLastSquaresToKing.isLight != piece.isLight) {
      return null;
    }

    var vectorToKingReversed = Square(-vectorToKing.column, -vectorToKing.row);
    var squaresToKingReversed = getSquaresFromSquareWithVector(squarePiece, vectorToKingReversed, stopAfterPiece: true);
    if (squaresToKingReversed.isEmpty) {
      return null;
    }

    var squareLastSquaresToKingReversed = squaresToKingReversed.last;
    var pieceLastSquaresToKingReversed = board[squareLastSquaresToKingReversed];
    if (pieceLastSquaresToKingReversed == null) {
      return null;
    }

    if (pieceLastSquaresToKingReversed.isLight == piece.isLight) {
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
    var isLight = kingToMove.isLight;
    var squareCorner = Square(isShort ? 8 : 1, isLight ? 1 : 8);
    var pieceCorner = board[squareCorner];
    if (pieceCorner == null) {
      return false;
    }
    for (Move move in moves) {
      // if king or piece has moved return false
      if (kingToMove.squareFirst == move.square1 || pieceCorner.squareFirst == move.square1) {
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

    if (pieceToMove == null) {
      return false;
    }

    if (pieceToMove.isLight != isLightToMove) {
      return false;
    }

    var pieceAtSquare2 = board[move.square2];
    if (pieceAtSquare2 != null && pieceAtSquare2.isLight == pieceToMove.isLight) {
      return false;
    }
        
    var squareKing = getEntriesFiltered(type: TypePiece.king, isLight: isLightToMove).first.key;
    var checks = getChecks(squareKing, isLightToMove);

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
          var checks = getChecks(move.square2, pieceToMove.isLight);
          if (checks.isNotEmpty) {
            return false;
          }
        }
        else if (isDeltaValidForKingMove(move, isCastle: true)) {
          var vectorCastle = getDeltaReducedFromMove(move);
          var isShort = (move.square1.column == 5) == (vectorCastle.column > 0) ? true : false;
          if (!canCastleKing(pieceToMove, isShort: isShort)) {
            return false;
          }
          var countSquaresToCastle = isShort ? 2 : 3;
          var squaresToCastle = getSquaresFromSquareWithVector(move.square1, vectorCastle, addSquare1: true, limit: countSquaresToCastle, stopBeforePiece: true);
          var pieceOnCastlePath = squaresToCastle.length != countSquaresToCastle;
          if (pieceOnCastlePath) {
            return false;
          }
          for (Square square in squaresToCastle) {
            var checks = getChecks(square, pieceToMove.isLight);
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
        var vector = getDeltaReducedFromMove(move);
        var squares = getSquaresFromSquareWithVector(move.square1, vector, stopBeforeSquare: move.square2);
        var pieceInBetween = getPiecesInSquares(squares);
        if (pieceInBetween.isNotEmpty) {
          return false;
        }
        break;

      case TypePiece.rook:
        if (!isDeltaValidForRookMove(move)) {
          return false;
        }
        var vector = getDeltaReducedFromMove(move);
        var squares = getSquaresFromSquareWithVector(move.square1, vector, stopBeforeSquare: move.square2);
        var pieceInBetween = getPiecesInSquares(squares);
        if (pieceInBetween.isNotEmpty) {
          return false;
        }
        break;

      case TypePiece.bishop:
        if (!isDeltaValidForBishopMove(move)) {
          return false;
        }
        var vector = getDeltaReducedFromMove(move);
        var squares = getSquaresFromSquareWithVector(move.square1, vector, stopBeforeSquare: move.square2);
        var pieceInBetween = getPiecesInSquares(squares);
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
        if (isDeltaValidForPawnMove(move, isLight: pieceToMove.isLight, isCapture: false)) {
          var vector = getDeltaReducedFromMove(move);
          var limit = (move.square1.row - move.square2.row).abs();
          if (limit == 2 && !canDoubleMove(move.square1)) {
            return false;
          }
          var squares = getSquaresFromSquareWithVector(move.square1, vector, limit:limit);
          if (!areSquaresEmpty(squares)) {
            return false;
          }
        }
        else if (isDeltaValidForPawnMove(move, isLight: pieceToMove.isLight, isCapture: true)) {
          if (pieceAtSquare2 == null) {
            var captureEnPassant = canCaptureEnPassant();
            if (captureEnPassant == null) {
              return false;
            }
            var squareEnPassant = getSquareOfPiece(captureEnPassant);
            if (!isDeltaValidForCaptureEnPassant(move.square2, squareEnPassant, isLight:pieceToMove.isLight)) {
              return false;
            }
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


  List<Move> getValidMoves(Square square1) {

    var pieceToMove = board[square1];

    if (pieceToMove == null || pieceToMove.isLight != isLightToMove) {
      return [];
    }

    var squares2 =  List<Square>();
    var vectors = getVectorsForPiece(pieceToMove);

    switch (pieceToMove.type) {

      case TypePiece.king:
        for (Square vector in vectors) {
          var isCastleDelta = getVectorsKingCastle().contains(vector);
          var squares = getSquaresFromSquareWithVector(square1, vector, limit: isCastleDelta ? 2 : 1, stopBeforePieceIsLight: pieceToMove.isLight, stopAfterPiece: isCastleDelta);
          squares2.addAll(squares);
        }
        break;

      case TypePiece.queen:
        for (Square vector in vectors) {
          var squares = getSquaresFromSquareWithVector(square1, vector, stopBeforePieceIsLight: pieceToMove.isLight, stopAfterPieceIsLight: !pieceToMove.isLight);
          squares2.addAll(squares);
        }
        break;

      case TypePiece.rook:
        for (Square vector in vectors) {
          var squares = getSquaresFromSquareWithVector(square1, vector, stopBeforePieceIsLight: pieceToMove.isLight, stopAfterPieceIsLight: !pieceToMove.isLight);
          squares2.addAll(squares);
        }
        break;

      case TypePiece.bishop:
        for (Square vector in vectors) {
          var squares = getSquaresFromSquareWithVector(square1, vector, stopBeforePieceIsLight: pieceToMove.isLight, stopAfterPieceIsLight: !pieceToMove.isLight);
          squares2.addAll(squares);
        }
        break;

      case TypePiece.knight:
        for (Square vector in vectors) {
          var squares = getSquaresFromSquareWithVector(square1, vector, limit: 1, stopBeforePieceIsLight: pieceToMove.isLight);
          squares2.addAll(squares);
        }
        break;

      case TypePiece.pawn:
        for (Square vector in vectors) {
          var isDeltaCapture = getVectorsPawnCapture(isLight: pieceToMove.isLight).contains(vector);
          var squares = getSquaresFromSquareWithVector(square1, vector, limit: isDeltaCapture ? 1 : 2, stopBeforePieceIsLight: pieceToMove.isLight, stopBeforePiece: !isDeltaCapture);
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
    var promotionRow = piece.isLight ? 8 : 1;
    var isSquareFinalPromotionRow = move.square2.row == promotionRow;
    return isPiecePawn && isSquareFinalPromotionRow;
  }


  // * does not validates
  bool isMoveCastling(Move move, {bool isShort}) {
    var piece = board[move.square1];
    var vectorColumn = move.square2.column - move.square1.column;
    var isDeltaAbsColumn2 = vectorColumn.abs() == 2;
    var isDeltaColumnPositive = vectorColumn > 0;
    return piece.type == TypePiece.king && isDeltaAbsColumn2 && isShort == isDeltaColumnPositive;
  }


  // * does not validates
  bool isMoveEnPassant(Move move) {
    var piece = board[move.square1];
    var pieceCapture = board[move.square2];
    var isDeltaColumn1 = (move.square1.column - move.square2.column).abs() == 1;
    return piece.type == TypePiece.pawn && pieceCapture == null && isDeltaColumn1;
  }

  bool isThereSufficientMaterialToCheckmate({bool isLight}) {
    var pieces = getEntriesFiltered(isLight: isLight);
    if (pieces.length == 1) {
      return false;
    }
    var isThereAKnight = pieces.where((piece) => piece.value.type == TypePiece.knight).isNotEmpty;
    var isThereABishop = pieces.where((piece) => piece.value.type == TypePiece.bishop).isNotEmpty;
    if (pieces.length == 2 && (isThereAKnight || isThereABishop)) {
      return false;
    }
    return true;
  }


  bool makeMove(Move move, {bool shouldValidate = true}) {

    // validate move
    if (shouldValidate && !isMoveValid(move)) {
      return false;
    }

    var pieceToMove = board[move.square1];

    // for png
    var entriesOtherWithValidSquare2 = getEntriesFiltered(type: pieceToMove.type, isLight: pieceToMove.isLight)
        .where((entryPiece) => entryPiece.value != pieceToMove)
        .where((entryPiece) => isMoveValid(Move(entryPiece.key, move.square2))).toList();

    if (isMovePromotion(move)) {
      pieceToMove.type = TypePiece.queen;
    }

    // if castling move rook
    var isCastleShort = isMoveCastling(move, isShort: true);
    var isCastleLong = isMoveCastling(move, isShort: false);
    if (isCastleShort || isCastleLong) {
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

    // NOTE update board after checking isMoveCastling isMoveEnPassant as they read the board
    board.remove(move.square1);
    var pieceTaken = board[move.square2];
    board[move.square2] = pieceToMove;
    moves.add(move);

    isLightToMove = !isLightToMove;
    
    var squareKing = getEntriesFiltered(type: TypePiece.king, isLight: isLightToMove).first.key;
    var checks = getChecks(squareKing, isLightToMove);

    var entriesPiecesToMove = getEntriesFiltered(isLight: isLightToMove);

    var areThereValidMoves = false;
    for (MapEntry<Square, Piece> entryPiece in entriesPiecesToMove) {
      if (getValidMoves(entryPiece.key).isNotEmpty) {
        areThereValidMoves = true;
        break;
      }
    }

    if (!areThereValidMoves) {
      if (checks.isNotEmpty) {
        state = StateGame.checkmate;
      }
      else {
        state = StateGame.stalemate;
      }
    }

    if (!isThereSufficientMaterialToCheckmate(isLight: true) && !isThereSufficientMaterialToCheckmate(isLight: false)) {
      state = StateGame.insufficientMaterial;
    }

    // notation
    // ...
    String notation;
    if (!isCastleShort && !isCastleLong) {
      var notationType = pieceToMove.notationType;
      var notationDisambiguation = "";
      if (pieceToMove.type == TypePiece.pawn && pieceTaken != null) {
        notationDisambiguation = move.square1.notationColumn;
      }
      if (entriesOtherWithValidSquare2.isNotEmpty) {
        var setSquare1 = move.square1.notation.split("").toSet();
        var setSquare1Other = entriesOtherWithValidSquare2.first.key.notation.split("").toSet();
        var intersection = setSquare1Other.intersection(setSquare1);
        notationDisambiguation = setSquare1.difference(intersection).first;
      }
      var notationCapture = pieceTaken != null ? "x" : "";
      var notationSquare = move.square2.notation;
      var notationEnd = state == StateGame.checkmate ? "#" : checks.isNotEmpty ? "+" : "";
      notation = "$notationType$notationDisambiguation$notationCapture$notationSquare$notationEnd";
    }
    else {
      notation = isCastleShort ? STRING_CASTLE_SHORT : STRING_CASTLE_LONG;
    }
    notations.add(notation);

    return true;
  }


  Move getMoveFromNotation(String notation) {

    if (notation == "") {
      print("");
    }

    Square squareInitial;
    Square squareFinal;

    var isShortCastle = notation == STRING_CASTLE_SHORT;
    var isLongCastle = notation == STRING_CASTLE_LONG;

    // if not castle
    // ...
    // ...
    if (!isShortCastle && !isLongCastle) {

      var charsPNG = notation.split("");

      // get type piece
      // ...
      var typePiece = notation.contains("K") ? TypePiece.king 
      : notation.contains("Q") ? TypePiece.queen 
      : notation.contains("B") ? TypePiece.bishop
      : notation.contains("N") ? TypePiece.knight
      : notation.contains("R") ? TypePiece.rook
      : TypePiece.pawn; 

      // get square final
      // ...
      var columns = charsPNG.map<int>((c) => "_abcdefgh".split("").indexOf(c)).where((index) => index != -1).toList();
      var columnFinal = columns.last;
      var rows = charsPNG.map<int>((c) => "_12345678".split("").indexOf(c)).where((index) => index != -1).toList();
      var rowFinal = rows.last;
      squareFinal = Square(columnFinal, rowFinal);

      // get square initial
      // ...
      var entries = getEntriesFiltered(type: typePiece, isLight: isLightToMove);
      if (entries.isEmpty) {
        print(entries);
        throw Exception("Invalid PNG move");
      }
      if (entries.length > 1) {
        int columnInitial = columns[0] != columnFinal ? columns[0] : null;
        if (columnInitial != null) {
          entries = entries.where((entryPiece) => entryPiece.key.column == columnInitial).toList();
        }
        int rowInitial = rows[0] != rowFinal ? rows[0] : null;
        if (rowInitial != null) {
          entries = entries.where((entryPiece) => entryPiece.key.row == rowInitial).toList();
        }
      }
      if (entries.length > 1) {
        entries = entries.where((entryPiece) => isMoveValid(Move(entryPiece.key, squareFinal))).toList();
      }
      if (entries.length > 1) {
        print(entries);
        throw Exception("Ambiguous PNG move");
      }
      squareInitial = entries.first.key;
    }
    
    // castle
    else {
      var entryKing = getEntriesFiltered(type: TypePiece.king, isLight: isLightToMove).first;
      squareInitial = entryKing.key;
      var vectorColumns = isShortCastle ? 2 : -2;
      squareFinal = Square(squareInitial.column + vectorColumns, squareInitial.row);
    }

    var move = Move(squareInitial, squareFinal);
    return move;
  }
}