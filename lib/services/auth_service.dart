import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:tija/constants/app_api.dart';
import 'package:tija/models/auth_model.dart';

class AuthService {
  static Future<(AuthResponse?, String errorMessage)> login({
    required String username,
    required String password,
  }) async {
    try {
      final url = await AppApi.loginFullUrl;
      final response = await http
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'username': username, 'password': password}),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw SocketException(
                'Connection timeout. Please check your internet connection.',
              );
            },
          );

      final dataResponse = jsonDecode(response.body);
      print('AuthService LOGIN RESPONSE: $dataResponse');

      if (response.statusCode >= 200 && response.statusCode <= 299) {
        return (
          AuthResponse.fromJson(dataResponse as Map<String, dynamic>),
          '',
        );
      }

      // Parse error message from response
      String errorMessage = 'Invalid email or password.';
      if (dataResponse.containsKey('errors')) {
        final errors = dataResponse['errors'] as Map<String, dynamic>;
        if (errors.isNotEmpty) {
          final firstErrorKey = errors.keys.first;
          final errorList = errors[firstErrorKey] as List;
          if (errorList.isNotEmpty) {
            errorMessage = errorList.first.toString();
          }
        }
      } else if (dataResponse.containsKey('detail')) {
        errorMessage = dataResponse['detail'].toString();
      } else if (dataResponse.containsKey('title')) {
        errorMessage = dataResponse['title'].toString();
      }

      return (null, errorMessage);
    } on SocketException catch (e) {
      print('AuthService LOGIN NETWORK ERROR: $e');
      return (
        null,
        'No internet connection. Please check your network and try again.',
      );
    } catch (e, stack) {
      print('AuthService LOGIN ERROR: $e');
      print('AuthService LOGIN STACK: $stack');
      return (null, 'An error occurred. Please try again.');
    }
  }

  static Future<(bool success, String errorMessage)> register({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    try {
      final url = await AppApi.registerFullUrl;
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'fullName': fullName,
          'email': email,
          'phoneNumber': phoneNumber,
          'password': password,
        }),
      );

      print('AuthService REGISTER RESPONSE STATUS: ${response.statusCode}');
      print('AuthService REGISTER RESPONSE BODY: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode <= 299) {
        return (true, '');
      }

      // Parse error message from response
      final dataResponse = jsonDecode(response.body) as Map<String, dynamic>;
      String errorMessage = 'Registration failed. Please try again.';

      if (dataResponse.containsKey('errors')) {
        final errors = dataResponse['errors'] as Map<String, dynamic>;
        if (errors.isNotEmpty) {
          final firstErrorKey = errors.keys.first;
          final errorList = errors[firstErrorKey] as List;
          if (errorList.isNotEmpty) {
            errorMessage = errorList.first.toString();
          }
        }
      } else if (dataResponse.containsKey('detail')) {
        errorMessage = dataResponse['detail'].toString();
      } else if (dataResponse.containsKey('title')) {
        errorMessage = dataResponse['title'].toString();
      }

      return (false, errorMessage);
    } catch (e, stack) {
      print('AuthService REGISTER ERROR: $e');
      print('AuthService REGISTER STACK: $stack');
      return (false, 'Registration failed. Please try again.');
    }
  }

  static Future<(bool success, String errorMessage)> registerAuthor({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    try {
      final url = await AppApi.registerAuthorFullUrl;
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'fullName': fullName,
          'email': email,
          'phoneNumber': phoneNumber,
          'password': password,
        }),
      );

      print(
        'AuthService REGISTER AUTHOR RESPONSE STATUS: ${response.statusCode}',
      );
      print('AuthService REGISTER AUTHOR RESPONSE BODY: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode <= 299) {
        return (true, '');
      }

      // Parse error message from response
      final dataResponse = jsonDecode(response.body) as Map<String, dynamic>;
      String errorMessage = 'Registration failed. Please try again.';

      if (dataResponse.containsKey('errors')) {
        final errors = dataResponse['errors'] as Map<String, dynamic>;
        if (errors.isNotEmpty) {
          final firstErrorKey = errors.keys.first;
          final errorList = errors[firstErrorKey] as List;
          if (errorList.isNotEmpty) {
            errorMessage = errorList.first.toString();
          }
        }
      } else if (dataResponse.containsKey('detail')) {
        errorMessage = dataResponse['detail'].toString();
      } else if (dataResponse.containsKey('title')) {
        errorMessage = dataResponse['title'].toString();
      }

      return (false, errorMessage);
    } catch (e, stack) {
      print('AuthService REGISTER AUTHOR ERROR: $e');
      print('AuthService REGISTER AUTHOR STACK: $stack');
      return (false, 'Registration failed. Please try again.');
    }
  }

  static Future<(bool success, String errorMessage)> forgotPassword({
    required String email,
  }) async {
    try {
      final url = await AppApi.forgotPasswordFullUrl;
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      print(
        'AuthService FORGOT PASSWORD RESPONSE STATUS: ${response.statusCode}',
      );
      print('AuthService FORGOT PASSWORD RESPONSE BODY: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode <= 299) {
        final dataResponse = jsonDecode(response.body) as Map<String, dynamic>;
        final message =
            dataResponse['message']?.toString() ??
            'If an account with that email exists, a reset link has been sent.';
        return (true, message);
      }

      // Parse error message from response
      final dataResponse = jsonDecode(response.body) as Map<String, dynamic>;
      String errorMessage = 'Failed to send reset link. Please try again.';

      if (dataResponse.containsKey('errors')) {
        final errors = dataResponse['errors'] as Map<String, dynamic>;
        if (errors.isNotEmpty) {
          final firstErrorKey = errors.keys.first;
          final errorList = errors[firstErrorKey] as List;
          if (errorList.isNotEmpty) {
            errorMessage = errorList.first.toString();
          }
        }
      } else if (dataResponse.containsKey('detail')) {
        errorMessage = dataResponse['detail'].toString();
      } else if (dataResponse.containsKey('title')) {
        errorMessage = dataResponse['title'].toString();
      }

      return (false, errorMessage);
    } catch (e, stack) {
      print('AuthService FORGOT PASSWORD ERROR: $e');
      print('AuthService FORGOT PASSWORD STACK: $stack');
      return (false, 'Failed to send reset link. Please try again.');
    }
  }
}
