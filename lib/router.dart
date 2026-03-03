import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:scanner/admin/screens/add_employee_screen.dart';
import 'package:scanner/admin/screens/admin_control_page.dart';
import 'package:scanner/admin/screens/all_employee_screen.dart';
import 'package:scanner/admin/screens/edit_documents_screen.dart';
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

      final bool isLoggingIn =
          state.matchedLocation == '/loggin' ||
          state.matchedLocation == '/signup' ||
          state.matchedLocation.startsWith('/reset-password');

      final bool isSplash = state.matchedLocation == '/splash';

      if (isSplash) return null;

      if (!loggedIn) {
        return isLoggingIn ? null : '/loggin';
      }

      if (loggedIn) {
        if (isLoggingIn) {
          return '/add_photos';
        }
      }

      return null;
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
      GoRoute(
        path: "/add_photos",
        name: "add_photos",
        builder: (context, state) => const AddPhotosScreen(),
      ),
      GoRoute(
        path: "/manage-employees",
        name: "manage-employees",
        builder: (context, state) => const ManageEmployeesScreen(),
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
      GoRoute(
        path: '/add-employee',
        builder: (context, state) => const AddEmployeeScreen(),
      ),
      GoRoute(path: "/", builder: (context, state) => const LogInScreen()),
      GoRoute(
        path: '/admin-dashboard',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/manage-documents',
        builder: (context, state) => const AllDocumentsScreen(),
      ),
      GoRoute(
        path: '/edit-document',
        builder: (context, state) {
          final doc = state.extra as Map<String, dynamic>;
          return EditDocumentScreen(doc: doc);
        },
      ),
    ],
  );
});
