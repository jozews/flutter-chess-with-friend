
import 'dart:io';
import 'dart:convert';

import 'package:path_provider/path_provider.dart';


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

  GameHistory({this.idDevice, this.nameLight, this.nameDark, this.isLightWinner, this.result, this.moves});

  GameHistory.fromMap(Map<String, dynamic> map) {
    idDevice = map["id_device"];
    nameLight = map["name_light"];
    nameDark = map["name_dark"];
    result = ResultGameHistory.values[map["result"]];
    isLightWinner = map["is_light_winner"];
    moves = map["moves"].map((move) => MoveGameHistory(move["notation"], move["time"]));
  }

  Map<String, dynamic> get toMap {
    return {
      "id_device" : idDevice,
      "name_light" : nameLight,
      "name_dark" : nameDark,
      "result" : ResultGameHistory.values.indexOf(result),
      "is_light_winner" : isLightWinner,
      "moves" : moves.map((move) => {
        "notation" : move.notation,
        "time" : move.time
      })
    };
  }
}


class History {

  Directory directoryApp;
  bool isLocalWhite;

  static saveGame(GameHistory gameHistory) async {
    var directoryApp = await getApplicationDocumentsDirectory();
    var pathGame = "$directoryApp/games/${gameHistory.idDevice}";
    var fileGame = File(pathGame);
    var json = jsonEncode(gameHistory.toMap);
    fileGame.writeAsStringSync(json);
  }

  static getGames() async {
    var directoryApp = await getApplicationDocumentsDirectory();
    var pathGames = "$directoryApp/games";
    var directoryGames = Directory(pathGames);
    var files = directoryGames.listSync();
    var gamesHistory = files.map((file) {
      var stringJson = (file as File).readAsStringSync();
      var mapJson = jsonDecode(stringJson);
      return GameHistory.fromMap(mapJson);
    });
    return gamesHistory;
  }
}