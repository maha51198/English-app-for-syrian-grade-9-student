// tool/build_dictionary.dart
//
// سكربت يستخرج كل الكلمات الإنجليزية الفريدة من ملفات JSON
// ويترجمها للعربية، ثم يحفظ النتيجة في assets/dictionary.json
//
// طريقة التشغيل:
//   dart run tool/build_dictionary.dart

import 'dart:convert';
import 'dart:io';

import 'package:translator/translator.dart';

// ✅ تم تحديث المسارات لتشير إلى مجلد assets/data/
const List<String> assetFiles = [
  'assets/data/review_1.json',
  'assets/data/review_2.json',
  'assets/data/unit1_bilingual.json',
  'assets/data/unit2_bilingual.json',
  'assets/data/unit3_bilingual.json',
  'assets/data/unit4_bilingual.json',
  'assets/data/unit5_bilingual.json',
  'assets/data/unit6_bilingual.json',
  'assets/data/unit7_bilingual.json',
  'assets/data/unit8_bilingual.json',
  'assets/data/unit9_bilingual.json',
  'assets/data/unit10_bilingual.json',
  'assets/data/unit11_bilingual.json',
  'assets/data/unit12_bilingual.json',
];

// كلمات شائعة لا تحتاج ترجمة (تُستثنى)
const Set<String> stopWords = {
  'a',
  'an',
  'the',
  'is',
  'are',
  'was',
  'were',
  'be',
  'been',
  'being',
  'am',
  'do',
  'does',
  'did',
  'have',
  'has',
  'had',
  'having',
  'in',
  'on',
  'at',
  'by',
  'for',
  'with',
  'about',
  'against',
  'between',
  'into',
  'through',
  'during',
  'before',
  'after',
  'above',
  'below',
  'to',
  'from',
  'up',
  'down',
  'of',
  'off',
  'over',
  'under',
  'and',
  'or',
  'but',
  'if',
  'so',
  'than',
  'then',
  'that',
  'this',
  'these',
  'those',
  'it',
  'its',
  'he',
  'she',
  'they',
  'them',
  'his',
  'her',
  'their',
  'our',
  'your',
  'my',
  'me',
  'you',
  'him',
  'we',
  'us',
  'i',
  'as',
  'not',
  'no',
  'yes',
  'can',
  'could',
  'will',
  'would',
  'shall',
  'should',
  'may',
  'might',
  'must',
  'there',
  'here',
  'when',
  'where',
  'why',
  'how',
  'what',
  'which',
  'who',
  'whom',
  'whose',
  'all',
  'any',
  'both',
  'each',
  'few',
  'more',
  'most',
  'other',
  'some',
  'such',
  'only',
  'own',
  'same',
  'too',
  'very',
  'just',
  'also',
  'now',
  'get',
  'got',
  'one',
  'two',
};

Future<void> main() async {
  final translator = GoogleTranslator();
  final Map<String, String> dictionary = {};

  // تحميل قاموس موجود مسبقاً إن وُجد
  final dictFile = File('assets/dictionary.json');
  if (await dictFile.exists()) {
    final existing = jsonDecode(await dictFile.readAsString()) as Map;
    existing.forEach((k, v) => dictionary[k.toString()] = v.toString());
    print('✔ تم تحميل ${dictionary.length} كلمة من قاموس موجود');
  }

  // استخراج الكلمات الفريدة من كل الملفات
  final Set<String> allWords = {};
  final wordRegex = RegExp(r"[a-zA-Z][a-zA-Z'\-]+");

  for (final path in assetFiles) {
    final file = File(path);
    if (!await file.exists()) {
      print('⚠ الملف غير موجود: $path');
      continue;
    }
    final content = await file.readAsString();

    // استخراج قيم "english" فقط
    final englishRegex = RegExp(r'"english"\s*:\s*"((?:[^"\\]|\\.)*)"');
    for (final m in englishRegex.allMatches(content)) {
      final text = m
          .group(1)!
          .replaceAll(r'\n', ' ')
          .replaceAll(r'\"', '"')
          .replaceAll(r'\\', r'\');

      for (final w in wordRegex.allMatches(text)) {
        final word = w.group(0)!.toLowerCase();
        if (word.length > 1 && !stopWords.contains(word)) {
          allWords.add(word);
        }
      }
    }
  }

  print('✔ عدد الكلمات الفريدة: ${allWords.length}');
  print('⏳ جارٍ الترجمة...');

  final newWords = allWords.where((w) => !dictionary.containsKey(w)).toList();
  print('   كلمات جديدة بحاجة إلى ترجمة: ${newWords.length}');

  int done = 0;
  for (final word in newWords) {
    try {
      final translation = await translator.translate(
        word,
        from: 'en',
        to: 'ar',
      );
      dictionary[word] = translation.text;
    } catch (e) {
      dictionary[word] = word; // احتفظ بالكلمة الأصلية عند الفشل
    }
    done++;
    if (done % 10 == 0) {
      print('   $done / ${newWords.length}');
      // احفظ تدريجياً لتفادي فقدان العمل
      await dictFile.writeAsString(
        const JsonEncoder.withIndent('  ').convert(dictionary),
      );
    }
    // تأخير لتجنب تجاوز حد Google
    await Future.delayed(const Duration(milliseconds: 250));
  }

  // حفظ نهائي
  await dictFile.writeAsString(
    const JsonEncoder.withIndent('  ').convert(dictionary),
  );
  print('✅ تم إنشاء القاموس: ${dictionary.length} كلمة');
  print('   الملف: ${dictFile.absolute.path}');
}
