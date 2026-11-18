import 'package:flutter/material.dart';

import '../models/content.dart';
import 'content_screen.dart';

class UnitDetailScreen extends StatelessWidget {
  final Content content;

  const UnitDetailScreen({super.key, required this.content});

  // 🔥 تم تحويلها إلى static const لحل مشكلة البناء
  static const List<String> allowedSections = [
    'Speaking',
    'Reading',
    'Vocabulary',
    'Grammar',
    'Pronunciation',
    'Listening',
    'Writing',
  ];

  IconData _getIconForSection(String sectionName) {
    switch (sectionName.toLowerCase()) {
      case 'speaking':
        return Icons.mic;
      case 'reading':
        return Icons.menu_book;
      case 'vocabulary':
        return Icons.translate;
      case 'grammar':
        return Icons.spellcheck;
      case 'pronunciation':
        return Icons.record_voice_over;
      case 'listening':
        return Icons.headphones;
      case 'writing':
        return Icons.edit_note;
      default:
        return Icons.article;
    }
  }

  @override
  Widget build(BuildContext context) {
    // فلترة الأقسام حسب القائمة المطلوبة
    final filteredSections = <MapEntry<int, Section>>[];
    for (var i = 0; i < content.sections.length; i++) {
      if (allowedSections.contains(content.sections[i].heading.english)) {
        filteredSections.add(MapEntry(i, content.sections[i]));
      }
    }

    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      appBar: AppBar(
        title: Text(content.title.english),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'اختر القسم الذي تريد دراسته',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.orange.shade800,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: filteredSections.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final section = filteredSections[index].value;
                  final originalIndex = filteredSections[index].key;

                  return Card(
                    elevation: 2,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: CircleAvatar(
                        backgroundColor: Colors.orange.shade100,
                        child: Icon(
                          _getIconForSection(section.heading.english),
                          color: Colors.orange.shade800,
                        ),
                      ),
                      title: Text(
                        section.heading.english,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      subtitle: Text(
                        section.heading.arabic,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ContentScreen(
                              content: content,
                              initialSectionIndex: originalIndex,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
