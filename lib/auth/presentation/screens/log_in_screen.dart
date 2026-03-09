// // ignore_for_file: deprecated_member_use

// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:scanner/auth/presentation/components/enter_ip.dart';
import 'package:scanner/core/presentation/widgets/button_widget.dart';
import 'package:scanner/translation.dart';
import 'package:reactive_forms/reactive_forms.dart';
import '../../../core/presentation/widgets/reactive_password_input_widget.dart';
import '../../../core/presentation/widgets/reactive_text_input_widget.dart';
import '../../application/auth_notifier_provider.dart';
import '../../application/log_in_form_provider.dart';

class LogInScreen extends ConsumerWidget {
  const LogInScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.read(logInFormProvider);

    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        children: [
          // 1. خلفية الشعار
          Positioned.fill(
            top: 50,
            child: Image.asset(
              "assets/images/logo.png",
              cacheWidth: 400,
              filterQuality: FilterQuality.low,
              color: Colors.white.withOpacity(0.1),
              colorBlendMode: BlendMode.modulate,
            ),
          ),

          // 2. طبقة المحتوى
          SafeArea(
            child: ReactiveForm(
              formGroup: form,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Gap(70),
                    GestureDetector(
                      onLongPress: () {
                        showIpSettingsDialog(context);
                      },
                      child: Column(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "وزارة المالية",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "Cairo",
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              Gap(15),
                              Text(
                                "الهيئة العامة للضرائب والرسوم",
                                style: TextStyle(
                                  fontFamily: "Cairo",
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primary.withOpacity(0.9),
                                ),
                              ),
                              Gap(15),
                              Text(
                                "مـديرية المـالية في محافــظة حــمص",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: "Cairo",
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primary.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      //  Image.asset(
                      //   'assets/images/splash.png',
                      //   width: 250,
                      // ),
                    ),
                    const Gap(100),
                    ReactiveTextInputWidget(
                      hint: 'اسم المستخدم'.i18n,
                      controllerName: 'username',
                      textInputAction: TextInputAction.next,
                    ),
                    const Gap(40),
                    ReactivePasswordInputWidget(
                      hint: "كلمة المرور",
                      controllerName: "password",
                      showEye: true,
                      textInputAction: TextInputAction.done,
                    ),
                    const Gap(60),
                    // زر تسجيل الدخول
                    ReactiveFormConsumer(
                      builder: (context, formGroup, child) {
                        return Center(
                          child: ButtonWidget(
                            text: "تسجيل دخول".i18n,
                            onTap: formGroup.invalid
                                ? null
                                : () {
                                    // final email = formGroup
                                    //     .control("email")
                                    //     .value;
                                    final username = formGroup
                                        .control("username")
                                        .value;
                                    final password = formGroup
                                        .control("password")
                                        .value;

                                    ref
                                        .read(authNotifierProvider.notifier)
                                        .login(username, password);
                                  },
                          ),
                        );
                      },
                    ),
                    const Gap(170),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Gh.AlS   ",
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: "Cairo",
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.5),
                          ),
                        ),
                        Text(
                          "version: 1.0.0+1 ",
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: "Cairo",
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
