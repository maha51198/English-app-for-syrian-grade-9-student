import 'package:flutter/material.dart';

import '../models/content.dart';
import 'text_item.dart';
import 'question_item.dart';
import 'exercise_item.dart';
import 'table_item.dart';
import 'model_dialogue_item.dart';
import 'model_composition_item.dart';

class ItemRenderer extends StatelessWidget {
  final Item item;
  final bool isActive;
  final bool isNavigable;

  const ItemRenderer({
    super.key,
    required this.item,
    this.isActive = false,
    this.isNavigable = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = _renderByType();

    // Wrap with highlight if it's a navigable item and currently active
    if (isNavigable && isActive) {
      content = Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue.shade300, width: 2),
          borderRadius: BorderRadius.circular(12),
          color: Colors.blue.shade50,
        ),
        padding: const EdgeInsets.all(12),
        child: content,
      );
    } else if (isNavigable) {
      // For other navigable items (not active) just add a light border
      content = Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(12),
        ),
        child: content,
      );
    }

    return content;
  }

  Widget _renderByType() {
    switch (item.type) {
      case 'text':
        return TextItem(item: item);
      case 'question':
        return QuestionItem(item: item);
      case 'exercise':
        return ExerciseItem(item: item);
      case 'table':
        return TableItem(item: item);
      case 'model_dialogue':
        return ModelDialogueItem(item: item);
      case 'model_composition':
        return ModelCompositionItem(item: item);
      default:
        // Fallback to simple text item for unknown types
        return TextItem(item: item);
    }
  }
}
