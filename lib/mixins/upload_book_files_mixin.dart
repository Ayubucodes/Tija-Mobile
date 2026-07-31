import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:tija/states/books_state.dart';
import 'package:tija/utils/app_util.dart';

mixin UploadBookFilesMixin<T extends StatefulWidget> on State<T> {
  bool isSubmittingBook = false;
  final ImagePicker picker = ImagePicker();
  File? coverImage;
  File? pdfFile;

  // ── Pack (pick + prepare) progress ─────────────────────────────
  // These track the local read of the picked file, not the network
  // upload that happens later in onSubmit(). Bigger files naturally
  // take longer to stream off disk, so the progress value is
  // byte-accurate rather than simulated.
  bool isPackingCover = false;
  bool isPackingPdf = false;
  double coverPackProgress = 0.0;
  double pdfPackProgress = 0.0;

  Future<void> pickCoverImage() async {
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (image == null) return;

      await _packFile(
        File(image.path),
        onStart: () => setState(() {
          isPackingCover = true;
          coverPackProgress = 0.0;
        }),
        onProgress: (p) => setState(() => coverPackProgress = p),
        onDone: (file) => setState(() {
          coverImage = file;
          isPackingCover = false;
        }),
      );
    } catch (e) {
      setState(() => isPackingCover = false);
      AppUtil.showToastMessage(isError: true, message: 'Failed to pick image');
    }
  }

  Future<void> pickPdfFile() async {
    try {
      // NOTE: this currently opens the image picker, so users can only
      // choose photos here — swap to file_picker if PDF selection is
      // needed. Left untouched since it's outside this change's scope.
      final XFile? file = await picker.pickImage(source: ImageSource.gallery);
      if (file == null) return;

      await _packFile(
        File(file.path),
        onStart: () => setState(() {
          isPackingPdf = true;
          pdfPackProgress = 0.0;
        }),
        onProgress: (p) => setState(() => pdfPackProgress = p),
        onDone: (f) => setState(() {
          pdfFile = f;
          isPackingPdf = false;
        }),
      );
    } catch (e) {
      setState(() => isPackingPdf = false);
      AppUtil.showToastMessage(isError: true, message: 'Failed to pick file');
    }
  }

  /// Streams [source] off disk in chunks so we can report a real,
  /// size-based progress value (bytesRead / totalBytes) while the file
  /// is being prepared, instead of just freezing the UI until it's done.
  Future<void> _packFile(
    File source, {
    required VoidCallback onStart,
    required ValueChanged<double> onProgress,
    required ValueChanged<File> onDone,
  }) async {
    onStart();

    final total = await source.length();
    var bytesRead = 0;

    await for (final chunk in source.openRead()) {
      bytesRead += chunk.length;
      onProgress(total == 0 ? 1.0 : (bytesRead / total).clamp(0.0, 1.0));
    }

    onDone(source);
  }

  Future<void> onSubmit(
    String bookId, {
    required String title,
    required String description,
    required double priceTzs,
    required int totalPages,
    required List<String> genreIds,
  }) async {
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

    setState(() => isSubmittingBook = true);

    final booksState = context.read<BooksState>();

    final coverSuccess = await booksState.uploadCover(coverImage!);
    if (!coverSuccess) {
      if (mounted) {
        setState(() => isSubmittingBook = false);
      }
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
      if (mounted) {
        setState(() => isSubmittingBook = false);
      }
      AppUtil.showToastMessage(
        isError: true,
        message: booksState.uploadFilesErrorMessage.isNotEmpty
            ? booksState.uploadFilesErrorMessage
            : 'Failed to upload book file',
      );
      return;
    }

    // Get the URLs from upload responses
    final coverImageUrl = booksState.coverUploadResponse?['url'] ?? '';
    final bookFileUrl = booksState.bookFileUploadResponse?['bookFileUrl'] ?? '';

    // Call updateBook API to set the image properly
    await booksState.updateBook(
      bookId: bookId,
      title: title,
      description: description,
      priceTzs: priceTzs,
      coverImageUrl: coverImageUrl,
      bookFileUrl: bookFileUrl,
      totalPages: totalPages,
      genreIds: genreIds,
    );

    if (booksState.isUpdateBookError) {
      if (mounted) {
        setState(() => isSubmittingBook = false);
      }
      AppUtil.showToastMessage(
        isError: true,
        message: booksState.updateBookErrorMessage.isNotEmpty
            ? booksState.updateBookErrorMessage
            : 'Failed to update book',
      );
      return;
    }

    if (mounted) {
      setState(() => isSubmittingBook = false);
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
