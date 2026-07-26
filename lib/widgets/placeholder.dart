import 'package:flutter/material.dart';
import 'package:tija/constants/app_asset.dart';

class PlaceholderCover extends StatelessWidget {
  final double width;
  final double height;

  const PlaceholderCover({
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.asset(
        AppAssets.FALLBACK_IMAGE, 
        width: width,
        height: height,
        fit: BoxFit.cover,
      ),
    );
  }
}