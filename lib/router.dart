import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth/application/auth_notifier_provider.dart' show authNotifierProvider;
import 'auth/presentation/screens/log_in_screen.dart';
import 'auth/presentation/screens/sign_up_screen.dart';
import 'core/presentation/screens/splash_screen.dart';
import 'home_management/presentation/screens/add_photos_screen.dart';
import 'home_management/presentation/screens/show_all_images.dart';

// final router = Provider(
//   (ref) => GoRouter(
final router = Provider<GoRouter>((ref) {
  // نقوم بمراقبة الحالة هنا
  final authState = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: "/splash",
    observers: [BotToastNavigatorObserver()],
    refreshListenable: authState != null ? null : null,
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => SplashScreen(),
      ), // AddPhotosScreen(), ),
      GoRoute(
        path: "/",
        name: "/",
        builder: (context, state) {
          return LogInScreen();
        },
        routes: [
          GoRoute(
            path: "/add_photos",
            name: "add_photos",
            builder: (context, state) {
              return AddPhotosScreen();
            },
          ),
        ],
      ),
      GoRoute(
        path: "/all-photos",
        name: "all-photos",
        builder: (context, state) {
          return AllPhotosScreen();
        },
      ),
      GoRoute(
        path: "/loggin",
        name: "/loggin",
        builder: (context, state) {
          return LogInScreen();
        },
      ),
      GoRoute(
        path: "/signup",
        name: "/signup",
        builder: (context, state) {
          return SignUpScreen();
        },
      ),
    ],
    // redirect: (context, state) {
    //   // نراقب حالة المستخدم من الـ Notifier
    //   final user = ref.read(authNotifierProvider);

    //   final bool isLoggedIn = user != null;
    //   final bool isLoggingIn = state.matchedLocation == '/loggin';
    //   final bool isSigningUp = state.matchedLocation == '/signup';
    //   final bool isSplash = state.matchedLocation == '/splash';

    //   // 1. إذا لم يكن هناك مستخدم (بما في ذلك غير المفعلين لأن حالتهم null)
    //   if (!isLoggedIn) {
    //     // إذا كان يحاول الذهاب لصفحة محمية (مثل add_photos)، ارجعه للدخول
    //     if (!isLoggingIn && !isSigningUp && !isSplash) {
    //       return '/loggin';
    //     }
    //     // إذا كان في صفحة الدخول أو التسجيل، اتركه
    //     return null;
    //   }

    //   // 2. إذا كان مسجل دخول ومفعل (أي الـ user ليس null)
    //   if (isLoggedIn) {
    //     // إذا كان في صفحات الدخول أو التسجيل، وجهه للداخل
    //     if (isLoggingIn || isSigningUp || isSplash) {
    //       return '/add_photos';
    //     }
    //   }

    //   return null;
    // },
    redirect: (context, state) async {
      String? userId = ref.watch(authNotifierProvider)?.id;

      // Get saved id from shared preferences
      final prefs = SharedPreferencesAsync();
      final savedId = await prefs.getString("userId");

      if (state.fullPath == "/") {
        if (userId == null && (savedId == null || savedId.isEmpty)) {
          return "/";
        } else if (userId == null && savedId != null && savedId.isNotEmpty) {
          return "/splash";
        } else {
          return "/add_photos";
        }
      } else {
        if (userId == null && (savedId == null || savedId.isEmpty)) {
          if (state.fullPath == "/signup") return null;
          return "/";
        } else if (userId == null && savedId != null && savedId.isNotEmpty) {
          // return "/splash";
          return "/all-photos";
        } else {
          return null;
        }
        // return null;
      }
    },
    // redirect: (context, state) {
    //   final user = ref.watch(authNotifierProvider);
    //   final bool isLoggedIn = user != null;

    //   // المسارات الحالية
    //   final bool isLoggingIn = state.matchedLocation == '/';
    //   final bool isSigningUp = state.matchedLocation == '/signup';
    //   final bool isSplash = state.matchedLocation == '/splash';

    //   // 1. إذا كنا في مرحلة السبلش (Splash)، لا نفعل شيئاً حتى يقرر الـ Notifier الحالة
    //   if (isSplash) return null;

    //   // 2. إذا لم يكن مسجلاً، وجهه لصفحة تسجيل الدخول إلا إذا كان في صفحة التسجيل أصلاً
    //   if (!isLoggedIn) {
    //     return (isLoggingIn || isSigningUp) ? null : "/";
    //   }

    //   // 3. إذا كان مسجلاً وبحاول يدخل صفحات تسجيل الدخول، وجهه للرئيسية
    //   if (isLoggedIn && (isLoggingIn || isSigningUp)) {
    //     return "/add_photos";
    //   }

    //   return null;
    // },
  );
});
