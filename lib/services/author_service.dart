import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:tija/constants/app_api.dart';
import 'package:tija/constants/app_preference.dart';
import 'package:tija/models/author_model.dart';

class AuthorService {
  static final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static Future<String?> _getAccessToken() async {
    return await _storage.read(key: AppPreference.accessToken);
  }

  static Future<PaginatedAuthors?> getAuthors() async {
    try {
      final url = await AppApi.authorsFullUrl;
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      final dataResponse = jsonDecode(response.body);
      print('AuthorService GET AUTHORS RESPONSE: $dataResponse');

      if (response.statusCode >= 200 && response.statusCode <= 299) {
        return PaginatedAuthors.fromJson(dataResponse as Map<String, dynamic>);
      }

      return null;
    } catch (e, stack) {
      print('AuthorService GET AUTHORS ERROR: $e');
      print('AuthorService GET AUTHORS STACK: $stack');
      return null;
    }
  }

  static Future<AuthorDetail?> getAuthorById(String id) async {
    try {
      final url = await AppApi.authorByIdFullUrl(id);
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      final dataResponse = jsonDecode(response.body);
      print('AuthorService GET AUTHOR BY ID RESPONSE: $dataResponse');

      if (response.statusCode >= 200 && response.statusCode <= 299) {
        return AuthorDetail.fromJson(dataResponse as Map<String, dynamic>);
      }

      return null;
    } catch (e, stack) {
      print('AuthorService GET AUTHOR BY ID ERROR: $e');
      print('AuthorService GET AUTHOR BY ID STACK: $stack');
      return null;
    }
  }

  static Future<AuthorDashboard?> getAuthorDashboard() async {
    try {
      final token = await _getAccessToken();
      final url = await AppApi.authorDashboardFullUrl;

      final headers = {'Content-Type': 'application/json'};
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(Uri.parse(url), headers: headers);

      final dataResponse = jsonDecode(response.body);
      print('AuthorService GET AUTHOR DASHBOARD RESPONSE: $dataResponse');

      if (response.statusCode >= 200 && response.statusCode <= 299) {
        return AuthorDashboard.fromJson(dataResponse as Map<String, dynamic>);
      }

      return null;
    } catch (e, stack) {
      print('AuthorService GET AUTHOR DASHBOARD ERROR: $e');
      print('AuthorService GET AUTHOR DASHBOARD STACK: $stack');
      return null;
    }
  }
}
