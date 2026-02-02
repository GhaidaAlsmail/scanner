import 'package:flutter/material.dart';
import 'package:news_watch/translation.dart';

class SettingsCardWidget extends StatelessWidget {
  const SettingsCardWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });
  final Widget icon;
  final String title;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.all(8),
          onTap: onTap,
          leading: icon,
          title: Text(title.i18n),
          trailing: Icon(
            Icons.arrow_forward_ios_rounded,
          ),
        ),
        Divider(
          color: Theme.of(context).colorScheme.onInverseSurface,
          height: 0,
          indent: 50,
        )
      ],
    );
  }
}
