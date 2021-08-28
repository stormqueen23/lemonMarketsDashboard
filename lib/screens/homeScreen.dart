import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lemon_markets_simple_dashboard/data/authData.dart';
import 'package:lemon_markets_simple_dashboard/provider/lemonMarketsProvider.dart';
import 'package:lemon_markets_simple_dashboard/widgets/portfolio/portfolioWidget.dart';
import 'package:lemon_markets_simple_dashboard/widgets/search/searchWidget.dart';
import 'package:lemon_markets_simple_dashboard/widgets/space/addSpaceWidget.dart';
import 'package:lemon_markets_simple_dashboard/widgets/common/loadingWidget.dart';
import 'package:lemon_markets_simple_dashboard/widgets/space/selectSpaceWidget.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  final log = Logger('HomeScreen');

  HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: context.read<LemonMarketsProvider>().init(),
      builder: (context, projectSnap) {
        log.fine('context.read<LemonProvider>().init: ${projectSnap.connectionState}');
        if (projectSnap.connectionState != ConnectionState.done) {
          log.fine('waiting for LemonProvider');
          return Scaffold(body: LemonLoadingWidget());
        }
        return HomeWidget();
      },
    );
  }
}

class HomeWidget extends StatelessWidget {
  const HomeWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AuthData? currentSpace = context.watch<LemonMarketsProvider>().selectedSpace;
    bool noSpace = currentSpace == null;
    return noSpace
        ? Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text('- No Space -'),
            ),
            body: Center(child: AddSpaceWidget()),
          )
        : MainTabWidget(currentSpace: currentSpace);
  }
}

class MainTabWidget extends StatefulWidget {
  final AuthData currentSpace;

  const MainTabWidget({Key? key, required this.currentSpace}) : super(key: key);

  @override
  _MainTabWidgetState createState() => _MainTabWidgetState();
}

class _MainTabWidgetState extends State<MainTabWidget> {
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: SpacesSelectWidget(),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () => context.read<LemonMarketsProvider>().deleteSpaceData(),
            icon: Icon(Icons.delete),
          ),
        ],
      ),
      body: currentIndex == 0
          ? LemonMarketSearch(
              spaceData: widget.currentSpace,
            )
          : PortfolioTabWidget(
              authData: widget.currentSpace,
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => setState(() {
          currentIndex = index;
        }),
        items: _generateBottomNavigationBarItems(),
      ),
    );
  }

  List<BottomNavigationBarItem> _generateBottomNavigationBarItems() {
    List<BottomNavigationBarItem> result = [];
    result.add(BottomNavigationBarItem(
      icon: Icon(Icons.search),
      label: 'Search',
    ));
    result.add(BottomNavigationBarItem(
      icon: Icon(Icons.show_chart_outlined),
      label: 'Portfolio',
    ));
    return result;
  }
}
