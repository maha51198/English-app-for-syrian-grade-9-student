import 'package:flutter/material.dart';

import '../utils/constants.dart';

class NavigationControls extends StatelessWidget {
  final int currentIndex;
  final int totalItems;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onSpeak;

  const NavigationControls({
    super.key,
    required this.currentIndex,
    required this.totalItems,
    required this.onPrevious,
    required this.onNext,
    required this.onSpeak,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Previous button
          ElevatedButton.icon(
            onPressed: currentIndex > 0 ? onPrevious : null,
            icon: const Icon(Icons.arrow_back, size: 18),
            label: const Text(AppStrings.back),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade200,
              foregroundColor: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 8),
          // Progress indicator (centered)
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${currentIndex + 1} / $totalItems',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: totalItems > 0 ? (currentIndex + 1) / totalItems : 0,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  minHeight: 4,
                  borderRadius: BorderRadius.circular(2),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Speak button
          IconButton(
            icon: const Icon(Icons.volume_up, color: AppColors.primary),
            onPressed: onSpeak,
            tooltip: 'نطق العنصر الحالي',
          ),
          const SizedBox(width: 4),
          // Next button
          ElevatedButton.icon(
            onPressed: currentIndex < totalItems - 1 ? onNext : null,
            icon: const Icon(Icons.arrow_forward, size: 18),
            label: const Text(AppStrings.next),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
