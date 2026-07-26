import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tija/states/author_state.dart';

mixin AuthorDetailMixin<T extends StatefulWidget> on State<T> {
  bool isFollowing = false;

  void toggleFollow() => setState(() => isFollowing = !isFollowing);

  void loadAuthor(String authorId) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthorState>().getAuthorById(authorId);
    });
  }

  void retryLoadAuthor(String authorId) {
    context.read<AuthorState>().getAuthorById(authorId);
  }
}
