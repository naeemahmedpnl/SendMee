

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final bool isCircular;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.isCircular = false,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[800]!,
      highlightColor: Colors.grey[600]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: isCircular
              ? BorderRadius.circular(height / 2)
              : BorderRadius.circular(8),
        ),
      ),
    );
  }
}

class BuildShimmerEffet extends StatefulWidget {
  const BuildShimmerEffet({super.key});

  @override
  State<BuildShimmerEffet> createState() => _BuildShimmerEffetState();
}

class _BuildShimmerEffetState extends State<BuildShimmerEffet> {
  @override
  Widget build(BuildContext context) {
    return _buildShimmerEffect();
  }
}

Widget _buildShimmerEffect() {
  return SingleChildScrollView(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Header
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ShimmerBox(width: 40, height: 40),
            ShimmerBox(width: 120, height: 24),
            ShimmerBox(width: 40, height: 40),
          ],
        ),
        const SizedBox(height: 20),

        // Profile Picture
        const ShimmerBox(width: 100, height: 100, isCircular: true),
        const SizedBox(height: 16),

        // Name and Rating
        const ShimmerBox(width: 150, height: 24),
        const SizedBox(height: 8),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ShimmerBox(width: 20, height: 20),
            SizedBox(width: 4),
            ShimmerBox(width: 20, height: 20),
            SizedBox(width: 4),
            ShimmerBox(width: 20, height: 20),
            SizedBox(width: 4),
            ShimmerBox(width: 20, height: 20),
            SizedBox(width: 4),
            ShimmerBox(width: 20, height: 20),
            SizedBox(width: 8),
            ShimmerBox(width: 30, height: 20),
          ],
        ),
        const SizedBox(height: 24),

        // Info Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey[800]!, width: 1),
          ),
          child: const Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ShimmerBox(width: 100, height: 20),
                  ShimmerBox(width: 150, height: 20),
                ],
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ShimmerBox(width: 100, height: 20),
                  ShimmerBox(width: 150, height: 20),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Earnings Container
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[800]!, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ShimmerBox(width: 150, height: 20),
              const SizedBox(height: 8),
              const ShimmerBox(width: 100, height: 24),
              const Divider(color: Colors.grey),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(
                  3,
                  (index) => const Column(
                    children: [
                      ShimmerBox(width: 80, height: 16),
                      SizedBox(height: 8),
                      ShimmerBox(width: 60, height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Wallet Section
        const SizedBox(height: 16),
        const Align(
          alignment: Alignment.centerLeft,
          child: ShimmerBox(width: 100, height: 24),
        ),
        const SizedBox(height: 10),
        Container(
          height: 60,
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[800]!, width: 1),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: const Row(
            children: [
              ShimmerBox(width: 28, height: 28),
              SizedBox(width: 15),
              ShimmerBox(width: 80, height: 20),
              Spacer(),
              ShimmerBox(width: 60, height: 20),
            ],
          ),
        ),
      ],
    ),
  );}