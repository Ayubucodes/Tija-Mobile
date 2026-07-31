import 'package:flutter/material.dart';
import 'package:tija/components/action_button.dart';
import 'package:tija/components/dropdown_field.dart';
import 'package:tija/components/input_field.dart';
import 'package:tija/components/loading_overlay.dart';
import 'package:tija/components/shake_error.dart';
import 'package:tija/constants/app_color.dart';
import 'package:tija/constants/app_theme.dart';
import 'package:tija/mixins/upload_book_mixin.dart';

class UploadBookScreen extends StatefulWidget {
  const UploadBookScreen({super.key});

  @override
  State<UploadBookScreen> createState() => _UploadBookScreenState();
}

class _UploadBookScreenState extends State<UploadBookScreen>
    with UploadBookMixin {
  @override
  void initState() {
    super.initState();
    loadGenres();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final width = MediaQuery.of(context).size.width;

    return LoadingOverlay(
      isVisible: isNavigatingToUploadBookFilesScreen,
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
                        'Upload Book',
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

              // ── Form ────────────────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    width / 15,
                    width / 12,
                    width / 15,
                    width / 6,
                  ),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //     // Page subtitle
                        // Text(
                        //   'Book Details',
                        //   style: TextStyle(
                        //     fontSize: 18,
                        //     fontWeight: FontWeight.w700,
                        //     color: theme.primaryText,
                        //   ),
                        // ),
                        // SizedBox(height: width / 150),
                        // Padding(
                        //   padding: const EdgeInsets.symmetric(horizontal: 8),
                        //   child: Text(
                        //     'Add the information for your new book',
                        //     style: TextStyle(
                        //       fontSize: 14,
                        //       color: theme.secondaryText,
                        //     ),
                        //   ),
                        // ),
                        SizedBox(height: width / 24),
                        ShakeError(
                          key: titleShakeKey,
                          duration: const Duration(milliseconds: 500),
                          shakeCount: 3,
                          shakeOffset: 10,
                          child: InputField(
                            hintText: 'Enter title',
                            controller: titleController,
                            validator: validateTitle,
                          ),
                        ),
                        SizedBox(height: width / 12),
                        ShakeError(
                          key: priceShakeKey,
                          duration: const Duration(milliseconds: 500),
                          shakeCount: 3,
                          shakeOffset: 10,
                          child: InputField(
                            hintText: 'Enter price',
                            controller: priceController,
                            keyboardType: TextInputType.number,
                            validator: validatePrice,
                          ),
                        ),
                        SizedBox(height: width / 12),
                        ShakeError(
                          key: totalPagesShakeKey,
                          duration: const Duration(milliseconds: 500),
                          shakeCount: 3,
                          shakeOffset: 10,
                          child: InputField(
                            hintText: 'Enter total pages',
                            controller: totalPagesController,
                            keyboardType: TextInputType.number,
                            validator: validateTotalPages,
                          ),
                        ),
                        SizedBox(height: width / 12),
                        ShakeError(
                          key: genreShakeKey,
                          duration: const Duration(milliseconds: 500),
                          shakeCount: 3,
                          shakeOffset: 10,
                          child: DropdownField<String>(
                            hintText: 'Select genre',
                            value: selectedGenreId,
                            errorText: genreError,
                            items: availableGenres
                                .map(
                                  (genre) => DropdownItem(
                                    label: genre.name,
                                    value: genre.id,
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedGenreId = value;
                                genreError = null;
                              });
                            },
                          ),
                        ),
                        SizedBox(height: width / 12),
                        ShakeError(
                          key: descriptionShakeKey,
                          duration: const Duration(milliseconds: 500),
                          shakeCount: 3,
                          shakeOffset: 10,
                          child: TextFormField(
                            controller: descriptionController,
                            maxLines: 5,
                            style: TextStyle(
                              fontSize: width / 26,
                              color: theme.primaryText,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Enter description (max 37 words)',
                              hintStyle: TextStyle(
                                color: theme.secondaryText,
                                fontSize: width / 26,
                              ),
                              filled: true,
                              fillColor: theme.inputFilledColor,
                              contentPadding: EdgeInsets.all(width / 22),
                              errorStyle: const TextStyle(height: 0),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(width / 27),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(width / 27),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(width / 27),
                                borderSide: const BorderSide(
                                  color: AppColor.defaultSecondaryColor,
                                  width: 1,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(width / 27),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE53935),
                                  width: 1,
                                ),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(width / 27),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE53935),
                                  width: 1,
                                ),
                              ),
                            ),
                            validator: validateDescription,
                            onChanged: (value) {
                              final words = value.trim().split(RegExp(r'\s+'));
                              if (words.length > 37) {
                                final truncated = words.take(37).join(' ');
                                descriptionController.value = TextEditingValue(
                                  text: truncated,
                                  selection: TextSelection.collapsed(
                                    offset: truncated.length,
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
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
            child: ActionButton(text: 'Next', onPressed: onNext),
          ),
        ),
      ),
    );
  }
}
