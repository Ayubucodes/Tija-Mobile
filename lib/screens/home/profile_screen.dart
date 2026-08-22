import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:tija/components/custom_bottom_navigation.dart';
import 'package:tija/components/loading_overlay.dart';
import 'package:tija/constants/app_color.dart';
import 'package:tija/constants/app_theme.dart';
import 'package:tija/mixins/profile_mixin.dart';
import 'package:tija/states/auth_state.dart';
import 'package:tija/states/reader_library_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with ProfileMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final width = MediaQuery.of(context).size.width;

    return LoadingOverlay(
      isVisible: isNavigatingToReaderLibrary,
      child: Scaffold(
        backgroundColor: theme.primaryBackground,
        extendBody: true,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // ── Top bar ───────────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.fromLTRB(
                  width / 45,
                  width / 30,
                  width / 18,
                  0,
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CustomBottomNavigation(),
                          ),
                          (route) => false,
                        );
                      },
                      icon: Icon(
                        Icons.chevron_left_rounded,
                        size: width / 13,
                        color: theme.primaryText,
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'Profile',
                          style: TextStyle(
                            fontSize: width / 22,
                            fontWeight: FontWeight.w600,
                            color: theme.primaryText,
                          ),
                        ),
                      ),
                    ),
                    // Logout
                    GestureDetector(
                      onTap: onLogout,
                      child: Padding(
                        padding: EdgeInsets.only(right: width / 90),
                        child: Icon(
                          Iconsax.logout,
                          size: width / 20,
                          color: AppColor.defaultSecondaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: width / 18),

              // ── Scrollable body ───────────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: EdgeInsets.only(bottom: width / 3.5),
                  child: Column(
                    children: [
                      // ── Avatar ────────────────────────────────────────────
                      Consumer<AuthState>(
                        builder: (_, authState, __) {
                          final user = authState.user;
                          return Column(
                            children: [
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    width: width / 4,
                                    height: width / 4,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppColor.defaultSecondaryColor,
                                        width: width / 120,
                                      ),
                                    ),
                                    child: ClipOval(
                                      child: Container(
                                        color: AppColor.inputFillColor,
                                        child: Icon(
                                          Iconsax.user,
                                          size: width / 7.5,
                                          color: AppColor.subtitleColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (user != null) ...[
                                SizedBox(height: width / 36),
                                Text(
                                  user.fullName,
                                  style: TextStyle(
                                    fontSize: width / 22,
                                    fontWeight: FontWeight.w700,
                                    color: theme.primaryText,
                                  ),
                                ),
                              ],
                            ],
                          );
                        },
                      ),
                      SizedBox(height: width / 11),

                      Consumer<AuthState>(
                        builder: (_, authState, __) {
                          final user = authState.user;
                          if (user == null) return const SizedBox.shrink();

                          return Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: width / 15,
                            ),
                            child: Column(
                              children: [
                                _ProfileCard(
                                  icon: Iconsax.user,
                                  label: 'Name',
                                  value: user.fullName,
                                  width: width,
                                  theme: theme,
                                ),
                                SizedBox(height: width / 22),
                                _ProfileCard(
                                  icon: Iconsax.shield,
                                  label: 'Role',
                                  value: user.roles.isNotEmpty
                                      ? user.roles.first
                                      : 'N/A',
                                  width: width,
                                  theme: theme,
                                ),
                                SizedBox(height: width / 22),
                                _ProfileCard(
                                  icon: Iconsax.message,
                                  label: 'Email',
                                  value: userEmail,
                                  width: width,
                                  theme: theme,
                                ),
                                SizedBox(height: width / 22),
                                Consumer<ReaderLibraryState>(
                                  builder: (_, libraryState, __) {
                                    return _ProfileCard(
                                      icon: Iconsax.book,
                                      label: 'My Books',
                                      value: libraryState.bookCount.toString(),
                                      width: width,
                                      theme: theme,
                                      onTap: () async {
                                        navigateToReaderLibrary();
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
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
      ),
    );
  }

  Widget _ProfileCard({
    required IconData icon,
    required String label,
    required String value,
    required double width,
    required AppTheme theme,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(width / 18),
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
              Container(
                width: width / 16,
                height: width / 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColor.defaultSecondaryColor.withOpacity(0.12),
                ),
                child: Icon(
                  icon,
                  color: AppColor.defaultSecondaryColor,
                  size: width / 32,
                ),
              ),
              SizedBox(width: width / 22),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: width / 34,
                        color: theme.secondaryText,
                      ),
                    ),
                    SizedBox(height: width / 150),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: width / 28,
                        fontWeight: FontWeight.w600,
                        color: theme.primaryText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (onTap != null)
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
}
