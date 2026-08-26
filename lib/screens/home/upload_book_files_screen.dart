import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:tija/components/action_button.dart';
import 'package:tija/components/loading_overlay.dart';
import 'package:tija/constants/app_color.dart';
import 'package:tija/constants/app_theme.dart';
import 'package:tija/mixins/upload_book_files_mixin.dart';
import 'package:tija/states/books_state.dart';

class UploadBookFilesScreen extends StatefulWidget {
  final String bookId;
  final String title;
  final String description;
  final double priceTzs;
  final int totalPages;
  final List<String> genreIds;

  const UploadBookFilesScreen({
    super.key,
    required this.bookId,
    required this.title,
    required this.description,
    required this.priceTzs,
    required this.totalPages,
    required this.genreIds,
  });

  @override
  State<UploadBookFilesScreen> createState() => _UploadBookFilesScreenState();
}

class _UploadBookFilesScreenState extends State<UploadBookFilesScreen>
    with UploadBookFilesMixin {
  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final width = MediaQuery.of(context).size.width;

    return LoadingOverlay(
      isVisible: isSubmittingBook,
      child: Scaffold(
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
                child: SizedBox(
                  height: width / 10,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Centered title, independent of the back button's width
                      Text(
                        'Upload Files',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: theme.primaryText,
                        ),
                      ),
                      // Back button pinned to the left
                      Align(
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
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
                      ),
                    ],
                  ),
                ),
              ),
              Divider(height: 1, thickness: 1, color: theme.lineColor),
              SizedBox(height: width / 22),

              // ── Form ────────────────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    width / 15,
                    width / 20,
                    width / 15,
                    width / 6,
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
                          decoration: BoxDecoration(
                            color: theme.inputFilledColor,
                            borderRadius: BorderRadius.circular(width / 27),
                            border: Border.all(color: theme.lineColor),
                          ),
                          padding: EdgeInsets.all(width / 25),
                          child: isPackingCover
                              ? _PackingRow(
                                  width: width,
                                  theme: theme,
                                  icon: Iconsax.gallery_add,
                                  title: 'Preparing Cover Image…',
                                  progress: coverPackProgress,
                                )
                              : Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                        width / 10,
                                      ),
                                      child: coverImage != null
                                          ? Image.file(
                                              coverImage!,
                                              width: width / 10,
                                              height: width / 10,
                                              fit: BoxFit.cover,
                                            )
                                          : Container(
                                              width: width / 10,
                                              height: width / 10,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: AppColor
                                                    .defaultSecondaryColor
                                                    .withOpacity(0.12),
                                                border: Border.all(
                                                  color: AppColor
                                                      .defaultSecondaryColor
                                                      .withOpacity(0.4),
                                                  width: 1,
                                                ),
                                              ),
                                              child: Icon(
                                                Iconsax.gallery_add,
                                                color: AppColor
                                                    .defaultSecondaryColor,
                                                size: width / 20,
                                              ),
                                            ),
                                    ),
                                    SizedBox(width: width / 22),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            coverImage != null
                                                ? 'Cover Image Selected'
                                                : 'Upload a Cover Image',
                                            style: TextStyle(
                                              fontSize: width / 28,
                                              fontWeight: FontWeight.w700,
                                              color: theme.primaryText,
                                            ),
                                          ),
                                          SizedBox(height: width / 150),
                                          Text(
                                            coverImage != null
                                                ? coverImage!.path
                                                      .split('/')
                                                      .last
                                                : 'Add a cover photo for your book',
                                            style: TextStyle(
                                              fontSize: width / 34,
                                              color: theme.secondaryText,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Iconsax.arrow_right_3,
                                      color: theme.secondaryText,
                                      size: width / 24,
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
                          decoration: BoxDecoration(
                            color: theme.inputFilledColor,
                            borderRadius: BorderRadius.circular(width / 27),
                            border: Border.all(color: theme.lineColor),
                          ),
                          padding: EdgeInsets.all(width / 25),
                          child: isPackingPdf
                              ? _PackingRow(
                                  width: width,
                                  theme: theme,
                                  icon: Iconsax.document_upload,
                                  title: 'Preparing PDF File…',
                                  progress: pdfPackProgress,
                                )
                              : Row(
                                  children: [
                                    Container(
                                      width: width / 10,
                                      height: width / 10,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColor.defaultSecondaryColor
                                            .withOpacity(0.12),
                                        border: Border.all(
                                          color: AppColor.defaultSecondaryColor
                                              .withOpacity(0.4),
                                          width: 1,
                                        ),
                                      ),
                                      child: Icon(
                                        Iconsax.document_upload,
                                        color: AppColor.defaultSecondaryColor,
                                        size: width / 20,
                                      ),
                                    ),
                                    SizedBox(width: width / 22),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            pdfFile != null
                                                ? 'PDF Selected'
                                                : 'Upload Book PDF',
                                            style: TextStyle(
                                              fontSize: width / 28,
                                              fontWeight: FontWeight.w700,
                                              color: theme.primaryText,
                                            ),
                                          ),
                                          SizedBox(height: width / 150),
                                          Text(
                                            pdfFile != null
                                                ? pdfFile!.path.split('/').last
                                                : 'Add the manuscript as a PDF file',
                                            style: TextStyle(
                                              fontSize: width / 34,
                                              color: theme.secondaryText,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Iconsax.arrow_right_3,
                                      color: theme.secondaryText,
                                      size: width / 24,
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Floating bottom-sheet-style action button ──────────────
        bottomNavigationBar: SafeArea(
          top: false,
          minimum: EdgeInsets.fromLTRB(
            width / 15,
            width / 20,
            width / 15,
            width / 20,
          ),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: width / 25,
              vertical: width / 28,
            ),
            child: Consumer<BooksState>(
              builder: (context, booksState, _) {
                return ActionButton(
                  text: 'Submit Book',
                  onPressed: booksState.isUploading
                      ? () {}
                      : () => onSubmit(
                          widget.bookId,
                          title: widget.title,
                          description: widget.description,
                          priceTzs: widget.priceTzs,
                          totalPages: widget.totalPages,
                          genreIds: widget.genreIds,
                        ),
                  isLoading: booksState.isUploading,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Shown inside an upload card while a picked file is being read off
/// disk and prepared, in place of the icon/title/arrow row.
class _PackingRow extends StatelessWidget {
  final double width;
  final dynamic theme;
  final IconData icon;
  final String title;
  final double progress;

  const _PackingRow({
    required this.width,
    required this.theme,
    required this.icon,
    required this.title,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (progress.clamp(0.0, 1.0) * 100).round();

    return Row(
      children: [
        Container(
          width: width / 10,
          height: width / 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColor.defaultSecondaryColor.withOpacity(0.12),
          ),
          child: Center(
            child: SizedBox(
              width: width / 16,
              height: width / 16,
              child: CircularProgressIndicator(
                value: progress > 0 ? progress : null,
                strokeWidth: 2.5,
                color: AppColor.defaultSecondaryColor,
                backgroundColor: AppColor.defaultSecondaryColor.withOpacity(
                  0.2,
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: width / 22),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: width / 28,
                  fontWeight: FontWeight.w700,
                  color: theme.primaryText,
                ),
              ),
              SizedBox(height: width / 60),
              ClipRRect(
                borderRadius: BorderRadius.circular(width / 60),
                child: LinearProgressIndicator(
                  value: progress > 0 ? progress : null,
                  minHeight: width / 60,
                  color: AppColor.defaultSecondaryColor,
                  backgroundColor: AppColor.defaultSecondaryColor.withOpacity(
                    0.15,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: width / 30),
        Text(
          '$percent%',
          style: TextStyle(
            fontSize: width / 28,
            fontWeight: FontWeight.w700,
            color: AppColor.defaultSecondaryColor,
          ),
        ),
      ],
    );
  }
}
