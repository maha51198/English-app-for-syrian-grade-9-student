import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/content.dart';
import '../services/tts_service.dart';
import 'word_tap_text.dart';
import '../utils/constants.dart';

class QuestionItem extends StatelessWidget {
  final Item item;

  const QuestionItem({super.key, required this.item});

  // 🔥 دالة نطق الإجابة النموذجية
  void _speakModelAnswer(BuildContext context) {
    final tts = context.read<TTSService>();
    if (item.modelAnswer != null) {
      String text = item.modelAnswer!.english;
      text = text
          .replaceAll(RegExp(r'\d+'), ' ')
          .replaceAll(RegExp(r'_+'), ' ');
      tts.speak(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final questionData = _parseQuestion(item.english ?? '');
    final arabicQuestionData = _parseArabicQuestion(item.arabic ?? '');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),

          // السؤال الرئيسي بالإنجليزية
          if (questionData.question.isNotEmpty)
            WordTapText(
              text: questionData.question,
              isArabic: false,
              fontSize: 16,
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

          // الترجمة العربية للسؤال
          if (arabicQuestionData.question.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              arabicQuestionData.question,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
                height: 1.5,
              ),
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
          ],

          const SizedBox(height: 16),

          // الخيارات (a, b, c)
          if (questionData.options.isNotEmpty) ...[
            ...questionData.options.asMap().entries.map((entry) {
              final index = entry.key;
              final option = entry.value;
              final letter = String.fromCharCode(97 + index);
              final arabicOption =
                  arabicQuestionData.options.isNotEmpty &&
                      arabicQuestionData.options.length > index
                  ? arabicQuestionData.options[index]
                  : '';

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 32,
                      child: Text(
                        '$letter.',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          WordTapText(
                            text: option,
                            isArabic: false,
                            fontSize: 15,
                          ),
                          if (arabicOption.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              arabicOption,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                              textAlign: TextAlign.right,
                              textDirection: TextDirection.rtl,
                              softWrap: true,
                              overflow: TextOverflow.visible,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],

          // الإجابة النموذجية (مع زر نطق خارج الصندوق)
          if (item.modelAnswer != null) ...[
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔥 زر نطق الإجابة (خارج الصندوق الأخضر، محاذي له)
                IconButton(
                  icon: const Icon(Icons.volume_up, color: Color(0xFF4CAF50)),
                  onPressed: () => _speakModelAnswer(context),
                  tooltip: 'نطق الإجابة',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9), // لون أخضر فاتح
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        WordTapText(
                          text: item.modelAnswer!.english,
                          isArabic: false,
                          fontSize: 15,
                        ),
                        if (item.modelAnswer!.arabic.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            item.modelAnswer!.arabic,
                            style: TextStyle(
                              fontSize: 14,
                              color: const Color(0xFF2E7D32)
                                  .withValues(alpha: 0.8),
                            ),
                            textAlign: TextAlign.right,
                            textDirection: TextDirection.rtl,
                            softWrap: true,
                            overflow: TextOverflow.visible,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // دوال التحليل (كما هي بدون تغيير)
  _ParsedQuestion _parseQuestion(String text) {
    if (text.isEmpty) return _ParsedQuestion('', [], null);

    int? number;
    String remaining = text;
    final numMatch = RegExp(r'^(\d+)\.\s*').firstMatch(text);
    if (numMatch != null) {
      number = int.tryParse(numMatch.group(1)!);
      remaining = text.substring(numMatch.end);
    }

    final options = <String>[];
    String questionText = remaining;

    final optionRegex = RegExp(r'\s*([a-c])[\.\)]\s*', caseSensitive: false);
    final matches = optionRegex.allMatches(remaining);

    if (matches.isNotEmpty) {
      final firstMatch = matches.first;
      questionText = remaining.substring(0, firstMatch.start).trim();

      for (int i = 0; i < matches.length; i++) {
        final match = matches.elementAt(i);
        final start = match.end;
        final end = i < matches.length - 1
            ? matches.elementAt(i + 1).start
            : remaining.length;
        final optionText = remaining.substring(start, end).trim();
        if (optionText.isNotEmpty) {
          options.add(optionText);
        }
      }

      if (options.isEmpty) {
        final lines = remaining.split('\n');
        for (final line in lines) {
          final trimmed = line.trim();
          if (trimmed.isNotEmpty && RegExp(r'^[a-c][\.\)]').hasMatch(trimmed)) {
            final optText = trimmed
                .substring(trimmed.indexOf(RegExp(r'[\.\)]')) + 1)
                .trim();
            if (optText.isNotEmpty) {
              options.add(optText);
            }
          } else if (questionText.isEmpty) {
            questionText = trimmed;
          }
        }
      }
    }

    if (options.isEmpty && questionText.isEmpty) {
      questionText = remaining;
    }

    questionText = questionText.replaceAll(RegExp(r'\s*\n\s*'), ' ');

    return _ParsedQuestion(questionText, options, number);
  }

  _ParsedQuestion _parseArabicQuestion(String text) {
    if (text.isEmpty) return _ParsedQuestion('', [], null);

    final options = <String>[];
    String questionText = text;

    final optionRegex = RegExp(r'\s*([أ-ج])[\.\)]\s*');
    final matches = optionRegex.allMatches(text);

    if (matches.isNotEmpty) {
      final firstMatch = matches.first;
      questionText = text.substring(0, firstMatch.start).trim();

      for (int i = 0; i < matches.length; i++) {
        final match = matches.elementAt(i);
        final start = match.end;
        final end = i < matches.length - 1
            ? matches.elementAt(i + 1).start
            : text.length;
        final optionText = text.substring(start, end).trim();
        if (optionText.isNotEmpty) {
          options.add(optionText);
        }
      }
    }

    questionText = questionText
        .replaceAll(RegExp(r'\s*\n\s*'), ' ')
        .replaceAll(RegExp(r'\s*[أ-ج][\.\)]\s*'), '')
        .trim();

    return _ParsedQuestion(questionText, options, null);
  }
}

class _ParsedQuestion {
  final String question;
  final List<String> options;
  final int? number;

  _ParsedQuestion(this.question, this.options, this.number);
}
