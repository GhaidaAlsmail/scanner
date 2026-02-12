// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:news_watch/auth/application/auth_notifier_provider.dart';
import 'package:news_watch/core/presentation/widgets/button_widget.dart';
import 'package:news_watch/core/presentation/widgets/reactive_password_input_widget.dart';
import 'package:reactive_forms/reactive_forms.dart';

class ResetPasswordScreen extends ConsumerWidget {
  final String token; // التوكن الذي سيأتي من الرابط
  const ResetPasswordScreen({super.key, required this.token});

  FormGroup buildForm() => fb.group(
    {
      'password': ['', Validators.required, Validators.minLength(6)],
      'confirmPassword': ['', Validators.required],
    },
    [Validators.mustMatch('password', 'confirmPassword')],
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = buildForm();

    return Scaffold(
      appBar: AppBar(title: const Text("تعيين كلمة مرور جديدة")),
      body: ReactiveForm(
        formGroup: form,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              ReactivePasswordInputWidget(
                hint: "كلمة المرور الجديدة",
                controllerName: "password",
              ),
              const Gap(20),
              ReactivePasswordInputWidget(
                hint: "تأكيد كلمة المرور",
                controllerName: "confirmPassword",
              ),
              const Gap(40),
              ButtonWidget(
                text: "تحديث كلمة المرور",
                onTap: () async {
                  if (form.valid) {
                    final newPassword = form.control('password').value;
                    // هنا سنستدعي الدالة التي سننشئها في الـ Notifier
                    await ref
                        .read(authNotifierProvider.notifier)
                        .completeResetPassword(token, newPassword);
                    context.go('/login'); // العودة للوجن بعد النجاح
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
