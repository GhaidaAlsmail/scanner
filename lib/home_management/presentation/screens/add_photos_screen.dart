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
import '../../../auth/application/auth_notifier_provider.dart';
import '../../../core/presentation/widgets/button_widget.dart';
import '../../application/add_photos_provider.dart';
import '../../application/photos_service.dart';

class AddPhotosScreen extends ConsumerWidget {
  const AddPhotosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(addNewsFormGroupProvider);
    final List<File> selectedImages = ref.watch(selectedImagesListProvider);
    final currentUser = ref.watch(authNotifierProvider);
    final bool isAdmin = currentUser?.isAdmin ?? false;
    final String userName = currentUser?.name ?? "مستخدم غير معروف";

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
                    _buildImageSection(context, ref, selectedImages),

                    const Gap(30),

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
                    const Gap(15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "المنطقة المختارة".i18n,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const Gap(5),
                        ReactiveDropdownField<String>(
                          formControlName: 'region',
                          hint: Text('اختر المنطقة'.i18n),
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
                          items:
                              [
                                    "دمشق",
                                    "حمص",
                                    "حلب",
                                    "اللاذقية",
                                    "طرطوس",
                                    "حماة",
                                  ]
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e),
                                    ),
                                  )
                                  .toList(),
                        ),
                      ],
                    ),
                    Gap(15),
                    ReactiveTextInputWidget(
                      hint: 'تفاصيل وملاحظات'.i18n,
                      controllerName: 'details',
                      inputStyle: InputStyle.outlined,
                    ),

                    const Gap(25),

                    // --- أزرار العمليات ---
                    _buildActionButtons(context, ref, form, selectedImages),

                    const Gap(20),

                    // --- أزرار الانتقال ---
                    _buildNavigationButtons(context, isAdmin),
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

Widget _buildImageSection(
  BuildContext context,
  WidgetRef ref,
  List<File> images,
) {
  return Material(
    borderRadius: BorderRadius.circular(20),
    elevation: 4,
    color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
    child: Container(
      width: double.infinity,
      height: 280,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: images.isEmpty
          ? InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => ref
                  .read(photosServicesProvider)
                  .showImagePicker(context, ref),
              child: Column(
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
              ),
            )
          : Column(
              children: [
                // زر لإضافة المزيد من اللقطات يظهر فوق الصور
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    onPressed: () => ref
                        .read(photosServicesProvider)
                        .showImagePicker(context, ref),
                    icon: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      radius: 15,
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    itemCount: images.length,
                    itemBuilder: (context, index) => Stack(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(right: 15, bottom: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.file(
                              images[index],
                              width: 140, // عرض الصورة داخل القائمة
                              height: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        // زر حذف صورة معينة
                        Positioned(
                          top: 0,
                          right: 10,
                          child: GestureDetector(
                            onTap: () {
                              final list = [
                                ...ref.read(selectedImagesListProvider),
                              ];
                              list.removeAt(index);
                              ref
                                      .read(selectedImagesListProvider.notifier)
                                      .state =
                                  list;
                            },
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.cancel,
                                color: Colors.red,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // عداد الصور أسفل المربع
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    "${"عدد الصور الملتقطة".i18n}: ${images.length}",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
    ),
  );
}

// أزرار الحفظ وتسجيل الخروج
Widget _buildActionButtons(
  BuildContext context,
  WidgetRef ref,
  FormGroup form,
  List<File> images,
) {
  return Row(
    children: [
      Expanded(
        child: ButtonWidget(
          text: "إنشاء ملف pdf".i18n,
          onTap: () async => _handleUpload(context, ref, form, images),
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
Widget _buildNavigationButtons(BuildContext context, bool isAdmin) {
  return Column(
    children: [
      Row(
        children: [
          // Gap(15),
          Expanded(
            child: ButtonWidget(
              text: "عرض ملفات PDF".i18n,
              onTap: () => context.push('/all-documents'),
            ),
          ),
          Gap(15),
          if (isAdmin)
            Expanded(
              child: ButtonWidget(
                text: "لوحة تحكم المدير".i18n,
                onTap: () => context.push('/admin-dashboard'),
              ),
            ),
          // if (isAdmin) ...[
          //   const Gap(15),
          //   Expanded(
          //     child: ButtonWidget(
          //       text: "إضافة موظف جديد".i18n,
          //       onTap: () => context.push('/add-employee'),
          //     ),
          //   ),
          // ],
        ],
      ),
    ],
  );
}

// 3.  دالة _handleUpload لترسل المنطقة:
Future<void> _handleUpload(
  BuildContext context,
  WidgetRef ref,
  FormGroup form,
  List<File> images,
) async {
  if (images.isEmpty) {
    BotToast.showText(text: 'يرجى التقاط صورة واحدة على الأقل');
    return;
  }

  if (form.control('head').value == null) {
    BotToast.showText(text: 'يرجى إضافة عنوان الملف');
    return;
  }

  if (form.control('name').value == null) {
    BotToast.showText(text: 'يرجى اختيار الموظف المسؤول');
    return;
  }
  // التحقق من اختيار المنطقة
  if (form.control('region').value == null) {
    BotToast.showText(text: 'يرجى اختيار المنطقة أولاً');
    return;
  }

  try {
    BotToast.showLoading();

    await ref
        .read(photosServicesProvider)
        .generateAndUploadPdfFromFiles(
          imageFiles: images,
          region: form.control('region').value,
          docTitle:
              form.control('head').value ??
              "Document_${DateTime.now().millisecondsSinceEpoch}",
        );

    BotToast.showText(text: 'تم إنشاء ورفع ملف PDF بنجاح'.i18n);
    ref.read(selectedImagesListProvider.notifier).state = [];
    form.reset();
  } catch (e) {
    BotToast.showText(text: 'خطأ: $e');
  } finally {
    BotToast.closeAllLoading();
  }
}
