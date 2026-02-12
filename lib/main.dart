// ignore_for_file: avoid_print, depend_on_referenced_packages, deprecated_member_use, unused_local_variable

import 'dart:convert';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:json_theme/json_theme.dart';
import 'router.dart';
import 'translation.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await initGoogleSignIn();
  await MyI18n.loadTranslations();
  // try {

  //   if (settings.authorizationStatus != AuthorizationStatus.authorized) {
  //     debugPrint("لم يتم منح إذن الإشعارات");
  //   }
  // } catch (e) {
  //   BotToast.closeAllLoading();
  // }

  usePathUrlStrategy();
  // Language ------------------------------------------------------------------
  Locale local = Locale("en", "En");
  // Theme ---------------------------------------------------------------------
  final themeStr = await rootBundle.loadString(
    "assets/themes/light_theme.json",
  );
  final themeJson = jsonDecode(themeStr);
  final decoder = ThemeDecoder();
  final theme = decoder.decodeThemeData(themeJson, validate: false);

  // ---------------------------------------------------------------------------
  runApp(ProviderScope(child: MyApp(theme: theme!)));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key, required this.theme});
  final ThemeData theme;
  @override
  Widget build(BuildContext context, ref) {
    return MaterialApp.router(
      title: 'Scanner',
      theme: theme,
      builder: BotToastInit(),
      locale: const Locale('en'),
      routerConfig: ref.watch(router),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
      ],
      supportedLocales: [Locale("ar", "AR")],
      debugShowCheckedModeBanner: false,
    );
  }
}
