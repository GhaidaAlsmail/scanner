import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/app_user.dart';
import 'app_user_repository.dart';

part 'api_app_user_repository.g.dart';

@riverpod
ApiAppUserRepository apiAppUserRepository(Ref ref) {
  return ApiAppUserRepository(baseUrl: 'http://localhost:3006/api');
}

class ApiAppUserRepository implements AppUserRepository {
  final String baseUrl;
  ApiAppUserRepository({required this.baseUrl});

  Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  @override
  Future<AppUser> getMe() async {
    final res = await http.get(
      Uri.parse('$baseUrl/users/me'),
      headers: await _headers(),
    );

    if (res.statusCode != 200) {
      throw Exception('Unauthorized');
    }

    return AppUser.fromJson(jsonDecode(res.body));
  }

  @override
  Future<AppUser?> getUserById(String id) async {
    final res = await http.get(
      Uri.parse('$baseUrl/users/$id'),
      headers: await _headers(),
    );

    if (res.statusCode != 200) return null;
    return AppUser.fromJson(jsonDecode(res.body));
  }

  @override
  Future<AppUser?> getUserByEmail(String email) async {
    final res = await http.get(
      Uri.parse('$baseUrl/users/by-email/$email'),
      headers: await _headers(),
    );

    if (res.statusCode != 200) return null;
    return AppUser.fromJson(jsonDecode(res.body));
  }

  @override
  Future<AppUser> createUser(AppUser user) async {
    final res = await http.post(
      Uri.parse('$baseUrl/users'),
      headers: await _headers(),
      body: jsonEncode(user.toJson()),
    );

    if (res.statusCode != 201) {
      throw Exception('Create failed');
    }

    return AppUser.fromJson(jsonDecode(res.body));
  }

  @override
  Future<AppUser> updateUser(AppUser user) async {
    final res = await http.put(
      Uri.parse('$baseUrl/users/${user.id}'),
      headers: await _headers(),
      body: jsonEncode(user.toJson()),
    );

    if (res.statusCode != 200) {
      throw Exception('Update failed');
    }

    return AppUser.fromJson(jsonDecode(res.body));
  }

  @override
  Future<void> deleteUser(String id) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/users/$id'),
      headers: await _headers(),
    );

    if (res.statusCode != 204) {
      throw Exception('Delete failed');
    }
  }

  @override
  Future<List<AppUser>> getAllUsers() async {
    final res = await http.get(
      Uri.parse('$baseUrl/users'),
      headers: await _headers(),
    );

    if (res.statusCode != 200) return [];

    final List list = jsonDecode(res.body);
    return list.map((e) => AppUser.fromJson(e)).toList();
  }
}
