import 'package:flutter/material.dart';
import 'package:news_watch/translation.dart';

class ButtonWidget extends StatelessWidget {
  const ButtonWidget({
    super.key,
    required this.text,
    this.onTap,
    this.width,
  });
  final String text;
  final Function()? onTap;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.surface,
        ),
        onPressed: onTap,
        child: Text(text.i18n),
      ),
    );
  }
}
