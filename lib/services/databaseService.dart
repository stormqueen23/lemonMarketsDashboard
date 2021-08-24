import 'dart:convert';

import 'package:lemon_markets_simple_dashboard/data/authData.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DatabaseService {
  final log = Logger('DatabaseService');

  final String currentSpaceKey = 'CURRENT_SPACE';
  final String allSpacesKey = 'ALL_SPACES';

  DatabaseService();

  Future<AuthData?> loadCurrentSpace() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? result = prefs.getString(currentSpaceKey);
    if (result != null) {
      Map<String, dynamic> tmp = json.decode(result);
      AuthData space = AuthData.fromJson(tmp);
      log.fine('current space loaded from preferences');
      return space;
    }
    log.fine('no current space found in preferences');
    return null;
  }

  Future<void> saveCurrentSpace(AuthData space) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String tmp = json.encode(space.toJson());
    prefs.setString(currentSpaceKey, tmp);
    log.fine('current space saved to preferences');
  }

  Future<List<AuthData>> loadAllSpaces() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? result = prefs.getStringList(allSpacesKey);
    List<AuthData> all = [];
    if (result != null) {
      result.forEach((element) {
        Map<String, dynamic> tmp = json.decode(element);
        AuthData space = AuthData.fromJson(tmp);
        all.add(space);
      });
      log.fine('all spaces loaded from preferences');
      return all;
    }
    log.fine('no all spaces found in preferences');
    return all;
  }

  Future<void> saveAllSpaces(List<AuthData> spaces) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> encoded = [];
    spaces.forEach((element) {
      String tmp = json.encode(element.toJson());
      encoded.add(tmp);
    });

    prefs.setStringList(allSpacesKey, encoded);
    log.fine('all spaces saved to preferences');
  }

  Future<void> clearAll() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(currentSpaceKey);
    prefs.remove(allSpacesKey);
    log.fine('all saved data deleted');
  }
}