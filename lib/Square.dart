

import 'package:quiver/core.dart';


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