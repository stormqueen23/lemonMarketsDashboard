import 'package:flutter/material.dart';
import 'package:lemon_markets_simple_dashboard/widgets/portfolio/portfolioItemWidget.dart';
import 'package:provider/provider.dart';
import 'package:lemon_markets_client/lemon_markets_client.dart';
import 'package:lemon_markets_simple_dashboard/provider/portfolioProvider.dart';

class PortfolioItemsListWidget extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    List<PortfolioItem> items = context.watch<PortfolioProvider>().items;
    return ListView(
      shrinkWrap: true,
      children: _getAllItems(items, context),
    );
  }

  List<Card> _getAllItems(List<PortfolioItem>? data, BuildContext context) {
    List<Card> result = [];

    if (data != null) {
      data.forEach((element) {
        List<ExistingOrder> boughtDates = context.watch<PortfolioProvider>().getInstrumentBuyOrders(element.instrument.isin);
        List<ExistingOrder> sellDates = context.watch<PortfolioProvider>().getInstrumentSellOrders(element.instrument.isin);
        Quote? latestQuote = context.watch<PortfolioProvider>().getLatestQuote(element.instrument.isin);

        Widget tile = PortfolioListItem(
          element: element,
          boughtDates: boughtDates,
          sellDates: sellDates,
          latestQuote: latestQuote,
        );
        result.add(
          Card(
            child: tile,
          ),
        );
      });
    }
    return result;
  }
}