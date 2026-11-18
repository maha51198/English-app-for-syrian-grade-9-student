import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/tts_service.dart';
import '../services/word_translator.dart';

class WordTapText extends StatelessWidget {
  final String text;
  final bool isArabic;
  final double fontSize;
  final Color? color;
  final TextDirection? textDirection;
  final TextStyle? textStyle;

  const WordTapText({
    super.key,
    required this.text,
    required this.isArabic,
    this.fontSize = 14,
    this.color,
    this.textDirection,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final tts = context.read<TTSService>();

    // 🔥 تقسيم النص إلى كلمات
    final words = text.split(' ');

    // 🔥 استخدام Wrap بدلاً من Text.rich لحل مشكلة اتجاه النص العربي
    return Directionality(
      textDirection: textDirection ?? (isArabic ? TextDirection.rtl : TextDirection.ltr),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.start,
        spacing: 4, // مسافة صغيرة بين الكلمات
        runSpacing: 4, // مسافة بين الأسطر
        children: words.map((word) {
          // تنظيف الكلمة من علامات الترقيم قبل النطق
          String cleanWord = word.replaceAll(RegExp(r'[.,;:!?]'), '');

          return GestureDetector(
            onTap: () async {
              if (cleanWord.isEmpty) return;

              // 1. نطق الكلمة
              await tts.speakWord(cleanWord);

              // 2. الحصول على الترجمة
              final translation = WordTranslator.translateWord(cleanWord);

              // 3. عرض الترجمة في SnackBar
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$cleanWord: ${translation ?? 'لا توجد ترجمة'}'),
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: Text(
              word,
              style: textStyle ?? TextStyle(fontSize: fontSize, color: color),
              textAlign: isArabic ? TextAlign.right : TextAlign.left,
            ),
          );
        }).toList(),
      ),
    );
  }
}