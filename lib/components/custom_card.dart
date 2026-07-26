import 'package:flutter/material.dart';
import 'package:tija/constants/app_theme.dart';
import 'package:tija/widgets/placeholder.dart';

class BookCard extends StatelessWidget {
  final String title;
  final String author;
  final String price;
  final String imageUrl;
  final double width;
  final double imageHeight;
  final VoidCallback? onTap;

  const BookCard({
    super.key,
    required this.title,
    required this.author,
    required this.price,
    required this.imageUrl,
    this.width = 130,
    this.imageHeight = 170,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover image
            ClipRRect(
              borderRadius: BorderRadius.circular(screenWidth / 27),
              child: imageUrl.startsWith('http')
                  ? Image.network(
                      imageUrl,
                      width: width,
                      height: imageHeight,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          PlaceholderCover(width: width, height: imageHeight),
                    )
                  : Image.asset(
                      imageUrl,
                      width: width,
                      height: imageHeight,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          PlaceholderCover(width: width, height: imageHeight),
                    ),
            ),
            SizedBox(height: screenWidth / 45),

            // Title
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
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
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: AppTheme.of(context).secondaryText,
              ),
            ),
            SizedBox(height: screenWidth / 90),

            // Price
            Text(
              price,
              style: TextStyle(
                fontSize: 13,
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
