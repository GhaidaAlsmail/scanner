// ignore_for_file: use_build_context_synchronously

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:scanner/core/presentation/widgets/reactive_text_input_widget.dart';
import 'package:scanner/translation.dart';
import '../../../core/presentation/widgets/button_widget.dart';
import '../../auth/application/auth_service.dart';
import '../application/add_employee_provider.dart';

class AddEmployeeScreen extends ConsumerWidget {
  const AddEmployeeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(addEmployeeFormProvider);
    return Scaffold(
      appBar: AppBar(title: Text("إضافة موظف جديد".i18n), centerTitle: true),
      body: ReactiveForm(
        formGroup: form,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Image.asset('assets/images/logo.png', width: 250),
              const Gap(40),

              // // حقل الاسم
              // ReactiveTextInputWidget(
              //   hint: 'اسم الموظف الكامل'.i18n,
              //   controllerName: 'name',
              //   inputStyle: InputStyle.outlined,
              // ),
              // const Gap(40),

              // // حقل البريد الإلكتروني
              // ReactiveTextInputWidget(
              //   hint: 'البريد الإلكتروني'.i18n,
              //   controllerName: 'email',
              //   inputStyle: InputStyle.outlined,
              // ),
              // const Gap(40),

              // // حقل كلمة المرور
              // ReactiveTextInputWidget(
              //   hint: 'كلمة المرور'.i18n,
              //   controllerName: 'password',
              //   inputStyle: InputStyle.outlined,
              // ),
              // const Gap(40),

              // // اختيار المنطقة (المدينة)
              // Column(
              //   crossAxisAlignment: CrossAxisAlignment.start,
              //   children: [
              //     Text(
              //       "المنطقة التابع لها".i18n,
              //       style: const TextStyle(fontSize: 12),
              //     ),
              //     const Gap(5),
              //     ReactiveDropdownField<String>(
              //       formControlName: 'city',
              //       decoration: InputDecoration(
              //         border: OutlineInputBorder(
              //           borderRadius: BorderRadius.circular(10),
              //         ),
              //         filled: true,
              //       ),
              //       items: ["حمص"]
              //           .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              //           .toList(),
              //     ),
              // داخل ملف AddEmployeeScreen في الـ Column:

              // 1. حقل الاسم الكامل
              ReactiveTextInputWidget(
                hint: 'اسم الموظف الكامل'.i18n,
                controllerName: 'name',
                inputStyle: InputStyle.outlined,
              ),
              const Gap(20),

              // 2. حقل اسم المستخدم (Username) - جديد وإجباري
              ReactiveTextInputWidget(
                hint: 'اسم المستخدم'.i18n,
                controllerName: 'username',
                inputStyle: InputStyle.outlined,
              ),
              const Gap(20),

              // 3. حقل البريد الإلكتروني (اختياري)
              ReactiveTextInputWidget(
                hint: 'البريد الإلكتروني (اختياري)'.i18n,
                controllerName: 'email',
                inputStyle: InputStyle.outlined,
              ),
              const Gap(20),

              // 4. حقل كلمة المرور
              ReactiveTextInputWidget(
                hint: 'كلمة المرور'.i18n,
                controllerName: 'password',
                inputStyle: InputStyle.outlined,
              ),
              const Gap(20),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "المنطقة التابع لها".i18n,
                    style: const TextStyle(fontSize: 12),
                  ),
                  const Gap(5),
                  ReactiveDropdownField<String>(
                    formControlName: 'city',
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Theme.of(
                        context,
                      ).colorScheme.outlineVariant.withAlpha(22),
                    ),
                    items: ["حمص", "ريف حمص"]
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                  ),
                ],
              ),
              const Gap(20),
              ReactiveCheckboxListTile(
                formControlName: 'isAdmin',
                title: Text("منح صلاحيات مدير (Admin)".i18n),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              const Gap(20),
              const Gap(40),

              // زر الحفظ
              ButtonWidget(
                text: "إنشاء الحساب الآن".i18n,
                onTap: () => _handleCreateAccount(context, ref, form),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleCreateAccount(
    BuildContext context,
    WidgetRef ref,
    FormGroup form,
  ) async {
    if (form.invalid) {
      form.markAllAsTouched();
      BotToast.showText(text: 'يرجى إكمال البيانات بشكل صحيح');
      return;
    }

    try {
      BotToast.showLoading();
      await ref
          .read(authServiceProvider)
          .addEmployeeByAdmin(
            name: form.control('name').value,
            username: form.control('username').value, // جديد
            email: form.control('email').value ?? "", // قد يكون فارغاً
            password: form.control('password').value,
            city: form.control('city').value,
            isAdmin: form.control('isAdmin').value, // جديد
          );
      BotToast.showText(text: 'تم إنشاء حساب الموظف بنجاح');
      Navigator.pop(context); // العودة للشاشة السابقة
    } catch (e) {
      BotToast.showText(text: 'خطأ أثناء الإنشاء: $e');
    } finally {
      BotToast.closeAllLoading();
    }
  }
}
