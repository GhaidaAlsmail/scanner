import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:news_watch/auth/presentation/screens/reset_passwords.dart';
import 'package:news_watch/home_management/presentation/screens/all_documents_screen.dart';
import 'auth/application/auth_notifier_provider.dart' show authNotifierProvider;
import 'auth/presentation/screens/log_in_screen.dart';
import 'auth/presentation/screens/sign_up_screen.dart';
import 'core/presentation/screens/splash_screen.dart';
import 'home_management/presentation/screens/add_photos_screen.dart';
import 'home_management/presentation/screens/show_all_images.dart';

//===========================معلق================================
// final router = Provider(
//   (ref) => GoRouter(
//===========================اخراستخدام هون===================
// final router = Provider<GoRouter>((ref) {
//   // نقوم بمراقبة الحالة هنا
//   // final authState = ref.watch(authNotifierProvider);

//   return GoRouter(
//     initialLocation: "/splash",
//     observers: [BotToastNavigatorObserver()],
//     // refreshListenable: authState != null ? null : null,
//     routes: [
//       GoRoute(
//         path: '/splash',
//         builder: (context, state) => SplashScreen(),
//       ), // AddPhotosScreen(), ),
//       GoRoute(
//         path: "/",
//         name: "/",
//         builder: (context, state) {
//           return LogInScreen();
//         },
//         routes: [
//           GoRoute(
//             path: "/add_photos",
//             name: "add_photos",
//             builder: (context, state) {
//               return AddPhotosScreen();
//             },
//           ),
//         ],
//       ),
//       // GoRoute(
//       //   path: "/all-photos",
//       //   name: "all-photos",
//       //   builder: (context, state) {
//       //     return AllPhotosScreen();
//       //   },
//       // ),
//       GoRoute(
//         path: "/loggin",
//         name: "/loggin",
//         builder: (context, state) {
//           return LogInScreen();
//         },
//       ),
//       GoRoute(
//         path: "/signup",
//         name: "/signup",
//         builder: (context, state) {
//           return SignUpScreen();
//         },
//       ),
//     ],
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
//   );
// });
//===========================لهون===================
final router = Provider<GoRouter>((ref) {
  // مراقبة حالة الـ AuthNotifier لإعادة بناء الراوتر عند تغير حالة المستخدم
  final authState = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: "/splash", // البداية دائماً من السبلاش
    observers: [BotToastNavigatorObserver()],

    redirect: (context, state) {
      final bool loggedIn = authState != null;

      // تحديد المسارات الخاصة بالمصادقة
      final bool isLoggingIn =
          state.matchedLocation == '/loggin' ||
          state.matchedLocation == '/signup' ||
          state.matchedLocation.startsWith('/reset-password');

      final bool isSplash = state.matchedLocation == '/splash';

      // 1. إذا كنا في السبلاش، اتركها تكمل عملها (هي من سيقوم بالتوجيه بعد ثانيتين)
      if (isSplash) return null;

      // 2. إذا لم يكن المستخدم مسجل دخول
      if (!loggedIn) {
        // إذا كان يحاول الدخول لصفحات اللوجن/الساين اب، اتركه يمر
        // أما إذا كان يحاول دخول أي صفحة أخرى، ارجعه للوجن
        return isLoggingIn ? null : '/loggin';
      }

      // 3. إذا كان المستخدم مسجل دخول (loggedIn == true)
      if (loggedIn) {
        // إذا كان يحاول الذهاب لصفحات اللوجن أو هو عالق في السبلاش بعد الخروج والعودة
        // وجهه فوراً للصفحة الرئيسية (add_photos)
        if (isLoggingIn) {
          return '/add_photos';
        }
      }

      return null; // اترك المستخدم يكمل مساره الطبيعي
    },

    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: "/loggin",
        name: "loggin",
        builder: (context, state) => const LogInScreen(),
      ),
      GoRoute(
        path: "/signup",
        name: "signup",
        builder: (context, state) => const SignUpScreen(),
      ),
      // جعلنا الـ add_photos مساراً مستقلاً أو رئيسياً لسهولة الوصول
      GoRoute(
        path: "/add_photos",
        name: "add_photos",
        builder: (context, state) => const AddPhotosScreen(),
      ),
      GoRoute(
        path: "/all-photos",
        name: "all-photos",
        builder: (context, state) => const AllPhotosScreen(),
      ),
      GoRoute(
        path: "/all-documents",
        name: "all-documents",
        builder: (context, state) => const AllDocumentsScreen(),
      ),
      GoRoute(
        path: '/reset-password/:token',
        name: 'reset-password',
        builder: (context, state) {
          final token = state.pathParameters['token']!;
          return ResetPasswordScreen(token: token);
        },
      ),
      // المسار الرئيسي الافتراضي يوجه للوجن (كاحتياط)
      GoRoute(path: "/", builder: (context, state) => const LogInScreen()),
    ],
  );
});
