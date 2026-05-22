import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerCard extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerCard({
    Key? key,
    required this.width,
    required this.height,
    this.borderRadius = 12.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
      highlightColor: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }

  // A complete skeleton list card representing a loading car card
  static Widget carSkeleton(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShimmerCard(width: double.infinity, height: 160, borderRadius: 10),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ShimmerCard(width: screenWidth * 0.4, height: 18),
                ShimmerCard(width: screenWidth * 0.15, height: 18),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ShimmerCard(width: 80, height: 14),
                const SizedBox(width: 12),
                ShimmerCard(width: 60, height: 14),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ShimmerCard(width: 90, height: 24, borderRadius: 20),
                ShimmerCard(width: 100, height: 32, borderRadius: 8),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
