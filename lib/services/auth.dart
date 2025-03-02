import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String KEY_EMAIL = 'email';
  static const String KEY_IS_LOGGED_IN = 'isLoggedIn';

  static Future<void> saveUserLogin(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(KEY_IS_LOGGED_IN, true);
    await prefs.setString(KEY_EMAIL, email);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(KEY_IS_LOGGED_IN) ?? false;
  }

  static Future<String?> getLoggedInUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(KEY_EMAIL);
  }
}
