import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:tija/states/books_state.dart';
import 'package:tija/utils/app_util.dart';

mixin UploadBookFilesMixin<T extends StatefulWidget> on State<T> {
  final ImagePicker picker = ImagePicker();
  File? coverImage;
  File? pdfFile;

  Future<void> pickCoverImage() async {
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (image != null) {
        setState(() {
          coverImage = File(image.path);
        });
      }
    } catch (e) {
      AppUtil.showToastMessage(isError: true, message: 'Failed to pick image');
    }
  }

  Future<void> pickPdfFile() async {
    try {
      final XFile? file = await picker.pickImage(source: ImageSource.gallery);
      if (file != null) {
        setState(() {
          pdfFile = File(file.path);
        });
      }
    } catch (e) {
      AppUtil.showToastMessage(isError: true, message: 'Failed to pick file');
    }
  }

  Future<void> onSubmit(Map<String, dynamic> bookData) async {
    if (coverImage == null) {
      AppUtil.showToastMessage(
        isError: true,
        message: 'Please select cover image',
      );
      return;
    }
    if (pdfFile == null) {
      AppUtil.showToastMessage(
        isError: true,
        message: 'Please select PDF file',
      );
      return;
    }

    final booksState = context.read<BooksState>();

    final success = await booksState.uploadBook(
      title: bookData['title'],
      description: bookData['description'],
      priceTzs: bookData['priceTzs'],
      totalPages: bookData['totalPages'],
      genreIds: bookData['genreIds'],
    );

    if (!success || booksState.uploadedBook == null) {
      AppUtil.showToastMessage(
        isError: true,
        message: booksState.uploadErrorMessage.isNotEmpty
            ? booksState.uploadErrorMessage
            : 'Failed to create book',
      );
      return;
    }

    final bookId = booksState.uploadedBook!.id;

    final coverSuccess = await booksState.uploadCover(coverImage!);
    if (!coverSuccess) {
      AppUtil.showToastMessage(
        isError: true,
        message: booksState.uploadFilesErrorMessage.isNotEmpty
            ? booksState.uploadFilesErrorMessage
            : 'Failed to upload cover image',
      );
      return;
    }

    final bookFileSuccess = await booksState.uploadBookFile(bookId, pdfFile!);
    if (!bookFileSuccess) {
      AppUtil.showToastMessage(
        isError: true,
        message: booksState.uploadFilesErrorMessage.isNotEmpty
            ? booksState.uploadFilesErrorMessage
            : 'Failed to upload book file',
      );
      return;
    }

    AppUtil.showToastMessage(
      isError: false,
      message: 'Book submitted successfully',
    );
    if (mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }
}
