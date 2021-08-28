import 'dart:async';

import 'package:lemon_markets_client/lemon_markets_client.dart';
import 'package:lemon_markets_simple_dashboard/data/authData.dart';
import 'package:lemon_markets_simple_dashboard/error.dart';
import 'package:logging/logging.dart';

class LemonMarketService {
  final log = Logger('LemonMarketService');

  LemonMarkets _market = LemonMarkets();

  LemonMarketService() {
    log.fine("create lemonMarketService");
  }

  Future<AccessToken?> requestToken(String clientId, String clientSecret) async {
    try {
      AccessToken result = await _market.requestToken(clientId, clientSecret);
      return result;
    } on LemonMarketsException catch (e) {
      log.warning(e, e.stacktrace);
      throw LemonMarketsError(e.toString());
    }
  }

  Future<SpaceState?> getSpaceState(AuthData currentSpace) async {
    try {
      SpaceState state = await _market.getSpaceState(currentSpace.token!, currentSpace.spaceUuid!);
      return state;
    } on LemonMarketsException catch (e) {
      log.warning(e, e.stacktrace);
      throw LemonMarketsError(e.toString());
    }
  }

  Future<ResultList<Space>?> getSpaces(AccessToken token) async {
    try {
      ResultList<Space> result = await _market.getSpaces(token);
      return result;
    } on LemonMarketsException catch (e) {
      log.warning(e, e.stacktrace);
      throw LemonMarketsError(e.toString());
    }
  }

  Future<ResultList<Instrument>?> searchInstruments(AccessToken token,
      {String? search, SearchType? type, bool? tradable, String? currency, String? limit, int? offset}) async {
    try {
      ResultList<Instrument> result = await _market.searchInstruments(token,
          currency: currency, limit: limit, offset: offset, query: search, tradable: tradable, types: type != null ? [type] : null);
      //add items to a local cache (a detail-screen for an instrument can get items for this cache)
      return result;
    } on LemonMarketsException catch (e) {
      log.warning(e, e.stacktrace);
      throw LemonMarketsError(e.toString());
    }
  }

  Future<ResultList<Instrument>?> searchInstrumentsByUrl(AccessToken token, String url) async {
    try {
      ResultList<Instrument> result = await _market.searchInstrumentsByUrl(token, url);
      //add items to a local cache (a detail-screen for an instrument can get items for this cache)
      return result;
    } on LemonMarketsException catch (e) {
      log.warning(e, e.stacktrace);
      throw LemonMarketsError(e.toString());
    }
  }

  Future<List<PortfolioItem>> getPortfolioItems(AuthData authData) async {
    List<PortfolioItem> result = [];
    try {
      ResultList<PortfolioItem> tmp = await _market.getPortfolioItems(authData.token!, authData.spaceUuid!);
      result.addAll(tmp.result);
      String? nextUrl = tmp.next;
      while (nextUrl != null) {
        tmp = await _market.getPortfolioItems(authData.token!, nextUrl);
        result.addAll(tmp.result);
        nextUrl = tmp.next;
      }
    } on LemonMarketsException catch (e) {
      log.warning(e, e.stacktrace);
      throw LemonMarketsError(e.toString());
    }
    return result;
  }

  Future<Quote?> getLatestQuote(AuthData authData, String isin) async {
    try {
      Quote? result;
      ResultList<Quote>? all = await _market.getLatestQuotes(authData.token!, [isin]);
      result = all.result.where((element) => element.isin == isin).first;
      return result;
    } on LemonMarketsException catch (e) {
      log.warning(e, e.stacktrace);
      throw LemonMarketsError(e.toString());
    }
  }

  Future<List<ExistingOrder>> getOrders(AuthData authData, OrderSide? side, OrderStatus? status) async {
    List<ExistingOrder> result = [];
    try {
      ResultList<ExistingOrder> tmp = await _market.getOrders(authData.token!, authData.spaceUuid!, side: side, status: status);
      result.addAll(tmp.result);
      String? nextUrl = tmp.next;
      while (nextUrl != null) {
        tmp = await _market.getOrdersByUrl(authData.token!, nextUrl);
        result.addAll(tmp.result);
        nextUrl = tmp.next;
      }
    } on LemonMarketsException catch (e) {
      log.warning(e, e.stacktrace);
      throw LemonMarketsError(e.toString());
    }
    return result;
  }
}
