import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:tija/components/loading_overlay.dart';
import 'package:tija/constants/app_color.dart';
import 'package:tija/constants/app_theme.dart';
import 'package:tija/mixins/reader_mixin.dart';
import 'package:tija/states/theme_state.dart';
import 'package:tija/states/reader_state.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

// ---------------------------------------------------------------------------
// Args
// ---------------------------------------------------------------------------
class ReadScreenArgs {
  final String bookId;

  const ReadScreenArgs({required this.bookId});
}

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------
class ReadScreen extends StatefulWidget {
  final ReadScreenArgs args;
  const ReadScreen({super.key, required this.args});

  @override
  State<ReadScreen> createState() => _ReadScreenState();
}

class _ReadScreenState extends State<ReadScreen> with ReaderMixin {
  @override
  void initState() {
    super.initState();
    loadBook(widget.args.bookId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      body: Consumer<ReaderState>(
        builder: (context, readerState, _) {
          return LoadingOverlay(
            isVisible:
                readerState.isLoading ||
                readerState.isDecrypting ||
                (!isLoaded || readerState.pdfBytes == null),
            child: Builder(
              builder: (context) {

                if (!isLoaded || readerState.pdfBytes == null) {
                  return const SizedBox.shrink();
                }

                return Column(
                  children: [
                    _ReadAppBar(
                      title: readerState.readerResponse?.title ?? 'Book',
                      onBack: () {
                        context.read<ReaderState>().clear();
                        Navigator.of(context).pop();
                      },
                    ),
                    Expanded(
                      child: SfPdfViewer.memory(
                        readerState.pdfBytes!,
                        controller: pdfController,

                        onDocumentLoaded: (details) {
                          setState(() {
                            totalPages = details.document.pages.count;
                          });

                          if (currentPage > 1 && currentPage <= totalPages) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              pdfController.jumpToPage(currentPage);
                            });
                          }
                        },

                        onPageChanged: (PdfPageChangedDetails details) {
                          setState(() {
                            currentPage = details.newPageNumber;
                          });
                          updateReadingProgress(currentPage);
                        },
                      ),
                    ),
                    _ReadBottomBar(
                      currentPage: currentPage,
                      totalPages: totalPages,
                      onPrev: currentPage > 1 ? goToPrev : null,
                      onNext: currentPage < totalPages ? goToNext : null,
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// App bar
// ---------------------------------------------------------------------------
class _ReadAppBar extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const _ReadAppBar({required this.title, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final themeState = context.watch<ThemeState>();
    final width = MediaQuery.of(context).size.width;

    return SafeArea(
      bottom: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
                  onTap: onBack,
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
                Expanded(
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: width / 22,
                      fontWeight: FontWeight.w700,
                      color: theme.primaryText,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => themeState.toggleTheme(),
                  child: Container(
                    width: width / 10,
                    height: width / 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.secondaryBackground,
                    ),
                    child: Icon(
                      themeState.isDarkTheme ? Iconsax.sun_1 : Iconsax.moon,
                      color: theme.primaryText,
                      size: width / 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, thickness: 1, color: theme.lineColor),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bottom navigation bar
// ---------------------------------------------------------------------------
class _ReadBottomBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  const _ReadBottomBar({
    required this.currentPage,
    required this.totalPages,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final width = MediaQuery.of(context).size.width;
    final progress = totalPages > 1 ? currentPage / (totalPages - 1) : 1.0;

    return Container(
      padding: EdgeInsets.fromLTRB(
        width / 20,
        width / 30,
        width / 20,
        width / 30 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        border: Border(top: BorderSide(color: theme.lineColor, width: 1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _NavButton(
                icon: Icons.arrow_back_rounded,
                enabled: onPrev != null,
                onTap: onPrev,
              ),
              SizedBox(width: width / 22),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(width / 90),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: width / 90,
                    backgroundColor: theme.lineColor,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColor.defaultSecondaryColor,
                    ),
                  ),
                ),
              ),
              SizedBox(width: width / 22),
              _NavButton(
                icon: Icons.arrow_forward_rounded,
                enabled: onNext != null,
                onTap: onNext,
              ),
            ],
          ),
          SizedBox(height: width / 45),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Page $currentPage',
                style: TextStyle(
                  fontSize: width / 28,
                  color: theme.secondaryText,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${currentPage.toString().padLeft(2, '0')} / ${totalPages.toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontSize: width / 28,
                  color: theme.secondaryText,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback? onTap;

  const _NavButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width / 8.5,
        height: width / 8.5,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: enabled
              ? AppColor.defaultSecondaryColor
              : AppColor.defaultSecondaryColor.withValues(alpha: 0.35),
        ),
        child: Icon(icon, color: Colors.white, size: width / 17),
      ),
    );
  }
}
