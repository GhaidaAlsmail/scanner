// import 'package:bot_toast/bot_toast.dart';
// import 'package:http/http.dart' as ref;
// import 'package:reactive_forms/reactive_forms.dart';
// import 'package:riverpod_annotation/riverpod_annotation.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// import '../../core/presentation/widgets/rich_text_widget.dart';

// @riverpod
// class SupabasePhotosNotifier extends _$SupabasePhotosNotifier {
//   @override
//   void build() {}

//   Future<void> uploadAndSavePhoto({required FormGroup form}) async {
//     try {
//       BotToast.showLoading();
      
//       final client = Supabase.instance.client;
//       final imageFile = ref.read(imgFileProvider);
      
//       String? imageUrl;

//       if (imageFile != null) {
//         // 1. رفع الصورة إلى Supabase Storage
//         final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
//         final path = 'photos/$fileName';
        
//         await client.storage.from('photos').upload(path, imageFile);
        
//         // 2. الحصول على الرابط العام
//         imageUrl = client.storage.from('photos').getPublicUrl(path);
//       }

//       // 3. حفظ البيانات في جدول قاعدة البيانات (Database)
//       await client.from('photos').insert({
//         'title': form.control('head').value,
//         'image_url': imageUrl,
//         'category': form.control('category').value,
//         'user_id': client.auth.currentUser?.id,
//         'details': ref.read(richTextProvider).document.toDelta().toJson().toString(),
//       });

//       BotToast.showText(text: "تم الرفع بنجاح ✅");
//     } catch (e) {
//       BotToast.showText(text: "خطأ: ${e.toString()}");
//     } finally {
//       BotToast.closeAllLoading();
//     }
//   }
// }