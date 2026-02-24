// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:scanner/auth/domain/app_user.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/presentation/widgets/get_base_url.dart';

part 'auth_service.g.dart';

@riverpod
AuthService authService(Ref ref) {
  return AuthService(Dio());
}

class AuthService {
  final Dio _dio;

  AuthService(this._dio);

  /// تحديث الـ IP من الشاشة المخفية
  Future<void> updateServerIp(String newIp) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('server_ip', newIp);
  }

  // /// LOGIN
  // Future<AppUser> login({
  //   required String email,
  //   required String password,
  // }) async {
  //   final baseUrl = await getDynamicBaseUrl();

  //   final res = await http.post(
  //     Uri.parse('$baseUrl/auth/login'),
  //     headers: {'Content-Type': 'application/json'},
  //     body: jsonEncode({'email': email, 'password': password}),
  //   );

  //   if (res.statusCode != 200) {
  //     throw Exception('Login failed');
  //   }

  //   final data = jsonDecode(res.body);
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.setString('token', data['token']);

  //   return AppUser.fromJson(data['user']);
  // }

  /// REGISTER
  Future<void> register({
    required AppUser user,
    required String password,
  }) async {
    final baseUrl = await getDynamicBaseUrl();

    final res = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({...user.toJson(), 'password': password}),
    );

    if (res.statusCode != 200 && res.statusCode != 201) {
      print("Server Error Response: ${res.body}");
      throw Exception('Register failed: ${res.body}');
    }

    // إذا وصل الكود هنا، فالتسجيل نجح فعلاً!
    print("Registration Successful!");
  }

  /// LOGIN
  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    final baseUrl = await getDynamicBaseUrl();

    final res = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (res.statusCode != 200) {
      throw Exception('Login failed');
    }

    // هنا نقوم بفك تشفير البيانات القادمة من السيرفر
    final data = jsonDecode(res.body);

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('token', data['token']);

    bool adminStatus = data['user']['isAdmin'] ?? false;
    await prefs.setBool('isAdmin', adminStatus);

    debugPrint("User Role: ${adminStatus ? 'Admin' : 'Employee'}");

    return AppUser.fromJson(data['user']);
  }

  /// GET CURRENT USER (/me)
  Future<AppUser> getMe() async {
    final baseUrl = await getDynamicBaseUrl();
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) throw Exception('No token');

    final res = await http.get(
      Uri.parse('$baseUrl/auth/me'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (res.statusCode != 200) {
      throw Exception('Unauthorized');
    }

    final responseData = jsonDecode(res.body);

    if (responseData['user'] != null) {
      return AppUser.fromJson(responseData['user']);
    } else if (responseData['data'] != null &&
        responseData['data']['user'] != null) {
      return AppUser.fromJson(responseData['data']['user']);
    } else {
      // إذا كان السيرفر يرسل بيانات المستخدم في جذور الـ JSON مباشرة
      return AppUser.fromJson(responseData);
    }
  }

  /// LOGOUT (Utility)
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  /// RESET PASSWORD
  Future<void> resetPassword({required String email}) async {
    final baseUrl = await getDynamicBaseUrl();

    final res = await http.post(
      Uri.parse('$baseUrl/auth/forgot-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (res.statusCode != 200) {
      throw Exception('Reset password failed');
    }
  }

  /// RESEND EMAIL VERIFICATION
  Future<void> resendVerificationEmail({required String email}) async {
    final baseUrl = await getDynamicBaseUrl();

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

  Future<void> confirmResetPassword({
    required String token,
    required String newPassword,
  }) async {
    final baseUrl = await getDynamicBaseUrl();

    try {
      await _dio.patch(
        '$baseUrl/auth/reset-password/$token',
        data: {'password': newPassword},
      );
    } on DioException catch (e) {
      print("Dio Error: ${e.response?.data}");
      throw Exception(e.response?.data['message'] ?? "فشل تغيير كلمة المرور");
    }
  }

  Future<void> addEmployeeByAdmin({
    required String name,
    required String email,
    required String password,
    required String city,
  }) async {
    // 1. الحصول على الرابط الديناميكي
    final baseUrl = await getDynamicBaseUrl();

    // 2. الحصول على توكن المدير (لأن السيرفر لن يقبل إضافة موظف بدون صلاحية مدير)
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    // 3. إرسال الطلب للسيرفر
    final res = await http.post(
      Uri.parse(
        '$baseUrl/auth/add-employee', //////////////////////////////////
      ),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token', // الهيدر الأساسي للصلاحية
      },
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'city': city,
      }),
    );

    // 4. التحقق من رد السيرفر
    if (res.statusCode != 200 && res.statusCode != 201) {
      // استخراج رسالة الخطأ من السيرفر إذا وجدت
      final errorData = jsonDecode(res.body);
      throw Exception(errorData['message'] ?? 'فشل إنشاء حساب الموظف');
    }
  }
}
