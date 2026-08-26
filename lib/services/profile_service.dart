import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:tija/constants/app_api.dart';
import 'package:tija/constants/app_preference.dart';
import 'package:tija/models/profile_model.dart';

class ProfileService {
  static final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static Future<String?> _getAccessToken() async {
    return await _storage.read(key: AppPreference.accessToken);
  }

  static Future<UserProfile?> getProfile() async {
    try {
      final token = await _getAccessToken();
      final url = await AppApi.profileFullUrl;

      final headers = {'Content-Type': 'application/json'};
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(Uri.parse(url), headers: headers);

      final dataResponse = jsonDecode(response.body);
      print('ProfileService GET PROFILE RESPONSE: $dataResponse');

      if (response.statusCode >= 200 && response.statusCode <= 299) {
        return UserProfile.fromJson(dataResponse as Map<String, dynamic>);
      }

      return null;
    } catch (e, stack) {
      print('ProfileService GET PROFILE ERROR: $e');
      print('ProfileService GET PROFILE STACK: $stack');
      return null;
    }
  }
}
