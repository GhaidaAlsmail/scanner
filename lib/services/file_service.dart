// import 'dart:io';
// import 'package:dio/dio.dart';

// class FileService {
//   final Dio _dio = Dio();
//   // الـ IP الجديد الخاص بسيرفر الملفات
//   final String _baseUrl = "http://122.124.4.16:8080/apiproject/api.php";

//   Future<void> uploadUserFile(File file, String userId) async {
//     String fileName = file.path.split('/').last;

//     // تحضير البيانات بصيغة FormData لأنها تحتوي على ملف
//     FormData formData = FormData.fromMap({
//       "path": await MultipartFile.fromFile(file.path, filename: fileName),
//       "details": "Uploaded by user ID: $userId",
//     });

//     try {
//       final response = await _dio.post(
//         _baseUrl,
//         queryParameters: {
//           "action": "upload_file",
//         }, // هذا هو الأكشن المطلوب في الـ PHP
//         data: formData,
//         options: Options(headers: {"Accept": "application/json"}),
//       );

//       if (response.data['status'] == "1") {
//         print("Success: ${response.data['message']}");
//       } else {
//         print("Server Error: ${response.data['message']}");
//       }
//     } catch (e) {
//       print("Connection Error: $e");
//     }
//   }
// }
