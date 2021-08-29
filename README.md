Prerequisite: Flutter SDK installed, IDE istalled (or at least a text editor...)

If you don't know what flutter is or how a project is created I recommend reading this first:
https://flutter.dev/docs/get-started/install and https://flutter.dev/docs/get-started/codelab

# Adding the lemon.markets SDK to a project

To use the lemon.markets SDK in your own project you have to create a new project first. This can be done via your IDE or the command 'flutter create my_lemon_markets_app'.

Since the lemon.markets SDK is not officially published yet at https://pub.dev/ you cannot add the package in the 'standard' way.
You have the following two option to add the SDK as a dependency:

1. Download or clone the Flutter  from https://github.com/stormqueen23/lemonMarketsClient
   Add the package as follows in the pubspec.yaml:

```
dependencies:
  flutter:
    sdk: flutter

  lemon_markets_client:
    path: "../lemon_market_client" 
```

The path element for the dependency points at your local folder with the SDK (in this case its paralell to the project folder that uses it)

2. You can directly refer to the github repository by adding this to the pubspec.yaml

```
dependencies:
  flutter:
    sdk: flutter

  lemon_markets_client:
    git:
      url: https://github.com/stormqueen23/lemonMarketsClient.git
```

More details on how to add packages to your app can be found here: https://flutter.dev/docs/development/packages-and-plugins/using-packages

After running 'flutter pub get' you can use the SDK in your app!

# Example project 'lemon markets dashboard'

To show you how the SDK can be used in your app I will explain it using a small dashboard example app that can be found here:
https://github.com/stormqueen23/lemonMarketsDashboard

This app uses some other packages besides the lemon.markets SDK. The most important are provider and get_it.
The provider package is used to hold the state of the application and the get_it package manages all service calls.

## The Home Screen

Like all flutter apps this example app starts in the main.dart where the first (and only) screen is created:

```
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
      home: HomeScreen(),
    );
  }
}
```

Since you need a lemon markets account respectively space credentials for using the lemon.markets SDK there are two different widgets that can be displayed:
1. No credentials can be found (AddSpaceWidget)
2. Credentials can be found (MainTabWidget)

```
class HomeScreen extends StatelessWidget {
  
  HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: context.read<LemonMarketsProvider>().init(),
      builder: (context, projectSnap) {
        if (projectSnap.connectionState != ConnectionState.done) {
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
```

## The LemonMarketsProvider

In order to find out which widget should be displayed we need the LemonMarketsProvider.
It handles all application-wide data like the selected space.
So on a high level in our widget tree we need to initialize this provider to get the relevant data for the whole application.
The init() method checks whether authentication data was saved or not.

If no authentication data can be found we want to have the possibility to add the credentials.
The AddSpaceWidget provides two input fields for adding a clientId / a clientSecret and a button that sends this data to our LemonMarketsProvider:

```
String? manualClientId;
String? manualClientSecret;
...
ElevatedButton(
	onPressed: manualClientId != null && manualClientSecret != null
		? () => context.read<LemonMarketsProvider>().addSpace(manualClientId!, manualClientSecret!) : null,
	child: Text('add'),
)
```

The LemonMarketsProvider receives this call and collects all the data that is needed: (and maybe persist the data)

```
class LemonMarketsProvider with ChangeNotifier {
	LemonMarketService _marketService = GetIt.instance<LemonMarketService>();
	
	AuthData? selectedSpace;
	...
	
	Future<void> addSpace(String clientId, String clientSecret) async {
		AuthData authData = AuthData(clientId, clientSecret);
		
		AccessToken? _token = await _marketService.requestToken(authData.clientId, authData.clientSecret);
		authData.token = _token;
		
		ResultList<Space>? spacesForId = await _marketService.getSpaces(authData.token!);
		
		if (spacesForId != null) {
		  if (spacesForId.result.isNotEmpty) {
			authData.spaceUuid = spacesForId.result.first.uuid;
			authData.spaceName = spacesForId.result.first.name;
		  }
		}
		
		selectedSpace = authData;
		notifyListeners();
  }
  
}
```

At this point we have our first contact with the lemon.markets SDK: We want a access token for the given clientId / clientSecret.
After receiving the token we want some more details for the space (like uuid) because some endpoints require this uuid.
Because we want to encapsulate all API calls in a service we have the LemonMarketService.

## The LemonMarketService

This is where all the SDK calls happen. We have to create an instance of LemonMarkets. Via this class we have access to all endpoints of the lemon.markets API that the lemon.markets Flutter SDK supports.
For now we need a function to request an access token and get some space detail data:

```
class LemonMarketService {
 
  LemonMarkets _market = LemonMarkets();

  Future<AccessToken?> requestToken(String clientId, String clientSecret) async {
    try {
      AccessToken result = await _market.requestToken(clientId, clientSecret);
      return result;
    } on LemonMarketsException catch (e) {
      throw LemonMarketsError(e.toString());
    }
  }
  
  Future<ResultList<Space>?> getSpaces(AccessToken token) async {
    try {
      ResultList<Space> result = await _market.getSpaces(token);
      return result;
    } on LemonMarketsException catch (e) {
      throw LemonMarketsError(e.toString());
    }
  }
}  
```

## A short wrapup

Now we have all the required data (AccessToken and Space-Uuid) to make more API calls and get all the data we need for our application

## The MainTabWidget
Once you have entered the credentials you can see a screen with two tabs. The search tab and the portfolio tab. 
Both tabs have one or more widgets for displaying the data and a provider for their state management.

### Search-Tab
The search tab is very simple. It contains a drop down button for the different instrument types, a text field and a button that starts the search.
The different search types are represented by the enum *SearchType* from the lemon.markets SDK. 
In the text field you can enter the query you want to search for and the button starts the search.
In the widget:
```
IconButton(
  icon: Icon(
    Icons.search,
  ),
  onPressed: () {
    if (!searching) {
      context.read<SearchProvider>().searchInstruments(widget.authData);
    }
  },
)
```
For the search you need the AccessToken that was received earlier in the LemonMarketsProvider. 
The search is done in the SearchProvider who delegates it to the MarketService:
```
class SearchProvider with ChangeNotifier {
  LemonMarketService marketService = GetIt.instance<LemonMarketService>();
  
  String? searchString;
  SearchType searchType = SearchType.stock;
  
  List<Instrument> instruments = [];
  String? previousUrl;
  String? nextUrl;
  
  void searchInstruments(AuthData authData) {
    marketService
        .searchInstruments(authData.token!, search: searchString, type: searchType)
        .then(
          (result) {
            if (result != null) {
              this.instruments = result.result;
              this.nextUrl = result.next;
              this.previousUrl = result.previous;
            }
          },
    );
    notifyListeners();
  }
}
```
And the MarketService needs one more method:
```
Future<ResultList<Instrument>?> searchInstruments(AccessToken token, {String? search, SearchType? type, bool? tradable, String? currency, String? limit, int? offset}) async {
    try {
      ResultList<Instrument> result = await _market.searchInstruments(token, currency: currency, limit: limit, offset: offset, query: search, tradable: tradable, types: type != null ? [type] : null);
      return result;
    } on LemonMarketsException catch (e) {
      throw LemonMarketsError(e.toString());
    }
  }
```
As you can see the search for instruments returns the type *ResultList*. 
This is a type from the lemon.markets SDK that contains beside the list of results an url for the previous and next results.
You can use this url for pagination. 
Depending on whether this next (or previous) is set a button is shown that triggers the search for the next url
In the widget:
```
context.watch<SearchProvider>().nextUrl != null ? IconButton(
   icon: Icon(
      Icons.forward,
   ),
   onPressed: () {
      if (!searching) {
         context.read<SearchProvider>().searchNext(widget.authData);
      }
   },
)
: Container(),
```
In the searchProvider:
```
void searchNext(AuthData authData) {
 if (nextUrl != null) {
   marketService
       .searchInstrumentsByUrl(authData.token!, nextUrl)
       .then(
         (result) {
       if (result != null) {
         this.instruments = result.result;
         this.nextUrl = result.next;
         this.previousUrl = result.previous;
       }
     },
   );
   notifyListeners();
 }
}
```
In the marketService:
```
Future<ResultList<Instrument>?> searchInstrumentsByUrl(AccessToken token, String url) async {
   try {
      ResultList<Instrument> result = await _market.searchInstrumentsByUrl(token, url);
      return result;
   } on LemonMarketsException catch (e) {
      throw LemonMarketsError(e.toString());
   }
}
 ```
> For all API calls that return the type *ResultList* a second method exists where you just need the AccessToken and the url as parameter. In this case the complete function is:
> searchInstruments(token, currency: currency, limit: limit, offset: offset, query: search, tradable: tradable, types: type != null ? [type] : null)
> and the corresponding function with just the url: 
> searchInstrumentsByUrl(token, url)

Finally we need a widget to display the result of our instrument search. In our example this is a ListView:
```
ListView(
   children: _getAllInstruments(context),
)
...
List<Card> _getAllInstruments(BuildContext context) {
   List<Card> result = [];
   context.watch<SearchProvider>().instruments.forEach((element) {
      ListTile tile = ListTile(
         title: Text('${element.title}'),
         subtitle: Text('${element.isin}'),
        );
      result.add(Card(child: tile));
   });
   return result;
}
```
That's it. Search-Tab is done so far. 
### Portfolio-Tab
The Portfolio-Tab is a little bit more complex. It collects data from different endpoints before it shows the information.
Like the search tab it has a provider for holding the data and different widgets for displaying them.
Lets take a look at the PortfolioProvider. 
During the init() method it collects all data that is needed to display the basic structure of the portfolio view with all items in the portfolio and the balance of the current space.
Therefore it
1. receives the current state of the space (used to display balance and the cash to invest)
2. receives all portfolio items
```
class PortfolioProvider with ChangeNotifier {
   ...
   Future<void> init(AuthData authData) async {
      spaceStateDetails = await _marketService.getSpaceState(authData);
      items = await _marketService.getPortfolioItems(authData);
      ...
   }
}
```
For this we need two new methods in our MarketService:
```
Future<SpaceState?> getSpaceState(AuthData authData) async {
 try {
   SpaceState state = await _market.getSpaceState(authData.token!, authData.spaceUuid!);
   return state;
 } on LemonMarketsException catch (e) {
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
   throw LemonMarketsError(e.toString());
 }
 return result;
}
```

The lemon.markets SDK returns again something of type *ResultList* for the portfolio items endpoint:
```
ResultList<PortfolioItem> tmp = await _market.getPortfolioItems(authData.token!, authData.spaceUuid!);
```
We have seen this before in the search for instrument method searchInstruments() but in this method we handle it a little bit different.
Since we need all items for calculating the current sum of the portfolio we repeat calling the function for getting the portfolioItems unless there are no more items to catch
```
while (nextUrl != null) {
     tmp = await _market.getPortfolioItems(authData.token!, nextUrl);
     ...
}
```
After getting the state of the space and the portfolio items we have all data to display the basic structure of our portfolio list and we can start rendering the UI.
We use a FutureBuilder to show a loadingWidget until all data in the init method has been collected.
```
FutureBuilder(
   future: context.read<PortfolioProvider>().init(widget.authData),
   builder: (context, projectSnap) {
     if (projectSnap.connectionState != ConnectionState.done) {
       // space state and portfolio items are loading
       return Center(child: CircularProgressIndicator());
     }
     // space state and portfolio items received!
     return Padding(
       padding: const EdgeInsets.all(16.0),
       child: PortfolioWidget(),
     );
   },
 ),
```
The last step during the init() method is calling the endpoints for 
*latest quote* for each portfolio item 
and  
*all orders*
The latest quote is used to calculate and display the current value of each item. 
The orders are used to display the buy and sell dates for each item.
We do not wait for the result of those calls as the UI can be updated if a result is received.
In the PortfolioProvider:
```
Future<void> init(AuthData authData) async {
   ...
   _initLatestQuoteForItems(authData);
   _initOrdersForItems(authData);
}

void _initLatestQuoteForItems(AuthData authData) {
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
```
Therefore we need two new methods in the MarketService:
```
Future<Quote?> getLatestQuote(AuthData authData, String isin) async {
 try {
   Quote? result;
   ResultList<Quote>? all = await _market.getLatestQuotes(authData.token!, [isin]);
   result = all.result.where((element) => element.isin == isin).first;
   return result;
 } on LemonMarketsException catch (e) {
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
   throw LemonMarketsError(e.toString());
 }
 return result;
}
```
The result of the getOrders endpoint is again of type ResultList and as we have seen before in the getPortfolioItems() method we want to get all of them in order to find out all dates of buying and selling an instrument.
So we keep calling the endpoint for the orders unless there is no nextUrl.

That's pretty much all the logic we need to display the portfolio tab.
Finally we need some widgets to display our data. We have a expandable header that displays the sums for the portfolio and a again a listView that displays all information for the portfolio items.
```
class PortfolioWidget extends StatelessWidget {
 
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
```
For more details you can explore the complete code for this example project:
https://github.com/stormqueen23/lemonMarketsDashboard

