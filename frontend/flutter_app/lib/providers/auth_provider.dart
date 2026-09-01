import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/auth_models.dart';
import '../services/api_service.dart';

const _tokenKey = 'crispr_access_token';

class AuthProvider extends ChangeNotifier {
  AuthProvider({ApiService? api})
      : _api = api ?? ApiService(),
        _storage = const FlutterSecureStorage();

  final ApiService _api;
  final FlutterSecureStorage _storage;

  AuthUser? user;
  bool isLoading = false;
  String? error;
  bool _bootstrapped = false;

  bool get isAuthenticated => user != null;
  bool get isBootstrapped => _bootstrapped;
  ApiService get api => _api;

  /// Skips login UI in widget tests.
  void skipAuthForTesting() {
    user = AuthUser(id: 'test', email: 'test@crispr.test', isActive: true);
    _bootstrapped = true;
    notifyListeners();
  }

  Future<void> bootstrap() async {
    isLoading = true;
    notifyListeners();
    try {
      final token = await _storage.read(key: _tokenKey);
      if (token != null && token.isNotEmpty) {
        _api.setAccessToken(token);
        user = await _api.fetchMe();
      }
    } catch (_) {
      await _clearToken();
    } finally {
      isLoading = false;
      _bootstrapped = true;
      notifyListeners();
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    String? fullName,
  }) async {
    return _auth(() => _api.register(email: email, password: password, fullName: fullName));
  }

  Future<bool> login({required String email, required String password}) async {
    return _auth(() => _api.login(email: email, password: password));
  }

  Future<bool> signInWithGoogle({
    String? idToken,
    String? accessToken,
    String? email,
    String? fullName,
    String? photoUrl,
  }) async {
    return _auth(() => _api.googleAuth(
      idToken: idToken,
      accessToken: accessToken,
      email: email,
      fullName: fullName,
      photoUrl: photoUrl,
    ));
  }

  Future<void> logout() async {
    try {
      await _api.logout();
    } catch (_) {
      // Still clear local session.
    }
    await _clearToken();
    user = null;
    notifyListeners();
  }

  Future<bool> deleteAccount() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      await _api.deleteAccount();
      await _clearToken();
      user = null;
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      isLoading = false;
      error = _friendlyAuthError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> _auth(Future<AuthTokenResponse> Function() call) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final res = await call();
      await _storage.write(key: _tokenKey, value: res.accessToken);
      _api.setAccessToken(res.accessToken);
      user = res.user;
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      isLoading = false;
      error = _friendlyAuthError(e);
      notifyListeners();
      return false;
    }
  }

  String _friendlyAuthError(Object e) {
    if (e is ApiException) {
      if (e.statusCode == 401) {
        return 'Incorrect email or password.';
      }
      if (e.statusCode == 409) {
        return 'This email is already registered. Try signing in instead.';
      }
      if (e.statusCode >= 500) {
        return 'Server is unavailable right now. The backend database may not be '
            'connected on Render — try again later or use a local API build.';
      }
      return e.message;
    }
    final text = e.toString();
    if (text.contains('SocketException') || text.contains('Failed host lookup')) {
      return 'Cannot reach the server. Check your internet connection and API URL.';
    }
    if (text.contains('FormatException')) {
      return 'Server returned an unexpected response. The API may be down '
          '(database not connected on production).';
    }
    return text;
  }

  Future<void> _clearToken() async {
    _api.setAccessToken(null);
    await _storage.delete(key: _tokenKey);
  }
}
