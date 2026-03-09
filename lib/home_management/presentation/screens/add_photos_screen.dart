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
import 'package:reactive_dropdown_search/reactive_dropdown_search.dart';

class AddPhotosScreen extends ConsumerWidget {
  const AddPhotosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(addNewsFormGroupProvider);
    final List<File> selectedImages = ref.watch(selectedImagesListProvider);
    final currentUser = ref.watch(authNotifierProvider);
    final bool isAdmin = currentUser?.isAdmin ?? false;
    final String userName = currentUser?.name ?? "مستخدم غير معروف";

    // --- (1) مراقبة نسبة التقدم ---
    final uploadProgress = ref.watch(uploadProgressProvider);

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
                    Text(
                      "${"مرحباً".i18n} $userName",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Gap(10),

                    // --- (2) عرض شريط التقدم هنا ---
                    _buildUploadProgressBar(uploadProgress),

                    _buildImageSection(context, ref, selectedImages),
                    const Gap(20),
                    areasAsyncValue.when(
                      data: (areasData) =>
                          _buildAreaSelectors(context, form, areasData),
                      loading: () => const CircularProgressIndicator(),
                      error: (err, _) => Text("خطأ في تحميل البيانات: $err"),
                    ),

                    const Gap(20),
                    Row(
                      children: [
                        Expanded(
                          child: ReactiveTextInputWidget(
                            hint: 'من'.i18n,
                            controllerName: 'headPart1',
                            inputStyle: InputStyle.outlined,
                          ),
                        ),
                        const Gap(10),
                        Expanded(
                          child: ReactiveTextInputWidget(
                            hint: 'إلى'.i18n,
                            controllerName: 'headPart2',
                            inputStyle: InputStyle.outlined,
                          ),
                        ),
                      ],
                    ),
                    const Gap(15),
                    ReactiveTextInputWidget(
                      hint: 'العنوان'.i18n,
                      controllerName: 'head',
                      inputStyle: InputStyle.outlined,
                    ),

                    const Gap(15),
                    _buildActionButtons(context, ref, form, selectedImages),
                    const Gap(15),
                    _buildNavigationButtons(context, isAdmin),
                    const Gap(5),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- دالة بناء شريط التقدم المخصصة ---
  Widget _buildUploadProgressBar(int progress) {
    if (progress <= 0 || progress >= 100) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress / 100,
              minHeight: 12,
              backgroundColor: Colors.grey[300],
              color: const Color.fromARGB(255, 26, 102, 29),
            ),
          ),
          const Gap(5),
          Text(
            "جاري الرفع الآن: $progress%",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
          const Gap(10),
        ],
      ),
    );
  }

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
        ReactiveDropdownSearch<String, String>(
          formControlName: 'mainCategory',
          items: (filter, props) => areasData.keys.toList(),
          itemAsString: (key) => areasData[key]['label']?.toString() ?? key,
          dropdownDecoratorProps: DropDownDecoratorProps(
            decoration: _inputDecoration(
              context,
            ).copyWith(hintText: 'اختر التصنيف'.i18n),
          ),
          popupProps: PopupProps.menu(
            showSearchBox: true,
            searchFieldProps: TextFieldProps(
              decoration: InputDecoration(
                hintText: "بحث عن تصنيف...".i18n,
                border: const OutlineInputBorder(),
              ),
            ),
          ),
        ),
        const Gap(15),
        ReactiveValueListenableBuilder<String>(
          formControlName: 'mainCategory',
          builder: (context, control, child) {
            if (control.dirty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                form.control('subArea').reset();
                form.control('id').reset();
              });
            }

            final String? selectedKey = control.value;
            List<dynamic> subAreas = [];
            if (selectedKey != null && areasData.containsKey(selectedKey)) {
              subAreas = areasData[selectedKey]['subAreas'] ?? [];
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
                ReactiveDropdownSearch<String, String>(
                  formControlName: 'subArea',
                  items: (filter, props) =>
                      subAreas.map((area) => area['name'].toString()).toList(),
                  dropdownDecoratorProps: DropDownDecoratorProps(
                    decoration: _inputDecoration(
                      context,
                    ).copyWith(hintText: 'اختر المنطقة'.i18n),
                  ),
                  popupProps: PopupProps.menu(
                    showSearchBox: true,
                    itemBuilder: (context, item, isSelected, isHighlighted) {
                      final areaObj = subAreas.firstWhere(
                        (e) => e['name'].toString() == item,
                        orElse: () => null,
                      );
                      return ListTile(
                        selected: isSelected,
                        title: Text(item),
                        trailing: Text(
                          areaObj != null ? areaObj['id'].toString() : "",
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                ReactiveValueListenableBuilder<String>(
                  formControlName: 'subArea',
                  builder: (context, subControl, child) {
                    final subVal = subControl.value;
                    if (subVal != null && subControl.dirty) {
                      final selectedAreaObject = subAreas.firstWhere(
                        (element) => element['name'].toString() == subVal,
                        orElse: () => null,
                      );
                      if (selectedAreaObject != null) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          form
                              .control('id')
                              .patchValue(selectedAreaObject['id'].toString());
                        });
                      }
                    }
                    return const SizedBox.shrink();
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
}

// الـ Widgets الخارجية (Section, ActionButtons, Navigation) تبقى كما هي مع التأكد من استدعاء _handleUpload بشكل صحيح

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
                              width: 140,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
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

Widget _buildNavigationButtons(BuildContext context, bool isAdmin) {
  return Column(
    children: [
      Row(
        children: [
          if (!isAdmin)
            Expanded(
              child: ButtonWidget(
                text: "عرض ملفات PDF".i18n,
                onTap: () => context.push('/all-documents'),
              ),
            ),
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

// دالة الرفع المعدلة لاستخدام الخدمة المحدثة
Future<void> _handleUpload(
  BuildContext context,
  WidgetRef ref,
  FormGroup form,
  List<File> images,
) async {
  // التحقق من الحقول الأساسية
  final String mainTitle = form.control('head').value?.toString().trim() ?? "";
  final String fromPart =
      form.control('headPart1').value?.toString().trim() ?? "";
  final String toPart =
      form.control('headPart2').value?.toString().trim() ?? "";

  if (mainTitle.isEmpty ||
      fromPart.isEmpty ||
      toPart.isEmpty ||
      images.isEmpty) {
    BotToast.showText(text: 'يرجى إكمال البيانات والتقاط الصور'.i18n);
    return;
  }

  final String combinedFullTitle = "$mainTitle ($fromPart - $toPart)";

  try {
    String mainLabel = form.control('mainCategory').value == 'city'
        ? "حمص - المدينة"
        : "ريف حمص";

    // استدعاء دالة الرفع من الخدمة (التي ستقوم بتحديث النسبة المئوية تلقائياً)
    await ref
        .read(photosServicesProvider)
        .uploadImagesAsList(
          imageFiles: images,
          region: mainLabel,
          subArea: form.control('subArea').value,
          docTitle: combinedFullTitle,
          id: form.control('id').value.toString(),
        );

    // تصفير الواجهة بعد النجاح
    ref.read(selectedImagesListProvider.notifier).state = [];
    form.reset();
  } catch (e) {
    debugPrint("Upload Error: $e");
    // الخطأ يتم معالجته داخل الخدمة عبر BotToast، ولكن يمكن إضافة معالجة هنا إذا أردتِ
  }
}
