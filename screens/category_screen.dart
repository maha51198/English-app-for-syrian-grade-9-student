import 'package:flutter/material.dart';

import '../models/content.dart';
import 'content_screen.dart';
import '../utils/constants.dart';

class CategoryScreen extends StatelessWidget {
  final String title;
  final List<Content> contents;

  const CategoryScreen({
    super.key,
    required this.title,
    required this.contents,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: contents.isEmpty
          ? const Center(child: Text('لا يوجد محتوى'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: contents.length,
              itemBuilder: (context, index) {
                final content = contents[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          content.title.english, // العنوان الإنجليزي
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          content.title.arabic, // العنوان العربي
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.right, // محاذاة عربية
                        ),
                      ],
                    ),
                    subtitle: Text(
                      '${content.sections.length} أقسام',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ContentScreen(content: content),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
