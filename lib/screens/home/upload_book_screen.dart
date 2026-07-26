import 'package:flutter/material.dart';
import 'package:tija/components/action_button.dart';
import 'package:tija/components/input_field.dart';
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
                      'Upload Book',
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
                    InputField(
                      label: 'Title',
                      hintText: 'Enter book title',
                      controller: titleController,
                    ),
                    SizedBox(height: width / 22),
                    InputField(
                      label: 'Description',
                      hintText: 'Enter book description',
                      controller: descriptionController,
                    ),
                    SizedBox(height: width / 22),
                    InputField(
                      label: 'Price (TZS)',
                      hintText: 'Enter price',
                      controller: priceController,
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: width / 22),
                    InputField(
                      label: 'Total Pages',
                      hintText: 'Enter total pages',
                      controller: totalPagesController,
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: width / 22),

                    // Genre selection
                    Text(
                      'Genres',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: theme.primaryText,
                        letterSpacing: 0.1,
                      ),
                    ),
                    SizedBox(height: width / 45),
                    Wrap(
                      spacing: width / 45,
                      runSpacing: width / 45,
                      children: availableGenres.map((genre) {
                        final isSelected = selectedGenreIds.contains(genre.id);
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                selectedGenreIds.remove(genre.id);
                              } else {
                                selectedGenreIds.add(genre.id);
                              }
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: width / 22,
                              vertical: width / 36,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? theme.primaryColor
                                  : theme.inputFilledColor,
                              borderRadius: BorderRadius.circular(width / 18),
                              border: Border.all(
                                color: isSelected
                                    ? theme.primaryColor
                                    : theme.lineColor,
                              ),
                            ),
                            child: Text(
                              genre.name,
                              style: TextStyle(
                                fontSize: 14,
                                color: isSelected
                                    ? Colors.white
                                    : theme.primaryText,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    SizedBox(height: width / 11),

                    // Next button
                    ActionButton(text: 'Next', onPressed: onNext),
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
