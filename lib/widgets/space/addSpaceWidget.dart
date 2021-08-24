import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:lemon_markets_simple_dashboard/provider/lemonMarketsProvider.dart';

class AddSpaceWidget extends StatefulWidget {
  @override
  _AddSpaceWidgetState createState() => _AddSpaceWidgetState();
}

class _AddSpaceWidgetState extends State<AddSpaceWidget> {
  bool processing = false;
  bool processed = false;

  String? manualClientId;
  String? manualClientSecret;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    FilePicker.platform.pickFiles(
                      withData: true,
                      type: FileType.custom,
                      allowedExtensions: ['json'],
                    ).then((value) {
                      setState(() {
                        processing = true;
                      });
                      processImport(value).then((value) {
                        setState(() {
                          processing = false;
                          processed = true;
                        });
                      });
                    });
                  },
                  child: Text('Spaces aus Datei laden'),
                ),
                ImportInfoWidget()
              ],
            ),
            processing
                ? CircularProgressIndicator()
                : processed
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Erfolgreich importiert'),
                          Container(
                            width: 20,
                          ),
                          Icon(Icons.check),
                        ],
                      )
                    : Container(),
            Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: Row(
                children: [
                  Expanded(
                    child: Divider(
                      thickness: 3,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 16),
                    child: Text('oder'),
                  ),
                  Expanded(
                    child: Divider(
                      thickness: 3,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 24.0, bottom: 16),
                  child: Text(
                    'Manuell hinzufügen:',
                    textScaleFactor: 1.4,
                  ),
                ),
                Text('Client-ID:'),
                Container(
                  width: MediaQuery.of(context).size.width / 1.5,
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        manualClientId = value;
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 24.0),
                  child: Text('Client-Secret:'),
                ),
                Container(
                  width: MediaQuery.of(context).size.width / 1.5,
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        manualClientSecret = value;
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: ElevatedButton(
                    onPressed: manualClientId != null && manualClientSecret != null
                        ? () => context.read<LemonMarketsProvider>().addSpace(manualClientId!, manualClientSecret!)
                        : null,
                    child: Text('Hinzufügen'),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Future<void> processImport(FilePickerResult? value) async {
    if (value != null) {
      await context.read<LemonMarketsProvider>().clearData();
      value.files.forEach((file) {
        Uint8List? content = file.bytes;
        if (content != null) {
          String stringData = utf8.decode(content);
          List<dynamic> spaces = json.decode(stringData);
          spaces.forEach((element) async {
            String id = element['client_id'];
            String secret = element['client_secret'];
            await context.read<LemonMarketsProvider>().addSpace(id, secret);
          });
        }
      });
    }
  }
}

class ImportInfoWidget extends StatelessWidget {
  const ImportInfoWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Struktur der import Datei (json):'),
          content: const SelectableText(
              '[\n {\n\  "client_id\": \"CLIENT_ID_1\",\n  \"client_secret\": \"CLIENT_SECRET_1\"\n },\n {\n  \"client_id\": \"CLIENT_ID_2\",\n  \"client_secret\": \"CLIENT_SECRET_2\"\n }\n]'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'OK'),
              child: const Text('OK'),
            ),
          ],
        ),
      ),
      icon: const Icon(Icons.info_outline),
    );
  }
}
