import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:tija/constants/app_api.dart';
import 'package:tija/constants/app_preference.dart';

class PayoutService {
  static final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static Future<String?> _getAccessToken() async {
    return await _storage.read(key: AppPreference.accessToken);
  }

  static Future<(bool success, String errorMessage, Map<String, dynamic>? data)> requestPayout({
    required String amountTzs,
    required String phoneNumber,
  }) async {
    try {
      final token = await _getAccessToken();
      final url = await AppApi.requestPayoutFullUrl;

      final headers = {'Content-Type': 'application/json'};
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode({'amountTzs': amountTzs, 'phoneNumber': phoneNumber}),
      );

      print(
        'PayoutService REQUEST PAYOUT RESPONSE STATUS: ${response.statusCode}',
      );
      print('PayoutService REQUEST PAYOUT RESPONSE BODY: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode <= 299) {
        final dataResponse = jsonDecode(response.body) as Map<String, dynamic>;
        return (true, '', dataResponse);
      }

      // Parse error message from response
      final dataResponse = jsonDecode(response.body) as Map<String, dynamic>;
      String errorMessage = 'Payout request failed. Please try again.';

      if (dataResponse.containsKey('detail')) {
        errorMessage = dataResponse['detail'].toString();
      } else if (dataResponse.containsKey('title')) {
        errorMessage = dataResponse['title'].toString();
      } else if (dataResponse.containsKey('errorCode')) {
        errorMessage = dataResponse['errorCode'].toString();
      }

      return (false, errorMessage, null);
    } catch (e, stack) {
      print('PayoutService REQUEST PAYOUT ERROR: $e');
      print('PayoutService REQUEST PAYOUT STACK: $stack');
      return (false, 'Payout request failed. Please try again.', null);
    }
  }
}
