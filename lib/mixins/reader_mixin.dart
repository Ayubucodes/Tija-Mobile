import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:tija/states/reader_state.dart';

mixin ReaderMixin<T extends StatefulWidget> on State<T> {
  final PdfViewerController pdfController = PdfViewerController();

  int currentPage = 1;
  int totalPages = 0;
  bool isLoaded = false;

  Future<void> loadBook(String bookId) async {
    final readerState = context.read<ReaderState>();

    await readerState.openBook(bookId);

    if (readerState.readerResponse != null) {
      await readerState.decryptBook();

      if (readerState.pdfBytes != null) {
        setState(() {
          currentPage = readerState.readerResponse!.currentPage + 1;
          isLoaded = true;
        });
      }
    }
  }

  void goToPrev() {
    if (currentPage > 1) {
      pdfController.previousPage();
    }
  }

  void goToNext() {
    if (currentPage < totalPages) {
      pdfController.nextPage();
    }
  }

  void updateReadingProgress(int page) {
    final progress = totalPages > 1 ? (page - 1) / (totalPages - 1) : 0.0;
    context.read<ReaderState>().updateProgress(page - 1, progress);
  }
}
