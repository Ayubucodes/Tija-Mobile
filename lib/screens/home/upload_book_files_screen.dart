import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tija/components/action_button.dart';
import 'package:tija/constants/app_theme.dart';
import 'package:tija/mixins/upload_book_files_mixin.dart';
import 'package:tija/states/books_state.dart';

class UploadBookFilesScreen extends StatefulWidget {
  final Map<String, dynamic> bookData;

  const UploadBookFilesScreen({super.key, required this.bookData});

  @override
  State<UploadBookFilesScreen> createState() => _UploadBookFilesScreenState();
}

class _UploadBookFilesScreenState extends State<UploadBookFilesScreen>
    with UploadBookFilesMixin {
  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── App bar ─────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(
                width / 22,
                width / 45,
                width / 22,
                width / 45,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: width / 10,
                      height: width / 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.secondaryBackground,
                      ),
                      child: Icon(
                        Icons.chevron_left_rounded,
                        color: theme.primaryText,
                        size: width / 16,
                      ),
                    ),
                  ),
                  SizedBox(width: width / 38),
                  Expanded(
                    child: Text(
                      'Upload Files',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: theme.primaryText,
                      ),
                    ),
                  ),
                  SizedBox(width: width / 10),
                ],
              ),
            ),
            Divider(height: 1, thickness: 1, color: theme.lineColor),
            SizedBox(height: width / 22),

            // ── Form ────────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: EdgeInsets.fromLTRB(
                  width / 15,
                  0,
                  width / 15,
                  width / 3.5,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cover image upload
                    Text(
                      'Cover Image',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: theme.primaryText,
                      ),
                    ),
                    SizedBox(height: width / 30),
                    GestureDetector(
                      onTap: pickCoverImage,
                      child: Container(
                        height: width / 1.8,
                        decoration: BoxDecoration(
                          color: theme.inputFilledColor,
                          borderRadius: BorderRadius.circular(width / 27),
                          border: Border.all(color: theme.lineColor),
                        ),
                        child: coverImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(width / 27),
                                child: Image.file(
                                  coverImage!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_photo_alternate_outlined,
                                    size: width / 7.5,
                                    color: theme.secondaryText,
                                  ),
                                  SizedBox(height: width / 30),
                                  Text(
                                    'Tap to select cover image',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: theme.secondaryText,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    SizedBox(height: width / 15),

                    // PDF file upload
                    Text(
                      'Book PDF',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: theme.primaryText,
                      ),
                    ),
                    SizedBox(height: width / 30),
                    GestureDetector(
                      onTap: pickPdfFile,
                      child: Container(
                        height: width / 3,
                        decoration: BoxDecoration(
                          color: theme.inputFilledColor,
                          borderRadius: BorderRadius.circular(width / 27),
                          border: Border.all(color: theme.lineColor),
                        ),
                        child: pdfFile != null
                            ? Padding(
                                padding: EdgeInsets.all(width / 22),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.picture_as_pdf,
                                      size: width / 9,
                                      color: theme.primaryText,
                                    ),
                                    SizedBox(width: width / 22),
                                    Expanded(
                                      child: Text(
                                        pdfFile!.path.split('/').last,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: theme.primaryText,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.upload_file,
                                    size: width / 9,
                                    color: theme.secondaryText,
                                  ),
                                  SizedBox(height: width / 30),
                                  Text(
                                    'Tap to select PDF file',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: theme.secondaryText,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    SizedBox(height: width / 11),

                    // Submit button
                    Consumer<BooksState>(
                      builder: (context, booksState, _) {
                        return ActionButton(
                          text: 'Submit Book',
                          onPressed: booksState.isUploading
                              ? () {}
                              : () => onSubmit(widget.bookData),
                          isLoading: booksState.isUploading,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
