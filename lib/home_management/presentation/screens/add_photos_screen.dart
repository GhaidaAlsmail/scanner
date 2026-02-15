import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart' show GoRouterHelper;
import 'package:news_watch/auth/application/auth_notifier_provider.dart';
import 'package:news_watch/core/presentation/widgets/reactive_text_input_widget.dart';
import 'package:news_watch/translation.dart';
import 'package:reactive_forms/reactive_forms.dart';
import '../../../auth/application/auth_service.dart';
import '../../../core/presentation/widgets/button_widget.dart';
import '../../application/add_photos_provider.dart';
import '../../application/photos_service.dart';

class AddPhotosScreen extends ConsumerWidget {
  const AddPhotosScreen({super.key});

  @override
  Widget build(BuildContext context, ref) {
    var form = ref.watch(addNewsFormGroupProvider);
    var image = ref.watch(imgFileProvider);

    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("Add Photo".i18n)),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: ReactiveForm(
        formGroup: form,
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                Gap(50),
                // --- قسم التقاط الصورة ---
                Material(
                  borderRadius: BorderRadius.circular(15),
                  color: Theme.of(context).colorScheme.onInverseSurface,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(15),
                    onTap: () async {
                      // استدعاء الملقط مع تمرير ref
                      await ref
                          .read(photosServicesProvider)
                          .showImagePicker(context, ref);
                    },
                    child: image == null
                        ? Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Theme.of(
                                  context,
                                ).colorScheme.outlineVariant,
                              ),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            height: 200,
                            child: const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add, size: 40),
                                  Text("Add Images"),
                                ],
                              ),
                            ),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Container(
                              width: double.infinity,
                              height: 200,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.outlineVariant,
                                ),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Image.file(image, fit: BoxFit.contain),
                            ),
                          ),
                  ),
                ),
                Gap(35),
                // --- الحقول النصية ---
                ReactiveTextInputWidget(
                  hint: 'العنوان',
                  controllerName: 'head',
                  inputStyle: InputStyle.outlined,
                ),
                Gap(35),
                ReactiveTextInputWidget(
                  hint: 'اسم الموظف',
                  controllerName: 'name',
                  inputStyle: InputStyle.outlined,
                ),
                Gap(35),
                ReactiveTextInputWidget(
                  hint: 'تفاصيل وملاحظات',
                  controllerName: 'details',
                  inputStyle: InputStyle.outlined,
                ),
                Gap(35),
                // --- الأزرار ---
                Row(
                  children: [
                    Expanded(
                      child: ButtonWidget(
                        text: "add photo".i18n,
                        onTap: () async {
                          // 1. التحقق من صلاحية الفورم والصورة
                          if (form.invalid) {
                            form.markAllAsTouched();
                            return;
                          }

                          if (image == null) {
                            BotToast.showText(
                              text: 'Please select an image'.i18n,
                            );
                            return;
                          }

                          try {
                            BotToast.showLoading();

                            // 2. إرسال الطلب للسيرفر
                            await ref
                                .read(photosServicesProvider)
                                .createPhoto(
                                  head: form.control('head').value,
                                  name: form.control('name').value,
                                  details: form.control('details').value,
                                  imageFile: image,
                                );

                            // 3. التحقق من أن الشاشة لا تزال موجودة قبل التحديث
                            if (context.mounted) {
                              BotToast.showText(
                                text: 'Saved Successfully!'.i18n,
                              );

                              // تحديث قائمة الصور فوراً
                              ref.invalidate(allPhotosProvider);

                              // تنظيف البيانات
                              form.reset();
                              ref.read(imgFileProvider.notifier).state = null;
                            }
                          } catch (e) {
                            // إذا كان الخطأ بسبب التوكن، سيظهر هنا بوضوح بدل تسجيل الخروج الصامت
                            debugPrint("Upload Error: $e");
                            BotToast.showText(text: 'Error: ${e.toString()}');
                          } finally {
                            BotToast.closeAllLoading();
                          }
                        },
                      ),
                    ),
                    const Gap(15),
                    Expanded(
                      child: ButtonWidget(
                        text: "sign out ".i18n,
                        onTap: () {
                          ref.read(authNotifierProvider.notifier).logout();
                        },
                      ),
                    ),
                  ],
                ),
                Gap(35),
                ButtonWidget(
                  text: "show all images".i18n,
                  onTap: () => context.push('/all-photos'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
