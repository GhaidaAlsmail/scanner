// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:news_watch/auth/domain/app_user.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'auth_service.g.dart';

@riverpod
AuthService authService(Ref ref) {
  return AuthService(baseUrl: 'http://YOUR_SERVER_URL/api');
}

class AuthService {
  final String baseUrl;
  AuthService({required this.baseUrl});

  /// LOGIN
  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (res.statusCode != 200) {
      throw Exception('Login failed');
    }

    final data = jsonDecode(res.body);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', data['token']);

    return AppUser.fromJson(data['user']);
  }

  /// REGISTER
  Future<void> register({
    required AppUser user,
    required String password,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({...user.toJson(), 'password': password}),
    );

    if (res.statusCode != 201) {
      throw Exception('Register failed');
    }
  }

  /// GET CURRENT USER (/me)
  Future<AppUser> getMe() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) throw Exception('No token');

    final res = await http.get(
      Uri.parse('$baseUrl/users/me'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (res.statusCode != 200) {
      throw Exception('Unauthorized');
    }

    return AppUser.fromJson(jsonDecode(res.body));
  }

  /// LOGOUT
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  /// RESET PASSWORD (backend endpoint)
  Future<void> resetPassword({required String email}) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/forgot-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (res.statusCode != 200) {
      throw Exception('Reset password failed');
    }
  }

  /// RESEND EMAIL VERIFICATION (backend endpoint)
  Future<void> resendVerificationEmail({required String email}) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/resend-verification'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (res.statusCode != 200) {
      final data = jsonDecode(res.body);
      throw Exception(data['message'] ?? 'Resend verification failed');
    }
  }
}
