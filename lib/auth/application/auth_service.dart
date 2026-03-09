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

    debugPrint("Registration Successful!");
  }

  /// LOGIN
  Future<AppUser> login({
    required String username,
    required String password,
  }) async {
    final baseUrl = await getDynamicBaseUrl();

    final res = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
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

  Future<List<dynamic>> getAllEmployees() async {
    try {
      // جلب الرابط الديناميكي (حسب الإعدادات لديكِ)
      String baseUrl = await getDynamicBaseUrl();

      // جلب التوكن المخزن للتأكد من صلاحية المدير
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await _dio.get(
        '$baseUrl/auth/employees',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        // السيرفر يعيد قائمة بالموظفين
        return response.data;
      } else {
        throw Exception("فشل جلب قائمة الموظفين");
      }
    } catch (e) {
      print("Error fetching employees: $e");
      rethrow;
    }
  }

  Future<void> updateEmployee({
    required String userId,
    required String newName, // إضافة الاسم
    required String newUsername,
    String? newPassword,
    required bool isAdmin,
  }) async {
    try {
      final baseUrl = await getDynamicBaseUrl();
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await _dio.patch(
        '$baseUrl/auth/update-employee/$userId',
        data: {
          'name': newName, // إرسال الاسم للسيرفر
          'username': newUsername,
          'isAdmin': isAdmin,
          if (newPassword != null && newPassword.isNotEmpty)
            'password': newPassword,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode != 200) {
        throw Exception("فشل تحديث بيانات الموظف");
      }
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? "حدث خطأ في الاتصال بالسيرفر",
      );
    }
  }

  Future<void> deleteEmployee({required String userId}) async {
    try {
      final baseUrl = await getDynamicBaseUrl();
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await _dio.delete(
        '$baseUrl/auth/delete-employee/$userId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode != 200) {
        throw Exception("فشل حذف حساب الموظف");
      }
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? "حدث خطأ أثناء محاولة الحذف",
      );
    }
  }

  Future<void> addEmployeeByAdmin({
    required String name,
    required String username,
    required String email,
    required String password,
    required String city,
    required bool isAdmin,
  }) async {
    final baseUrl = await getDynamicBaseUrl();
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    final res = await http.post(
      Uri.parse('$baseUrl/auth/add-employee'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': name,
        'username': username,
        'email': email,
        'password': password,
        'city': city,
        'isAdmin': isAdmin,
      }),
    );

    if (res.statusCode != 200 && res.statusCode != 201) {
      final errorData = jsonDecode(res.body);
      throw Exception(errorData['message'] ?? 'فشل إنشاء حساب الموظف');
    }
  }
}
