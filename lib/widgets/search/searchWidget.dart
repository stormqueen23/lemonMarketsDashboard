import 'package:flutter/material.dart';
import 'package:lemon_markets_client/lemon_markets_client.dart';
import 'package:lemon_markets_simple_dashboard/data/authData.dart';
import 'package:lemon_markets_simple_dashboard/provider/searchProvider.dart';

import 'package:provider/provider.dart';

class LemonMarketSearch extends StatelessWidget {
  final AuthData spaceData;

  LemonMarketSearch({Key? key, required this.spaceData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (_) => SearchProvider(),
        builder: (context, child) {
          return LemonMarketSearchWidget(spaceData: spaceData,);
        });
  }
}

class LemonMarketSearchWidget extends StatefulWidget {
  final AuthData spaceData;

  const LemonMarketSearchWidget({Key? key, required this.spaceData}) : super(key: key);

  @override
  _LemonMarketSearchWidgetState createState() => _LemonMarketSearchWidgetState();
}

class _LemonMarketSearchWidgetState extends State<LemonMarketSearchWidget> {
  TextEditingController _controller = TextEditingController();
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    focusNode.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool searching = context.watch<SearchProvider>().searching;
    return Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        'Suche:',
                        textScaleFactor: 1.5,
                      ),
                      Container(
                        width: 16,
                      ),
                      SearchTypeDropdown()
                    ],
                  ),
                  Container(
                    height: 8,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width / 1.5,
                        child: TextField(
                          controller: _controller,
                          focusNode: focusNode,
                          decoration: InputDecoration(
                              suffixIcon: focusNode.hasFocus
                                  ? IconButton(
                                  icon: Icon(Icons.clear),
                                  onPressed: () {
                                    setState(() {
                                      _controller.text = "";
                                    });
                                    context.read<SearchProvider>().setSearchString("");
                                    FocusScope.of(context).unfocus();
                                  })
                                  : Container(
                                width: 0,
                              )),
                          onChanged: (value) {
                            context.read<SearchProvider>().setSearchString(value);
                          },
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.search,),
                        onPressed: () {
                          if (!searching) {
                            context.read<SearchProvider>().searchInstruments(widget.spaceData);
                            FocusScope.of(context).unfocus();
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            context.watch<SearchProvider>().instruments.isNotEmpty
                ? Divider(
              height: 40,
              thickness: 2,
            )
                : Container(),
            searching
                ? Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: CircularProgressIndicator(),
            )
                : Flexible(
              child: ListView(
                shrinkWrap: true,
                children: _getAllInstruments(context),
              ),
            )
          ],
        ));
  }

  List<Card> _getAllInstruments(BuildContext context) {
    List<Card> result = [];

    context.watch<SearchProvider>().instruments.forEach((element) {
      String headerText = element.title.isNotEmpty ? element.title : element.name;
      ListTile tile = ListTile(
        title: Text('$headerText'),
        subtitle: Text('${element.isin}'),
        onTap: () => null, //TODO
      );
      result.add(Card(child: tile));
    });
    return result;
  }
}

class SearchTypeDropdown extends StatelessWidget {
  const SearchTypeDropdown({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SearchType type = context.watch<SearchProvider>().searchType;
    return DropdownButton<SearchType>(
      value: type,
      icon: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: const Icon(
          Icons.arrow_downward,
        ),
      ),
      iconSize: 12,
      elevation: 16,
      //style: const TextStyle(color: Colors.black54),
      dropdownColor: Colors.grey[800],
      underline: Container(
        height: 2,
        color: Colors.white,
      ),
      onChanged: (SearchType? newValue) {
        context.read<SearchProvider>().setSearchType(newValue);
      },
      items: SearchType.values.map<DropdownMenuItem<SearchType>>((SearchType value) {
        return DropdownMenuItem<SearchType>(
          value: value,
          child: Text('${_getTranslation(value)}'),
        );
      }).toList(),
    );
  }

  String _getTranslation(SearchType type) {
    String result = "";
    switch (type) {
      case SearchType.bond:
        result = "Anleihe";
        break;
      case SearchType.etf:
        result = "ETF";
        break;
      case SearchType.fund:
        result = "Fond";
        break;
      case SearchType.stock:
        result = "Aktie";
        break;
      case SearchType.warrant:
        result = "Optionsschein";
        break;
      case SearchType.none:
        result = "Alles";
        break;
    }
    return result;
  }
}
