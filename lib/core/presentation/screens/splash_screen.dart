import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:scanner/auth/application/auth_notifier_provider.dart';
import '../../../translation.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // تنفيذ التنقل بعد بناء أول إطار للشاشة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleNavigation();
    });
  }

  Future<void> _handleNavigation() async {
    // ننتظر 3 ثوانٍ لمشاهدة اللوغو
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    // قراءة حالة المستخدم
    final user = ref.read(authNotifierProvider);

    if (user == null) {
      context.go("/loggin");
    } else {
      context.go("/add_photos");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // تأكدي أن اللون ليس أسود
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // تأكدي من صحة مسار الصورة، إذا لم تكن موجودة ستظهر شاشة سوداء أحياناً
            Image.asset(
              "assets/images/splash.png",
              width: 200,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.image, size: 100, color: Colors.grey),
            ),
            const Gap(20),
            Text(
              "Hello in Scanner App".i18n,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Gap(10),
            const CircularProgressIndicator(), // مؤشر تحميل ليعرف المستخدم أن التطبيق يعمل
          ],
        ),
      ),
    );
  }
}
