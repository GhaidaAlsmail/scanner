// ignore_for_file: use_build_context_synchronously

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:reactive_forms/reactive_forms.dart';
import '../../../core/presentation/widgets/button_widget.dart';
import '../../../core/presentation/widgets/reactive_password_input_widget.dart'
    show ReactivePasswordInputWidget;
import '../../../core/presentation/widgets/reactive_text_input_widget.dart';
import '../../../translation.dart';
// import '../../application/auth_notifier_provider.dart';
import '../../application/auth_notifier_provider.dart';
import '../../application/sign_up_form_provider.dart';
import '../../domain/app_user.dart';

class SignUpScreen extends ConsumerWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context, ref) {
    var form = ref.read(signUpFormProvider);

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
                  Gap(20),
                  Image.asset('assets/images/splash.png', width: 250),
                  const Gap(40),
                  ReactiveTextInputWidget(
                    hint: 'Username',
                    controllerName: 'userName',
                    textInputAction: TextInputAction.next,
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
                  ),
                  Gap(40),
                  ReactiveFormConsumer(
                    builder: (context, formGroup, child) {
                      return ButtonWidget(
                        text: "Sign Up".i18n,
                        onTap: formGroup.invalid
                            ? null
                            : () async {
                                var userName = form.control("userName").value;
                                var email = form.control("email").value;
                                var password = form.control("password").value;

                                ref
                                    .read(authNotifierProvider.notifier)
                                    .register(
                                      email,
                                      password,
                                      AppUser(
                                        email: email,
                                        password: password,
                                        name: userName,
                                      ),
                                    )
                                    .then((value) {
                                      // if (value != null) {
                                      formGroup.reset();
                                      context.pop();
                                      // }
                                    });
                              },
                      );
                    },
                  ),

                  Gap(300),

                  Wrap(
                    children: [
                      Text(
                        'By signing up to Watch News you are acceptin our '
                            .i18n,
                      ),
                      InkWell(
                        onTap: () {
                          BotToast.showText(
                            text: "Soon",
                            textStyle: TextStyle(
                              color: Theme.of(context).colorScheme.scrim,
                            ),
                          );
                        },
                        child: Text("Terms & Conditions".i18n),
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
