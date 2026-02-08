import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/app_user.dart';

part 'app_user_service.g.dart';

@riverpod
AppUserService appUserService(Ref ref) {
  return AppUserService(baseUrl: 'http://10.72.210.150:3006/api');
  // return AppUserService(baseUrl: 'http://10.0.2.2:3006/api');
}

class AppUserService {
  final String baseUrl;
  AppUserService({required this.baseUrl});

  ///  المستخدم الحالي
  Future<AppUser> getMe() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('No token');
    }

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

  ///  تحديث المستخدم
  Future<AppUser> updateUser(AppUser user) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final res = await http.put(
      Uri.parse('$baseUrl/users/me'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(user.toJson()),
    );

    if (res.statusCode != 200) {
      throw Exception('Update failed');
    }

    return AppUser.fromJson(jsonDecode(res.body));
  }
}
