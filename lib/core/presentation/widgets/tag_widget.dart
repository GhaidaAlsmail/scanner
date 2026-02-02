import 'package:flutter/material.dart';
import 'package:news_watch/translation.dart';

class TagWidget extends StatelessWidget {
  const TagWidget({
    super.key,
    required this.text,
  });
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Center(
        child: Text(
          "#${text.i18n}",
          style: TextStyle(color: Theme.of(context).colorScheme.outline),
        ),
      ),
    );
  }
}
