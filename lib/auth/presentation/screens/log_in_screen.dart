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
                  Image.asset('assets/images/splash.png', width: 250),
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
                    child: ReactiveValueListenableBuilder(
                      formControlName: "email",
                      builder: (context, control, child) {
                        return TextButtonWidget(
                          foregroundColor: Theme.of(context).colorScheme.scrim,
                          text: "Forgot Password?",
                          onTap: control.invalid
                              ? null
                              : () {
                                  ref
                                      .read(authNotifierProvider.notifier)
                                      .resetPassword(control.value as String);
                                },
                        );
                      },
                    ),
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
                                    .signInWithEmailAndPassword(
                                      email,
                                      password,
                                    );
                              },
                      );
                    },
                  ),
                  Gap(20),
                  ButtonWidget(
                    text: "Resend Email Verification".i18n,
                    onTap: () {
                      ref
                          .read(authNotifierProvider.notifier)
                          .resendEmailVerification();
                    },
                  ),
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
