import 'package:flutter/material.dart';

import '../models/content.dart';
import '../utils/data_loader.dart';

class ContentProvider extends ChangeNotifier {
  List<Content> _units = [];
  List<Content> _reviews = [];
  List<Content> _projects = [];
  Content? _selectedContent;
  bool _isLoading = false;
  String? _error;

  List<Content> get units => _units;
  List<Content> get reviews => _reviews;
  List<Content> get projects => _projects;
  Content? get selectedContent => _selectedContent;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadAllContent() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    // تحميل الوحدات من unit1 إلى unit12
    final unitFiles = List.generate(
      12,
      (index) => 'unit${index + 1}_bilingual.json',
    );

    // تحميل المراجعات
    final reviewFiles = ['review_1.json', 'review_2.json', 'review_3.json'];

    // تحميل المشاريع
    final projectFiles = ['project_1.json', 'project_2.json', 'project_3.json'];

    try {
      // تحميل الوحدات (مع تجاهل أي ملف مفقود)
      _units = [];
      for (final file in unitFiles) {
        try {
          final loaded = await DataLoader.loadMultiple([file]);
          if (loaded.isNotEmpty) _units.addAll(loaded);
        } catch (e) {
          debugPrint('Skipping missing unit file: $file');
        }
      }

      // تحميل المراجعات
      _reviews = [];
      for (final file in reviewFiles) {
        try {
          final loaded = await DataLoader.loadMultiple([file]);
          if (loaded.isNotEmpty) _reviews.addAll(loaded);
        } catch (e) {
          debugPrint('Skipping missing review file: $file');
        }
      }

      // تحميل المشاريع
      _projects = [];
      for (final file in projectFiles) {
        try {
          final loaded = await DataLoader.loadMultiple([file]);
          if (loaded.isNotEmpty) _projects.addAll(loaded);
        } catch (e) {
          debugPrint('Skipping missing project file: $file');
        }
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectContent(Content content) {
    _selectedContent = content;
    notifyListeners();
  }

  void clearSelection() {
    _selectedContent = null;
    notifyListeners();
  }

  List<Item> getNavigableItems() {
    if (_selectedContent == null) return [];
    final items = <Item>[];
    for (final section in _selectedContent!.sections) {
      for (final item in section.items) {
        if (item.isNavigable) {
          items.add(item);
        }
      }
    }
    return items;
  }

  List<Item> getAllItems() {
    if (_selectedContent == null) return [];
    final items = <Item>[];
    for (final section in _selectedContent!.sections) {
      items.addAll(section.items);
    }
    return items;
  }

  int getSectionIndexForItem(Item item) {
    if (_selectedContent == null) return -1;
    for (int i = 0; i < _selectedContent!.sections.length; i++) {
      if (_selectedContent!.sections[i].items.contains(item)) {
        return i;
      }
    }
    return -1;
  }
}
