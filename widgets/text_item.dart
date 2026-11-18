import 'package:flutter/material.dart';

import '../models/content.dart';
import 'word_tap_text.dart';

class TextItem extends StatelessWidget {
  final Item item;

  const TextItem({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (item.english != null && item.english!.isNotEmpty)
          WordTapText(text: item.english!, isArabic: false),
        if (item.arabic != null && item.arabic!.isNotEmpty) ...[
          const SizedBox(height: 4),
          WordTapText(text: item.arabic!, isArabic: true),
        ],
      ],
    );
  }
}
