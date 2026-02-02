import 'package:news_watch/auth/domain/app_user.dart';

class AppUserService {
  final Dio dio;

  AppUserService(this.dio);

  Future<AppUser?> getAccountByEmail(String email) async {
    final res = await dio.get(
      '/users/by-email',
      queryParameters: {'email': email},
    );

    return res.data == null ? null : AppUser.fromJson(res.data);
  }

  Future<void> updateUser(AppUser user) async {
    await dio.put('/users/${user.id}', data: user.toJson());
  }
}
