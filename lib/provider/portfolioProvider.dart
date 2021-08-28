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
    _resetData();
    spaceStateDetails = await _marketService.getSpaceState(authData);
    items = await _marketService.getPortfolioItems(authData);
    items.forEach((element) {
      latestQuotes[element.instrument.isin] = null;
      existingOrders[element.instrument.isin] = [];
      portfolioSum += element.latestTotalValue;
    });

    _getLatestQuoteForItems(authData);
    _initOrdersForItems(authData);
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

  void _resetData() {
    currentSum = 0;
    portfolioSum = 0;
    sumInitialized = false;
    latestQuotes = {};
    existingOrders = {};
    items = [];

  }

  void _getLatestQuoteForItems(AuthData authData) {
    items.forEach((element) {
      _marketService.getLatestQuote(authData, element.instrument.isin).then((value) {
        latestQuotes[element.instrument.isin] = value;
        if (_latestQuotesInitialized()) {
          _calculateSum();
          sumInitialized = true;
        }
        notifyListeners();
      });
    });
  }

  void _initOrdersForItems(AuthData currentSpace) {
    _marketService.getOrders(currentSpace, null, OrderStatus.executed).then((value) {
      value.forEach((element) {
        existingOrders[element.instrument.isin]?.add(element);
        if (element.processedAt != null) {
          notifyListeners();
        }
      });
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