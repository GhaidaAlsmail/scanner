// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_watch/core/presentation/widgets/get_base_url.dart';
import 'package:news_watch/home_management/application/photos_service.dart';
import '../../application/add_photos_provider.dart';
import '../widgets/convert_to_pdf.dart';

class AllPhotosScreen extends ConsumerWidget {
  const AllPhotosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photosAsync = ref.watch(allPhotosProvider);

    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('All Photos'),
      //   actions: [
      //     photosAsync.maybeWhen(
      //       data: (photosList) => IconButton(
      //         icon: const Icon(Icons.picture_as_pdf),
      //         onPressed: () async {
      //           if (photosList.isNotEmpty) {
      //             final rawBaseUrl = await getDynamicBaseUrl();
      //             final imageBaseUrl = rawBaseUrl.replaceAll('/api', '');

      //             final List<String> urls = photosList.map((p) {
      //               return "$imageBaseUrl${p.profilePictureUrl}";
      //             }).toList();

      //             createPdfFromImages(urls);
      //           } else {
      //             ScaffoldMessenger.of(context).showSnackBar(
      //               const SnackBar(content: Text("لا توجد صور لتحويلها")),
      //             );
      //           }
      //         },
      //       ),
      //       orElse: () =>
      //           const SizedBox.shrink(), // لا يظهر الزر في حالة التحميل أو الخطأ
      //     ),
      //   ],
      //   centerTitle: true,
      // ),
      appBar: AppBar(
        title: const Text('All Photos'),
        actions: [
          photosAsync.maybeWhen(
            data: (photosList) => IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              // onPressed: () async {
              //   final rawBaseUrl = await getDynamicBaseUrl();
              //   final imageBaseUrl = rawBaseUrl.replaceAll('/api', '');

              //   final List<String> urls = photosList
              //       .map((p) => "$imageBaseUrl${p.profilePictureUrl}")
              //       .toList();

              //   await ref
              //       .read(photosServicesProvider)
              //       .generateAndUploadPdf(
              //         imageUrls: urls,
              //         docTitle:
              //             "My_Document_${DateTime.now().millisecondsSinceEpoch}",
              //       );
              // },
              onPressed: () async {
                if (photosList.isNotEmpty) {
                  // أ- اطلب الاسم من المستخدم أولاً
                  final String? fileName = await _showFileNameDialog(context);

                  // ب- إذا لم يغلق النافذة وأدخل اسماً
                  if (fileName != null && fileName.isNotEmpty) {
                    final rawBaseUrl = await getDynamicBaseUrl();
                    final imageBaseUrl = rawBaseUrl.replaceAll('/api', '');

                    final List<String> urls = photosList.map((p) {
                      return "$imageBaseUrl${p.profilePictureUrl}";
                    }).toList();

                    // ج- استدعاء الدالة مع الاسم الذي اختاره المستخدم
                    await ref
                        .read(photosServicesProvider)
                        .generateAndUploadPdf(
                          imageUrls: urls,
                          docTitle: fileName, // هنا نمرر الاسم المختار
                        );
                  }
                }
              },
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: photosAsync.when(
        data: (photos) {
          if (photos.isEmpty) {
            return const Center(
              child: Text(
                'لا يوجد صور حالياً',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          //  1. يفضل جلب الـ BaseUrl مرة واحدة خارج الـ Builder للأداء
          return FutureBuilder<String>(
            future: getDynamicBaseUrl(),
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return const Center(child: CircularProgressIndicator());

              // final baseUrl = snapshot.data!;

              return GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.8,
                ),
                itemCount: photos.length,
                itemBuilder: (context, index) {
                  final photo = photos[index];
                  final String rawBaseUrl = snapshot.data!;
                  final String imageBaseUrl = rawBaseUrl.replaceAll('/api', '');

                  final fullImageUrl =
                      "$imageBaseUrl${photo.profilePictureUrl}";

                  debugPrint("📸 Final Image URL: $fullImageUrl");
                  // داخل itemBuilder في GridView.builder
                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      // استخدمنا Stack لوضع زر الحذف فوق الصورة
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: Image.network(
                                fullImageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (ctx, error, stack) => Container(
                                  color: Colors.grey[200],
                                  child: const Icon(
                                    Icons.broken_image,
                                    size: 40,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                photo.title ?? 'بدون عنوان',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        // --- زر الحذف في الزاوية ---
                        Positioned(
                          top: 5,
                          right: 5,
                          child: CircleAvatar(
                            backgroundColor: Colors.white.withOpacity(0.8),
                            radius: 18,
                            child: IconButton(
                              icon: const Icon(
                                Icons.delete_forever,
                                color: Colors.grey,
                                size: 20,
                              ),
                              // ابحثي عن زر الحذف وغيري سطر الـ onPressed
                              onPressed: () {
                                // استخراج البيانات كماب (Map)
                                final Map<String, dynamic> photoMap = photo
                                    .toJson();

                                // MongoDB يرسل المعرف دائماً باسم _id
                                // سنحاول جلبه من _id أولاً، وإذا لم يوجد نجرب id
                                final String? actualId =
                                    photoMap['_id']?.toString() ??
                                    photoMap['id']?.toString();

                                debugPrint(
                                  "🔍 الموديل يحتوي على ID: $actualId",
                                );

                                if (actualId != null && actualId != "null") {
                                  _confirmDelete(context, ref, actualId);
                                } else {
                                  BotToast.showText(
                                    text:
                                        "خطأ: لم يتم العثور على معرف الصورة في البيانات",
                                  );
                                  debugPrint(
                                    "البيانات الكاملة للصورة: $photoMap",
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                  // return Card(
                  //   elevation: 3,
                  //   shape: RoundedRectangleBorder(
                  //     borderRadius: BorderRadius.circular(15),
                  //   ),
                  //   clipBehavior: Clip.antiAlias,
                  //   child: Column(
                  //     crossAxisAlignment: CrossAxisAlignment.stretch,
                  //     children: [
                  //       Expanded(
                  //         child: Image.network(
                  //           fullImageUrl,
                  //           fit: BoxFit.cover,
                  //           errorBuilder: (ctx, error, stack) {
                  //             return Container(
                  //               color: Colors.grey[200],
                  //               child: const Column(
                  //                 mainAxisAlignment: MainAxisAlignment.center,
                  //                 children: [
                  //                   Icon(
                  //                     Icons.broken_image,
                  //                     size: 40,
                  //                     color: Colors.grey,
                  //                   ),
                  //                   Text(
                  //                     "404",
                  //                     style: TextStyle(color: Colors.grey),
                  //                   ),
                  //                 ],
                  //               ),
                  //             );
                  //           },
                  //         ),
                  //       ),
                  //       Padding(
                  //         padding: const EdgeInsets.all(8.0),
                  //         child: Text(
                  //           photo.title ?? 'بدون عنوان',
                  //           maxLines: 1,
                  //           overflow: TextOverflow.ellipsis,
                  //           textAlign: TextAlign.center,
                  //           style: const TextStyle(fontWeight: FontWeight.bold),
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // );
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("خطأ: $err")),
      ),
    );
  }
}

// نضع هذه الدالة في شاشة العرض (UI) وليس في الـ Service
Future<String?> _showFileNameDialog(BuildContext context) async {
  TextEditingController controller = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("حفظ الملف كمستند PDF"),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(hintText: "أدخل اسم الملف هنا..."),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("إلغاء"),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, controller.text),
          child: const Text("حفظ ورفع"),
        ),
      ],
    ),
  );
}

Future<void> _confirmDelete(
  BuildContext context,
  WidgetRef ref,
  String photoId,
) async {
  final bool? confirm = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("تأكيد الحذف"),
      content: const Text("هل أنت متأكد من رغبتك في حذف هذه الصورة نهائياً؟"),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text("إلغاء"),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text("حذف"),
        ),
      ],
    ),
  );

  if (confirm == true) {
    try {
      // استدعاء دالة الحذف من الـ Service
      await ref.read(photosServicesProvider).deletePhoto(photoId);

      // تحديث القائمة بعد الحذف
      ref.invalidate(allPhotosProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("تم حذف الصورة بنجاح")));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("فشل الحذف: $e")));
      }
    }
  }
}
