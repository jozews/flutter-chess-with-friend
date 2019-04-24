

import 'package:quiver/core.dart';

import 'Square.dart';


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