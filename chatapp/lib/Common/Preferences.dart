import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  static void setAuthToken({required String token}) async {
    final SharedPreferences local = await SharedPreferences.getInstance();
    local.setString('token', token);
  }

  static Future<String> getAuthToken() async {
    final SharedPreferences local = await SharedPreferences.getInstance();
    String? token = local.getString('token');
    if (token == null) throw Error();
    return token;
  }

  static Future<void> deleteAuthToken() async {
    final SharedPreferences local = await SharedPreferences.getInstance();
    local.remove("token");
  }
}
