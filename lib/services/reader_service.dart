import 'dart:convert';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:tija/constants/app_api.dart';
import 'package:tija/constants/app_preference.dart';
import 'package:tija/models/reader_model.dart';

class ReaderService {
  static final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static Future<String?> _getAccessToken() async {
    return await _storage.read(key: AppPreference.accessToken);
  }

  static Future<ReaderResponse?> openBook(String bookId) async {
    try {
      final token = await _getAccessToken();
      final baseUrl = await AppApi.readerOpenBookFullUrl(bookId);
      final uri = Uri.parse(baseUrl);

      final headers = {'Content-Type': 'application/json'};
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(uri, headers: headers);

      final dataResponse = jsonDecode(response.body);
      print('ReaderService OPEN BOOK RESPONSE: $dataResponse');

      if (response.statusCode >= 200 && response.statusCode <= 299) {
        if (dataResponse is Map<String, dynamic>) {
          return ReaderResponse.fromJson(dataResponse);
        }
      }

      return null;
    } catch (e, stack) {
      print('ReaderService OPEN BOOK ERROR: $e');
      print('ReaderService OPEN BOOK STACK: $stack');
      return null;
    }
  }

  static Future<Uint8List> loadDecryptedBook(
    String fileUrl,
    String encryptionKeyBase64,
  ) async {
    try {
      final response = await http.get(Uri.parse(fileUrl));
      final blob = response.bodyBytes;

      final nonce = blob.sublist(0, 12);
      final tag = blob.sublist(blob.length - 16);
      final cipherText = blob.sublist(12, blob.length - 16);

      final algorithm = AesGcm.with256bits();
      final secretKey = SecretKey(base64Decode(encryptionKeyBase64));
      final secretBox = SecretBox(cipherText, nonce: nonce, mac: Mac(tag));

      final decryptedBytes = await algorithm.decrypt(
        secretBox,
        secretKey: secretKey,
      );

      return Uint8List.fromList(decryptedBytes);
    } catch (e, stack) {
      print('ReaderService DECRYPT ERROR: $e');
      print('ReaderService DECRYPT STACK: $stack');
      rethrow;
    }
  }

  static Future<ReaderResponse?> updateProgress(
    String bookId,
    int currentPage,
    double progressPercentage,
  ) async {
    try {
      final token = await _getAccessToken();
      final baseUrl = await AppApi.readerProgressFullUrl(bookId);
      final uri = Uri.parse(baseUrl);

      final headers = {'Content-Type': 'application/json'};
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final body = jsonEncode({
        'currentPage': currentPage.toString(),
        'progressPercentage': progressPercentage.toString(),
      });

      final response = await http.put(uri, headers: headers, body: body);

      final dataResponse = jsonDecode(response.body);
      print('ReaderService UPDATE PROGRESS RESPONSE: $dataResponse');

      if (response.statusCode >= 200 && response.statusCode <= 299) {
        if (dataResponse is Map<String, dynamic>) {
          return ReaderResponse.fromJson(dataResponse);
        }
      }

      return null;
    } catch (e, stack) {
      print('ReaderService UPDATE PROGRESS ERROR: $e');
      print('ReaderService UPDATE PROGRESS STACK: $stack');
      return null;
    }
  }
}
