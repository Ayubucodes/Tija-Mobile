import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:tija/constants/app_api.dart';
import 'package:tija/constants/app_preference.dart';

class PaymentService {
  static final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static Future<String?> _getAccessToken() async {
    return await _storage.read(key: AppPreference.accessToken);
  }

  static Future<(bool success, String errorMessage)> initiatePayment({
    required String bookId,
    required String phoneNumber,
  }) async {
    try {
      final token = await _getAccessToken();
      final url = await AppApi.initiatePaymentFullUrl;

      final headers = {'Content-Type': 'application/json'};
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode({'bookId': bookId, 'phoneNumber': phoneNumber}),
      );

      print(
        'PaymentService INITIATE PAYMENT RESPONSE STATUS: ${response.statusCode}',
      );
      print('PaymentService INITIATE PAYMENT RESPONSE BODY: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode <= 299) {
        return (true, '');
      }

      // Parse error message from response
      final dataResponse = jsonDecode(response.body) as Map<String, dynamic>;
      String errorMessage = 'Payment failed. Please try again.';

      if (dataResponse.containsKey('detail')) {
        errorMessage = dataResponse['detail'].toString();
      } else if (dataResponse.containsKey('title')) {
        errorMessage = dataResponse['title'].toString();
      } else if (dataResponse.containsKey('errorCode')) {
        errorMessage = dataResponse['errorCode'].toString();
      }

      return (false, errorMessage);
    } catch (e, stack) {
      print('PaymentService INITIATE PAYMENT ERROR: $e');
      print('PaymentService INITIATE PAYMENT STACK: $stack');
      return (false, 'Payment failed. Please try again.');
    }
  }
}
