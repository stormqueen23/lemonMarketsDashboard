import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lemon_markets_client/lemon_markets_client.dart';
import 'package:lemon_markets_simple_dashboard/data/authData.dart';
import 'package:lemon_markets_simple_dashboard/services/databaseService.dart';
import 'package:lemon_markets_simple_dashboard/services/lemonMarketService.dart';
import 'package:logging/logging.dart';

class LemonMarketsProvider with ChangeNotifier {
  final log = Logger('LemonMarketsProvider');

  LemonMarketService _marketService = GetIt.instance<LemonMarketService>();
  DatabaseService databaseService = GetIt.instance<DatabaseService>();

  List<AuthData> allSpaces = [];

  AuthData? selectedSpace;

  LemonMarketsProvider() {
    log.fine('create lemonProvider');
  }

  Future<void> init() async {
    log.fine('init lemonProvider');
    selectedSpace = null;
    allSpaces = [];
    allSpaces = await databaseService.loadAllSpaces();
    selectedSpace = await databaseService.loadCurrentSpace();
    if (selectedSpace == null) {
      if (allSpaces.isNotEmpty) {
        setCurrentSpace(allSpaces.first);
        log.fine('no current space saved yet but a list of spaces is provided -> use first as current space');
      } else {
        log.fine('no current space saved yet and no list of available spaces!');
      }
    }
    log.fine('lemonProvider initialized');
  }

  void deleteSpaceData() {
    selectedSpace = null;
    allSpaces = [];
    databaseService.clearAll();
    notifyListeners();
  }

  Future<void> setCurrentSpace(AuthData? space) async {
    log.fine('set current space from ${selectedSpace?.clientId} to ${space?.clientId}');
    if (space != null) {
      selectedSpace = space;
      databaseService.saveCurrentSpace(space);
      notifyListeners();
    }
  }

  Future<void> clearData() async {
    selectedSpace = null;
    allSpaces.clear();
    databaseService.clearAll();
  }

  Future<void> addSpace(String clientId, String clientSecret) async {
    AuthData newSpace = AuthData(clientId, clientSecret);

    await _initMissingMySpaceData(newSpace);
    allSpaces.add(newSpace);
    databaseService.saveAllSpaces(allSpaces);

    if (selectedSpace == null) {
      selectedSpace = newSpace;
      databaseService.saveCurrentSpace(selectedSpace!);
    }
    notifyListeners();
  }

  Future<void> _initMissingMySpaceData(AuthData authData) async {
    if (authData.token == null) {
      log.fine('space has no access token yet!');
      AccessToken? _token = await _marketService.requestToken(authData.clientId, authData.clientSecret);
      double now = LemonMarketsTimeConverter.getUTCUnixTimestamp(DateTime.now());
      authData.tokenExpireDate = LemonMarketsTimeConverter.getUTXUnixDateTimeForLemonMarket(now+_token!.expiresIn);
      authData.token = _token;
      log.fine('requested token expires at ${authData.tokenExpireDate}');
    }
    if (authData.spaceUuid == null) {
      log.fine('space has no uuid yet!');
      ResultList<Space>? spacesForId = await _marketService.getSpaces(authData.token!);
      if (spacesForId != null) {
        if (spacesForId.result.isNotEmpty) {
          authData.spaceUuid = spacesForId.result.first.uuid;
          authData.spaceName = spacesForId.result.first.name;
        }
      }
    }
  }

}