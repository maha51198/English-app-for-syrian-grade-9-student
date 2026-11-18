// lib/services/translation_service.dart
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:translator/translator.dart';

class TranslationService {
  final GoogleTranslator _translator = GoogleTranslator();

  /// قاموس محمّل من assets/dictionary.json
  final Map<String, String> _dictionary = {};

  /// ترجمات مؤقتة (runtime) للكلمات الجديدة التي لا توجد في الملف
  final Map<String, String> _runtimeCache = {};

  bool _loaded = false;

  /// يُستدعى من SplashScreen أو main قبل بدء الاستخدام
  Future<void> loadDictionary() async {
    if (_loaded) return;
    try {
      final raw = await rootBundle.loadString('assets/dictionary.json');
      final Map<String, dynamic> map = jsonDecode(raw);
      map.forEach((key, value) {
        _dictionary[key.toLowerCase()] = value.toString();
      });
      _loaded = true;
      print('✅ TranslationService: تم تحميل ${_dictionary.length} كلمة');
    } catch (e) {
      print('⚠ TranslationService: فشل تحميل القاموس: $e');
    }
  }

  /// تُرجع ترجمة الكلمة، أو null إذا لم توجد
  Future<String?> translateToArabic(String word) async {
    final w = word.toLowerCase().trim().replaceAll(
      RegExp(r"[^\w'\-]"),
      '',
    ); // تنظيف علامات الترقيم

    if (w.isEmpty) return null;

    // 1) البحث في القاموس المحمّل
    if (_dictionary.containsKey(w)) {
      return _dictionary[w];
    }

    // 2) البحث في الكاش المؤقت
    if (_runtimeCache.containsKey(w)) {
      return _runtimeCache[w];
    }

    // 3) محاولة الترجمة عبر Google
    try {
      final result = await _translator.translate(w, from: 'en', to: 'ar');
      final text = result.text;
      _runtimeCache[w] = text;
      return text;
    } catch (_) {
      return null;
    }
  }

  /// للاستخدام المتزامن (يعيد الترجمة إن وُجدت فقط بدون انتظار)
  String? getCached(String word) {
    final w = word.toLowerCase().trim();
    return _dictionary[w] ?? _runtimeCache[w];
  }

  int get dictionarySize => _dictionary.length;
}
