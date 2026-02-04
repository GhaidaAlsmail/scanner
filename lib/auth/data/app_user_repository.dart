import '../domain/app_user.dart';

abstract class AppUserRepository {
  Future<AppUser> createUser(AppUser appUser);
  Future<AppUser?> getUserById(String id);
  Future<AppUser?> getUserByEmail(String email);
  Future<AppUser> updateUser(AppUser appUser);
  Future<void> deleteUser(String id);
  Future<List<AppUser>> getAllUsers();
  Future<AppUser> getMe();
}
