import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:scanner/admin/screens/add_employee_screen.dart';
import 'package:scanner/admin/screens/admin_control_page.dart';
import 'package:scanner/auth/presentation/screens/reset_passwords.dart';
import 'package:scanner/home_management/presentation/screens/all_documents_screen.dart';
import 'auth/application/auth_notifier_provider.dart' show authNotifierProvider;
import 'auth/presentation/screens/log_in_screen.dart';
import 'auth/presentation/screens/sign_up_screen.dart';
import 'core/presentation/screens/splash_screen.dart';
import 'home_management/presentation/screens/add_photos_screen.dart';

final router = Provider<GoRouter>((ref) {
  final authState = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: "/splash",
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
      // GoRoute(
      //   path: "/all-photos",
      //   name: "all-photos",
      //   builder: (context, state) => const AllPhotosScreen(),
      // ),
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
      GoRoute(
        path: '/add-employee',
        builder: (context, state) => const AddEmployeeScreen(),
        // builder: (context, state) => const SignUpScreen(),
      ),
      // المسار الرئيسي الافتراضي يوجه للوجن (كاحتياط)
      GoRoute(path: "/", builder: (context, state) => const LogInScreen()),
      GoRoute(
        path: '/admin-dashboard',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
    ],
  );
});
