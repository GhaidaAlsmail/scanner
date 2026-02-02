// ignore_for_file: prefer_conditional_assignment, invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/app_user.dart';
import 'app_user_service.dart';
import 'auth_notifier_provider.dart';

Future<void> initGoogleSignIn() async {
  await GoogleSignIn.instance.initialize();
}

Future<void> signInWithGoogle(WidgetRef ref) async {
  try {
    final account = await GoogleSignIn.instance.authenticate();

    final auth = account.authentication;

    final credential = GoogleAuthProvider.credential(idToken: auth.idToken);

    final userCredential = await FirebaseAuth.instance.signInWithCredential(
      credential,
    );

    final user = userCredential.user;
    if (user == null) return;

    final appUserService = ref.read(appUserServiceProvider);

    var existing = await appUserService.getAccountByEmail(user.email!);

    if (existing == null) {
      existing = await appUserService.createAccount(
        AppUser(
          id: user.uid,
          email: user.email!,
          name: user.displayName ?? '',
          city: '',
        ),
      );
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', existing.id!);

    ref.read(authNotifierProvider.notifier).state = existing;
  } catch (e, s) {
    print('Google login error: $e');
    print(s);
  }
}
