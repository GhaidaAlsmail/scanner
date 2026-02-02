import '../domain/app_user.dart';

class AuthServiceExpress {
  final Dio dio;

  AuthServiceExpress(this.dio);

  Future<String> login(String email, String password) async {
    final res = await dio.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );

    return res.data['token'];
  }

  Future<void> register(AppUser user, String password) async {
    await dio.post(
      '/auth/register',
      data: {...user.toJson(), 'password': password},
    );
  }
}
