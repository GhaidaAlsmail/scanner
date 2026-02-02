import 'package:flutter/material.dart';
import 'package:news_watch/translation.dart';

class MainIconButton extends StatelessWidget {
  const MainIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      tooltip: "Go Up".i18n,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(100),
        side: BorderSide(
          width: 2,
          color: Theme.of(context).colorScheme.scrim,
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      onPressed: () {},
      child: Icon(
        Icons.arrow_upward,
        color: Theme.of(context).colorScheme.scrim,
      ),
    );
  }
}
