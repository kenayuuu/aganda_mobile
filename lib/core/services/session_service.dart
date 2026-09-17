import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const String tokenKey = 'token';
  static const String userIdKey = 'user_id';
  static const String nameKey = 'name';
  static const String emailKey = 'email';
  static const String roleKey = 'role';
  static const String memberIdKey = 'member_id';

  Future<void> saveSession({
    required String token,
    required int userId,
    required String name,
    required String email,
    required String role,
    String? memberId,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(tokenKey, token);
    await prefs.setInt(userIdKey, userId);
    await prefs.setString(nameKey, name);
    await prefs.setString(emailKey, email);
    await prefs.setString(roleKey, role);

    if (memberId != null) {
      await prefs.setString(memberIdKey, memberId);
    } else {
      await prefs.remove(memberIdKey);
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(roleKey);
  }

  Future<String?> getName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(nameKey);
  }

  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(userIdKey);
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}