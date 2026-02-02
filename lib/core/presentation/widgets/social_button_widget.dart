import 'package:flutter/material.dart';

class SocialButtonWidget extends StatelessWidget {
  const SocialButtonWidget({super.key, required this.path, this.onTap});
  final String path;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(5),
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.all(3),
        child: Image.asset(
          path,
          height: 48,
          width: 48,
        ),
      ),
    );
  }
}
