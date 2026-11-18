import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'providers/content_provider.dart';
import 'services/tts_service.dart';
import 'services/translation_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1) حمّل قاموس الترجمة قبل تشغيل التطبيق
  final translationService = TranslationService();
  await translationService.loadDictionary();

  // 2) هيّئ خدمة النطق (Google engine + أفضل صوت)
  final ttsService = TTSService();
  await ttsService.init(language: 'en');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ContentProvider>(
          create: (_) => ContentProvider(),
        ),
        Provider<TTSService>.value(value: ttsService),
        Provider<TranslationService>.value(value: translationService),
      ],
      child: const StudyApp(),
    ),
  );
}