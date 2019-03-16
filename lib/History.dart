
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'Game.dart';
import 'Connection.dart';


enum ResultGameHistory {
  def
}

class GameHistory {

  String notatedMoves;

  GameHistory.file(FileSystemEntity file) {
    var string = (file as File).readAsStringSync();
  }
}

class History {

  Directory directoryApp;
  bool isLocalWhite;

  static saveGame(Game game, Connection connection, {bool isResignLocal, bool isDraw, bool isTimeLightOver, bool isAbort}) async {
    var directoryApp = await getApplicationDocumentsDirectory();
    var pathGame = "$directoryApp/games/${connection.idDevice}";
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