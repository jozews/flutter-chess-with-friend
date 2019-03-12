import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

class Defaults {

  static const AUTO_ROTATES = "auto_rotates";
  static const INDEX_ACCENT = "index_accent";
  static const INDEX_NAME_PIECES = "index_name_pieces";
  static const SHOWS_VALID_MOVES = "shows_valid_move";

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
}