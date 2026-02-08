// // ignore_for_file: avoid_print

// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:news_watch/auth/domain/app_user.dart';
// import 'package:riverpod_annotation/riverpod_annotation.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// part 'auth_service.g.dart';

// @riverpod
// AuthService authService(Ref ref) {
//   return AuthService(baseUrl: 'http://10.0.2.2:3006/api');
// }

// class AuthService {
//   final String baseUrl;
//   AuthService({required this.baseUrl});

//   /// get url
//   Future<String> getBaseUrl() async {
//     final prefs = await SharedPreferences.getInstance();
//     // إذا لم يجد IP مخزن، يستخدم الافتراضي (مثلاً IP الجهاز حالياً)
//     String savedIp = prefs.getString('server_ip') ?? '10.0.2.2';
//     return "http://$savedIp:3006/api/auth";
//   }

//   /// LOGIN
//   Future<AppUser> login({
//     required String email,
//     required String password,
//   }) async {
//     // 1. جلب الـ IP المخزن من SharedPreferences
//     final prefs = await SharedPreferences.getInstance();
//     // إذا لم يجد IP مخزن، سيستخدم IP افتراضي (مثلاً 10.0.2.2 للمحاكي)
//     final String savedIp = prefs.getString('server_ip') ?? '10.0.2.2';

//     // 2. بناء الرابط الكامل ديناميكياً
//     final String dynamicUrl = 'http://$savedIp:3006/api';

//     // 3. إرسال الطلب باستخدام الرابط الجديد
//     final res = await http.post(
//       Uri.parse('$dynamicUrl/auth/login'), // لاحظي استخدام dynamicUrl هنا
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({'email': email, 'password': password}),
//     );

//     if (res.statusCode != 200) {
//       throw Exception('Login failed');
//     }

//     final data = jsonDecode(res.body);

//     // حفظ التوكن
//     await prefs.setString('token', data['token']);

//     return AppUser.fromJson(data['user']);
//   }

//   /// =================هي شغالة================
//   // Future<AppUser> login({
//   //   required String email,
//   //   required String password,
//   // }) async {

//   //   final res = await http.post(
//   //     Uri.parse('$baseUrl/auth/login'),
//   //     headers: {'Content-Type': 'application/json'},
//   //     body: jsonEncode({'email': email, 'password': password}),
//   //   );

//   //   if (res.statusCode != 200) {
//   //     throw Exception('Login failed');
//   //   }

//   //   final data = jsonDecode(res.body);

//   //   final prefs = await SharedPreferences.getInstance();
//   //   await prefs.setString('token', data['token']);

//   //   return AppUser.fromJson(data['user']);
//   // }

//   ///update ip server
//   Future<void> updateServerIp(String newIp) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('server_ip', newIp);
//   }

//   /// REGISTER
//   Future<void> register({
//     required AppUser user,
//     required String password,
//   }) async {
//     final res = await http.post(
//       Uri.parse('$baseUrl/auth/register'),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({...user.toJson(), 'password': password}),
//     );

//     if (res.statusCode != 201) {
//       throw Exception('Register failed');
//     }
//   }

//   /// GET CURRENT USER (/me)
//   Future<AppUser> getMe() async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('token');

//     if (token == null) throw Exception('No token');

//     final res = await http.get(
//       Uri.parse('$baseUrl/auth/me'),
//       headers: {
//         'Authorization': 'Bearer $token',
//         'Content-Type': 'application/json',
//       },
//     );

//     if (res.statusCode != 200) {
//       throw Exception('Unauthorized');
//     }
//     final responseData = jsonDecode(res.body);
//     return AppUser.fromJson(responseData['data']['user']);
//     // return AppUser.fromJson(jsonDecode(res.body));
//   }

//   /// LOGOUT
//   Future<void> logout() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove('token');
//   }

//   /// RESET PASSWORD (backend endpoint)
//   Future<void> resetPassword({required String email}) async {
//     final res = await http.post(
//       Uri.parse('$baseUrl/auth/forgot-password'),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({'email': email}),
//     );

//     if (res.statusCode != 200) {
//       throw Exception('Reset password failed');
//     }
//   }

//   /// RESEND EMAIL VERIFICATION (backend endpoint)
//   Future<void> resendVerificationEmail({required String email}) async {
//     final res = await http.post(
//       Uri.parse('$baseUrl/auth/resend-verification'),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({'email': email}),
//     );

//     if (res.statusCode != 200) {
//       final data = jsonDecode(res.body);
//       throw Exception(data['message'] ?? 'Resend verification failed');
//     }
//   }
// }

//===========================بعد توحيد دالة تغير الip==================

// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:news_watch/auth/domain/app_user.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'auth_service.g.dart';

@riverpod
AuthService authService(Ref ref) {
  // القيمة هنا لم تعد تؤثر لأننا نعتمد على SharedPreferences داخل الكلاس
  return AuthService();
}

class AuthService {
  // لم نعد بحاجة لـ final String baseUrl في الكونستركتور لتجنب التعارض
  AuthService();

  /// دالة خاصة (Private) لجلب الرابط الديناميكي من التخزين
  /// تستخدم داخلياً في كل طلبات الـ API
  Future<String> _getDynamicBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    // القيمة الافتراضية للمحاكي هي 10.0.2.2
    String savedIp = prefs.getString('server_ip') ?? '10.0.2.2';
    return "http://$savedIp:3006/api";
  }

  /// تحديث الـ IP من الشاشة المخفية
  Future<void> updateServerIp(String newIp) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('server_ip', newIp);
  }

  /// LOGIN
  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    final baseUrl = await _getDynamicBaseUrl();

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
    final baseUrl = await _getDynamicBaseUrl();

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
    final baseUrl = await _getDynamicBaseUrl();
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
    // تأكدي من مسار البيانات في الـ JSON القادم من سيرفرك
    return AppUser.fromJson(responseData['data']['user']);
  }

  /// LOGOUT
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  /// RESET PASSWORD
  Future<void> resetPassword({required String email}) async {
    final baseUrl = await _getDynamicBaseUrl();

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
    final baseUrl = await _getDynamicBaseUrl();

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
