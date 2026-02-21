// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:scanner/core/presentation/widgets/reactive_text_input_widget.dart';
import 'package:scanner/translation.dart';
import 'package:reactive_forms/reactive_forms.dart';

// استيراد المكتبات الخاصة بمشروعك
import '../../../auth/application/auth_notifier_provider.dart';
import '../../../core/presentation/widgets/button_widget.dart';
import '../../application/add_photos_provider.dart';
import '../../application/photos_service.dart';

class AddPhotosScreen extends ConsumerWidget {
  const AddPhotosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(addNewsFormGroupProvider);
    final image = ref.watch(imgFileProvider);
    final currentUser = ref.watch(authNotifierProvider);
    final String userName = currentUser?.name ?? "مستخدم غير معروف";

    // تزويد الفورم بالقيمة تلقائياً إذا كان الحقل فارغاً
    if (form.control('name').value == null) {
      form.control('name').patchValue(userName);
    }
    return Scaffold(
      resizeToAvoidBottomInset: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "إضافة صورة".i18n,
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            top: 200,
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
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Gap(30),

                    // --- قسم التقاط الصورة الذكي ---
                    _buildImageSection(context, ref, image),

                    const Gap(40),

                    // --- حقول الإدخال ---
                    ReactiveTextInputWidget(
                      hint: 'العنوان'.i18n,
                      controllerName: 'head',
                      inputStyle: InputStyle.outlined,
                    ),
                    const Gap(20),
                    // --- حقل اسم الموظف (قائمة منسدلة تحتوي على اسم صاحب الحساب فقط) ---
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "الموظف المسؤول".i18n,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const Gap(5),
                        ReactiveDropdownField<String>(
                          formControlName: 'name',
                          hint: Text('اختر الاسم'.i18n),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 15,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surface,
                          ),
                          items: [
                            DropdownMenuItem(
                              value: userName,
                              child: Text(userName),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // ReactiveTextInputWidget(
                    //   hint: 'اسم الموظف'.i18n,
                    //   controllerName: 'name',
                    //   inputStyle: InputStyle.outlined,
                    // ),
                    const Gap(20),
                    ReactiveTextInputWidget(
                      hint: 'تفاصيل وملاحظات'.i18n,
                      controllerName: 'details',
                      inputStyle: InputStyle.outlined,
                    ),

                    const Gap(40),

                    // --- أزرار العمليات ---
                    _buildActionButtons(context, ref, form, image),

                    const Gap(20),

                    // --- أزرار الانتقال ---
                    _buildNavigationButtons(context),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ويجيت عرض واختيار الصورة
  Widget _buildImageSection(BuildContext context, WidgetRef ref, File? image) {
    return Material(
      borderRadius: BorderRadius.circular(20),
      elevation: 4,
      color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () async {
          // استدعاء الملقط (الذي سنطوره ليدعم السكنر)
          await ref.read(photosServicesProvider).showImagePicker(context, ref);
        },
        child: Container(
          width: double.infinity,
          height: 250,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
              width: 2,
            ),
          ),
          child: image == null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.document_scanner,
                      size: 60,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const Gap(10),
                    Text(
                      "إضغط لالتقاط صورة مستند".i18n,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.file(image, fit: BoxFit.contain),
                ),
        ),
      ),
    );
  }

  // أزرار الحفظ وتسجيل الخروج
  Widget _buildActionButtons(
    BuildContext context,
    WidgetRef ref,
    FormGroup form,
    File? image,
  ) {
    return Row(
      children: [
        Expanded(
          child: ButtonWidget(
            text: "إضافة صورة".i18n,
            onTap: () async => _handleUpload(context, ref, form, image),
          ),
        ),
        const Gap(15),
        Expanded(
          child: ButtonWidget(
            text: "تسجيل خروج ".i18n,
            onTap: () => ref.read(authNotifierProvider.notifier).logout(),
          ),
        ),
      ],
    );
  }

  // أزرار التنقل بين الصفحات
  Widget _buildNavigationButtons(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ButtonWidget(
                text: "عرض كل الصور".i18n,
                onTap: () => context.push('/all-photos'),
              ),
            ),
            const Gap(15),
            Expanded(
              child: ButtonWidget(
                text: "عرض ملفات PDF".i18n,
                onTap: () => context.push('/all-documents'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // دالة المعالجة والرفع
  Future<void> _handleUpload(
    BuildContext context,
    WidgetRef ref,
    FormGroup form,
    File? image,
  ) async {
    if (form.invalid) {
      form.markAllAsTouched();
      return;
    }

    if (image == null) {
      BotToast.showText(text: 'Please select an image'.i18n);
      return;
    }

    try {
      BotToast.showLoading();
      await ref
          .read(photosServicesProvider)
          .createPhoto(
            head: form.control('head').value,
            name: form.control('name').value,
            details: form.control('details').value,
            imageFile: image,
          );

      if (context.mounted) {
        BotToast.showText(text: 'تم حفظ الصورة بنجاح!'.i18n);
        ref.invalidate(allPhotosProvider);
        form.reset();
        ref.read(imgFileProvider.notifier).state = null;
      }
    } catch (e) {
      BotToast.showText(text: 'Error: ${e.toString()}');
    } finally {
      BotToast.closeAllLoading();
    }
  }
}
