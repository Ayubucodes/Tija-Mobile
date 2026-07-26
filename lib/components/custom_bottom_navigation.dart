import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:tija/constants/app_color.dart';
import 'package:tija/constants/app_theme.dart';
import 'package:tija/screens/home/authors_screen.dart';
import 'package:tija/screens/home/author_dashboard_screen.dart';
import 'package:tija/screens/home/homepage.dart';
import 'package:tija/screens/home/profile_screen.dart';
import 'package:tija/screens/home/search_screen.dart';
import 'package:tija/states/auth_state.dart';

class CustomBottomNavigation extends StatefulWidget {
  final String? phoneNumber;

  const CustomBottomNavigation({super.key, this.phoneNumber});

  @override
  State<CustomBottomNavigation> createState() => _CustomBottomNavigationState();
}

class _CustomBottomNavigationState extends State<CustomBottomNavigation> {
  int _currentIndex = 0;

  List<Widget> getScreens(String? phoneNumber) {
    final authState = context.read<AuthState>();
    final isAuthor = authState.user?.roles.contains('Author') ?? false;

    return [
      const Homepage(),
      const AuthorsScreen(),
      const SearchScreen(),
      if (isAuthor) const AuthorDashboardScreen() else const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = AppTheme.of(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor: theme.primaryBackground,
        systemNavigationBarIconBrightness: isDark
            ? Brightness.light
            : Brightness.dark,
        systemNavigationBarContrastEnforced: false,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: IndexedStack(
              index: _currentIndex,
              children: getScreens(widget.phoneNumber),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomNavigationBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(width / 4.5, 0, width / 4.5, width / 110),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(width / 17),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                color: (isDark ? Colors.black : Colors.white).withValues(
                  alpha: 0.25,
                ),
                borderRadius: BorderRadius.circular(width / 17),
                border: Border.all(
                  color: Colors.white.withValues(alpha: isDark ? 0.12 : 0.4),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: Offset(0, width / 45),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: width / 60,
                  horizontal: width / 45,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (i) {
                    final isActive = i == _currentIndex;
                    return Padding(
                      padding: EdgeInsets.only(left: i == 0 ? 0 : width / 60),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _currentIndex = i;
                          });
                        },
                        behavior: HitTestBehavior.opaque,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: EdgeInsets.symmetric(
                            horizontal: width / 36,
                            vertical: width / 60,
                          ),
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppColor.defaultSecondaryColor.withValues(
                                    alpha: 0.18,
                                  )
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(width / 27),
                          ),
                          child: Icon(
                            _getIcon(i),
                            size: width / 22,
                            color: isActive
                                ? AppColor.defaultSecondaryColor
                                : AppTheme.of(context).secondaryText,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIcon(int index) {
    final authState = context.read<AuthState>();
    final isAuthor = authState.user?.roles.contains('Author') ?? false;

    switch (index) {
      case 0:
        return Iconsax.home_2;
      case 1:
        return Iconsax.book;
      case 2:
        return Iconsax.search_normal;
      case 3:
        return isAuthor ? Iconsax.chart_square : Iconsax.user;
      default:
        return Iconsax.home_2;
    }
  }
}
