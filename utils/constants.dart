import 'package:flutter/material.dart';

class AppColors {
  // 🔥 لوحة ألوان بنية دافئة وهادئة جداً (أقرب للبني)
  static const Color primary = Color(0xFF8D4E2A); // بني محمر داكن (أساسي)
  static const Color secondary = Color(0xFFA66C4F); // بني محمر فاتح (ثانوي)
  static const Color accent = Color(0xFFD7CCC8); // بيج بني (للتمييز)
  static const Color background = Color(
    0xFFF7F1EC,
  ); // بيج دافئ فاتح (خلفية مريحة)
  static const Color cardBackground = Colors.white;
  static const Color textPrimary = Color(
    0xFF2C1A12,
  ); // بني داكن جداً (نص أساسي مريح)
  static const Color textSecondary = Color(0xFF5D4037); // بني متوسط (نص ثانوي)
  static const Color arabicColor = Color(0xFF795548); // بني (للنص العربي)
  static const Color englishColor = Color(
    0xFF8D4E2A,
  ); // بني محمر (للنص الإنجليزي)
}

class AppStrings {
  static const String appTitle = 'Study App';
  static const String units = 'الوحدات';
  static const String reviews = 'المراجعات';
  static const String projects = 'المشاريع';
  static const String chooseCategory = 'اختر ما تريد دراسته';
  static const String next = 'التالي';
  static const String back = 'الخلف';
  static const String translate = 'ترجمة';
  static const String speak = 'نطق';
  static const String speed = 'سرعة النطق';
}
