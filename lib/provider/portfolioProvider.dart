import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lemon_markets_client/lemon_markets_client.dart';
import 'package:lemon_markets_simple_dashboard/data/authData.dart';
import 'package:lemon_markets_simple_dashboard/services/lemonMarketService.dart';

class PortfolioProvider with ChangeNotifier {
  LemonMarketService _marketService = GetIt.instance<LemonMarketService>();

  SpaceState? spaceStateDetails;

  List<PortfolioItem> items = [];
  Map<String, Quote?> latestQuotes = {};
  Map<String, List<ExistingOrder>> existingOrders = {};

  double currentSum = 0;
  double portfolioSum = 0;
  bool sumInitialized = false;

  Future<void> init(AuthData authData) async {
    spaceStateDetails = await _marketService.getSpaceState(authData);
    await _initItems(authData);
    notifyListeners();
  }

  Quote? getLatestQuote(String isin) {
    return latestQuotes[isin];
  }

  List<ExistingOrder> getInstrumentBuyOrders(String isin) {
    List<ExistingOrder> all = existingOrders[isin] ?? [];
    all = all.where((element) => element.side == OrderSide.buy && element.processedAt != null).toList();
    return all;
  }

  List<ExistingOrder> getInstrumentSellOrders(String isin) {
    List<ExistingOrder> all = existingOrders[isin] ?? [];
    all = all.where((element) => element.side == OrderSide.sell && element.processedAt != null).toList();
    return all;
  }

  Future<void> _initItems(AuthData authData) async {
    currentSum = 0;
    portfolioSum = 0;
    sumInitialized = false;

    items = [];
    items = await _marketService.getPortfolioItems(authData);

    latestQuotes = {};
    existingOrders = {};

    items.forEach((element) async {
      latestQuotes[element.instrument.isin] = null;
      existingOrders[element.instrument.isin] = [];
      await _initPortfolioItem(authData, element.instrument.isin);
    });
    await _initOrders(authData);
    await _calculatePortfolioSum();
  }

  Future<void> _initPortfolioItem(AuthData currentSpace, String isin) async {
    debugPrint('_initPortfolioItem ${this.hashCode}');
    _marketService.getLatestQuote(currentSpace, isin).then((value) {
      latestQuotes[isin] = value;
      if (_latestQuotesInitialized()) {
        _calculateSum();
        sumInitialized = true;
      }
      notifyListeners();
    });
  }

  Future<void> _initOrders(AuthData currentSpace) async {
    debugPrint('_initOrders ${this.hashCode}');
    _marketService.getOrders(currentSpace, null, OrderStatus.executed).then((value) {
      value.forEach((element) {
        existingOrders[element.instrument.isin]?.add(element);
        if (element.processedAt != null) {
          notifyListeners();
        }
      });
    });
  }

  _calculatePortfolioSum() {
    portfolioSum = 0;
    items.forEach((element) {
      portfolioSum += element.latestTotalValue;
    });
  }

  void _calculateSum() {
    currentSum = 0;
    latestQuotes.forEach((key, value) {
      currentSum += value!.bit * _getPortfolioItem(key).quantity;
    });
  }

  PortfolioItem _getPortfolioItem(String isin) {
    return items.firstWhere((element) => element.instrument.isin == isin);
  }

  bool _latestQuotesInitialized() {
    bool result = true;
    latestQuotes.forEach((key, value) {
      if (value == null) {
        result = false;
      }
    });
    return result;
  }
}