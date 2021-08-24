import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lemon_markets_client/lemon_markets_client.dart';
import 'package:lemon_markets_simple_dashboard/data/authData.dart';
import 'package:lemon_markets_simple_dashboard/services/lemonMarketService.dart';
import 'package:logging/logging.dart';

class SearchProvider  with ChangeNotifier {
  final log = Logger('SearchProvider');

  bool searching = false;
  String? searchString;
  SearchType searchType = SearchType.stock;

  List<Instrument> instruments = [];

  LemonMarketService marketService = GetIt.instance<LemonMarketService>();

  bool buying = false;
  CreatedOrder? orderForActivation;

  void setSearchString(String value) {
    this.searchString = value;
  }

  void setSearchType(SearchType? value) {
    if (value == null) {
      this.searchType = SearchType.none;
    } else {
      this.searchType = value;
    }
    notifyListeners();
  }

  void searchInstruments(AuthData currentSpace) {
    log.info("searchInstruments $searchString");
    instruments.clear();
    searching = true;
    notifyListeners();

      marketService.searchInstruments(currentSpace.token!, search: searchString, type: searchType).then((value) {
        if (value != null) {
          this.instruments = value.result;
          searching = false;
          notifyListeners();
        }
      },);

  }

}