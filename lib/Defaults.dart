
import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

import 'Const.dart';


class Defaults {

  static const SHOW_VALID_MOVES = "shows_valid_move";
  static const SHOW_TAG_SQUARES = "shows_tag_squares";
  static const AUTO_ROTATES = "auto_rotates";
  static const INDEX_ACCENT = "index_accent";
  static const INDEX_NAME_PIECES = "index_name_pieces";

  bool showsValidMoves;
  bool showsTagSquares;
  bool autoRotates;
  int indexAccent;
  int indexNamePieces;

  // GET
  // ..
  // ..
  static Future<String> getString(String key) async {
    var completer = new Completer<String>();
    var prefs = await SharedPreferences.getInstance();
    completer.complete(prefs.getString(key));
    return completer.future;
  }

  static Future<int> getInt(String key) async {
    var completer = new Completer<int>();
    var prefs = await SharedPreferences.getInstance();
    completer.complete(prefs.getInt(key));
    return completer.future;
  }

  static Future<bool> getBool(String key) async {
    var completer = new Completer<bool>();
    var prefs = await SharedPreferences.getInstance();
    completer.complete(prefs.getBool(key));
    return completer.future;
  }
  // SET
  // ..
  // ..
  static Future setString(String key, String value) async {
    var completer = new Completer();
    var prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
    completer.complete();
    return completer.future;
  }

  static Future setInt(String key, int value) async {
    var completer = new Completer();
    var prefs = await SharedPreferences.getInstance();
    prefs.setInt(key, value);
    completer.complete();
    return completer.future;
  }

  static Future setBool(String key, bool value) async {
    var completer = new Completer();
    var prefs = await SharedPreferences.getInstance();
    prefs.setBool(key, value);
    completer.complete();
    return completer.future;
  }

  //UTILS
  // ...
  // ...
  getBoard() async {
    showsValidMoves = await Defaults.getBool(Defaults.SHOW_VALID_MOVES) ?? true;
    showsTagSquares = await Defaults.getBool(Defaults.SHOW_TAG_SQUARES) ?? false;
    autoRotates = await Defaults.getBool(Defaults.AUTO_ROTATES) ?? false;
    indexAccent = await Defaults.getInt(Defaults.INDEX_ACCENT) ?? 0;
    indexNamePieces = await Defaults.getInt(Defaults.INDEX_NAME_PIECES) ?? 0;
  }

  setBoard() async {
    await Defaults.setBool(Defaults.SHOW_VALID_MOVES, showsValidMoves);
    await Defaults.setBool(Defaults.SHOW_TAG_SQUARES, showsTagSquares);
    await Defaults.setInt(Defaults.INDEX_ACCENT, indexAccent);
    await Defaults.setInt(Defaults.INDEX_NAME_PIECES, indexNamePieces);
    await Defaults.setBool(Defaults.AUTO_ROTATES, autoRotates);
  }
}