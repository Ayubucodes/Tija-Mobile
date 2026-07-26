import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:tija/components/loading_overlay.dart';
import 'package:tija/constants/app_color.dart';
import 'package:tija/constants/app_theme.dart';
import 'package:tija/mixins/author_dashboard_mixin.dart';
import 'package:tija/screens/authentication/login.dart';
import 'package:tija/screens/home/reader_library_screen.dart';
import 'package:tija/states/auth_state.dart';
import 'package:tija/states/author_state.dart';
import 'package:tija/states/reader_library_state.dart';

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------
class AuthorDashboardScreen extends StatefulWidget {
  const AuthorDashboardScreen({super.key});

  @override
  State<AuthorDashboardScreen> createState() => _AuthorDashboardScreenState();
}

class _AuthorDashboardScreenState extends State<AuthorDashboardScreen>
    with AuthorDashboardMixin {
  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final width = MediaQuery.of(context).size.width;
    final authState = context.watch<AuthState>();

    return Consumer<AuthorState>(
      builder: (_, authorState, __) => LoadingOverlay(
        isVisible: authorState.isDashboardLoading,
        child: Scaffold(
          backgroundColor: theme.primaryBackground,
          body: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── App bar ──────────────────────────────────────────────────
                SafeArea(
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
                            // GestureDetector(
                            //   onTap: () => Navigator.of(context).pop(),
                            //   child: Container(
                            //     width: width / 10,
                            //     height: width / 10,
                            //     decoration: BoxDecoration(
                            //       shape: BoxShape.circle,
                            //       color: theme.secondaryBackground,
                            //     ),
                            //     child: Icon(
                            //       Icons.chevron_left_rounded,
                            //       color: theme.primaryText,
                            //       size: width / 16,
                            //     ),
                            //   ),
                            // ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Text(
                                  //   'Dashboard',
                                  //   textAlign: TextAlign.center,
                                  //   style: TextStyle(
                                  //     fontSize: width / 22,
                                  //     fontWeight: FontWeight.w700,
                                  //     color: theme.primaryText,
                                  //   ),
                                  // ),
                                  if (authState.user?.fullName != null)
                                    Text(
                                      authState.user!.fullName,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: width / 22,
                                        fontWeight: FontWeight.w700,
                                        color: theme.primaryText,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                await authState.logout();
                                if (mounted) {
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                      builder: (_) => const LoginScreen(),
                                    ),
                                    (route) => false,
                                  );
                                }
                              },
                              child: Container(
                                width: width / 12,
                                height: width / 12,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: theme.secondaryBackground,
                                ),
                                child: Icon(
                                  Iconsax.logout,
                                  color: theme.primaryText,
                                  size: width / 24,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(height: 1, thickness: 1, color: theme.lineColor),
                    ],
                  ),
                ),

                Expanded(
                  child: Consumer<AuthorState>(
                    builder: (context, authorState, _) {
                      if (authorState.isDashboardError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                authorState.dashboardErrorMessage,
                                style: TextStyle(
                                  fontSize: width / 26,
                                  color: theme.secondaryText,
                                ),
                              ),
                              SizedBox(height: width / 22),
                              ElevatedButton(
                                onPressed: retryLoadDashboard,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        );
                      }

                      final dashboard = authorState.authorDashboard;
                      if (dashboard == null) {
                        return Center(
                          child: Text(
                            'Dashboard not available',
                            style: TextStyle(
                              fontSize: width / 26,
                              color: theme.secondaryText,
                            ),
                          ),
                        );
                      }

                      return SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        padding: EdgeInsets.fromLTRB(
                          width / 22,
                          width / 90,
                          width / 22,
                          width / 12,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: width / 22),
                            GridView.count(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: 2,
                              mainAxisSpacing: width / 22,
                              crossAxisSpacing: width / 22,
                              childAspectRatio: 1.3,
                              children: [
                                _StatCard(
                                  icon: Iconsax.book,
                                  label: 'Total Books',
                                  value: dashboard.totalBooks.toString(),
                                  color: const Color(0xFF4CAF50),
                                  width: width,
                                  theme: theme,
                                ),
                                _StatCard(
                                  icon: Iconsax.book_saved,
                                  label: 'Published',
                                  value: dashboard.publishedBooks.toString(),
                                  color: const Color(0xFF2196F3),
                                  width: width,
                                  theme: theme,
                                ),
                                // _StatCard(
                                //   icon: Iconsax.shopping_cart,
                                //   label: 'Total Sales',
                                //   value: dashboard.totalSales.toString(),
                                //   color: const Color(0xFFFF9800),
                                //   width: width,
                                //   theme: theme,
                                // ),
                                _StatCard(
                                  icon: Iconsax.money,
                                  label: 'Revenue',
                                  value:
                                      'TZS ${dashboard.totalRevenueTzs.toStringAsFixed(0)}',
                                  color: const Color(0xFF9C27B0),
                                  width: width,
                                  theme: theme,
                                ),
                                // _StatCard(
                                //   icon: Iconsax.wallet,
                                //   label: 'Earnings',
                                //   value:
                                //       'TZS ${dashboard.totalEarningsTzs.toStringAsFixed(0)}',
                                //   color: const Color(0xFFE91E63),
                                //   width: width,
                                //   theme: theme,
                                // ),
                                // _StatCard(
                                //   icon: Iconsax.user,
                                //   label: 'Readers',
                                //   value: dashboard.totalReaders.toString(),
                                //   color: const Color(0xFF00BCD4),
                                //   width: width,
                                //   theme: theme,
                                // ),
                                // _StatCard(
                                //   icon: Iconsax.card,
                                //   label: 'Free Grants',
                                //   value: dashboard.totalFreeGrants.toString(),
                                //   color: const Color(0xFF8BC34A),
                                //   width: width,
                                //   theme: theme,
                                // ),
                                _StatCard(
                                  icon: Iconsax.money_send,
                                  label: 'Paid Out',
                                  value:
                                      'TZS ${dashboard.totalPaidOutTzs.toStringAsFixed(0)}',
                                  color: const Color(0xFFFF5722),
                                  width: width,
                                  theme: theme,
                                ),
                              ],
                            ),
                            SizedBox(height: width / 22),

                            // ── Pending Balance Card ───────────────────────────
                            Container(
                              padding: EdgeInsets.all(width / 22),
                              decoration: BoxDecoration(
                                color: theme.secondaryBackground,
                                borderRadius: BorderRadius.circular(width / 18),
                                border: Border.all(
                                  color: AppColor.defaultSecondaryColor,
                                  width: 2,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: width / 10,
                                    height: width / 10,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColor.defaultSecondaryColor,
                                    ),
                                    child: Icon(
                                      Iconsax.wallet_2,
                                      color: Colors.white,
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
                                          'Pending Balance',
                                          style: TextStyle(
                                            fontSize: width / 30,
                                            color: theme.secondaryText,
                                          ),
                                        ),
                                        SizedBox(height: width / 90),
                                        Text(
                                          'TZS ${dashboard.pendingBalanceTzs.toStringAsFixed(0)}',
                                          style: TextStyle(
                                            fontSize: width / 20,
                                            fontWeight: FontWeight.w700,
                                            color: theme.primaryText,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: width / 22),

                            // ── Upload Book Card ───────────────────────────────
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(width / 18),
                                onTap: () {
                                  // TODO: point this at your actual upload
                                  // flow/route. Common options:
                                  //   Navigator.of(context).pushNamed('/upload-book');
                                  //   Navigator.of(context).push(MaterialPageRoute(
                                  //     builder: (_) => const UploadBookScreen(),
                                  //   ));
                                },
                                child: Container(
                                  padding: EdgeInsets.all(width / 22),
                                  decoration: BoxDecoration(
                                    color: theme.secondaryBackground,
                                    borderRadius: BorderRadius.circular(
                                      width / 18,
                                    ),
                                    border: Border.all(
                                      color: AppColor.defaultSecondaryColor
                                          .withOpacity(0.4),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: width / 10,
                                        height: width / 10,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppColor.defaultSecondaryColor
                                              .withOpacity(0.12),
                                          border: Border.all(
                                            color: AppColor
                                                .defaultSecondaryColor
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
                                              'Upload a Book',
                                              style: TextStyle(
                                                fontSize: width / 28,
                                                fontWeight: FontWeight.w700,
                                                color: theme.primaryText,
                                              ),
                                            ),
                                            SizedBox(height: width / 150),
                                            Text(
                                              'Add a new title to your catalog',
                                              style: TextStyle(
                                                fontSize: width / 34,
                                                color: theme.secondaryText,
                                              ),
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
                            ),
                            SizedBox(height: width / 22),

                            // ── Books To Read Card ───────────────────────────────
                            Consumer<ReaderLibraryState>(
                              builder: (_, libraryState, __) {
                                return Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(
                                      width / 18,
                                    ),
                                    onTap: () async {
                                      // Show loading and fetch data
                                      await libraryState.getReaderLibrary();

                                      // Only navigate if not in error state
                                      if (!libraryState.isError && mounted) {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const ReaderLibraryScreen(),
                                          ),
                                        );
                                      } else if (libraryState.isError &&
                                          mounted) {
                                        // Show error message
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              libraryState.errorMessage,
                                            ),
                                            backgroundColor:
                                                AppColor.defaultErrorColor,
                                          ),
                                        );
                                      }
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(width / 22),
                                      decoration: BoxDecoration(
                                        color: theme.secondaryBackground,
                                        borderRadius: BorderRadius.circular(
                                          width / 18,
                                        ),
                                        border: Border.all(
                                          color: AppColor.defaultSecondaryColor
                                              .withOpacity(0.4),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
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
                                              Iconsax.book,
                                              color: AppColor
                                                  .defaultSecondaryColor,
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
                                                  'Books To Read',
                                                  style: TextStyle(
                                                    fontSize: width / 28,
                                                    fontWeight: FontWeight.w700,
                                                    color: theme.primaryText,
                                                  ),
                                                ),
                                                SizedBox(height: width / 150),
                                                Text(
                                                  '${libraryState.bookCount} books available',
                                                  style: TextStyle(
                                                    fontSize: width / 34,
                                                    color: theme.secondaryText,
                                                  ),
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
                                );
                              },
                            ),

                            // ── Stats Grid ─────────────────────────────────────
                          ],
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
// Stat Card
// ---------------------------------------------------------------------------
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final double width;
  final AppTheme theme;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.width,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(width / 24),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(width / 18),
        border: Border.all(color: theme.lineColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: width / 12,
            height: width / 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.12),
              border: Border.all(color: color.withOpacity(0.35), width: 1),
            ),
            child: Icon(icon, color: color, size: width / 26),
          ),
          SizedBox(height: width / 40),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: width / 32,
                  color: theme.secondaryText,
                  letterSpacing: 0.1,
                ),
              ),
              SizedBox(height: width / 150),
              Text(
                value,
                style: TextStyle(
                  fontSize: width / 25,
                  fontWeight: FontWeight.w700,
                  color: theme.primaryText,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
