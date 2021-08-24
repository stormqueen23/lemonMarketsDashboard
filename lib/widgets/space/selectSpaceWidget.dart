import 'package:flutter/material.dart';
import 'package:lemon_markets_simple_dashboard/data/authData.dart';
import 'package:provider/provider.dart';

import 'package:lemon_markets_simple_dashboard/provider/lemonMarketsProvider.dart';

class SpacesSelectWidget extends StatelessWidget {
  const SpacesSelectWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AuthData? currentSpace = context.watch<LemonMarketsProvider>().selectedSpace ?? null;
    if (currentSpace != null) {
      return DropdownButton<AuthData>(
        value: currentSpace,
        icon: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: const Icon(
            Icons.arrow_downward,
          ),
        ),
        iconSize: 12,
        elevation: 16,
        dropdownColor: Colors.grey[800],
        underline: Container(
          height: 2,
          color: Colors.white,
        ),
        onChanged: (AuthData? newValue) {
          context.read<LemonMarketsProvider>().setCurrentSpace(newValue);
        },
        items: context.watch<LemonMarketsProvider>().allSpaces.map<DropdownMenuItem<AuthData>>((AuthData value) {
          return DropdownMenuItem<AuthData>(
            value: value,
            child: Text('Space: ${value.spaceName ?? value.clientId}'),
          );
        }).toList(),
      );
    }
    return Text('Lemon markets dashboard');
  }
}
