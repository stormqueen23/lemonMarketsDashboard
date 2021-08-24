import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lemon_markets_client/lemon_markets_client.dart';
import 'package:lemon_markets_simple_dashboard/helper.dart';
import 'package:lemon_markets_simple_dashboard/widgets/common/loadingWidget.dart';
import 'package:lemon_markets_simple_dashboard/widgets/common/rowWidgets.dart';

class PortfolioListItem extends StatelessWidget {
  final PortfolioItem element;
  final List<ExistingOrder> boughtDates;
  final List<ExistingOrder> sellDates;
  final Quote? latestQuote;

  const PortfolioListItem({Key? key, required this.element, this.boughtDates = const [], this.sellDates = const [], this.latestQuote}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double height = 4;
    int quantity = element.quantity;
    double width = MediaQuery.of(context).size.width;
    bool showIsinInTitle = kIsWeb && width > 600;
    Widget titleText = showIsinInTitle ? Text('${element.instrument.title} (${element.instrument.isin})') : Text('${element.instrument.title}');
    double currentSum = (latestQuote?.bit ?? 0) * quantity;
    double diff = currentSum - element.latestTotalValue;
    Color color = AppHelper.getAmountColor(diff);
    double percent = diff /element.latestTotalValue * 100.0;

    Widget diffText = Text(
      '${diff > 0 ? '+' : ''}${AppHelper.toDisplayMoneyString(diff)}',
      style: TextStyle(color: color),
    );
    Widget diffPercent = Text(
      '${diff > 0 ? '+' : ''}${AppHelper.toDisplayPercentString(percent)}',
      style: TextStyle(color: color),
    );

    return ListTile(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(child: titleText),
          latestQuote != null ? Text(AppHelper.toDisplayMoneyString(currentSum)) : SmallLoading()
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: height,
          ),
          showIsinInTitle
              ? Container()
              : Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AttributeRow(
                title: 'Isin: ',
                value: element.instrument.isin,
                mainAxisSize: MainAxisSize.min,
              ),
              latestQuote != null ? diffText : Container()
            ],
          ),
          showIsinInTitle
              ? Container()
              : Container(
            height: height,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AttributeRow(
                title: 'Ø Kaufpreis: ',
                value: AppHelper.toDisplayMoneyString(element.latestTotalValue),
                mainAxisSize: MainAxisSize.min,
              ),
              !showIsinInTitle && latestQuote != null
                  ? diffPercent
                  : showIsinInTitle && latestQuote != null
                  ? diffText
                  : Container()
            ],
          ),
          Container(
            height: height,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AttributeRow(
                title: 'Ø Einzelpreis: ',
                value: '$quantity x ${AppHelper.toDisplayMoneyString(element.averagePrice)}',
                mainAxisSize: MainAxisSize.min,
              ),
              showIsinInTitle && latestQuote != null ? diffPercent : Container()
            ],
          ),
          Container(
            height: height,
          ),
          AttributeWidgetRow(
            title: 'Kauf: ',
            value: PortfolioItemOrderDatesWidget(
              orderDates: boughtDates,
            ),
          ),
          Container(
            height: sellDates.length > 0 ? height : 0,
          ),
          sellDates.length > 0
              ? AttributeWidgetRow(
              title: 'Verkauf: ',
              value: PortfolioItemOrderDatesWidget(
                orderDates: sellDates,
                showDetails: true,
              ))
              : Container(),
        ],
      ),
    );
  }
}

class PortfolioItemOrderDatesWidget extends StatefulWidget {
  final List<ExistingOrder> orderDates;
  final bool showDetails;

  PortfolioItemOrderDatesWidget({Key? key, required this.orderDates, this.showDetails = false}) : super(key: key);

  @override
  _PortfolioItemOrderDatesWidgetState createState() => _PortfolioItemOrderDatesWidgetState();
}

class _PortfolioItemOrderDatesWidgetState extends State<PortfolioItemOrderDatesWidget> {
  bool showAll = false;

  @override
  Widget build(BuildContext context) {
    return widget.orderDates.length == 0
        ? Container()
        : GestureDetector(
      onTap: () => widget.orderDates.length < 2 ? null : setState(() => showAll = !showAll),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          showAll ? _getAll(widget.orderDates) : _getLine(widget.orderDates.first, widget.showDetails),
          Container(
            width: 8,
          ),
          widget.orderDates.length < 2
              ? Container()
              : Padding(
            padding: const EdgeInsets.only(top: 4.0, bottom: 8),
            child: Text(showAll ? 'Zeige weniger...' : 'Zeige mehr...'),
          )
        ],
      ),
    );
  }

  Widget _getLine(ExistingOrder order, bool withDetail) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(AppHelper.getDateTimeStringForLemonMarket(order.processedAt!)),
        withDetail ? Flexible(child: Text(' (${order.processedQuantity} x ${AppHelper.toDisplayMoneyString(order.averagePrice)})')) : Container()
      ],
    );
  }

  Widget _getAll(List<ExistingOrder> boughtTimes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: boughtTimes.map((e) => _getLine(e, true)).toList(),
    );
  }
}
