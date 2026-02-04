import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'auth/presentation/screens/log_in_screen.dart';
import 'auth/presentation/screens/sign_up_screen.dart';
import 'core/presentation/screens/splash_screen.dart';
import 'home_management/presentation/screens/add_photos_screen.dart';

// final router = Provider(
//   (ref) => GoRouter(
final router = Provider<GoRouter>((ref) {
  // نقوم بمراقبة الحالة هنا
  // final authState = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: "/splash",
    observers: [BotToastNavigatorObserver()],
    // refreshListenable: authState != null ? null : null,
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
      // GoRoute(
      //   path: "/all-photos",
      //   name: "all-photos",
      //   builder: (context, state) {
      //     return AllPhotosScreen();
      //   },
      // ),
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
    // redirect: (context, state) async {
    //   String? userId = ref.watch(authNotifierProvider)?.id;

    //   // Get saved id from shared preferences
    //   final prefs = SharedPreferencesAsync();
    //   final savedId = await prefs.getString("userId");

    //   if (state.fullPath == "/") {
    //     if (userId == null && (savedId == null || savedId.isEmpty)) {
    //       return "/";
    //     } else if (userId == null && savedId != null && savedId.isNotEmpty) {
    //       return "/splash";
    //     } else {
    //       return "/add_photos";
    //     }
    //   } else {
    //     if (userId == null && (savedId == null || savedId.isEmpty)) {
    //       if (state.fullPath == "/signup") return null;
    //       return "/";
    //     } else if (userId == null && savedId != null && savedId.isNotEmpty) {
    //       // return "/splash";
    //       return "/all-photos";
    //     } else {
    //       return null;
    //     }
    //     // return null;
    //   }
    // },
    // re
  );
});
