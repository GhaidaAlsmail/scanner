import 'package:i18n_extension/i18n_extension.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

// class MyI18n {
//   static Translations translations = Translations.byLocale("en");

//   // static Future<void> loadTranslations() async {
//   //   translations += await JSONImporter().fromAssetDirectory(
//   //     'assets/translations',
//   //   );
//   // }
//   static Future<void> loadTranslations() async {
//     final arJson = await rootBundle.loadString("assets/translations/ar.json");
//     // final enJson = await rootBundle.loadString("assets/translation/en.json");

//     final Map<String, dynamic> arMap = jsonDecode(arJson);
//     // final Map<String, dynamic> enMap = jsonDecode(enJson);

//     // تحويل إلى Map<String, String>
//     final arStrings = arMap.map(
//       (key, value) => MapEntry(key, value.toString()),
//     );
//     // final enStrings = enMap.map(
//     //   (key, value) => MapEntry(key, value.toString()),
//     // );

//     // دمج الترجمة الإنجليزية
//     // translations += {"en": enStrings};

//     // دمج الترجمة العربية
//     translations += {"ar": arStrings};
//   }
// }
class MyI18n {
  static Translations translations = Translations.byLocale("en");

  static Future<void> loadTranslations() async {
    final enJson = await rootBundle.loadString("assets/translations/en.json");
    final arJson = await rootBundle.loadString("assets/translations/ar.json");

    final Map<String, dynamic> enMap = jsonDecode(enJson);
    final Map<String, dynamic> arMap = jsonDecode(arJson);

    translations += {
      "en": enMap.map((k, v) => MapEntry(k, v.toString())),
      "ar": arMap.map((k, v) => MapEntry(k, v.toString())),
    };
  }
}

extension Localization on String {
  String get i18n => localize(this, MyI18n.translations);
  String fill(List<Object> params) => localizeFill(this, params);
  String plural(value) => localizePlural(value, this, MyI18n.translations);
}
