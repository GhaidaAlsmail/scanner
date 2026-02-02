import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../../translation.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen.withScreenRouteFunction(
      splashIconSize: 500,
      splash: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FittedBox(child: Image.asset("assets/images/splash.png")),
          Gap(10),
          Text("Hello in Scanner App".i18n),
        ],
      ),
      splashTransition: SplashTransition.scaleTransition,
      animationDuration: Duration(seconds: 1),
      screenRouteFunction: () async {
        await Future.delayed(Duration(seconds: 1)).then((value) {
          // ignore: use_build_context_synchronously
          context.pushReplacement('/');
        });
        return "/loggin";
      },
    );
  }
}
