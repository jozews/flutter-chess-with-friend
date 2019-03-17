
import 'dart:io';

import 'package:path_provider/path_provider.dart';


enum ResultGameHistory {
  checkmate, stalemate, insufficientMaterial, timeOver, resignation, draw, abort
}


class MoveGameHistory {
  String time;
  String notation;
}


class GameHistory {

  String idDevice;
  String nameLight;
  String nameDark;
  ResultGameHistory result;
  bool isLightWinner;
  List<MoveGameHistory> moves;

  GameHistory({this.idDevice, this.nameLight, this.nameDark, this.isLightWinner, this.result, this.moves});

  GameHistory.file(File file) {
    var string = file.readAsStringSync();
  }
}


class History {

  Directory directoryApp;
  bool isLocalWhite;

  static saveGame(GameHistory gameHistory) async {
    var directoryApp = await getApplicationDocumentsDirectory();
    var pathGame = "$directoryApp/games/${gameHistory.idDevice}";
    var fileGame = File(pathGame);
  }

  static getGames() async {
    var directoryApp = await getApplicationDocumentsDirectory();
    var pathGames = "$directoryApp/games";
    var directoryGames = Directory(pathGames);
    var files = directoryGames.listSync();
    var gamesHistory = files.map((file) => GameHistory.file(file));
    return gamesHistory;
  }
}