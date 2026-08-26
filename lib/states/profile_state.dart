import 'package:flutter/material.dart';
import 'package:tija/models/profile_model.dart';
import 'package:tija/services/profile_service.dart';

class ProfileState extends ChangeNotifier {
  UserProfile? _profile;
  bool _isLoading = false;
  bool _isError = false;
  String _errorMessage = '';

  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  bool get isError => _isError;
  String get errorMessage => _errorMessage;

  Future<void> getProfile() async {
    _isLoading = true;
    _isError = false;
    _errorMessage = '';
    notifyListeners();

    try {
      final result = await ProfileService.getProfile();

      if (result != null) {
        _profile = result;
        _isError = false;
      } else {
        _isError = true;
        _errorMessage = 'Failed to load profile';
      }
    } catch (e) {
      _isError = true;
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }
}
