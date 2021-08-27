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
...

### Search-Tab
...

### Portfolio-Tab
...