import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lemon_markets_simple_dashboard/data/authData.dart';
import 'package:lemon_markets_simple_dashboard/provider/portfolioProvider.dart';
import 'package:lemon_markets_simple_dashboard/widgets/portfolio/portfolioHeaderWidget.dart';
import 'package:lemon_markets_simple_dashboard/widgets/portfolio/portfolioItemListWidget.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

class PortfolioTabWidget extends StatefulWidget {
  final AuthData spaceData;
  PortfolioTabWidget({Key? key, required this.spaceData}) : super(key: key);

  @override
  _PortfolioTabWidgetState createState() => _PortfolioTabWidgetState();
}

class _PortfolioTabWidgetState extends State<PortfolioTabWidget> {
  final log = Logger('PortfolioTabWidget');

  Future<void> _refreshData() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PortfolioProvider(),
      builder: (context, child) {
        return RefreshIndicator(
          onRefresh: _refreshData,
          child: FutureBuilder(
            future: context.read<PortfolioProvider>().init(widget.spaceData),
            builder: (context, projectSnap) {
              log.fine('${projectSnap.connectionState} ${projectSnap.data}');
              if (projectSnap.connectionState != ConnectionState.done) {
                log.fine('waiting for portfolioItems');
                return Center(child: CircularProgressIndicator());
              }
              log.fine('all portfolioItems received');
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    PortfolioHeaderWidget(),
                    Container(
                      height: 8,
                    ),
                    Expanded(
                      child: PortfolioItemsListWidget(),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
class PortfolioWidget extends StatelessWidget {

  const PortfolioWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PortfolioHeaderWidget(),
        Container(
          height: 8,
        ),
        Expanded(
          child: PortfolioItemsListWidget(),
        ),
      ],
    );
  }
}