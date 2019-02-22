
import 'package:flutter/material.dart';

import 'Game.dart';

class WidgetPiece {

  static Image withPiece(Piece piece) {
    var namePiece = piece.type.toString().replaceFirst("TypePiece.", "");
    var nameIsLight = piece.isLight ? "light" : "dark";
    var name = "$namePiece-$nameIsLight";
    return Image.asset("sets/default/$name.png");
  }
}