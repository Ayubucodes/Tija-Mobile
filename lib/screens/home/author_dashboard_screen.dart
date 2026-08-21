import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:tija/components/loading_overlay.dart';
import 'package:tija/constants/app_color.dart';
import 'package:tija/constants/app_theme.dart';
import 'package:tija/mixins/author_dashboard_mixin.dart';
import 'package:tija/mixins/withdrawal_mixin.dart';
import 'package:tija/screens/authentication/login.dart';
import 'package:tija/states/auth_state.dart';
import 'package:tija/states/author_state.dart';
import 'package:tija/utils/app_util.dart';
import 'package:tija/widgets/empty_state.dart';

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------
class AuthorDashboardScreen extends StatefulWidget {
  const AuthorDashboardScreen({super.key});

  @override
  State<AuthorDashboardScreen> createState() => _AuthorDashboardScreenState();
}

class _AuthorDashboardScreenState extends State<AuthorDashboardScreen>
    with AuthorDashboardMixin, WithdrawalMixin {
  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  bool isNavigatingToUploadBookScreen = false;
  bool isNavigatingToReaderLibrary = false;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final width = MediaQuery.of(context).size.width;
    final authState = context.watch<AuthState>();

    return Consumer<AuthorState>(
      builder: (_, authorState, __) => LoadingOverlay(
        isVisible:
            authorState.isDashboardLoading ||
            isNavigatingToUploadBookScreen ||
            isNavigatingToReaderLibrary ||
            isNavigatingToAuthorLibrary ||
            isWithdrawing,
        child: Scaffold(
          backgroundColor: theme.primaryBackground,
          body: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── App bar ───────────────────────────────────────────────
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
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
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
                        return RefreshIndicator(
                          onRefresh: retryLoadDashboard,
                          displacement: 20,
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics(),
                            ),
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height,
                              child: EmptyState(
                                message:
                                    'Something went wrong, please logout and login again',
                              ),
                            ),
                          ),
                        );
                      }

                      final dashboard = authorState.authorDashboard;
                      if (dashboard == null) {
                        return RefreshIndicator(
                          onRefresh: retryLoadDashboard,
                          displacement: 20,
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics(),
                            ),
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height,
                              child: EmptyState(
                                message: 'Dashboard not available',
                              ),
                            ),
                          ),
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: retryLoadDashboard,
                        displacement: 20,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: MediaQuery.of(context).size.height,
                            ),
                            child: Padding(
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

                                  // ── Combined Overview Card ──────────────────────
                                  _OverviewCard(
                                    width: width,
                                    theme: theme,
                                    pendingBalanceTzs:
                                        dashboard.pendingBalanceTzs,
                                    totalBooks: dashboard.totalBooks,
                                    publishedBooks: dashboard.publishedBooks,
                                    revenueTzs: dashboard.totalRevenueTzs,
                                    paidOutTzs: dashboard.totalPaidOutTzs,
                                  ),
                                  SizedBox(height: width / 22),

                                  // ── Withdraw Money Card ─────────────────────────────
                                  Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(
                                        width / 18,
                                      ),
                                      onTap: () {
                                        showWithdrawalBottomSheet();
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(width / 22),
                                        decoration: BoxDecoration(
                                          color: theme.secondaryBackground,
                                          borderRadius: BorderRadius.circular(
                                            width / 18,
                                          ),
                                          border: Border.all(
                                            color: AppColor
                                                .defaultSecondaryColor
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
                                                Iconsax.money_send,
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
                                                    'Withdraw Money',
                                                    style: TextStyle(
                                                      fontSize: width / 28,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: theme.primaryText,
                                                    ),
                                                  ),
                                                  SizedBox(height: width / 150),
                                                  Text(
                                                    'Request withdrawal to your account',
                                                    style: TextStyle(
                                                      fontSize: width / 34,
                                                      color:
                                                          theme.secondaryText,
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

                                  Consumer<AuthorState>(
                                    builder: (_, authorState, __) {
                                      return Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(
                                            width / 18,
                                          ),
                                          onTap: () async {
                                            navigateToAuthorLibrary();
                                          },
                                          child: Container(
                                            padding: EdgeInsets.all(width / 22),
                                            decoration: BoxDecoration(
                                              color: theme.secondaryBackground,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    width / 18,
                                                  ),
                                              border: Border.all(
                                                color: AppColor
                                                    .defaultSecondaryColor
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
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        'My Books',
                                                        style: TextStyle(
                                                          fontSize: width / 28,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          color:
                                                              theme.primaryText,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: width / 150,
                                                      ),
                                                      Text(
                                                        '${authorState.authorDashboard?.totalBooks ?? 0} books available',
                                                        style: TextStyle(
                                                          fontSize: width / 34,
                                                          color: theme
                                                              .secondaryText,
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
                                  SizedBox(height: width / 22),

                                  // ── Upload Book Card ───────────────────────────────
                                  Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(
                                        width / 18,
                                      ),
                                      onTap: () {
                                        navigateToBookUploadScreen();
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(width / 22),
                                        decoration: BoxDecoration(
                                          color: theme.secondaryBackground,
                                          borderRadius: BorderRadius.circular(
                                            width / 18,
                                          ),
                                          border: Border.all(
                                            color: AppColor
                                                .defaultSecondaryColor
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
                                                Iconsax.document_upload,
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
                                                    'Upload a Book',
                                                    style: TextStyle(
                                                      fontSize: width / 28,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: theme.primaryText,
                                                    ),
                                                  ),
                                                  SizedBox(height: width / 150),
                                                  Text(
                                                    'Add a new title to your catalog',
                                                    style: TextStyle(
                                                      fontSize: width / 34,
                                                      color:
                                                          theme.secondaryText,
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
                                ],
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
// Overview Card — Pending Balance hero + secondary stats
// ---------------------------------------------------------------------------
class _OverviewCard extends StatefulWidget {
  final double width;
  final AppTheme theme;
  final double pendingBalanceTzs;
  final int totalBooks;
  final int publishedBooks;
  final double revenueTzs;
  final double paidOutTzs;

  const _OverviewCard({
    required this.width,
    required this.theme,
    required this.pendingBalanceTzs,
    required this.totalBooks,
    required this.publishedBooks,
    required this.revenueTzs,
    required this.paidOutTzs,
  });

  @override
  State<_OverviewCard> createState() => _OverviewCardState();
}

class _OverviewCardState extends State<_OverviewCard> {
  bool isHidden = true; // start hidden

  @override
  Widget build(BuildContext context) {
    final width = widget.width;
    return Container(
      padding: EdgeInsets.all(width / 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColor.defaultSecondaryColor,
            AppColor.defaultSecondaryColor.withOpacity(0.75),
          ],
        ),
        borderRadius: BorderRadius.circular(width / 16),
        boxShadow: [
          BoxShadow(
            color: AppColor.defaultSecondaryColor.withOpacity(0.28),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Hero: Pending Balance ─────────────────────────────────
          Row(
            children: [
              Container(
                width: width / 10,
                height: width / 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.18),
                ),
                child: Icon(
                  Iconsax.wallet_2,
                  color: Colors.white,
                  size: width / 20,
                ),
              ),
              SizedBox(width: width / 30),
              Expanded(
                child: Text(
                  'Pending Balance',
                  style: TextStyle(
                    fontSize: width / 28,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.9),
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    isHidden = !isHidden;
                  });
                },
                child: Container(
                  padding: EdgeInsets.all(width / 60),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.18),
                  ),
                  child: Icon(
                    isHidden ? Iconsax.eye_slash : Iconsax.eye,
                    color: Colors.white,
                    size: width / 26,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: width / 45),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              isHidden
                  ? 'TZS * * * * *'
                  : AppUtil.formatMoney(widget.pendingBalanceTzs),
              style: TextStyle(
                fontSize: width / 10,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1.0,
              ),
            ),
          ),
          SizedBox(height: width / 18),
          Divider(
            height: 1,
            thickness: 1,
            color: Colors.white.withOpacity(0.2),
          ),
          SizedBox(height: width / 18),

          // ── Secondary stats row ────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MiniStat(
                width: width,
                label: 'Total Books',
                value: widget.totalBooks.toString(),
              ),
              _MiniStat(
                width: width,
                label: 'Published',
                value: widget.publishedBooks.toString(),
              ),
            ],
          ),
          SizedBox(height: width / 22),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MiniStat(
                width: width,
                label: 'Revenue',
                value: isHidden
                    ? 'TZS * * * * *'
                    : AppUtil.formatMoney(widget.revenueTzs),
              ),
              _MiniStat(
                width: width,
                label: 'Paid Out',
                value: isHidden
                    ? 'TZS * * * * *'
                    : AppUtil.formatMoney(widget.paidOutTzs),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final double width;
  final String label;
  final String value;

  const _MiniStat({
    required this.width,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: width / 34,
              color: Colors.white.withOpacity(0.75),
              letterSpacing: 0.1,
            ),
          ),
          SizedBox(height: width / 150),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: width / 26,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
