import 'package:flutter/material.dart';

class AttributeRow extends StatelessWidget {
  final String title;
  final String value;
  final FlexFit fit;
  final MainAxisSize mainAxisSize;

  const AttributeRow({Key? key, required this.title, required this.value, this.fit = FlexFit.loose, this.mainAxisSize = MainAxisSize.max}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AttributeWidgetRow(title: title, value: SelectableText(value), fit: fit, mainAxisSize: mainAxisSize,);
  }
}

class AttributeWidgetRow extends StatelessWidget {
  final String title;
  final Widget value;
  final FlexFit fit;
  final MainAxisSize mainAxisSize;

  const AttributeWidgetRow({Key? key, required this.title, required this.value, this.fit = FlexFit.loose, this.mainAxisSize = MainAxisSize.max}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: mainAxisSize,
      children: [
        SizedBox(width: 100, child: Text(title),),
        Flexible(fit: fit, child: value)
      ],);
  }
}