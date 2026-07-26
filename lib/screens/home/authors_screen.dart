import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:tija/components/loading_overlay.dart';
import 'package:tija/constants/app_asset.dart';
import 'package:tija/constants/app_color.dart';
import 'package:tija/constants/app_theme.dart';
import 'package:tija/mixins/search_mixin.dart';
import 'package:tija/models/author_model.dart';
import 'package:tija/screens/home/author_detail_screen.dart';
import 'package:tija/states/author_state.dart';

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------
class AuthorsScreen extends StatefulWidget {
  const AuthorsScreen({super.key});

  @override
  State<AuthorsScreen> createState() => _AuthorsScreenState();
}

class _AuthorsScreenState extends State<AuthorsScreen> with SearchMixin {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthorState>().getAuthors();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final width = MediaQuery.of(context).size.width;

    return Consumer<AuthorState>(
      builder: (_, authorState, __) => LoadingOverlay(
        isVisible: authorState.isLoading || authorState.isDetailLoading,
        child: Scaffold(
          backgroundColor: theme.primaryBackground,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                // ── App bar with centered title ────────────────────────────
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
                        // Centered title — stays centered regardless of
                        // any leading/trailing icons added later.
                        Center(
                          child: Text(
                            'Authors',
                            style: TextStyle(
                              fontSize: width / 22,
                              fontWeight: FontWeight.w700,
                              color: theme.primaryText,
                            ),
                          ),
                        ),
                        // Uncomment if you bring back a leading back button:
                        // Align(
                        //   alignment: Alignment.centerLeft,
                        //   child: GestureDetector(
                        //     onTap: () => Navigator.of(context).pop(),
                        //     child: Container(
                        //       width: width / 10,
                        //       height: width / 10,
                        //       decoration: BoxDecoration(
                        //         shape: BoxShape.circle,
                        //         color: theme.secondaryBackground,
                        //       ),
                        //       child: Icon(
                        //         Icons.chevron_left_rounded,
                        //         color: theme.primaryText,
                        //         size: width / 16,
                        //       ),
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ),
                Divider(height: 1, thickness: 1, color: theme.lineColor),
                SizedBox(height: width / 22),

                // ── Search bar ──────────────────────────────────────────
                Padding(
                  padding: EdgeInsets.fromLTRB(width / 22, 0, width / 22, 0),
                  child: Container(
                    height: width / 8,
                    padding: EdgeInsets.symmetric(horizontal: width / 45),
                    decoration: BoxDecoration(
                      color: theme.inputFilledColor,
                      borderRadius: BorderRadius.circular(width / 27),
                    ),
                    child: Row(
                      children: [
                        // Prefix icon — search, in a soft circular badge
                        Container(
                          width: width / 16,
                          height: width / 16,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColor.defaultSecondaryColor.withOpacity(
                              0.12,
                            ),
                          ),
                          child: Icon(
                            Iconsax.search_normal,
                            color: AppColor.defaultSecondaryColor,
                            size: width / 32,
                          ),
                        ),
                        SizedBox(width: width / 45),
                        Expanded(
                          child: TextField(
                            controller: searchController,
                            onChanged: (_) => setState(() {}),
                            style: TextStyle(
                              fontSize: width / 26,
                              color: theme.primaryText,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Search authors...',
                              hintStyle: TextStyle(
                                color: theme.secondaryText,
                                fontSize: width / 26,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        // Cancel icon — clears the search text, only shown
                        // once the user has typed something.
                        if (searchController.text.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              searchController.clear();
                              setState(() {});
                            },
                            child: Padding(
                              padding: EdgeInsets.only(left: width / 45),
                              child: Icon(
                                Iconsax.close_circle,
                                color: theme.secondaryText,
                                size: width / 22,
                              ),
                            ),
                          ),
                        SizedBox(width: width / 60),
                        // Suffix icon — filter/sort action
                        GestureDetector(
                          onTap: () {
                            // TODO: hook up filter/sort logic here
                          },
                          child: Icon(
                            Iconsax.setting_4,
                            color: theme.secondaryText,
                            size: width / 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: width / 45),

                // ── Authors list ────────────────────────────────────────
                Expanded(
                  child: Consumer<AuthorState>(
                    builder: (context, authorState, _) {
                      if (authorState.isError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                authorState.errorMessage,
                                style: TextStyle(
                                  fontSize: width / 26,
                                  color: theme.secondaryText,
                                ),
                              ),
                              SizedBox(height: width / 22),
                              ElevatedButton(
                                onPressed: () => authorState.getAuthors(),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        );
                      }

                      if (authorState.authors.isEmpty) {
                        return Center(
                          child: Text(
                            'No authors found',
                            style: TextStyle(
                              fontSize: width / 26,
                              color: theme.secondaryText,
                            ),
                          ),
                        );
                      }

                      // Filter authors based on search query
                      final searchQuery = searchController.text.toLowerCase();
                      final filteredAuthors = authorState.authors.where((
                        author,
                      ) {
                        return author.fullName.toLowerCase().contains(
                          searchQuery,
                        );
                      }).toList();

                      if (filteredAuthors.isEmpty) {
                        return Center(
                          child: Text(
                            'No authors match "${searchController.text}"',
                            style: TextStyle(
                              fontSize: width / 26,
                              color: theme.secondaryText,
                            ),
                          ),
                        );
                      }

                      return ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        padding: EdgeInsets.fromLTRB(
                          width / 22,
                          width / 30,
                          width / 22,
                          width / 3.5,
                        ),
                        itemCount: filteredAuthors.length,
                        separatorBuilder: (_, __) =>
                            SizedBox(height: width / 30),
                        itemBuilder: (_, i) => _AuthorRow(
                          author: filteredAuthors[i],
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => AuthorDetailScreen(
                                authorId: filteredAuthors[i].id,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Author row (card style)
// ---------------------------------------------------------------------------
class _AuthorRow extends StatelessWidget {
  final Author author;
  final VoidCallback onTap;

  const _AuthorRow({required this.author, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final width = MediaQuery.of(context).size.width;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(width / 18),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(width / 22),
          decoration: BoxDecoration(
            color: theme.secondaryBackground,
            borderRadius: BorderRadius.circular(width / 18),
            border: Border.all(
              color: AppColor.defaultSecondaryColor.withOpacity(0.4),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Avatar in tinted, bordered circle
              Container(
                width: width / 10,
                height: width / 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColor.defaultSecondaryColor.withOpacity(0.12),
                  border: Border.all(
                    color: AppColor.defaultSecondaryColor.withOpacity(0.4),
                    width: 1,
                  ),
                ),
                child: ClipOval(
                  child: author.profilePictureUrl != null
                      ? Image.network(
                          author.profilePictureUrl!,
                          width: width / 10,
                          height: width / 10,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _buildDefaultAvatarIcon(width),
                        )
                      : _buildDefaultAvatarIcon(width),
                ),
              ),
              SizedBox(width: width / 22),

              // Name + stats
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      author.fullName,
                      style: TextStyle(
                        fontSize: width / 28,
                        fontWeight: FontWeight.w700,
                        color: theme.primaryText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: width / 150),
                    Text(
                      '${author.totalBooks} books',
                      style: TextStyle(
                        fontSize: width / 34,
                        color: theme.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: width / 38),

              // Rating (optional)
              if (author.averageRating != null) ...[
                Icon(
                  Icons.star_rounded,
                  color: const Color(0xFFFFB800),
                  size: width / 24,
                ),
                SizedBox(width: width / 90),
                Text(
                  author.averageRating!.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: width / 28,
                    fontWeight: FontWeight.w600,
                    color: theme.primaryText,
                  ),
                ),
                SizedBox(width: width / 45),
              ],

              // Trailing arrow
              Icon(
                Iconsax.arrow_right_3,
                color: theme.secondaryText,
                size: width / 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultAvatarIcon(double width) {
    return Icon(
      Iconsax.user,
      color: AppColor.defaultSecondaryColor,
      size: width / 20,
    );
  }
}