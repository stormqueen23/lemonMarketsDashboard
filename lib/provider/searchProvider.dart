import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lemon_markets_client/lemon_markets_client.dart';
import 'package:lemon_markets_simple_dashboard/data/authData.dart';
import 'package:lemon_markets_simple_dashboard/services/lemonMarketService.dart';
import 'package:logging/logging.dart';

class SearchProvider with ChangeNotifier {
  final log = Logger('SearchProvider');

  LemonMarketService marketService = GetIt.instance<LemonMarketService>();

  bool searching = false;
  String? searchString;
  SearchType searchType = SearchType.stock;

  List<Instrument> instruments = [];
  String? previousUrl;
  String? nextUrl;

  String? errorMessage;

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
    _beforeSearch();

    marketService
        .searchInstruments(currentSpace.token!, search: searchString, type: searchType)
        .then(
          (value) => _afterSearch(value),
        )
        .onError((error, stackTrace) {
      searching = false;
      errorMessage = error.toString();
      notifyListeners();
    });
  }

  void searchNext(AuthData currentSpace) {
    if (nextUrl != null) {
      _searchByUrl(currentSpace, nextUrl!);
    }
  }

  void searchPrevious(AuthData currentSpace) {
    if (previousUrl != null) {
      _searchByUrl(currentSpace, previousUrl!);
    }
  }

  void _searchByUrl(AuthData currentSpace, String url) {
    _beforeSearch();

    marketService
        .searchInstrumentsByUrl(currentSpace.token!, url)
        .then(
          (value) => _afterSearch(value),
        )
        .onError((error, stackTrace) {
      searching = false;
      errorMessage = error.toString();
      notifyListeners();
    });
  }

  void _beforeSearch() {
    instruments.clear();
    searching = true;
    errorMessage = null;
    notifyListeners();
  }

  void _afterSearch(ResultList<Instrument>? result) {
    if (result != null) {
      this.instruments = result.result;
      this.nextUrl = result.next;
      this.previousUrl = result.previous;
    }
    searching = false;
    notifyListeners();
  }
}
