import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/express_app_user_repository.dart';
import '../domain/app_user.dart';
import 'express_auth_service.dart';

class AuthNotifier extends StateNotifier<AppUser?> {
  final AuthServiceExpress authService;
  final AppUserService userService;

  AuthNotifier(this.authService, this.userService) : super(null);

  Future<void> login(String email, String password) async {
    BotToast.showLoading();

    final token = await authService.login(email, password);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);

    final user = await userService.getAccountByEmail(email);
    state = user;

    BotToast.closeAllLoading();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    state = null;
  }
}
