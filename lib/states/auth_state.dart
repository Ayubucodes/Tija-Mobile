import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tija/constants/app_preference.dart';
import 'package:tija/models/auth_model.dart';
import 'package:tija/services/auth_service.dart';
import 'package:tija/states/connectivity_state.dart';
import 'package:tija/utils/app_util.dart';

class AuthState extends ChangeNotifier {
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  AuthState(this._connectivityState);

  final ConnectivityState _connectivityState;

  AuthResponse? _user;
  bool _isLoading = false;
  bool _isError = false;
  String _errorMessage = '';
  bool _noInactivityTimeout = false;

  AuthResponse? get user => _user;
  bool get isLoading => _isLoading;
  bool get isError => _isError;
  String get errorMessage => _errorMessage;
  bool get isLoggedIn => _user != null;
  bool get noInactivityTimeout => _noInactivityTimeout;

  // ── Login ────────────────────────────────────────────────────────────────
  Future<bool> onLogin({
    required String username,
    required String password,
  }) async {
    if (!_connectivityState.connectivityStatus) {
      AppUtil.showToastMessage(
        message: 'Please check your network.',
        isError: true,
      );
      return false;
    }

    _isLoading = true;
    _isError = false;
    _errorMessage = '';
    notifyListeners();

    try {
      final result = await AuthService.login(
        username: username,
        password: password,
      );

      if (result != null) {
        _user = result;
        await _storage.write(
          key: AppPreference.accessToken,
          value: result.accessToken,
        );
        await _storage.write(key: AppPreference.userId, value: result.userId);
        await _storage.write(
          key: AppPreference.fullName,
          value: result.fullName,
        );
        await _storage.write(key: AppPreference.email, value: username);
        _isError = false;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isError = true;
        _errorMessage = 'Invalid email or password.';
      }
    } catch (e) {
      _isError = true;
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // ── Register ─────────────────────────────────────────────────────────────
  Future<bool> onRegister({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    if (!_connectivityState.connectivityStatus) {
      AppUtil.showToastMessage(
        message: 'Please check your network.',
        isError: true,
      );
      return false;
    }

    _isLoading = true;
    _isError = false;
    _errorMessage = '';
    notifyListeners();

    try {
      final (success, errorMessage) = await AuthService.register(
        fullName: fullName,
        email: email,
        phoneNumber: phoneNumber,
        password: password,
      );

      if (success) {
        await _storage.write(key: AppPreference.email, value: email);
        await _storage.write(
          key: AppPreference.phoneNumber,
          value: phoneNumber,
        );
        _isError = false;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isError = true;
        _errorMessage = errorMessage;
      }
    } catch (e) {
      _isError = true;
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // ── Register Author ──────────────────────────────────────────────────────
  Future<bool> onRegisterAuthor({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    if (!_connectivityState.connectivityStatus) {
      AppUtil.showToastMessage(
        message: 'Please check your network.',
        isError: true,
      );
      return false;
    }

    _isLoading = true;
    _isError = false;
    _errorMessage = '';
    notifyListeners();

    try {
      final (success, errorMessage) = await AuthService.registerAuthor(
        fullName: fullName,
        email: email,
        phoneNumber: phoneNumber,
        password: password,
      );

      if (success) {
        _isError = false;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isError = true;
        _errorMessage = errorMessage;
      }
    } catch (e) {
      _isError = true;
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // ── Logout ───────────────────────────────────────────────────────────────
  Future<void> logout() async {
    _user = null;
    _noInactivityTimeout = true;
    await _storage.delete(key: AppPreference.accessToken);
    await _storage.delete(key: AppPreference.userId);
    await _storage.delete(key: AppPreference.fullName);
    await _storage.delete(key: AppPreference.email);
    await _storage.delete(key: AppPreference.phoneNumber);
    notifyListeners();
  }

  // ── Set App No Inactivity Status ──────────────────────────────────────────
  void onSetAppNoInactivityStatus({required bool inactivityStatus}) {
    _noInactivityTimeout = inactivityStatus;
    notifyListeners();
  }

  // ── Arm Session ───────────────────────────────────────────────────────────
  void armSession() {
    _noInactivityTimeout = false;
    notifyListeners();
  }

  // ── Forgot Password ─────────────────────────────────────────────────────
  Future<bool> onForgotPassword({required String email}) async {
    if (!_connectivityState.connectivityStatus) {
      AppUtil.showToastMessage(
        message: 'Please check your network.',
        isError: true,
      );
      return false;
    }

    _isLoading = true;
    _isError = false;
    _errorMessage = '';
    notifyListeners();

    try {
      final (success, message) = await AuthService.forgotPassword(email: email);

      if (success) {
        _isError = false;
        _isLoading = false;
        notifyListeners();

        AppUtil.showToastMessage(message: message, isError: false);
        return true;
      } else {
        _isError = true;
        _errorMessage = message;
      }
    } catch (e) {
      _isError = true;
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }
}
