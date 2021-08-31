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
    List<PortfolioItem> items = context.watch<PortfolioProvider>().items;
    double buySum = context.watch<PortfolioProvider>().portfolioSum;
    double currentSum = context.watch<PortfolioProvider>().currentSum;
    double balance = context.watch<PortfolioProvider>().spaceStateDetails?.balance ?? 0;
    double cashToInvest = context.watch<PortfolioProvider>().spaceStateDetails?.cashToInvest ?? 0;
    bool sumInitialized = context.watch<PortfolioProvider>().sumInitialized;

    String pre = currentSum > buySum ? '+' : '';

    double overallSum = currentSum + balance;
    double diffPortfolio = currentSum - buySum;

    String portfolioPercent = AppHelper.toDisplayPercentString(((diffPortfolio / buySum) * 100.0));
    String overallPercent = !sumInitialized ? '' : AppHelper.toDisplayPercentString(((diffPortfolio) / (overallSum)) * 100.0);

    Color textColor = AppHelper.getAmountColor(diffPortfolio);

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
            "Portfolio value: ${!sumInitialized ? '' : AppHelper.toDisplayMoneyString(overallSum)}",
            textScaleFactor: 1.4,
          ),
          Container(
            width: 8,
          ),
          !sumInitialized
              ? Container()
              : Text(
                  pre + '$overallPercent',
                  style: TextStyle(color: textColor),
                )
        ],
      ),
      collapsed: Container(),
      expanded: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Balance:'),
                Text('$balance'),
              ],
            ),
            Container(
              height: 3,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Cash to invest:'),
                Text('$cashToInvest'),
              ],
            ),
            Container(
              height: 8,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Buy price:'),
                Text('${AppHelper.toDisplayMoneyString(buySum)}'),
              ],
            ),
            Container(
              height: 3,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Current price:'),
                !sumInitialized
                    ? SmallLoading()
                    : Text(
                  '${AppHelper.toDisplayMoneyString(currentSum)}',
                  style: TextStyle(color: textColor),
                ),
              ],
            ),
            Container(
              height: 3,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Difference:'),
                !sumInitialized
                    ? SmallLoading()
                    : Text(
                  '$pre ${AppHelper.toDisplayMoneyString(diffPortfolio)}',
                  style: TextStyle(color: textColor),
                ),
              ],
            ),
            Container(
              height: 3,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Difference %:'),
                !sumInitialized
                    ? SmallLoading()
                    : Text(
                  '$pre $portfolioPercent',
                  style: TextStyle(color:textColor),
                ),
              ],
            ),
            Container(
              height: 8,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Different positions:'),
                Text('${items.length.toString()}')
              ],
            ),
          ],
        ),
      ),
    );
  }
}
