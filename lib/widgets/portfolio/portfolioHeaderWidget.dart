import 'dart:math' as math;
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:lemon_markets_simple_dashboard/widgets/common/loadingWidget.dart';
import 'package:provider/provider.dart';
import 'package:lemon_markets_client/lemon_markets_client.dart';
import 'package:lemon_markets_simple_dashboard/helper.dart';
import 'package:lemon_markets_simple_dashboard/provider/portfolioProvider.dart';

class PortfolioHeaderWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String cashToInvest = AppHelper.toDisplayMoneyString(context.watch<PortfolioProvider>().spaceStateDetails?.cashToInvest);
    String balance = AppHelper.toDisplayMoneyString(context.watch<PortfolioProvider>().spaceStateDetails?.balance);
    double portfolioSum = context.watch<PortfolioProvider>().portfolioSum;
    double currentSum = context.watch<PortfolioProvider>().currentSum;
    double currentMoney = context.watch<PortfolioProvider>().spaceStateDetails?.balance ?? 0 + currentSum;
    bool sumInitialized = context.watch<PortfolioProvider>().sumInitialized;
    List<PortfolioItem> items = context.watch<PortfolioProvider>().items;

    double diff = currentSum - portfolioSum;
    bool positive = currentSum > portfolioSum;

    String portfolioPercent = !sumInitialized ? '' : ((diff / currentMoney) * 100.0).toStringAsFixed(2);
    debugPrint("PortfolioHeaderWidget");
    return ExpandablePanel(
      theme: ExpandableThemeData(
        iconColor: Colors.yellow,
        expandIcon: Icons.chevron_left,
        collapseIcon: Icons.chevron_left,
        iconRotationAngle: -math.pi / 2,
        headerAlignment: ExpandablePanelHeaderAlignment.center,
        tapHeaderToExpand: true,
        tapBodyToCollapse: true,
      ),
      header: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Portfolio value: ${!sumInitialized ? '' : AppHelper.toDisplayMoneyString(currentSum)}",
            textScaleFactor: 1.4,
          ),
          Container(
            width: 8,
          ),
          !sumInitialized
              ? Container()
              : Text(
                  (positive ? '+' : '') + '$portfolioPercent %',
                  style: TextStyle(color: AppHelper.getAmountColor(diff)),
                )
        ],
      ),
      collapsed: Container(),
      expanded: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Balance:'),
                Text('Cash to invest:'),
                Container(
                  height: 8,
                ),
                Text('Buy price:'),
                Text('Current price:'),
                Text('Difference:'),
                Text('Difference %:'),
                Container(
                  height: 8,
                ),
                Text('Different positions:'),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('$balance'),
                Text('$cashToInvest'),
                Container(
                  height: 8,
                ),
                Text('${AppHelper.toDisplayMoneyString(portfolioSum)}'),
                !sumInitialized
                    ? SmallLoading()
                    : Text(
                        '${AppHelper.toDisplayMoneyString(currentSum)}',
                        style: TextStyle(color: AppHelper.getAmountColor(diff)),
                      ),
                !sumInitialized
                    ? SmallLoading()
                    : Text(
                        '${positive ? '+' : ''} ${AppHelper.toDisplayMoneyString(diff)}',
                        style: TextStyle(color: AppHelper.getAmountColor(diff)),
                      ),
                !sumInitialized
                    ? SmallLoading()
                    : Text(
                        '${positive ? '+' : ''} ${AppHelper.toDisplayPercentString(((diff / portfolioSum) * 100.0))}',
                        style: TextStyle(color: AppHelper.getAmountColor(diff)),
                      ),
                Container(
                  height: 8,
                ),
                Text('${items.length.toString()}')
              ],
            )
          ],
        ),
      ),
    );
  }
}
