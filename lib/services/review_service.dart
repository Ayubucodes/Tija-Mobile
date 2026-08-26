import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:tija/constants/app_api.dart';
import 'package:tija/constants/app_preference.dart';
import 'package:tija/models/books_model.dart';

class ReviewService {
  static final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static Future<String?> _getAccessToken() async {
    return await _storage.read(key: AppPreference.accessToken);
  }

  static Future<Review?> submitReview({
    required String bookId,
    required String rating,
    required String comment,
  }) async {
    try {
      final token = await _getAccessToken();
      final url = await AppApi.submitReviewFullUrl(bookId);

      final headers = {'Content-Type': 'application/json'};
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode({'rating': rating, 'comment': comment}),
      );

      final dataResponse = jsonDecode(response.body);
      print('ReviewService SUBMIT REVIEW RESPONSE: $dataResponse');

      if (response.statusCode >= 200 && response.statusCode <= 299) {
        return Review.fromJson(dataResponse as Map<String, dynamic>);
      }

      return null;
    } catch (e, stack) {
      print('ReviewService SUBMIT REVIEW ERROR: $e');
      print('ReviewService SUBMIT REVIEW STACK: $stack');
      return null;
    }
  }

  static Future<Reviews?> getReviews(String bookId) async {
    try {
      final token = await _getAccessToken();
      final url = await AppApi.getReviewsFullUrl(bookId);

      final headers = {'Content-Type': 'application/json'};
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(Uri.parse(url), headers: headers);

      final dataResponse = jsonDecode(response.body);
      print('ReviewService GET REVIEWS RESPONSE: $dataResponse');

      if (response.statusCode >= 200 && response.statusCode <= 299) {
        return Reviews.fromJson(dataResponse as Map<String, dynamic>);
      }

      return null;
    } catch (e, stack) {
      print('ReviewService GET REVIEWS ERROR: $e');
      print('ReviewService GET REVIEWS STACK: $stack');
      return null;
    }
  }
}
