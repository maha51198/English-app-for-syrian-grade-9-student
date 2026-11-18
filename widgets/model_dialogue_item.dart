import 'package:flutter/material.dart';

import '../models/content.dart';
import 'word_tap_text.dart';

class ModelDialogueItem extends StatelessWidget {
  final Item item;

  const ModelDialogueItem({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.amber.shade100,
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text(
            'حوار نموذجي',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        if (item.english != null && item.english!.isNotEmpty)
          WordTapText(text: item.english!, isArabic: false),
        const SizedBox(height: 4),
        if (item.arabic != null && item.arabic!.isNotEmpty)
          WordTapText(text: item.arabic!, isArabic: true),
        if (item.modelAnswer != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '📝 النموذج:',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 4),
                if (item.modelAnswer!.english.isNotEmpty)
                  WordTapText(text: item.modelAnswer!.english, isArabic: false),
                if (item.modelAnswer!.arabic.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  WordTapText(text: item.modelAnswer!.arabic, isArabic: true),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}
