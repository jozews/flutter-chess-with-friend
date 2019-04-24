
import 'Square.dart';

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