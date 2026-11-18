// lib/services/tts_service.dart
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  final FlutterTts _flutterTts = FlutterTts();

  double _speed = 0.5;
  bool _isSpeaking = false;
  bool _initialized = false;

  /// اللغة الحالية (en أو ar)
  String _currentLanguage = 'en';

  TTSService() {
    _flutterTts.setCompletionHandler(() => _isSpeaking = false);
    _flutterTts.setCancelHandler(() => _isSpeaking = false);
    _flutterTts.setErrorHandler((msg) {
      _isSpeaking = false;
      debugPrint('⚠ TTS error: $msg');
    });
    _flutterTts.setStartHandler(() => _isSpeaking = true);
  }

  // ─────────────────────────────────────────────────────────────
  //  التهيئة: اختيار محرك Google + أفضل صوت متاح
  // ─────────────────────────────────────────────────────────────
  Future<void> init({String language = 'en'}) async {
    if (_initialized) {
      await setLanguage(language);
      return;
    }

    // 1) على Android: استخدم محرك Google TTS (وليس محرك الشركة المصنعة)
    if (Platform.isAndroid) {
      try {
        await _flutterTts.setEngine('com.google.android.tts');
      } catch (e) {
        debugPrint('⚠ Could not set Google TTS engine: $e');
      }
    }

    // 2) اضبط الصوت على اللغة المطلوبة
    await setLanguage(language);

    // 3) اضبط السرعة والنبرة
    await _flutterTts.setSpeechRate(_speed);
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setVolume(1.0);

    // 4) انتظر انتهاء أي كلام سابق قبل النطق الجديد
    if (Platform.isAndroid) {
      await _flutterTts.awaitSpeakCompletion(true);
    }

    _initialized = true;
    debugPrint('✅ TTS initialized (lang=$language)');
  }

  // ─────────────────────────────────────────────────────────────
  //  اختيار أفضل صوت لغة متاح (HIGH quality أولاً)
  // ─────────────────────────────────────────────────────────────
  Future<void> setLanguage(String langCode) async {
    _currentLanguage = langCode;

    // اللغة المفضلة (en-US / ar-SA)
    final preferredLocale = langCode == 'ar' ? 'ar-SA' : 'en-US';

    try {
      final voices = await _flutterTts.getVoices;
      if (voices is List) {
        Map? bestVoice;
        int bestScore = -1;

        for (final v in voices) {
          if (v is! Map) continue;
          final locale = (v['locale'] ?? '').toString();
          if (!locale.toLowerCase().startsWith(langCode.toLowerCase())) {
            continue;
          }

          // حساب نقاط الجودة
          int score = 0;

          // تفضيل locale المحدد (en-US / ar-SA)
          if (locale == preferredLocale) score += 5;

          // جودة HIGH (Android)
          final quality = (v['quality'] ?? '').toString().toLowerCase();
          if (quality == 'high' || quality == 'very_high') score += 4;
          if (quality == 'normal') score += 1;

          // أصوات Google أفضل
          final name = (v['name'] ?? '').toString().toLowerCase();
          if (name.contains('google')) score += 3;
          if (name.contains('neural')) score += 4;
          if (name.contains('network')) score += 1;

          // iOS: أصوات Premium / Enhanced
          if (name.contains('premium') || name.contains('enhanced')) {
            score += 4;
          }

          if (score > bestScore) {
            bestScore = score;
            bestVoice = v;
          }
        }

        if (bestVoice != null) {
          await _flutterTts.setVoice({
            'name': bestVoice['name'].toString(),
            'locale': bestVoice['locale'].toString(),
          });
          debugPrint(
            '🎙 Using voice: ${bestVoice['name']} (${bestVoice['locale']}) score=$bestScore',
          );
          return;
        }
      }
    } catch (e) {
      debugPrint('⚠ Voice selection failed: $e');
    }

    // احتياطي: اللغة فقط
    await _flutterTts.setLanguage(preferredLocale);
  }

  // ─────────────────────────────────────────────────────────────
  //  تنظيف النص قبل النطق
  // ─────────────────────────────────────────────────────────────
  String _cleanText(String text) {
    if (text.isEmpty) return '';
    return text
        .replaceAll(RegExp(r'_+'), ' ') // foo_bar → foo bar
        .replaceAll(RegExp(r'\s+'), ' ') // collapse whitespace
        .replaceAll(RegExp(r'\.+'), ' ')
        .replaceAll(
          RegExp(r"[^\w\s\u0600-\u06FF.,!?'-]"),
          ' ',
        ) // keep letters, numbers, Arabic, basic punctuation
        .trim();
  }

  // ─────────────────────────────────────────────────────────────
  //  نطق نص كامل
  // ─────────────────────────────────────────────────────────────
  Future<void> speak(String text, {String? language}) async {
    if (!_initialized) await init(language: language ?? _currentLanguage);
    if (language != null && language != _currentLanguage) {
      await setLanguage(language);
    }

    final clean = _cleanText(text);
    if (clean.isEmpty) return;

    await _flutterTts.stop();
    await _flutterTts.setSpeechRate(_speed);
    await _flutterTts.speak(clean);
    _isSpeaking = true;
  }

  // ─────────────────────────────────────────────────────────────
  //  نطق كلمة واحدة
  // ─────────────────────────────────────────────────────────────
  Future<void> speakWord(String word, {String? language}) async {
    await speak(word, language: language);
  }

  // ─────────────────────────────────────────────────────────────
  //  إيقاف / سرعة / حالة
  // ─────────────────────────────────────────────────────────────
  Future<void> stop() async {
    await _flutterTts.stop();
    _isSpeaking = false;
  }

  Future<void> setSpeed(double speed) async {
    _speed = speed.clamp(0.1, 1.0);
    await _flutterTts.setSpeechRate(_speed);
  }

  Future<void> setSpeechRate(double rate) => setSpeed(rate);

  double get speed => _speed;
  bool get isSpeaking => _isSpeaking;
  String get currentLanguage => _currentLanguage;
}
