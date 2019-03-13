
import 'dart:typed_data';

import 'Game.dart';
import 'Timer.dart';

enum TypeActionNearby {
  moveStart, moveEnd, timer, resign, draw, start
}

class ActionNearby {

  TypeActionNearby type;
  Move move;
  double timestampStart;
  double timestampEnd;
  ControlTimer control;

  ActionNearby.moveEnd(this.move, this.timestampEnd) {
    this.type = TypeActionNearby.moveEnd;
  }

  ActionNearby.moveStart(this.timestampStart) {
    this.type = TypeActionNearby.moveStart;
  }

  ActionNearby.timer(this.control) {
    this.type = TypeActionNearby.timer;
  }

  ActionNearby.resign() {
    this.type = TypeActionNearby.resign;
  }

  ActionNearby.draw() {
    this.type = TypeActionNearby.draw;
  }

  ActionNearby.fromBytes(Uint8List list) {
    ByteData byteData = ByteData.view(list.buffer);
    this.type = TypeActionNearby.values[byteData.getInt8(0)];
    switch (type) {
      case TypeActionNearby.moveStart:
        this.timestampStart = byteData.getFloat32(1);
        break;
      case TypeActionNearby.moveEnd:
        this.timestampEnd = byteData.getFloat32(1);
        var square1 = Square.fromInt(byteData.getInt8(5));
        var square2 = Square.fromInt(byteData.getInt8(6));
        this.move = Move(square1, square2);
        break;
      case TypeActionNearby.timer:
        this.control = ControlTimer.values[byteData.getInt8(1)];
        break;
      default:
        break;
    }
  }

  Uint8List toBytes() {
    ByteData byteData;
    switch (type) {
      case TypeActionNearby.moveStart:
        byteData = new ByteData(9);
        byteData.setInt8(0, TypeActionNearby.values.indexOf(type));
        byteData.setFloat32(1, timestampStart);
        break;
      case TypeActionNearby.moveEnd:
        byteData = new ByteData(11);
        byteData.setInt8(0, TypeActionNearby.values.indexOf(type));
        byteData.setFloat32(1, timestampEnd);
        byteData.setInt8(5, move.square1.toInt());
        byteData.setInt8(6, move.square2.toInt());
        break;
      case TypeActionNearby.timer:
        byteData = new ByteData(2);
        byteData.setInt8(0, TypeActionNearby.values.indexOf(type));
        byteData.setInt8(0, ControlTimer.values.indexOf(control));
        break;
      case TypeActionNearby.resign:
        byteData = new ByteData(1);
        byteData.setInt8(0, TypeActionNearby.values.indexOf(type));
        break;
      case TypeActionNearby.draw:
        byteData = new ByteData(1);
        byteData.setInt8(0, TypeActionNearby.values.indexOf(type));
        break;
      case TypeActionNearby.start:
        byteData = new ByteData(1);
        byteData.setInt8(0, TypeActionNearby.values.indexOf(type));
        break;
    }
    Uint8List list = Uint8List.view(byteData.buffer);
    return list;
  }
}