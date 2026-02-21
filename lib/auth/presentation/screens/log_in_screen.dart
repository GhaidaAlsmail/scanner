import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:scanner/core/presentation/widgets/button_widget.dart';
import 'package:scanner/translation.dart';
import 'package:reactive_forms/reactive_forms.dart';
import '../../../core/presentation/widgets/reactive_password_input_widget.dart';
import '../../../core/presentation/widgets/reactive_text_input_widget.dart';
import '../../application/auth_notifier_provider.dart';
import '../../application/log_in_form_provider.dart';
import '../components/enter_ip.dart';

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
                  children: [
                    const Gap(70),
                    GestureDetector(
                      onLongPress: () {
                        showIpSettingsDialog(context);
                      },
                      child: Image.asset(
                        'assets/images/splash.png',
                        width: 250,
                      ),
                    ),
                    const Gap(40),
                    ReactiveTextInputWidget(
                      hint: 'Email',
                      controllerName: 'email',
                      textInputAction: TextInputAction.next,
                    ),
                    const Gap(40),
                    ReactivePasswordInputWidget(
                      hint: "Password",
                      controllerName: "password",
                      showEye: true,
                      textInputAction: TextInputAction.done,
                    ),
                    const Gap(60),
                    // Align(
                    //   alignment: AlignmentDirectional.centerEnd,
                    //   child: ReactiveValueListenableBuilder<dynamic>(
                    //     formControlName: "email",
                    //     builder: (context, control, child) {
                    //       return TextButtonWidget(
                    //         foregroundColor: Theme.of(context).colorScheme.scrim,
                    //         text: "Forgot Password?".i18n,
                    //         onTap:
                    //             (control.value == null ||
                    //                 control.value.toString().isEmpty)
                    //             ? () => BotToast.showText(
                    //                 text: "يرجى كتابة البريد الإلكتروني أولاً",
                    //               )
                    //             : () async {
                    //                 // تفعيل استدعاء إعادة تعيين كلمة المرور
                    //                 await ref
                    //                     .read(authNotifierProvider.notifier)
                    //                     .resetPassword(control.value.toString());
                    //               },
                    //       );
                    //     },
                    //   ),
                    // ),
                    // const Gap(40),

                    // // زر تسجيل الدخول (Sign In)
                    // ReactiveFormConsumer(
                    //   builder: (context, formGroup, child) {
                    //     return ButtonWidget(
                    //       text: "Sign in".i18n,
                    //       onTap: formGroup.invalid
                    //           ? null
                    //           : () {
                    //               var email = formGroup.control("email").value;
                    //               var password = formGroup
                    //                   .control("password")
                    //                   .value;

                    //               ref
                    //                   .read(authNotifierProvider.notifier)
                    //                   .login(email, password);
                    //             },
                    //     );
                    //   },
                    // ),
                    // زر تسجيل الدخول
                    ReactiveFormConsumer(
                      builder: (context, formGroup, child) {
                        return ButtonWidget(
                          text: "Sign in".i18n,
                          onTap: formGroup.invalid
                              ? null
                              : () {
                                  final email = formGroup
                                      .control("email")
                                      .value;
                                  final password = formGroup
                                      .control("password")
                                      .value;

                                  ref
                                      .read(authNotifierProvider.notifier)
                                      .login(email, password);
                                },
                        );
                      },
                    ),
                    const Gap(170), // Gap(20),
                    // ButtonWidget(
                    //   text: "Resend Email Verification".i18n,
                    //   onTap: () async {
                    //     var email = form
                    //         .control("email")
                    //         .value; //  سحب الإيميل المكتوب في الحقل
                    //     if (email != null && email.isNotEmpty) {
                    //       await ref
                    //           .read(authServiceProvider)
                    //           .resendVerificationEmail(email: email);
                    //     } else {
                    //       BotToast.showText(
                    //         text: "يرجى كتابة البريد الإلكتروني أولاً",
                    //       );
                    //     }
                    //   },
                    // ),
                    // Gap(40),

                    // Gap(170),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   children: [
                    //     Text('- if you dont have an account - '.i18n),
                    //     TextButtonWidget(
                    //       text: "Register".i18n,
                    //       onTap: () {
                    //         context.push("/signup");
                    //       },
                    //       foregroundColor: Theme.of(context).colorScheme.scrim,
                    //     ),
                    //   ],
                    // ),
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
