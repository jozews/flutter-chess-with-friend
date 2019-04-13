
import 'dart:core';
import 'package:quiver/core.dart';

import 'UtilsGame.dart';


enum TypePiece {
  king, queen, bishop, knight, rook, pawn
}



class Piece {

  Square squareFirst;
  TypePiece type;
  bool isLight;

  Piece(this.type, this.isLight, this.squareFirst);

  @override
  String toString() {
    return "${isLight ? 'light' : 'dark'} $type";
  }

  bool operator ==(o) => o is Piece && o.squareFirst == squareFirst;
  int get hashCode => squareFirst.hashCode;

  String get notationType {
    return type == TypePiece.king ? "K" 
        : type == TypePiece.queen ? "Q" 
        : type == TypePiece.bishop ? "B" 
        : type == TypePiece.knight ? "N" 
        : type == TypePiece.rook ? "R" 
        : "";
  }
}



enum StateGame {
  ongoing, checkmate, stalemate, insufficientMaterial
}



class Square {

  int column;
  int row;

  Square(this.column, this.row);

  Square.fromInt(int i) {
    this.column = i ~/ 10;
    this.row = i % 10;
  }

  bool get isLight => row % 2 != column % 2;

  int toInt() {
    return column*10 + row;
  }


  @override
  String toString() {
    return "($column, $row)";
  }

  bool get isInBounds => column >= 1 && column <= 8 && row >= 1 && row <= 8;
  bool operator ==(o) => o is Square && o.column == column && o.row == row;
  int get hashCode => hash2(column.hashCode, row.hashCode);
  
  String get notation => notationColumn + row.toString();
  String get notationColumn => "_abcdefgh".split("")[column];
}



class Move {

  Square square1;
  Square square2;

  Move(this.square1, this.square2);

  @override
  String toString() {
    return "$square1 to $square2";
  }

  bool operator ==(o) => o is Move && o.square1 == square1 && o.square2 == square2;
  int get hashCode => hash2(square1, square2);
}


enum TypeGame {
  standard, chess12
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


  List<Square> getSquaresFromSquareWithDelta(Square square1, Square delta, {int limit = -1, Square stopBeforeSquare, bool stopBeforePiece = false, bool stopBeforePieceIsLight, bool stopAfterPiece = false, bool stopAfterPieceIsLight, Piece ignorePiece, bool addSquare1 = false}) {
    var squares = List<Square>();
    var square = Square(square1.column + delta.column, square1.row + delta.row);
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
      square = Square(square.column + delta.column, square.row + delta.row);
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

    for (Square deltaCheck in getDeltasCheck()) {
      var squares = getSquaresFromSquareWithDelta(square, deltaCheck, stopAfterPiece: true, ignorePiece: king);
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
    var deltaToKing = getDeltaReducedFromMove(moveToKing);

    var squaresToKing = getSquaresFromSquareWithDelta(squarePiece, deltaToKing, stopAfterPiece: true, addSquare1: true);
    var pieceLastSquaresToKing = board[squaresToKing.last];
    if (pieceLastSquaresToKing == null || pieceLastSquaresToKing.type != TypePiece.king || pieceLastSquaresToKing.isLight != piece.isLight) {
      return null;
    }

    var deltaToKingReversed = Square(-deltaToKing.column, -deltaToKing.row);
    var squaresToKingReversed = getSquaresFromSquareWithDelta(squarePiece, deltaToKingReversed, stopAfterPiece: true);
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
          var deltaCastle = getDeltaReducedFromMove(move);
          var isShort = (move.square1.row == 5) == (deltaCastle.column > 0) ? false : true;
          if (!canCastleKing(pieceToMove, isShort: isShort)) {
            return false;
          }
          var countSquaresToCastle = isShort ? 2 : 3;
          var squaresToCastle = getSquaresFromSquareWithDelta(move.square1, deltaCastle, limit: countSquaresToCastle, stopBeforePiece: true);
          if (squaresToCastle.length != countSquaresToCastle) {
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
        var delta = getDeltaReducedFromMove(move);
        var squares = getSquaresFromSquareWithDelta(move.square1, delta, stopBeforeSquare: move.square2);
        var pieceInBetween = getPiecesInSquares(squares);
        if (pieceInBetween.isNotEmpty) {
          return false;
        }
        break;

      case TypePiece.rook:
        if (!isDeltaValidForRookMove(move)) {
          return false;
        }
        var delta = getDeltaReducedFromMove(move);
        var squares = getSquaresFromSquareWithDelta(move.square1, delta, stopBeforeSquare: move.square2);
        var pieceInBetween = getPiecesInSquares(squares);
        if (pieceInBetween.isNotEmpty) {
          return false;
        }
        break;

      case TypePiece.bishop:
        if (!isDeltaValidForBishopMove(move)) {
          return false;
        }
        var delta = getDeltaReducedFromMove(move);
        var squares = getSquaresFromSquareWithDelta(move.square1, delta, stopBeforeSquare: move.square2);
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
          var delta = getDeltaReducedFromMove(move);
          var limit = (move.square1.row - move.square2.row).abs();
          if (limit == 2 && !canDoubleMove(move.square1)) {
            return false;
          }
          var squares = getSquaresFromSquareWithDelta(move.square1, delta, limit:limit);
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
    var deltas = getDeltasForPiece(pieceToMove);

    switch (pieceToMove.type) {

      case TypePiece.king:
        for (Square delta in deltas) {
          var isCastleDelta = getDeltasKingCastle().contains(delta);
          var squares = getSquaresFromSquareWithDelta(square1, delta, limit: isCastleDelta ? 2 : 1, stopBeforePieceIsLight: pieceToMove.isLight, stopAfterPiece: isCastleDelta);
          squares2.addAll(squares);
        }
        break;

      case TypePiece.queen:
        for (Square delta in deltas) {
          var squares = getSquaresFromSquareWithDelta(square1, delta, stopBeforePieceIsLight: pieceToMove.isLight, stopAfterPieceIsLight: !pieceToMove.isLight);
          squares2.addAll(squares);
        }
        break;

      case TypePiece.rook:
        for (Square delta in deltas) {
          var squares = getSquaresFromSquareWithDelta(square1, delta, stopBeforePieceIsLight: pieceToMove.isLight, stopAfterPieceIsLight: !pieceToMove.isLight);
          squares2.addAll(squares);
        }
        break;

      case TypePiece.bishop:
        for (Square delta in deltas) {
          var squares = getSquaresFromSquareWithDelta(square1, delta, stopBeforePieceIsLight: pieceToMove.isLight, stopAfterPieceIsLight: !pieceToMove.isLight);
          squares2.addAll(squares);
        }
        break;

      case TypePiece.knight:
        for (Square delta in deltas) {
          var squares = getSquaresFromSquareWithDelta(square1, delta, limit: 1, stopBeforePieceIsLight: pieceToMove.isLight);
          squares2.addAll(squares);
        }
        break;

      case TypePiece.pawn:
        for (Square delta in deltas) {
          var isDeltaCapture = getDeltasPawnCapture(isLight: pieceToMove.isLight).contains(delta);
          var squares = getSquaresFromSquareWithDelta(square1, delta, limit: isDeltaCapture ? 1 : 2, stopBeforePieceIsLight: pieceToMove.isLight, stopBeforePiece: !isDeltaCapture);
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
    var deltaColumn = move.square2.column - move.square1.column;
    var isDeltaAbsColumn2 = deltaColumn.abs() == 2;
    var isDeltaColumnPositive = deltaColumn > 0;
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


  bool makeMove(Move move) {

    // validate move
    if (!isMoveValid(move)) {
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
      var deltaColumns = isShortCastle ? 2 : -2;
      squareFinal = Square(squareInitial.column + deltaColumns, squareInitial.row);
    }

    var move = Move(squareInitial, squareFinal);
    return move;
  }
}