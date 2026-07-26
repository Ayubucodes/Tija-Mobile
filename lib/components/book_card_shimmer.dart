import 'package:flutter/material.dart';
import 'package:tija/constants/app_theme.dart';

class ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final double radius;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.radius = 8,
  });

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final base = theme.inputFilledColor;
    final highlight = theme.primaryBackground.withValues(alpha: 0.65);

    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            gradient: LinearGradient(
              begin: Alignment(-1 + (_controller.value * 2), 0),
              end: Alignment(1 + (_controller.value * 2), 0),
              colors: [
                base,
                highlight,
                base,
              ],
              stops: const [
                0.2,
                0.5,
                0.8,
              ],
            ),
          ),
        );
      },
    );
  }
}

class BookCardShimmer extends StatelessWidget {
  final double width;
  final double imageHeight;

  const BookCardShimmer({
    super.key,
    this.width = 130,
    this.imageHeight = 170,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return SizedBox(
      width: width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(
            width: width,
            height: imageHeight,
            radius: 12,
          ),

          SizedBox(height: screenWidth / 45),

          ShimmerBox(
            width: width * 0.8,
            height: 14,
            radius: 4,
          ),

          SizedBox(height: screenWidth / 60),

          ShimmerBox(
            width: width * 0.62,
            height: 12,
            radius: 4,
          ),

          SizedBox(height: screenWidth / 45),

          ShimmerBox(
            width: width * 0.5,
            height: 14,
            radius: 4,
          ),
        ],
      ),
    );
  }
}

class BookCardShimmerList extends StatelessWidget {
  final double itemWidth;
  final double imageHeight;
  final int itemCount;

  const BookCardShimmerList({
    super.key,
    required this.itemWidth,
    required this.imageHeight,
    this.itemCount = 4,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Calculate the exact height needed by each card.
    final cardHeight =
        imageHeight +
        (screenWidth / 45) +
        14 +
        (screenWidth / 60) +
        12 +
        (screenWidth / 45) +
        14;

    return SizedBox(
      height: cardHeight + 4, // Small safety margin
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth / 20,
        ),
        itemCount: itemCount,
        separatorBuilder: (_, __) =>
            SizedBox(width: screenWidth / 22),
        itemBuilder: (_, __) => BookCardShimmer(
          width: itemWidth,
          imageHeight: imageHeight,
        ),
      ),
    );
  }
}