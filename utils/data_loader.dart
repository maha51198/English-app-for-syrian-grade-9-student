import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/content.dart';

class DataLoader {
  static Future<Content> loadFromAsset(String fileName) async {
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/data/$fileName',
      );
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      return Content.fromJson(jsonData);
    } catch (e) {
      throw Exception('Failed to load $fileName: $e');
    }
  }

  static Future<List<Content>> loadMultiple(List<String> fileNames) async {
    final List<Content> contents = [];
    for (final fileName in fileNames) {
      try {
        final content = await loadFromAsset(fileName);
        contents.add(content);
      } catch (e) {
        continue;
      }
    }
    return contents;
  }
}
