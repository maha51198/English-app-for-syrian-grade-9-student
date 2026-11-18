import 'package:flutter/material.dart';

import '../models/content.dart';
import 'word_tap_text.dart';

class TableItem extends StatelessWidget {
  final Item item;

  const TableItem({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.teal.shade100,
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text(
            'جدول',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(12),
            child: _parseTableContent(),
          ),
        ),
      ],
    );
  }

  Widget _parseTableContent() {
    final String? content = item.english ?? item.arabic;
    if (content == null || content.isEmpty) {
      return const SizedBox.shrink();
    }

    // Split content into lines, ignoring empty ones
    final lines = content
        .split('\n')
        .where((l) => l.trim().isNotEmpty)
        .toList();

    // Need at least header row and separator row to be a valid table
    if (lines.length < 3) {
      // Not a table, just show as plain text
      return WordTapText(
        text: content,
        isArabic: item.arabic != null && item.english == null,
        fontSize: 14,
      );
    }

    // Parse headers (first row)
    final headers = _parseRow(lines[0]);
    // Second row is separator (skip)
    // Parse data rows starting from index 2
    final rows = <List<String>>[];
    for (int i = 2; i < lines.length; i++) {
      final row = _parseRow(lines[i]);
      if (row.isNotEmpty) {
        rows.add(row);
      }
    }

    if (headers.isEmpty) {
      return WordTapText(
        text: content,
        isArabic: item.arabic != null && item.english == null,
        fontSize: 14,
      );
    }

    final colCount = headers.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Table Header
        Container(
          decoration: BoxDecoration(
            color: Colors.teal.shade50,
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          child: Row(
            children: [
              for (int i = 0; i < headers.length; i++)
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      headers[i].trim(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.teal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        // Table Rows
        for (final row in rows) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                for (
                  int i = 0;
                  i < (row.length > colCount ? colCount : row.length);
                  i++
                )
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: WordTapText(
                        text: row[i].trim(),
                        isArabic: false, // Assume English content; if needed, can detect
                        fontSize: 12,
                      ),
                    ),
                  ),
                // If row has fewer cells, fill with empty
                if (row.length < colCount)
                  for (int i = row.length; i < colCount; i++)
                    const Expanded(flex: 1, child: SizedBox.shrink()),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 0.5, color: Colors.grey),
        ],
      ],
    );
  }

  // Helper method to split a row by '|' and return cleaned cells
  List<String> _parseRow(String line) {
    // Remove leading/trailing pipe if present
    String trimmed = line.trim();
    if (trimmed.startsWith('|')) trimmed = trimmed.substring(1);
    if (trimmed.endsWith('|')) {
      trimmed = trimmed.substring(0, trimmed.length - 1);
    }
    // Split by pipe
    final parts = trimmed.split('|');
    return parts.map((p) => p.trim()).toList();
  }
}
