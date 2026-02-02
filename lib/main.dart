// ignore_for_file: avoid_print, depend_on_referenced_packages, deprecated_member_use, unused_local_variable

import 'dart:convert';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:news_watch/firebase_options.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:json_theme/json_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'router.dart';
import 'translation.dart';

//Platform  Firebase App Id
// web       1:520383701430:web:fd1447bc6111cf93bfa117
// android   1:520383701430:android:897ad7b9487e83b3bfa117
//SHA256-90:b5:c7:8a:a0:4f:b0:4e:f9:b0:69:b0:47:b9:fd:d3:e3:46:48:c1:11:40:ad:6f:ae:b4:1e:8d:05:cc:d0:2b
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await initGoogleSignIn();
  await MyI18n.loadTranslations();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.debug,
    );
    await Supabase.initialize(
      url: 'رابط_المشروع_URL',
      anonKey: 'مفتاح_الأمان_API_KEY',
    );
    print("Firebase initialized successfully");
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus != AuthorizationStatus.authorized) {
      debugPrint("لم يتم منح إذن الإشعارات");
    }
  } catch (e) {
    BotToast.closeAllLoading();
  }

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
