import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:news_watch/core/presentation/widgets/button_widget.dart';
import 'package:news_watch/translation.dart';
import 'package:reactive_forms/reactive_forms.dart';
import '../../../core/presentation/widgets/reactive_password_input_widget.dart';
import '../../../core/presentation/widgets/reactive_text_input_widget.dart';
import '../../../core/presentation/widgets/text_button_widget.dart';
import '../../application/auth_notifier_provider.dart';
import '../../application/log_in_form_provider.dart';
import '../components/enter_ip.dart';

class LogInScreen extends ConsumerWidget {
  const LogInScreen({super.key});

  @override
  Widget build(BuildContext context, ref) {
    var form = ref.read(logInFormProvider);

    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: ReactiveForm(
            formGroup: form,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Gap(70),
                  GestureDetector(
                    onLongPress: () {
                      showIpSettingsDialog(context);
                    },
                    child: Image.asset('assets/images/splash.png', width: 250),
                  ),
                  const Gap(40),
                  ReactiveTextInputWidget(
                    hint: 'Email',
                    controllerName: 'email',
                    textInputAction: TextInputAction.next,
                  ),
                  Gap(40),
                  ReactivePasswordInputWidget(
                    hint: "Password",
                    controllerName: "password",
                    showEye: true,
                    textInputAction: TextInputAction.done,
                  ),

                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: ReactiveValueListenableBuilder<dynamic>(
                      formControlName: "email",
                      builder: (context, control, child) {
                        return TextButtonWidget(
                          foregroundColor: Theme.of(context).colorScheme.scrim,
                          text: "Forgot Password?".i18n,
                          onTap:
                              (control.value == null ||
                                  control.value.toString().isEmpty)
                              ? () => BotToast.showText(
                                  text: "يرجى كتابة البريد الإلكتروني أولاً",
                                )
                              : () async {
                                  // تفعيل استدعاء إعادة تعيين كلمة المرور
                                  await ref
                                      .read(authNotifierProvider.notifier)
                                      .resetPassword(control.value.toString());
                                },
                        );
                      },
                    ),
                  ),

                  const Gap(40),

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
                  const Gap(20),

                  // زر إعادة إرسال رمز التفعيل (Resend Verification)
                  TextButtonWidget(
                    text: "Resend Email Verification".i18n,
                    foregroundColor:
                        Colors.blueGrey, // يمكنكِ تغيير اللون حسب الثيم
                    onTap: () async {
                      var email = form.control("email").value;
                      if (email != null && email.toString().isNotEmpty) {
                        // استدعاء الدالة من الـ Notifier لضمان ظهور الـ Loading
                        await ref
                            .read(authNotifierProvider.notifier)
                            .resendVerification(email.toString());
                      } else {
                        BotToast.showText(
                          text: "يرجى كتابة البريد الإلكتروني أولاً",
                        );
                      }
                    },
                  ),

                  Gap(40),
                  ReactiveFormConsumer(
                    builder: (context, formGroup, child) {
                      return ButtonWidget(
                        text: "Sign in".i18n,
                        onTap: formGroup.invalid
                            ? null
                            : () {
                                var email = formGroup.control("email").value;
                                var password = formGroup
                                    .control("password")
                                    .value;

                                ref
                                    .read(authNotifierProvider.notifier)
                                    .login(email, password);
                              },
                      );
                    },
                  ),
                  // Gap(20),
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
                  Gap(40),

                  Gap(170),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('- if you dont have an account - '.i18n),
                      TextButtonWidget(
                        text: "Register".i18n,
                        onTap: () {
                          context.push("/signup");
                        },
                        foregroundColor: Theme.of(context).colorScheme.scrim,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
