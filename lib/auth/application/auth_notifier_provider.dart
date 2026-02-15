// ignore_for_file: avoid_print

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/app_user.dart';
import 'auth_service.dart';
import 'app_user_service.dart';

/// للراوتر
final routerListenableProvider = Provider((ref) {
  return ref.watch(authNotifierProvider);
});

class AuthNotifier extends StateNotifier<AppUser?> {
  final AuthService authService;
  final AppUserService appUserService;

  AuthNotifier(this.authService, this.appUserService) : super(null) {
    _restoreSession();
  }

  ///  استعادة الجلسة عند فتح التطبيق
  Future<void> _restoreSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        state = null;
        return;
      }

      state = await appUserService.getMe();
    } catch (e) {
      await logout();
    }
  }

  ///  LOGIN
  Future<void> login(String email, String password) async {
    try {
      BotToast.showLoading();
      final user = await authService.login(email: email, password: password);
      state = user;
    } catch (e) {
      BotToast.showText(text: "البريد الإلكتروني أو كلمة المرور غير صحيحة");
    } finally {
      BotToast.closeAllLoading();
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required AppUser user,
  }) async {
    try {
      BotToast.showLoading();
      await authService.register(user: user, password: password);

      // 1. رسالة النجاح المطلوبة
      BotToast.showText(
        text: "تم إنشاء الحساب بنجاح، يرجى مراجعة بريدك لتأكيد الحساب",
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      // 2. إظهار الخطأ القادم من السيرفر بشكل نظيف
      String cleanError = e.toString().replaceAll("Exception:", "");
      BotToast.showText(text: "خطأ: $cleanError");
      print("Registration Error: $e");
      rethrow;
    } finally {
      BotToast.closeAllLoading();
    }
  }

  ///  تحديث بيانات المستخدم
  Future<void> refreshUser() async {
    try {
      state = await appUserService.getMe();
    } catch (e) {
      BotToast.showText(text: "فشل تحديث البيانات");
    }
  }

  ///  LOGOUT
  Future<void> logout() async {
    try {
      // 1. حذف التوكن من الذاكرة
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');

      // 2. تصفير الحالة فوراً (هذا هو السر في تحديث الشاشة)
      state = null;

      // 3. (اختياري) إظهار رسالة بسيطة
      BotToast.showText(text: "تم تسجيل الخروج بنجاح");
    } catch (e) {
      print("Logout Error: $e");
    }
  }

  ///  RESET PASSWORD (endpoint backend)
  Future<void> resetPassword(String email) async {
    try {
      BotToast.showLoading();
      await authService.resetPassword(email: email);
      BotToast.showText(text: "تم إرسال رابط تغيير كلمة المرور");
    } catch (e) {
      BotToast.showText(text: "حصل خطأ");
    } finally {
      BotToast.closeAllLoading();
    }
  }

  /// Reset  password

  Future<void> completeResetPassword(String token, String newPassword) async {
    try {
      BotToast.showLoading();
      // استدعاء الـ API (تأكدي من إضافة هذه الدالة في auth_service أولاً)
      await authService.confirmResetPassword(
        token: token,
        newPassword: newPassword,
      );
      BotToast.showText(text: "تم تغيير كلمة المرور بنجاح");
    } catch (e) {
      BotToast.showText(text: "فشل التحديث: ${e.toString()}");
    } finally {
      BotToast.closeAllLoading();
    }
  }

  /// Resend vervication email (endpoint backend)
  Future<void> resendVerification(String email) async {
    try {
      BotToast.showLoading();
      await authService.resendVerificationEmail(email: email);
      BotToast.showText(text: "تم إعادة إرسال رمز التفعيل بنجاح");
    } catch (e) {
      BotToast.showText(text: e.toString());
    } finally {
      BotToast.closeAllLoading();
    }
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AppUser?>((
  ref,
) {
  final authService = ref.read(authServiceProvider);
  final appUserService = ref.read(appUserServiceProvider);
  return AuthNotifier(authService, appUserService);
});
