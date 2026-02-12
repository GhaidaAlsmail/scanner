import 'package:shared_preferences/shared_preferences.dart';

Future<String> getDynamicBaseUrl() async {
  //الرابط الرسمي الثابت (عند رفع السيرفر أونلاين)
  const String productionUrl = "https://your-real-domain.com/api";

  final prefs = await SharedPreferences.getInstance();
  String? savedIp = prefs.getString('server_ip');

  if (savedIp != null && savedIp.isNotEmpty) {
    return "http://$savedIp:3006/api";
  }

  return productionUrl;
}
