
import 'dart:typed_data';

import 'package:utf/utf.dart';

import 'Game.dart';
import 'Timer.dart';


enum TypePayloadGame {
  idDevice, timer, start, moveStart, moveEnd, resign, draw
}

class PayloadGame {

  TypePayloadGame type;
  Move move;
  double timestampStart;
  double timestampEnd;
  ControlTimer control;
  String idDevice;

  PayloadGame.idDevice(this.idDevice) {
    this.type = TypePayloadGame.idDevice;
  }

  PayloadGame.timer(this.control) {
    this.type = TypePayloadGame.timer;
  }

  PayloadGame.start() {
    this.type = TypePayloadGame.start;
  }

  PayloadGame.resign() {
    this.type = TypePayloadGame.resign;
  }

  PayloadGame.draw() {
    this.type = TypePayloadGame.draw;
  }

  PayloadGame.moveEnd(this.move, this.timestampEnd) {
    this.type = TypePayloadGame.moveEnd;
  }

  PayloadGame.moveStart(this.timestampStart) {
    this.type = TypePayloadGame.moveStart;
  }

  PayloadGame.fromBytes(Uint8List list) {
    ByteData byteData = ByteData.view(list.buffer);
    this.type = TypePayloadGame.values[byteData.getInt8(0)];
    switch (type) {
      case TypePayloadGame.idDevice:
        var bytesString =  byteData.buffer.asUint8List(1, byteData.lengthInBytes - 1);
        this.idDevice = decodeUtf8(bytesString);
        break;
      case TypePayloadGame.timer:
        this.control = ControlTimer.values[byteData.getInt8(1)];
        break;
      case TypePayloadGame.moveStart:
        this.timestampStart = byteData.getFloat32(1);
        break;
      case TypePayloadGame.moveEnd:
        this.timestampEnd = byteData.getFloat32(1);
        var square1 = Square.fromInt(byteData.getInt8(5));
        var square2 = Square.fromInt(byteData.getInt8(6));
        this.move = Move(square1, square2);
        break;
      default:
        break;
    }
  }

  Uint8List toBytes() {
    ByteData byteData;
    switch (type) {
      case TypePayloadGame.idDevice:
        var bytes = encodeUtf8(idDevice);
        byteData = new ByteData(1 + bytes.length);
        byteData.setInt8(0, TypePayloadGame.values.indexOf(type));
        bytes.asMap().forEach((idx, byte) {
          byteData.setInt8(1 + idx, byte);
        });
        break;
      case TypePayloadGame.timer:
        byteData = new ByteData(2);
        byteData.setInt8(0, TypePayloadGame.values.indexOf(type));
        byteData.setInt8(1, ControlTimer.values.indexOf(control));
        break;
      case TypePayloadGame.moveStart:
        byteData = new ByteData(5);
        byteData.setInt8(0, TypePayloadGame.values.indexOf(type));
        byteData.setFloat32(1, timestampStart);
        break;
      case TypePayloadGame.moveEnd:
        byteData = new ByteData(11);
        byteData.setInt8(0, TypePayloadGame.values.indexOf(type));
        byteData.setFloat32(1, timestampEnd);
        byteData.setInt8(5, move.square1.toInt());
        byteData.setInt8(6, move.square2.toInt());
        break;
      default:
        byteData = new ByteData(1);
        byteData.setInt8(0, TypePayloadGame.values.indexOf(type));
        break;
    }
    Uint8List list = Uint8List.view(byteData.buffer);
    return list;
  }
}