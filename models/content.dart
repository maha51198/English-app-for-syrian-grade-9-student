class Content {
  final String id;
  final BilingualTitle title;
  final List<Section> sections;

  Content({required this.id, required this.title, required this.sections});

  factory Content.fromJson(Map<String, dynamic> json) {
    return Content(
      id: json['id'] ?? '',
      title: BilingualTitle.fromJson(json['title']),
      sections:
          (json['sections'] as List?)
              ?.map((s) => Section.fromJson(s))
              .toList() ??
          [],
    );
  }

  String get displayTitle =>
      title.arabic.isNotEmpty ? title.arabic : title.english;
}

class BilingualTitle {
  final String english;
  final String arabic;

  BilingualTitle({required this.english, required this.arabic});

  factory BilingualTitle.fromJson(Map<String, dynamic> json) {
    return BilingualTitle(
      english: json['english'] ?? '',
      arabic: json['arabic'] ?? '',
    );
  }
}

class Section {
  final BilingualTitle heading;
  final List<Item> items;

  Section({required this.heading, required this.items});

  factory Section.fromJson(Map<String, dynamic> json) {
    return Section(
      heading: BilingualTitle.fromJson(json['heading']),
      items:
          (json['items'] as List?)?.map((i) => Item.fromJson(i)).toList() ?? [],
    );
  }
}

class Item {
  final String type;
  final String? english;
  final String? arabic;
  final BilingualTitle? modelAnswer;
  final List<Answer>? answers;

  Item({
    required this.type,
    this.english,
    this.arabic,
    this.modelAnswer,
    this.answers,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    List<Answer>? answerList;
    if (json['answers'] != null && json['answers'] is List) {
      answerList = (json['answers'] as List)
          .map((a) => Answer.fromJson(a))
          .toList();
    }

    BilingualTitle? modelAnswer;
    if (json['model_answer'] != null && json['model_answer'] is Map) {
      modelAnswer = BilingualTitle.fromJson(json['model_answer']);
    }

    return Item(
      type: json['type'] ?? 'text',
      english: json['english'],
      arabic: json['arabic'],
      modelAnswer: modelAnswer,
      answers: answerList,
    );
  }

  bool get isNavigable => type == 'question' || type == 'exercise';

  String get displayEnglish => english ?? '';
  String get displayArabic => arabic ?? '';
}

class Answer {
  final String english;
  final String arabic;

  Answer({required this.english, required this.arabic});

  factory Answer.fromJson(Map<String, dynamic> json) {
    return Answer(english: json['english'] ?? '', arabic: json['arabic'] ?? '');
  }
}
