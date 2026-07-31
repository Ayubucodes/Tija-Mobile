import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:tija/constants/app_theme.dart';
import 'package:tija/utils/app_util.dart';
import 'package:tija/widgets/placeholder.dart';

class BookCard extends StatelessWidget {
  final String title;
  final String author;
  final double price;
  final String imageUrl;
  final double width;
  final VoidCallback? onTap;
  final bool isNew;

  const BookCard({
    super.key,
    required this.title,
    required this.author,
    required this.price,
    required this.imageUrl,
    this.width = 130,
    this.onTap,
    this.isNew = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final radius = screenWidth / 27;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            // Cover image - flexes to fill remaining space, never overflows
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(radius),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: imageUrl.startsWith('http')
                          ? Image.network(
                              imageUrl,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => PlaceholderCover(
                                width: width,
                                height: double.infinity,
                              ),
                            )
                          : Image.asset(
                              imageUrl,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => PlaceholderCover(
                                width: width,
                                height: double.infinity,
                              ),
                            ),
                    ),
                    if (isNew) _NewRibbon(width: width),
                  ],
                ),
              ),
            ),
            SizedBox(height: screenWidth / 45),

            // Title
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: screenWidth / 28,
                fontWeight: FontWeight.w600,
                color: AppTheme.of(context).primaryText,
              ),
            ),
            SizedBox(height: screenWidth / 180),

            // Author
            Text(
              author,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: screenWidth / 32,
                fontWeight: FontWeight.w400,
                color: AppTheme.of(context).secondaryText,
              ),
            ),
            SizedBox(height: screenWidth / 90),

            // Price
            Text(
              AppUtil.formatMoney(price),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: screenWidth / 28,
                fontWeight: FontWeight.w600,
                color: AppTheme.of(context).primaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Diagonal "NEW" ribbon that sits in the top-left corner and
/// spans across it, joining the top and left edges of the card.
class _NewRibbon extends StatelessWidget {
  final double width;

  const _NewRibbon({required this.width});

  @override
  Widget build(BuildContext context) {
    // Ribbon length scales with the card so it always reaches both edges.
    final ribbonLength = width * 0.95;

    return Positioned(
      top: ribbonLength * 0.12,
      left: -ribbonLength * 0.32,
      child: Transform.rotate(
        angle: -math.pi / 4, // -45 degrees
        child: Container(
          width: ribbonLength,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            'NEW',
            style: TextStyle(
              fontSize: width / 11,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}