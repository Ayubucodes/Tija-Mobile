import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:tija/constants/app_api.dart';
import 'package:tija/constants/app_preference.dart';
import 'package:tija/constants/app_status_code.dart';
import 'package:tija/models/books_model.dart';
import 'package:tija/models/reader_library_model.dart';

class BooksService {
  static final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static Future<String?> _getAccessToken() async {
    return await _storage.read(key: AppPreference.accessToken);
  }

  static Future<Books?> onGetBooks({
    int page = 1,
    int pageSize = 10,
    String? genreId,
  }) async {
    try {
      final baseUrl = await AppApi.getBooksFullUrl;
      final queryParams = {
        'page': page.toString(),
        'pageSize': pageSize.toString(),
      };
      if (genreId != null) {
        queryParams['genreId'] = genreId;
      }

      final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);
      print('BooksService: Requesting $uri');

      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      print('BooksService: Status code ${response.statusCode}');
      final dataResponse = jsonDecode(response.body);
      print('BooksService RESPONSE: $dataResponse');

      if (response.statusCode >= 200 && response.statusCode <= 299) {
        // Support both response shapes:
        // 1) direct paging payload: { items, totalCount, ... }
        // 2) wrapped payload: { responseCode, books: { items, ... } }
        if (dataResponse is Map<String, dynamic>) {
          if (dataResponse.containsKey('items')) {
            return Books.fromJson(dataResponse);
          }

          if (dataResponse['responseCode'] ==
                  ApiStatusResponseCode.validCREDENTIALS &&
              dataResponse['books'] is Map<String, dynamic>) {
            return Books.fromJson(dataResponse['books']);
          }

          // Log unexpected response format for debugging
          print('BooksService: Unexpected response format: $dataResponse');
        }
      } else {
        // Log non-2xx status code
        print('BooksService: Non-2xx status code: ${response.statusCode}');
        print('BooksService: Response body: $dataResponse');
      }

      return null;
    } catch (e, stack) {
      print('BooksService ERROR: $e');
      print('BooksService STACK: $stack');
      return null;
    }
  }

  static Future<List<Genre>?> onGetGenres() async {
    try {
      final baseUrl = await AppApi.genresFullUrl;
      final uri = Uri.parse(baseUrl);
      print('BooksService: Requesting genres $uri');

      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      print('BooksService: Genres status code ${response.statusCode}');
      final dataResponse = jsonDecode(response.body);
      print('BooksService GENRES RESPONSE: $dataResponse');

      if (response.statusCode >= 200 && response.statusCode <= 299) {
        if (dataResponse is List) {
          return List<Genre>.from(dataResponse.map((x) => Genre.fromJson(x)));
        }
      } else {
        print(
          'BooksService: Genres non-2xx status code: ${response.statusCode}',
        );
        print('BooksService: Genres response body: $dataResponse');
      }

      return null;
    } catch (e, stack) {
      print('BooksService GENRES ERROR: $e');
      print('BooksService GENRES STACK: $stack');
      return null;
    }
  }

  static Future<Books?> searchBooks({
    int page = 1,
    int pageSize = 10,
    String? query,
  }) async {
    try {
      final baseUrl = await AppApi.getBooksFullUrl;
      final queryParams = {
        'page': page.toString(),
        'pageSize': pageSize.toString(),
      };
      if (query != null && query.isNotEmpty) {
        queryParams['search'] = query;
      }

      final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);
      print('BooksService: Searching books $uri');

      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      print('BooksService: Search status code ${response.statusCode}');
      final dataResponse = jsonDecode(response.body);
      print('BooksService SEARCH RESPONSE: $dataResponse');

      if (response.statusCode >= 200 && response.statusCode <= 299) {
        if (dataResponse is Map<String, dynamic>) {
          if (dataResponse.containsKey('items')) {
            return Books.fromJson(dataResponse);
          }

          if (dataResponse['responseCode'] ==
                  ApiStatusResponseCode.validCREDENTIALS &&
              dataResponse['books'] is Map<String, dynamic>) {
            return Books.fromJson(dataResponse['books']);
          }

          print(
            'BooksService: Search unexpected response format: $dataResponse',
          );
        }
      } else {
        print(
          'BooksService: Search non-2xx status code: ${response.statusCode}',
        );
        print('BooksService: Search response body: $dataResponse');
      }

      return null;
    } catch (e, stack) {
      print('BooksService SEARCH ERROR: $e');
      print('BooksService SEARCH STACK: $stack');
      return null;
    }
  }

  static Future<Books?> getMostPopularBooks({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final baseUrl = await AppApi.getBooksFullUrl;
      final queryParams = {
        'page': page.toString(),
        'pageSize': pageSize.toString(),
        'Sort': 'MostPopular',
      };

      final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      final dataResponse = jsonDecode(response.body);
      print('BooksService MOST POPULAR RESPONSE: $dataResponse');

      if (response.statusCode >= 200 && response.statusCode <= 299) {
        if (dataResponse is Map<String, dynamic>) {
          if (dataResponse.containsKey('items')) {
            return Books.fromJson(dataResponse);
          }

          if (dataResponse['responseCode'] ==
                  ApiStatusResponseCode.validCREDENTIALS &&
              dataResponse['books'] is Map<String, dynamic>) {
            return Books.fromJson(dataResponse['books']);
          }
        }
      }

      return null;
    } catch (e, stack) {
      print('BooksService MOST POPULAR ERROR: $e');
      print('BooksService MOST POPULAR STACK: $stack');
      return null;
    }
  }

  static Future<BookDetail?> onGetBookById(String id) async {
    try {
      final baseUrl = await AppApi.bookByIdFullUrl(id);
      final uri = Uri.parse(baseUrl);

      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      final dataResponse = jsonDecode(response.body);
      print('BooksService BOOK DETAIL RESPONSE: $dataResponse');

      if (response.statusCode >= 200 && response.statusCode <= 299) {
        if (dataResponse is Map<String, dynamic>) {
          return BookDetail.fromJson(dataResponse);
        }
      }

      return null;
    } catch (e, stack) {
      print('BooksService BOOK DETAIL ERROR: $e');
      print('BooksService BOOK DETAIL STACK: $stack');
      return null;
    }
  }

  static Future<BookDetail?> uploadBook({
    required String title,
    required String description,
    required double priceTzs,
    required int totalPages,
    required List<String> genreIds,
  }) async {
    try {
      final token = await _getAccessToken();
      final baseUrl = await AppApi.uploadBookFullUrl;
      final uri = Uri.parse(baseUrl);

      final body = jsonEncode({
        'title': title,
        'description': description,
        'priceTzs': priceTzs.toString(),
        'totalPages': totalPages.toString(),
        'genreIds': genreIds,
      });

      final headers = {'Content-Type': 'application/json'};
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.post(uri, headers: headers, body: body);

      final dataResponse = jsonDecode(response.body);
      print('BooksService UPLOAD BOOK RESPONSE: $dataResponse');

      if (response.statusCode >= 200 && response.statusCode <= 299) {
        if (dataResponse is Map<String, dynamic>) {
          return BookDetail.fromJson(dataResponse);
        }
      }

      return null;
    } catch (e, stack) {
      print('BooksService UPLOAD BOOK ERROR: $e');
      print('BooksService UPLOAD BOOK STACK: $stack');
      return null;
    }
  }

  static Future<BookDetail?> updateBook({
    required String bookId,
    required String title,
    required String description,
    required double priceTzs,
    required String coverImageUrl,
    required String bookFileUrl,
    required int totalPages,
    required List<String> genreIds,
  }) async {
    try {
      final token = await _getAccessToken();
      final baseUrl = await AppApi.updateBookFullUrl(bookId);
      final uri = Uri.parse(baseUrl);

      final body = jsonEncode({
        'title': title,
        'description': description,
        'priceTzs': priceTzs.toString(),
        'coverImageUrl': coverImageUrl,
        'bookFileUrl': bookFileUrl,
        'totalPages': totalPages.toString(),
        'genreIds': genreIds,
      });

      final headers = {'Content-Type': 'application/json'};
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.put(uri, headers: headers, body: body);

      final dataResponse = jsonDecode(response.body);
      print('BooksService UPDATE BOOK RESPONSE: $dataResponse');

      if (response.statusCode >= 200 && response.statusCode <= 299) {
        if (dataResponse is Map<String, dynamic>) {
          return BookDetail.fromJson(dataResponse);
        }
      }

      return null;
    } catch (e, stack) {
      print('BooksService UPDATE BOOK ERROR: $e');
      print('BooksService UPDATE BOOK STACK: $stack');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> uploadBookFile(
    String bookId,
    File file,
  ) async {
    try {
      final token = await _getAccessToken();
      final baseUrl = await AppApi.uploadBookFileFullUrl(bookId);
      final uri = Uri.parse(baseUrl);

      final request = http.MultipartRequest('POST', uri);
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      final fileStream = http.ByteStream(file.openRead());
      final fileLength = await file.length();
      final extension = file.path.split('.').last.toLowerCase();

      // Set content type based on file extension
      String contentType;
      switch (extension) {
        case 'pdf':
          contentType = 'application/pdf';
          break;
        default:
          contentType = 'application/pdf'; // Default to pdf
      }

      final multipartFile = http.MultipartFile(
        'File',
        fileStream,
        fileLength,
        filename: file.path.split('/').last,
        contentType: http.MediaType.parse(contentType),
      );
      request.files.add(multipartFile);

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      print('BooksService UPLOAD BOOK FILE STATUS: ${response.statusCode}');
      print('BooksService UPLOAD BOOK FILE RESPONSE BODY: $responseBody');

      if (responseBody.isEmpty) {
        print('BooksService UPLOAD BOOK FILE ERROR: Empty response body');
        return null;
      }

      final dataResponse = jsonDecode(responseBody);
      print('BooksService UPLOAD BOOK FILE RESPONSE: $dataResponse');

      if (response.statusCode >= 200 && response.statusCode <= 299) {
        if (dataResponse is Map<String, dynamic>) {
          return dataResponse;
        }
      }

      // Return error response for non-2xx status codes
      if (dataResponse is Map<String, dynamic>) {
        return dataResponse;
      }

      return null;
    } catch (e, stack) {
      print('BooksService UPLOAD BOOK FILE ERROR: $e');
      print('BooksService UPLOAD BOOK FILE STACK: $stack');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> uploadCover(File file) async {
    try {
      final token = await _getAccessToken();
      final baseUrl = await AppApi.uploadCoverFullUrl;
      final uri = Uri.parse(baseUrl);

      final request = http.MultipartRequest('POST', uri);
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      final fileStream = http.ByteStream(file.openRead());
      final fileLength = await file.length();
      final extension = file.path.split('.').last.toLowerCase();

      // Set content type based on file extension
      String contentType;
      switch (extension) {
        case 'jpg':
        case 'jpeg':
          contentType = 'image/jpeg';
          break;
        case 'png':
          contentType = 'image/png';
          break;
        default:
          contentType = 'image/jpeg'; // Default to jpeg
      }

      final multipartFile = http.MultipartFile(
        'File',
        fileStream,
        fileLength,
        filename: file.path.split('/').last,
        contentType: http.MediaType.parse(contentType),
      );
      request.files.add(multipartFile);

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final dataResponse = jsonDecode(responseBody);
      print('BooksService UPLOAD COVER RESPONSE: $dataResponse');

      if (response.statusCode >= 200 && response.statusCode <= 299) {
        if (dataResponse is Map<String, dynamic>) {
          return dataResponse;
        }
      }

      // Return error response for non-2xx status codes
      if (dataResponse is Map<String, dynamic>) {
        return dataResponse;
      }

      return null;
    } catch (e, stack) {
      print('BooksService UPLOAD COVER ERROR: $e');
      print('BooksService UPLOAD COVER STACK: $stack');
      return null;
    }
  }

  static Future<List<ReaderLibraryBook>?> getReaderLibrary() async {
    try {
      final token = await _getAccessToken();
      final baseUrl = await AppApi.readerLibraryFullUrl;
      final uri = Uri.parse(baseUrl);

      final headers = {'Content-Type': 'application/json'};
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(uri, headers: headers);

      final dataResponse = jsonDecode(response.body);
      print('BooksService READER LIBRARY RESPONSE: $dataResponse');

      if (response.statusCode >= 200 && response.statusCode <= 299) {
        if (dataResponse is List) {
          return List<ReaderLibraryBook>.from(
            dataResponse.map((x) => ReaderLibraryBook.fromJson(x)),
          );
        }
      }

      return null;
    } catch (e, stack) {
      print('BooksService READER LIBRARY ERROR: $e');
      print('BooksService READER LIBRARY STACK: $stack');
      return null;
    }
  }

  static Future<Books?> getAuthorBooks() async {
    try {
      final token = await _getAccessToken();
      final baseUrl = await AppApi.authorBooksFullUrl;
      final uri = Uri.parse(baseUrl);

      final headers = {'Content-Type': 'application/json'};
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(uri, headers: headers);

      final dataResponse = jsonDecode(response.body);
      print('BooksService AUTHOR BOOKS RESPONSE: $dataResponse');

      if (response.statusCode >= 200 && response.statusCode <= 299) {
        if (dataResponse is Map<String, dynamic>) {
          if (dataResponse.containsKey('items')) {
            return Books.fromJson(dataResponse);
          }
        }
      }

      return null;
    } catch (e, stack) {
      print('BooksService AUTHOR BOOKS ERROR: $e');
      print('BooksService AUTHOR BOOKS STACK: $stack');
      return null;
    }
  }

  static Future<bool> deleteBook(String bookId) async {
    try {
      final token = await _getAccessToken();
      final baseUrl = await AppApi.deleteBookFullUrl(bookId);
      final uri = Uri.parse(baseUrl);

      final headers = {'Content-Type': 'application/json'};
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.delete(uri, headers: headers);

      print('BooksService DELETE BOOK RESPONSE: ${response.statusCode}');

      if (response.statusCode >= 200 && response.statusCode <= 299) {
        return true;
      }

      return false;
    } catch (e, stack) {
      print('BooksService DELETE BOOK ERROR: $e');
      print('BooksService DELETE BOOK STACK: $stack');
      return false;
    }
  }

  static Future<bool> submitBookForReview(String bookId) async {
    try {
      final token = await _getAccessToken();
      final baseUrl = await AppApi.submitBookFullUrl(bookId);
      final uri = Uri.parse(baseUrl);

      final headers = {'Content-Type': 'application/json'};
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.post(uri, headers: headers);

      // Only try to decode JSON if response body is not empty
      if (response.body.isNotEmpty) {
        final dataResponse = jsonDecode(response.body);
        print('BooksService SUBMIT BOOK RESPONSE: $dataResponse');
      } else {
        print(
          'BooksService SUBMIT BOOK RESPONSE: Status ${response.statusCode} (empty body)',
        );
      }

      if (response.statusCode >= 200 && response.statusCode <= 299) {
        return true;
      }

      return false;
    } catch (e, stack) {
      print('BooksService SUBMIT BOOK ERROR: $e');
      print('BooksService SUBMIT BOOK STACK: $stack');
      return false;
    }
  }
}
