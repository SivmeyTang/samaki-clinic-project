import 'dart:convert';
import 'package:samaki_clinic/BackEnd/Model/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserSession {
  static const String _userKey = 'currentUser';

  UserSession._internal();
  static final UserSession _instance = UserSession._internal();
  factory UserSession() => _instance;

  UserModel? _currentUser;

  UserModel? get user => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  Future<void> setUser(UserModel user) async {
    _currentUser = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  Future<void> clearSession() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  Future<bool> loadUserFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userJson = prefs.getString(_userKey);

    if (userJson != null) {
      try {
        _currentUser = UserModel.fromJson(jsonDecode(userJson));
        return true;
      } catch (_) {
        await clearSession();
        return false;
      }
    }
    return false;
  }
}
