
import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';


class Defaults {

  static const SHOWS_VALID_MOVES = "shows_valid_move";
  static const SHOWS_TAG_SQUARES = "shows_tag_squares";
  static const ROTATES_AUTOMATICALLY = "rotates_automatically";
  static const PROMOTES_AUTOMATICALLY = "promotes_automatically";

  static const INDEX_ACCENT = "index_accent";
  static const INDEX_NAME_PIECES = "index_name_pieces";

  static const SCORE_LOCAL = "score_local";
  static const SCORE_REMOTE = "score_remote";

  bool showsValidMoves;
  bool showsTagSquares;
  bool rotatesAutomatically;
  bool promotesAutomatically;
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

  static Future<double> getDouble(String key) async {
    var completer = new Completer<double>();
    var prefs = await SharedPreferences.getInstance();
    completer.complete(prefs.getDouble(key));
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

  static Future setDouble(String key, double value) async {
    var completer = new Completer();
    var prefs = await SharedPreferences.getInstance();
    prefs.setDouble(key, value);
    completer.complete();
    return completer.future;
  }

  //UTILS
  // ...
  // ...
  getBoard() async {
    showsValidMoves = await Defaults.getBool(Defaults.SHOWS_VALID_MOVES) ?? true;
    showsTagSquares = await Defaults.getBool(Defaults.SHOWS_TAG_SQUARES) ?? false;
    rotatesAutomatically = await Defaults.getBool(Defaults.ROTATES_AUTOMATICALLY) ?? false;
    promotesAutomatically = await Defaults.getBool(Defaults.PROMOTES_AUTOMATICALLY) ?? true;
    indexAccent = await Defaults.getInt(Defaults.INDEX_ACCENT) ?? 0;
    indexNamePieces = await Defaults.getInt(Defaults.INDEX_NAME_PIECES) ?? 0;
  }

  setBoard() async {
    await Defaults.setBool(Defaults.SHOWS_VALID_MOVES, showsValidMoves);
    await Defaults.setBool(Defaults.SHOWS_TAG_SQUARES, showsTagSquares);
    await Defaults.setBool(Defaults.ROTATES_AUTOMATICALLY, rotatesAutomatically);
    await Defaults.setBool(Defaults.PROMOTES_AUTOMATICALLY, promotesAutomatically);
    await Defaults.setInt(Defaults.INDEX_ACCENT, indexAccent);
    await Defaults.setInt(Defaults.INDEX_NAME_PIECES, indexNamePieces);
  }
}