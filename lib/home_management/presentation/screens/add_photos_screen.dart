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

    // جلب بيانات المناطق
    final areasAsyncValue = ref.watch(areasDataProvider);

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
              color: Colors.white.withOpacity(0.4),
              colorBlendMode: BlendMode.modulate,
            ),
          ),
          SafeArea(
            child: ReactiveForm(
              formGroup: form,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // const Gap(30),
                    _buildImageSection(context, ref, selectedImages),
                    const Gap(20),

                    ReactiveTextInputWidget(
                      hint: 'العنوان'.i18n,
                      controllerName: 'head',
                      inputStyle: InputStyle.outlined,
                    ),
                    const Gap(5),

                    // --- قسم الموظف المسؤول ---
                    _buildEmployeeDropdown(context, userName),

                    // const Gap(5),
                    areasAsyncValue.when(
                      data: (areasData) =>
                          _buildAreaSelectors(context, form, areasData),
                      loading: () => const CircularProgressIndicator(),
                      error: (err, _) => Text("خطأ في تحميل البيانات: $err"),
                    ),

                    const Gap(15),
                    ReactiveTextInputWidget(
                      hint: 'تفاصيل وملاحظات'.i18n,
                      controllerName: 'details',
                      inputStyle: InputStyle.outlined,
                    ),
                    const Gap(15),
                    _buildActionButtons(context, ref, form, selectedImages),
                    const Gap(15),
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

  // دالة بناء المربعات المنسدلة للمناطق
  Widget _buildAreaSelectors(
    BuildContext context,
    FormGroup form,
    Map<String, dynamic> areasData,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "التصنيف الرئيسي".i18n,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const Gap(5),
        ReactiveDropdownField<String>(
          formControlName: 'mainCategory',
          hint: Text('اختر التصنيف'.i18n),
          decoration: _inputDecoration(context),
          items: areasData.keys.map((key) {
            return DropdownMenuItem<String>(
              value: key,
              child: Text(areasData[key]['label']),
            );
          }).toList(),
          onChanged: (control) => form.control('subArea').reset(),
        ),
        const Gap(15),
        ReactiveValueListenableBuilder<String>(
          formControlName: 'mainCategory',
          builder: (context, control, child) {
            final String? selectedKey = control.value;
            List<dynamic> subAreas = [];
            if (selectedKey != null && areasData.containsKey(selectedKey)) {
              subAreas = areasData[selectedKey]['subAreas'];
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "المنطقة الفرعية".i18n,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const Gap(5),
                ReactiveDropdownField<String>(
                  formControlName: 'subArea',
                  hint: Text('اختر المنطقة'.i18n),
                  decoration: _inputDecoration(context),
                  items: subAreas.map((area) {
                    return DropdownMenuItem<String>(
                      value: area['name'].toString(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(area['name']),
                          Text(
                            " - ${area['id'] ?? 'N/A'}", // عرض الرقم
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.6),
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (control) {
                    // 1. نبحث عن كائن المنطقة الذي يطابق الاسم المختار
                    final selectedAreaObject = subAreas.firstWhere(
                      (element) => element['name'] == control.value,
                      orElse: () => null,
                    );

                    // 2. إذا وجدناه، نقوم بتحديث حقل 'id' في الفورم بقيمة الـ id الحقيقية
                    if (selectedAreaObject != null) {
                      form
                          .control('id')
                          .patchValue(selectedAreaObject['id'].toString());
                      debugPrint(
                        "تم تحديث معرف المنطقة ليكون: ${selectedAreaObject['id']}",
                      );
                    }
                  },
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(BuildContext context) {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      filled: true,
      fillColor: Theme.of(context).colorScheme.outlineVariant.withAlpha(22),
    );
  }

  Widget _buildEmployeeDropdown(BuildContext context, String userName) {
    return Column(
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
          decoration: _inputDecoration(context),
          items: [DropdownMenuItem(value: userName, child: Text(userName))],
        ),
      ],
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
          if (!isAdmin)
            Expanded(
              child: ButtonWidget(
                text: "عرض ملفات PDF".i18n,
                onTap: () => context.push('/all-documents'),
              ),
            ),
          // Gap(15),
          if (isAdmin)
            Expanded(
              child: ButtonWidget(
                text: "لوحة تحكم المدير".i18n,
                onTap: () => context.push('/admin-dashboard'),
              ),
            ),
        ],
      ),
    ],
  );
}

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

  if (form.control('mainCategory').value == null ||
      form.control('subArea').value == null) {
    BotToast.showText(text: 'يرجى اختيار التصنيف والمنطقة');
    return;
  }

  try {
    BotToast.showLoading();

    String mainLabel = form.control('mainCategory').value == 'city'
        ? "حمص - المدينة"
        : "ريف حمص";

    await ref
        .read(photosServicesProvider)
        .generateAndUploadPdfFromFiles(
          imageFiles: images,
          region: mainLabel,
          subArea: form.control('subArea').value,
          docTitle:
              form.control('head').value ??
              "Document_${DateTime.now().millisecondsSinceEpoch}",
          id: form.control('id').value,
        );
    print("Sending ID: ${form.control('id').value}");
    BotToast.showText(text: 'تم إنشاء ورفع ملف PDF بنجاح'.i18n);
    ref.read(selectedImagesListProvider.notifier).state = [];
    form.reset();
  } catch (e) {
    BotToast.showText(text: 'خطأ: $e');
  } finally {
    BotToast.closeAllLoading();
  }
}
