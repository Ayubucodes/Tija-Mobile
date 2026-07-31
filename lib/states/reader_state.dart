import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:tija/models/reader_model.dart';
import 'package:tija/services/reader_service.dart';

class ReaderState extends ChangeNotifier {
  ReaderResponse? _readerResponse;
  Uint8List? _pdfBytes;
  bool _isLoading = false;
  bool _isDecrypting = false;
  bool _isError = false;
  String _errorMessage = '';

  ReaderResponse? get readerResponse => _readerResponse;
  Uint8List? get pdfBytes => _pdfBytes;
  bool get isLoading => _isLoading;
  bool get isDecrypting => _isDecrypting;
  bool get isError => _isError;
  String get errorMessage => _errorMessage;

  Future<void> openBook(String bookId) async {
    _isLoading = true;
    _isError = false;
    _errorMessage = '';
    notifyListeners();

    try {
      final result = await ReaderService.openBook(bookId);

      if (result != null) {
        // Check if response contains error (validation error from server)
        if (result.containsKey('detail') && result['detail'] is String) {
          _isError = true;
          _errorMessage = result['detail'].toString();
        } else if (result.containsKey('title') &&
            result.containsKey('status')) {
          // Check if it's an error response with title and status
          if (result['status'] != 200 && result['status'] != 201) {
            _isError = true;
            _errorMessage =
                result['detail']?.toString() ??
                result['title']?.toString() ??
                'Failed to open book.';
          } else {
            _readerResponse = ReaderResponse.fromJson(result);
            _isError = false;
          }
        } else {
          _readerResponse = ReaderResponse.fromJson(result);
          _isError = false;
        }
      } else {
        _isError = true;
        _errorMessage = 'Failed to open book.';
      }
    } catch (e) {
      _isError = true;
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> decryptBook() async {
    if (_readerResponse == null) {
      _isError = true;
      _errorMessage = 'No book opened to decrypt.';
      notifyListeners();
      return;
    }

    _isDecrypting = true;
    _isError = false;
    _errorMessage = '';
    notifyListeners();

    try {
      final bytes = await ReaderService.loadDecryptedBook(
        _readerResponse!.fileUrl,
        _readerResponse!.encryptionKeyBase64,
      );

      _pdfBytes = bytes;
      _isError = false;
    } catch (e) {
      _isError = true;
      _errorMessage = e.toString();
    }

    _isDecrypting = false;
    notifyListeners();
  }

  void clear() {
    _readerResponse = null;
    _pdfBytes = null;
    _isLoading = false;
    _isDecrypting = false;
    _isError = false;
    _errorMessage = '';
    notifyListeners();
  }

  Future<void> updateProgress(
    int currentPage,
    double progressPercentage,
  ) async {
    if (_readerResponse == null) {
      return;
    }

    try {
      final result = await ReaderService.updateProgress(
        _readerResponse!.bookId,
        currentPage,
        progressPercentage,
      );

      if (result != null) {
        _readerResponse = result;
        notifyListeners();
      }
    } catch (e) {
      print('ReaderState UPDATE PROGRESS ERROR: $e');
    }
  }
}
