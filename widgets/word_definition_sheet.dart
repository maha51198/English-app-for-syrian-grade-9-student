// lib/widgets/word_definition_sheet.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/translation_service.dart';
import '../services/tts_service.dart';
import '../services/word_translator.dart';
import '../utils/constants.dart';

/// يُظهر نافذة سفلية تحتوي على الكلمة وترجمتها.
/// - نطق الكلمة فوراً.
/// - ترجمة من القاموس المحلي → الكاش → Google أونلاين.
Future<void> showWordDefinition(
  BuildContext context, {
  required String word,
  bool isArabic = false,
}) async {
  if (word.trim().isEmpty) return;

  // 1) نطق الكلمة فوراً (قبل أن تُفتح النافذة)
  final tts = context.read<TTSService>();
  final cleanForSpeak =
      word.replaceAll(RegExp(r"[^\w\u0600-\u06FF'\-]"), '');
  if (cleanForSpeak.isNotEmpty) {
    if (isArabic) {
      tts.speakWord(cleanForSpeak, language: 'ar');
    } else {
      tts.speakWord(cleanForSpeak, language: 'en');
    }
  }

  // 2) فتح النافذة
  await showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _WordDefinitionSheet(word: word, isArabic: isArabic),
  );
}

class _WordDefinitionSheet extends StatefulWidget {
  final String word;
  final bool isArabic;
  const _WordDefinitionSheet({required this.word, required this.isArabic});

  @override
  State<_WordDefinitionSheet> createState() => _WordDefinitionSheetState();
}

class _WordDefinitionSheetState extends State<_WordDefinitionSheet> {
  String? _translation;
  bool _loading = false;
  String? _source; // 'قائمة' | 'محفوظة' | 'إنترنت'

  @override
  void initState() {
    super.initState();
    if (!widget.isArabic) _load();
  }

  String get _cleanWord => widget.word
      .replaceAll(RegExp(r"[^\w\u0600-\u06FF'\-]"), '')
      .toLowerCase()
      .trim();

  Future<void> _load() async {
    final clean = _cleanWord;
    if (clean.isEmpty) {
      setState(() => _translation = null);
      return;
    }

    // 1) القاموس الثابت (بدون إنترنت)
    final offline = WordTranslator.translateWord(clean);
    if (offline != null) {
      setState(() {
        _translation = offline;
        _source = 'قائمة';
      });
      return;
    }

    // 2) كاش الترجمة (ترجمات سابقة)
    final service = context.read<TranslationService>();
    final cached = service.getCached(clean);
    if (cached != null) {
      setState(() {
        _translation = cached;
        _source = 'محفوظة';
      });
      return;
    }

    // 3) ترجمة عبر الإنترنت (Google)
    setState(() => _loading = true);
    try {
      final result = await service.translateToArabic(clean);
      if (!mounted) return;
      setState(() {
        _translation = result;
        _source = result != null ? 'إنترنت' : null;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _translation = null;
        _loading = false;
      });
    }
  }

  void _speakEnglish() {
    final clean = widget.word.replaceAll(RegExp(r"[^\w'\-]"), '');
    if (clean.isEmpty) return;
    context.read<TTSService>().speakWord(clean, language: 'en');
  }

  void _speakArabic() {
    if (_translation == null) return;
    context.read<TTSService>().speakWord(_translation!, language: 'ar');
  }

  @override
  Widget build(BuildContext context) {
    final isArabicWord = widget.isArabic;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 12,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // مقبض السحب
            Center(
              child: Container(
                width: 45,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── الكلمة الأصلية ─────────────────────────
            Row(
              children: [
                Expanded(
                  child: Directionality(
                    textDirection: isArabicWord
                        ? TextDirection.rtl
                        : TextDirection.ltr,
                    child: Text(
                      widget.word,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: isArabicWord ? _speakArabic : _speakEnglish,
                  icon: const Icon(Icons.volume_up_rounded),
                  color: AppColors.primary,
                  tooltip: 'نطق الكلمة',
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                  color: Colors.grey.shade600,
                ),
              ],
            ),

            const Divider(height: 24),

            // ── منطقة الترجمة ──────────────────────────
            if (isArabicWord)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'هذه الكلمة بالعربية',
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              )
            else if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    ),
                    SizedBox(width: 12),
                    Text('جاري البحث عن الترجمة...'),
                  ],
                ),
              )
            else if (_translation != null)
              Row(
                children: [
                  Expanded(
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: Text(
                        _translation!,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _speakArabic,
                    icon: const Icon(Icons.volume_up_rounded),
                    color: AppColors.primary,
                    tooltip: 'نطق الترجمة',
                  ),
                ],
              )
            else
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  'لم يتم العثور على ترجمة',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),

            // ── مصدر الترجمة ───────────────────────────
            if (_source != null && !_loading)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _source == 'إنترنت'
                          ? Icons.cloud_done_rounded
                          : Icons.offline_pin_rounded,
                      size: 14,
                      color: Colors.grey.shade500,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'المصدر: $_source',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}