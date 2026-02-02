import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';

class ReactiveDropWidget extends StatelessWidget {
  const ReactiveDropWidget({
    super.key,
    required this.items,
    required this.controllerName,
  });
  final List<String> items;
  final String controllerName;

  @override
  Widget build(BuildContext context) {
    return ReactiveDropdownField(
      borderRadius: BorderRadius.circular(10),
      icon: Icon(
        Icons.keyboard_arrow_down_rounded,
      ),
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      formControlName: controllerName,
      items: items
          .map(
            (e) => DropdownMenuItem(
              value: e,
              child: Text(e),
            ),
          )
          .toList(),
    );
  }
}
