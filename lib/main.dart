import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lemon_markets_simple_dashboard/provider/lemonMarketsProvider.dart';
import 'package:lemon_markets_simple_dashboard/screens/homeScreen.dart';
import 'package:lemon_markets_simple_dashboard/services/databaseService.dart';
import 'package:lemon_markets_simple_dashboard/services/lemonMarketService.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  //logging
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    print('${record.loggerName} [${record.level.name}]: ${record.time}: ${record.message}');
  });

  //get_it
  GetIt.instance.registerSingleton<DatabaseService>(DatabaseService());
  GetIt.instance.registerSingleton<LemonMarketService>(LemonMarketService());

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => LemonMarketsProvider()),
    ],
    child: LemonMarketsDashboardApp(),
  ));
}

class LemonMarketsDashboardApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lemon markets dashboard',
      theme: ThemeData(
        primarySwatch: Colors.yellow,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.yellow,
        accentColor: Colors.yellow,
        tabBarTheme: TabBarTheme(indicator: BoxDecoration(color: Colors.yellow), labelColor: Colors.grey[800], unselectedLabelColor: Colors.yellow),
      ),
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}
