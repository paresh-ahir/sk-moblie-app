import 'package:flutter/foundation.dart';
import 'package:saleskido/core/network/api_exception.dart';
import 'package:saleskido/core/storage/token_storage.dart';
import 'package:saleskido/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({
    AuthService? authService,
    TokenStorage? storage,
  })  : _authService = authService ?? AuthService(),
        _storage = storage ?? TokenStorage();

  final AuthService _authService;
  final TokenStorage _storage;

  Map<String, dynamic>? _user;
  String? _token;
  bool _loading = false;
  String? _error;
  bool _initialized = false;

  Map<String, dynamic>? get user => _user;
  String? get token => _token;
  bool get isLoading => _loading;
  String? get error => _error;
  bool get isAuthenticated => _token != null && _token!.isNotEmpty;
  bool get initialized => _initialized;

  String get userId => (_user?['_id'] ?? _user?['id'] ?? '').toString();
  String get companyId => (_user?['company_id'] ?? '').toString();
  String get userName {
    final name = _user?['name'] ?? _user?['fullName'] ?? '';
    return name.toString().isEmpty ? 'User' : name.toString();
  }

  String get designation => (_user?['designation'] ?? _user?['role'] ?? '').toString();
  String get email => (_user?['email'] ?? '').toString();
  String get phone => (_user?['phone'] ?? _user?['mobile'] ?? '').toString();
  String? get profileImage => _user?['profile']?.toString();

  Future<void> loadSession() async {
    _loading = true;
    notifyListeners();
    try {
      _token = await _storage.getToken();
      _user = await _storage.getUser();
      if (_token != null && _token!.isNotEmpty) {
        try {
          final res = await _authService.getUserFromToken();
          if (res['status'] == true && res['data'] != null) {
            _user = Map<String, dynamic>.from(res['data'] as Map);
            await _storage.saveUser(_user!);
          }
        } catch (_) {
          // Keep cached user if token refresh fails offline
        }
      }
    } finally {
      _initialized = true;
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final res = await _authService.login(
        email: email,
        password: password,
        rememberMe: rememberMe,
      );
      _token = res['token']?.toString();
      if (res['data'] is Map) {
        _user = Map<String, dynamic>.from(res['data'] as Map);
      }
      if (_token != null) await _storage.saveToken(_token!);
      if (_user != null) await _storage.saveUser(_user!);
      await _storage.setRememberMe(rememberMe, email: email);
      _loading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _loading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
    } catch (_) {}
    _token = null;
    _user = null;
    await _storage.clearSession();
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
