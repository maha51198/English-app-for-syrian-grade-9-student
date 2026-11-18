import 'package:flutter/material.dart';

import '../models/content.dart';
import 'word_tap_text.dart';

class ExerciseItem extends StatelessWidget {
  final Item item;

  const ExerciseItem({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.purple.shade100,
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text(
            'تمرين',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        if (item.english != null && item.english!.isNotEmpty)
          WordTapText(text: item.english!, isArabic: false),
        const SizedBox(height: 4),
        if (item.arabic != null && item.arabic!.isNotEmpty)
          WordTapText(text: item.arabic!, isArabic: true),
        if (item.answers != null && item.answers!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '✏️ الإجابات:',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 4),
                for (final answer in item.answers!)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Expanded(
                          child: WordTapText(
                            text: answer.english,
                            isArabic: false,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: WordTapText(
                            text: answer.arabic,
                            isArabic: true,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
