import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tija/constants/app_asset.dart';
import 'package:tija/constants/app_theme.dart';

class EmptyState extends StatelessWidget {
  final String message;
  final String? iconAsset;
  final double? iconSize;

  const EmptyState({
    super.key,
    required this.message,
    this.iconAsset,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final width = MediaQuery.of(context).size.width;

    return SizedBox(
      height: width / 1.6,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              iconAsset ?? AppAssets.STAR_ICON,
              width: iconSize ?? width / 16,
              height: iconSize ?? width / 16,
            ),
            SizedBox(height: width / 30),
            Text(
              message,
              style: TextStyle(
                fontSize: width / 26,
                color: theme.secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
