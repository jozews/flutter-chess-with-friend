
import 'dart:io';
import 'dart:convert';

import 'package:path_provider/path_provider.dart';

import 'TimerGame.dart';

enum ResultGameHistory {
  checkmate, stalemate, insufficientMaterial, timeOver, resignation, draw, abort
}


class MoveGameHistory {
  String notation;
  double time;
  MoveGameHistory(this.notation, this.time);
}


class GameHistory {

  String idDevice;
  String nameLight;
  String nameDark;
  ResultGameHistory result;
  bool isLightWinner;
  List<MoveGameHistory> moves;
  double timestamp;

  GameHistory({this.idDevice, this.nameLight, this.nameDark, this.isLightWinner, this.result, this.moves});

  GameHistory.fromMap(Map<String, dynamic> map) {
    idDevice = map["id_device"];
    nameLight = map["name_light"];
    nameDark = map["name_dark"];
    result = ResultGameHistory.values[map["result"]];
    isLightWinner = map["is_light_winner"];
    moves = map["moves"].map<MoveGameHistory>((move) => MoveGameHistory(move["notation"], move["time"])).toList();
    timestamp = map["timestamp"];
  }

  Map<String, dynamic> get toMap {
    return {
      "id_device" : idDevice,
      "name_light" : nameLight,
      "name_dark" : nameDark,
      "result" : ResultGameHistory.values.indexOf(result),
      "is_light_winner" : isLightWinner,
      "timestamp" : TimerGame.timestampNow,
      "moves" : moves.map((move) => {
        "notation" : move.notation,
        "time" : move.time
      }).toList()
    };
  }
}


class History {

  Directory directoryApp;
  bool isLocalWhite;

  static saveGame(GameHistory gameHistory) async {
    var directoryGames = await getDirectoryGames();
    var pathGame = "${directoryGames.path}/${TimerGame.timestampNow}";
    var fileGame = File(pathGame);
    var json = jsonEncode(gameHistory.toMap);
    fileGame.writeAsStringSync(json);
  }

  static Future<List<GameHistory>> getGames() async {
    var directoryGames = await getDirectoryGames();
    var files = directoryGames.listSync();
    var gamesHistory =   files.map((file) {
      var stringJson = (file as File).readAsStringSync();
      var mapJson = jsonDecode(stringJson);
      return GameHistory.fromMap(mapJson);
    }).toList();
    return gamesHistory;
  }

  static clearGames() async {
    var directoryGames = await getDirectoryGames(createIfNonExistent: false);
    if (directoryGames.existsSync()) {
      await directoryGames.delete();
    }
  }

  static Future<Directory> getDirectoryGames({bool createIfNonExistent = true}) async {
    var directoryApp = await getApplicationDocumentsDirectory();
    var pathGames = "${directoryApp.path}/history";
    var directoryGames = Directory(pathGames);
    if (createIfNonExistent && !directoryGames.existsSync()) {
      directoryGames.createSync();
    }
    return directoryGames;
  }
}