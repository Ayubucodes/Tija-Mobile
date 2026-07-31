import 'package:flutter/material.dart';
import 'package:tija/services/payout_service.dart';

class PayoutState extends ChangeNotifier {
  Map<String, dynamic>? _payoutData;
  bool _isRequesting = false;
  bool _isError = false;
  String _errorMessage = '';

  Map<String, dynamic>? get payoutData => _payoutData;
  bool get isRequesting => _isRequesting;
  bool get isError => _isError;
  String get errorMessage => _errorMessage;

  Future<bool> requestPayout({
    required String amountTzs,
    required String phoneNumber,
  }) async {
    _isRequesting = true;
    _isError = false;
    _errorMessage = '';
    notifyListeners();

    try {
      final (success, errorMessage, data) = await PayoutService.requestPayout(
        amountTzs: amountTzs,
        phoneNumber: phoneNumber,
      );

      if (success && data != null) {
        _payoutData = data;
        _isError = false;
        _isRequesting = false;
        notifyListeners();
        return true;
      } else {
        _isError = true;
        _errorMessage = errorMessage.isNotEmpty
            ? errorMessage
            : 'Failed to request payout.';
      }
    } catch (e) {
      _isError = true;
      _errorMessage = e.toString();
    }

    _isRequesting = false;
    notifyListeners();
    return false;
  }

  void clearPayoutData() {
    _payoutData = null;
    _isError = false;
    _errorMessage = '';
    notifyListeners();
  }
}
