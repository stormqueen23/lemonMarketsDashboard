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
> For all API calls that return the type *ResultList* a second method exists where you just need the AccessToken and the url as parameter. In this case:
> searchInstruments(token, currency: currency, limit: limit, offset: offset, query: search, tradable: tradable, types: type != null ? [type] : null)
> and 
> searchInstrumentsByUrl(token, url)

Finally we need a widget to display the result. In our case a ListView:
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
...