import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tija/states/author_state.dart';
import 'package:tija/states/reader_library_state.dart';

mixin AuthorDashboardMixin<T extends StatefulWidget> on State<T> {
  void loadDashboard() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthorState>().getAuthorDashboard();
      context.read<ReaderLibraryState>().getReaderLibrary();
    });
  }

  void retryLoadDashboard() {
    context.read<AuthorState>().getAuthorDashboard();
  }
}
