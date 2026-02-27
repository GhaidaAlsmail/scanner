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

              // حقل الاسم
              ReactiveTextInputWidget(
                hint: 'اسم الموظف الكامل'.i18n,
                controllerName: 'name',
                inputStyle: InputStyle.outlined,
              ),
              const Gap(40),

              // حقل البريد الإلكتروني
              ReactiveTextInputWidget(
                hint: 'البريد الإلكتروني'.i18n,
                controllerName: 'email',
                inputStyle: InputStyle.outlined,
              ),
              const Gap(40),

              // حقل كلمة المرور
              ReactiveTextInputWidget(
                hint: 'كلمة المرور'.i18n,
                controllerName: 'password',
                inputStyle: InputStyle.outlined,
                // يمكنك إضافة خاصية obscureText إذا كانت مدعومة في الويجت الخاص بكِ
              ),
              const Gap(40),

              // اختيار المنطقة (المدينة)
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
                    ),
                    items: ["حمص"]
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                  ),
                ],
              ),

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

      // استدعاء دالة الإضافة من AuthService
      // ملاحظة: يجب أن تكون دالة register في الـ Service تقبل هذه البارامترات
      await ref
          .read(authServiceProvider)
          .addEmployeeByAdmin(
            name: form.control('name').value,
            email: form.control('email').value,
            password: form.control('password').value,
            city: form.control('city').value,
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
