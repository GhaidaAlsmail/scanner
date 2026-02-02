import 'package:flutter/material.dart';
import 'package:news_watch/translation.dart';

class DividerWIthTextWidget extends StatelessWidget {
  const DividerWIthTextWidget({
    super.key,
    required this.text,
  });
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            margin: EdgeInsets.symmetric(
              horizontal: 5,
            ),
            height: 1,
            color: Theme.of(context).colorScheme.scrim,
          ),
        ),
        Text(text.i18n),
        Expanded(
          child: Container(
            margin: EdgeInsets.symmetric(
              horizontal: 5,
            ),
            height: 1,
            color: Theme.of(context).colorScheme.scrim,
          ),
        ),
      ],
    );
  }
}
