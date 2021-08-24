import 'package:flutter/material.dart';

/// add your custom loading animation here
class LemonLoadingWidget extends StatelessWidget {
  const LemonLoadingWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator();
  }
}

class SmallLoading extends StatelessWidget {
  const SmallLoading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 12,
        width: 12,
        child: CircularProgressIndicator(
          strokeWidth: 1,
        ));
  }
}

