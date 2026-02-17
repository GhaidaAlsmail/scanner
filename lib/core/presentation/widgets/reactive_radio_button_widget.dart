import 'package:flutter/material.dart';
import 'package:scanner/translation.dart';
import 'package:reactive_forms/reactive_forms.dart';

// ignore: must_be_immutable
class ReactiveRadioButtonWidget extends StatelessWidget {
  const ReactiveRadioButtonWidget({
    super.key,
    required this.value,
    required this.title,
    required this.controllerName,
  });
  final String value;
  final String controllerName;
  final String title;

  @override
  Widget build(BuildContext context) {
    return ReactiveRadioListTile(
      formControlName: controllerName,
      value: value.i18n,
      title: Text(title.i18n),
    );
  }
}
