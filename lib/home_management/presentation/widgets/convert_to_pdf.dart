// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:pdf/pdf.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:dio/dio.dart';
// import 'package:printing/printing.dart';

// Future<void> createPdfFromImages(List<String> imageUrls) async {
//   final pdf = pw.Document();
//   final dio = Dio();

//   try {
//     for (var url in imageUrls) {
//       // 1. تحميل الصورة كـ Bytes
//       final response = await dio.get(
//         url,
//         options: Options(responseType: ResponseType.bytes),
//       );

//       final image = pw.MemoryImage(response.data);

//       // 2. إضافة صفحة لكل صورة في ملف الـ PDF
//       pdf.addPage(
//         pw.Page(
//           build: (pw.Context context) {
//             return pw.Center(child: pw.Image(image, fit: pw.BoxFit.contain));
//           },
//         ),
//       );
//     }

//     // 3. حفظ الملف أو عرضه للطباعة والمشاركة
//     // خيار أ: عرض الشاشة المخصصة للطباعة والمشاركة (أسهل للمستخدم)
//     await Printing.layoutPdf(
//       onLayout: (PdfPageFormat format) async => pdf.save(),
//       name: 'Scanner_Document.pdf',
//     );

//     // خيار ب: حفظ الملف في ذاكرة الهاتف مباشرة
//     final output = await getExternalStorageDirectory();
//     final file = File("${output!.path}/scanner_document.pdf");
//     await file.writeAsBytes(await pdf.save());
//   } catch (e) {
//     debugPrint("Error creating PDF: $e");
//   }
// }
