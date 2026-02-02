import 'package:flutter/material.dart';
import 'package:news_watch/translation.dart';

class TextButtonWidget extends StatelessWidget {
  const TextButtonWidget({
    super.key,
    required this.text,
    this.onTap,
    this.size,
    this.foregroundColor,
  });
  final String text;
  final Function()? onTap;
  final double? size;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        foregroundColor: foregroundColor,
      ),
      onPressed: onTap,
      child: Text(
        text.i18n,
        style: TextStyle(fontSize: size),
      ),
    );
  }
}
