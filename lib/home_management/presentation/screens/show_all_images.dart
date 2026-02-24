// // ignore_for_file: curly_braces_in_flow_control_structures, deprecated_member_use

// import 'package:bot_toast/bot_toast.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:scanner/core/presentation/widgets/get_base_url.dart';
// import 'package:scanner/home_management/application/photos_service.dart';
// import '../../application/add_photos_provider.dart';

// class AllPhotosScreen extends ConsumerStatefulWidget {
//   const AllPhotosScreen({super.key});

//   @override
//   ConsumerState<AllPhotosScreen> createState() => _AllPhotosScreenState();
// }

// class _AllPhotosScreenState extends ConsumerState<AllPhotosScreen> {
//   // 1. قائمة لتخزين الروابط المختارة
//   final List<String> _selectedImageUrls = [];

//   @override
//   Widget build(BuildContext context) {
//     final photosAsync = ref.watch(allPhotosProvider);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('جميع الصور'),
//         actions: [
//           // زر إنشاء PDF يظهر فقط إذا تم اختيار صور
//           if (_selectedImageUrls.isNotEmpty)
//             IconButton(
//               icon: const Icon(Icons.picture_as_pdf, color: Colors.red),
//               onPressed: () async {
//                 final String? fileName = await _showFileNameDialog(context);

//                 if (fileName != null && fileName.isNotEmpty) {
//                   try {
//                     BotToast.showLoading(); // إظهار مؤشر تحميل

//                     await ref
//                         .read(photosServicesProvider)
//                         .generateAndUploadPdf(
//                           imageUrls: _selectedImageUrls,
//                           docTitle: fileName,
//                         );

//                     BotToast.closeAllLoading();
//                     // 2. رسالة نجاح عند اكتمال العملية
//                     BotToast.showText(
//                       text: " تم حفظ ورفع ملف PDF بنجاح",
//                       duration: const Duration(seconds: 3),
//                     );

//                     // إفراغ القائمة بعد النجاح
//                     setState(() => _selectedImageUrls.clear());
//                   } catch (e) {
//                     BotToast.closeAllLoading();
//                     BotToast.showText(text: " فشل إنشاء الملف: $e");
//                   }
//                 }
//               },
//             ),
//         ],
//       ),
//       body: photosAsync.when(
//         data: (photos) {
//           if (photos.isEmpty) {
//             return const Center(
//               child: Text(
//                 'لا يوجد صور حالياً',
//                 style: TextStyle(fontSize: 18, color: Colors.grey),
//               ),
//             );
//           }

//           return FutureBuilder<String>(
//             future: getDynamicBaseUrl(),
//             builder: (context, snapshot) {
//               if (!snapshot.hasData)
//                 return const Center(child: CircularProgressIndicator());

//               final String rawBaseUrl = snapshot.data!;
//               final String imageBaseUrl = rawBaseUrl.replaceAll('/api', '');

//               return GridView.builder(
//                 padding: const EdgeInsets.all(12),
//                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 2,
//                   crossAxisSpacing: 12,
//                   mainAxisSpacing: 12,
//                   childAspectRatio: 0.8,
//                 ),
//                 itemCount: photos.length,
//                 itemBuilder: (context, index) {
//                   final photo = photos[index];
//                   final fullImageUrl =
//                       "$imageBaseUrl${photo.profilePictureUrl}";

//                   // فحص هل الصورة مختارة حالياً
//                   final bool isSelected = _selectedImageUrls.contains(
//                     fullImageUrl,
//                   );

//                   return Card(
//                     elevation: isSelected ? 8 : 3,
//                     color: isSelected ? Colors.blue[50] : Colors.white,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(15),
//                       side: isSelected
//                           ? const BorderSide(color: Colors.blue, width: 2)
//                           : BorderSide.none,
//                     ),
//                     clipBehavior: Clip.antiAlias,
//                     child: Stack(
//                       children: [
//                         InkWell(
//                           onTap: () {
//                             // تبديل حالة الاختيار عند الضغط على الكارد
//                             setState(() {
//                               if (isSelected) {
//                                 _selectedImageUrls.remove(fullImageUrl);
//                               } else {
//                                 _selectedImageUrls.add(fullImageUrl);
//                               }
//                             });
//                           },
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.stretch,
//                             children: [
//                               Expanded(
//                                 child: Image.network(
//                                   fullImageUrl,
//                                   fit: BoxFit.cover,
//                                   errorBuilder: (ctx, error, stack) =>
//                                       const Icon(Icons.broken_image),
//                                 ),
//                               ),
//                               Padding(
//                                 padding: const EdgeInsets.all(8.0),
//                                 child: Text(
//                                   photo.title ?? 'بدون عنوان',
//                                   maxLines: 1,
//                                   textAlign: TextAlign.center,
//                                   style: const TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         // --- شيك بوكس الاختيار ---
//                         Positioned(
//                           top: 5,
//                           left: 5,
//                           child: Checkbox(
//                             value: isSelected,
//                             activeColor: Colors.blue,
//                             onChanged: (bool? value) {
//                               setState(() {
//                                 if (value == true) {
//                                   _selectedImageUrls.add(fullImageUrl);
//                                 } else {
//                                   _selectedImageUrls.remove(fullImageUrl);
//                                 }
//                               });
//                             },
//                           ),
//                         ),
//                         // --- زر الحذف الأصلي ---
//                         // Positioned(
//                         //   top: 5,
//                         //   right: 5,
//                         //   child: CircleAvatar(
//                         //     backgroundColor: Colors.white.withOpacity(0.8),
//                         //     radius: 18,
//                         //     child: IconButton(
//                         //       icon: const Icon(
//                         //         Icons.delete_forever,
//                         //         color: Colors.grey,
//                         //         size: 20,
//                         //       ),
//                         //       onPressed: () {
//                         //         final Map<String, dynamic> photoMap = photo
//                         //             .toJson();
//                         //         final String? actualId =
//                         //             photoMap['_id']?.toString() ??
//                         //             photoMap['id']?.toString();
//                         //         if (actualId != null) {
//                         //           _confirmDelete(context, ref, actualId);
//                         //         }
//                         //       },
//                         //     ),
//                         //   ),
//                         // ),
//                       ],
//                     ),
//                   );
//                 },
//               );
//             },
//           );
//         },
//         loading: () => const Center(child: CircularProgressIndicator()),
//         error: (err, stack) => Center(child: Text("خطأ: $err")),
//       ),
//     );
//   }
// }

// Future<String?> _showFileNameDialog(BuildContext context) async {
//   TextEditingController controller = TextEditingController();
//   return showDialog<String>(
//     context: context,
//     builder: (context) => AlertDialog(
//       title: const Text("حفظ الملف كمستند PDF"),
//       content: TextField(
//         controller: controller,
//         decoration: const InputDecoration(hintText: "أدخل اسم الملف هنا..."),
//       ),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.pop(context),
//           child: const Text("إلغاء"),
//         ),
//         TextButton(
//           onPressed: () => Navigator.pop(context, controller.text),
//           child: const Text("حفظ ورفع"),
//         ),
//       ],
//     ),
//   );
// }

// // Future<void> _confirmDelete(
// //   BuildContext context,
// //   WidgetRef ref,
// //   String photoId,
// // ) async {
// //   final bool? confirm = await showDialog<bool>(
// //     context: context,
// //     builder: (context) => AlertDialog(
// //       title: const Text("تأكيد الحذف"),
// //       content: const Text("هل أنت متأكد من رغبتك في حذف هذه الصورة نهائياً؟"),
// //       actions: [
// //         TextButton(
// //           onPressed: () => Navigator.pop(context, false),
// //           child: const Text("إلغاء"),
// //         ),
// //         TextButton(
// //           onPressed: () => Navigator.pop(context, true),
// //           style: TextButton.styleFrom(foregroundColor: Colors.red),
// //           child: const Text("حذف"),
// //         ),
// //       ],
// //     ),
// //   );

// //   if (confirm == true) {
// //     try {
// //       // استدعاء دالة الحذف من الـ Service
// //       await ref.read(photosServicesProvider).deletePhoto(photoId);

// //       // تحديث القائمة بعد الحذف
// //       ref.invalidate(allPhotosProvider);

// //       if (context.mounted) {
// //         ScaffoldMessenger.of(
// //           context,
// //         ).showSnackBar(const SnackBar(content: Text("تم حذف الصورة بنجاح")));
// //       }
// //     } catch (e) {
// //       if (context.mounted) {
// //         ScaffoldMessenger.of(
// //           context,
// //         ).showSnackBar(SnackBar(content: Text("فشل الحذف: $e")));
// //       }
// //     }
// //   }
// // }
