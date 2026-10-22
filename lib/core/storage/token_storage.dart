import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const _tokenKey = 'auth_token';
  static const _userKey = 'auth_user';
  static const _onboardingKey = 'onboarding_seen';
  static const _rememberKey = 'remember_me';
  static const _emailKey = 'remembered_email';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<void> saveToken(String token) async {
    final p = await _prefs;
    await p.setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    final p = await _prefs;
    return p.getString(_tokenKey);
  }

  Future<void> saveUser(Map<String, dynamic> user) async {
    final p = await _prefs;
    await p.setString(_userKey, jsonEncode(user));
  }

  Future<Map<String, dynamic>?> getUser() async {
    final p = await _prefs;
    final raw = p.getString(_userKey);
    if (raw == null || raw.isEmpty) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> setOnboardingSeen(bool seen) async {
    final p = await _prefs;
    await p.setBool(_onboardingKey, seen);
  }

  Future<bool> isOnboardingSeen() async {
    final p = await _prefs;
    return p.getBool(_onboardingKey) ?? false;
  }

  Future<void> setRememberMe(bool value, {String? email}) async {
    final p = await _prefs;
    await p.setBool(_rememberKey, value);
    if (value && email != null) {
      await p.setString(_emailKey, email);
    } else if (!value) {
      await p.remove(_emailKey);
    }
  }

  Future<bool> getRememberMe() async {
    final p = await _prefs;
    return p.getBool(_rememberKey) ?? false;
  }

  Future<String?> getRememberedEmail() async {
    final p = await _prefs;
    return p.getString(_emailKey);
  }

  Future<void> clearSession() async {
    final p = await _prefs;
    await p.remove(_tokenKey);
    await p.remove(_userKey);
  }
}
