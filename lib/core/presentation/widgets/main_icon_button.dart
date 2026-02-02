import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainIconButton extends StatelessWidget {
  const MainIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            spreadRadius: 3,
            color: Theme.of(context).colorScheme.tertiaryContainer,
            blurRadius: 3,
          ),
        ],
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.surface,
      ),
      padding: EdgeInsets.all(10),
      child: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.primary,
        shape: CircleBorder(),
        onPressed: () {
          context.pushNamed("add_photos");
        },
        child: Icon(Icons.add, color: Theme.of(context).colorScheme.surface),
      ),
    );
  }
}
