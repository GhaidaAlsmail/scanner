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

  ///  REGISTER
  Future<void> register(AppUser user, String password) async {
    try {
      BotToast.showLoading();
      await authService.register(user: user, password: password);
      BotToast.showText(text: "تم إنشاء الحساب بنجاح، يمكنك تسجيل الدخول");
    } catch (e) {
      BotToast.showText(text: "فشل إنشاء الحساب");
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
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    state = null;
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
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AppUser?>((
  ref,
) {
  final authService = ref.read(authServiceProvider);
  final appUserService = ref.read(appUserServiceProvider);
  return AuthNotifier(authService, appUserService);
});
