import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart' show GoRouterHelper;
import 'package:news_watch/core/presentation/widgets/reactive_text_input_widget.dart';
import 'package:news_watch/translation.dart';
import 'package:reactive_forms/reactive_forms.dart';
// import '../../../auth/application/auth_notifier_provider.dart';
import '../../../core/presentation/widgets/button_widget.dart';
import '../../application/add_photos_provider.dart';

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
                Material(
                  borderRadius: BorderRadius.circular(15),
                  color: Theme.of(context).colorScheme.onInverseSurface,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(15),
                    onTap: () async {
                      // ref
                      //     .read(photosServicesProvider)
                      //     .showImagePicker(context, ref);
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
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.outlineVariant,
                                ),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              height: 200,
                              child: Image.file(image, fit: BoxFit.contain),
                            ),
                          ),
                  ),
                ),
                Gap(35),
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
                Row(
                  children: [
                    Gap(35),
                    ButtonWidget(
                      text: "add photo".i18n,
                      onTap: () async {
                        final form = ref.read(addNewsFormGroupProvider);

                        //  تحقق من صحة الفورم
                        // if (!form.valid) {
                        //   form.markAllAsTouched();
                        //   BotToast.showText(
                        //     text: 'Please fill all required fields'.i18n,
                        //   );
                        //   return;
                        // }

                        //  تحقق من وجود صورة
                        final image = ref.read(imgFileProvider);
                        if (image == null) {
                          BotToast.showText(
                            text: 'Please select an image'.i18n,
                          );
                          return;
                        }

                        //  إنشاء وتخزين الصورة
                        // await ref
                        //     .read(photosServicesProvider)
                        //     .createPhoto(form: form);
                        // الكود الجديد (Supabase)
                        // await ref.read(supabasePhotosNotifierProvider.notifier).uploadAndSavePhoto(form: form);
                        // reset
                        form.reset();
                        ref.read(imgFileProvider.notifier).state = null;
                      },
                    ),

                    Gap(70),
                    ButtonWidget(
                      text: "sign out ".i18n,
                      onTap: () {
                        // ref.read(authNotifierProvider.notifier).logOut();
                      },
                    ),
                  ],
                ),
                Gap(35),
                ButtonWidget(
                  text: "show all images".i18n,
                  onTap: () {
                    context.push('/all-photos');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
