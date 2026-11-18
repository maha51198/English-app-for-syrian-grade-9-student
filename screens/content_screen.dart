import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/word_definition_sheet.dart';
import '../models/content.dart';
import '../providers/content_provider.dart';
import '../services/tts_service.dart';
import '../utils/constants.dart';
import '../widgets/item_renderer.dart';
import '../widgets/question_item.dart';

class _RedTrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color.fromARGB(255, 188, 121, 116)
      ..style = PaintingStyle.fill;
    final path = Path();
    final r = 8.0;
    path.moveTo(r, 0);
    path.quadraticBezierTo(0, 0, 0, r);
    path.lineTo(0, size.height - r);
    path.quadraticBezierTo(0, size.height, r, size.height);
    path.lineTo(size.width - r, size.height / 2 + r);
    path.quadraticBezierTo(
      size.width,
      size.height / 2,
      size.width - r,
      size.height / 2 - r,
    );
    path.lineTo(r, 0);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ContentBlock {
  final Item? header;
  final List<Item> items;

  _ContentBlock({this.header, required this.items});
}

class ContentScreen extends StatefulWidget {
  final Content content;
  final int? initialSectionIndex;

  const ContentScreen({
    super.key,
    required this.content,
    this.initialSectionIndex,
  });

  @override
  State<ContentScreen> createState() => _ContentScreenState();
}

class _ContentScreenState extends State<ContentScreen> {
  final ScrollController _scrollController = ScrollController();
  int _currentSectionIndex = 0;
  int _currentBlockIndex = 0;
  int _currentItemIndexInBlock = 0;
  List<_ContentBlock> _blocks = [];
  bool _showTtsControls = false;

  final String _currentSpeakOption = 'question';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ContentProvider>();
      provider.selectContent(widget.content);
      _currentSectionIndex = widget.initialSectionIndex ?? 0;
      _loadBlocks();
      setState(() {});
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadBlocks() {
    final items = widget.content.sections[_currentSectionIndex].items;
    _blocks = [];
    Item? currentHeader;
    List<Item> currentItems = [];

    for (var item in items) {
      if (item.type == 'question_header') {
        if (currentHeader != null || currentItems.isNotEmpty) {
          if (currentItems.isNotEmpty) {
            _blocks.add(
              _ContentBlock(header: currentHeader, items: currentItems),
            );
          }
        }
        currentHeader = item;
        currentItems = [];
      } else {
        currentItems.add(item);
      }
    }

    if (currentHeader != null || currentItems.isNotEmpty) {
      if (currentItems.isNotEmpty) {
        _blocks.add(_ContentBlock(header: currentHeader, items: currentItems));
      }
    }

    if (_blocks.isEmpty && items.isNotEmpty) {
      _blocks.add(_ContentBlock(header: null, items: items));
    }

    _currentBlockIndex = 0;
    _currentItemIndexInBlock = 0;
    _findNextValidBlock(0);
  }

  void _findNextValidBlock(int startIndex) {
    for (int i = startIndex; i < _blocks.length; i++) {
      if (_blocks[i].items.isNotEmpty) {
        _currentBlockIndex = i;
        _currentItemIndexInBlock = 0;
        return;
      }
    }
    if (_blocks.isNotEmpty) {
      for (int i = _blocks.length - 1; i >= 0; i--) {
        if (_blocks[i].items.isNotEmpty) {
          _currentBlockIndex = i;
          return;
        }
      }
      _currentBlockIndex = 0;
    }
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToSection(int index) {
    if (index < 0 || index >= widget.content.sections.length) return;
    setState(() {
      _currentSectionIndex = index;
      _loadBlocks();
    });
    _scrollToTop();
  }

  void _goToNextSection() => _goToSection(_currentSectionIndex + 1);
  void _goToPrevSection() => _goToSection(_currentSectionIndex - 1);

  void _goToNextItem() {
    final currentBlock = _blocks[_currentBlockIndex];
    if (currentBlock.items.isEmpty) return;

    if (_currentItemIndexInBlock < currentBlock.items.length - 1) {
      setState(() {
        _currentItemIndexInBlock++;
      });
    } else {
      if (_currentBlockIndex < _blocks.length - 1) {
        setState(() {
          _findNextValidBlock(_currentBlockIndex + 1);
        });
      } else {
        _goToNextSection();
      }
    }
    _scrollToTop();
  }

  void _goToPrevItem() {
    if (_currentBlockIndex < 0 || _currentBlockIndex >= _blocks.length) return;
    final currentBlock = _blocks[_currentBlockIndex];
    if (currentBlock.items.isEmpty) return;

    if (_currentItemIndexInBlock > 0) {
      setState(() {
        _currentItemIndexInBlock--;
      });
    } else {
      if (_currentBlockIndex > 0) {
        setState(() {
          int prevIndex = _currentBlockIndex - 1;
          while (prevIndex >= 0 && _blocks[prevIndex].items.isEmpty) {
            prevIndex--;
          }
          if (prevIndex >= 0) {
            _currentBlockIndex = prevIndex;
            _currentItemIndexInBlock =
                _blocks[_currentBlockIndex].items.length - 1;
          }
        });
      } else {
        _goToPrevSection();
      }
    }
    _scrollToTop();
  }

  String _extractLabelFromText(String text) {
    final match = RegExp(r'^([a-zA-Z0-9]+)\.\s*').firstMatch(text);
    if (match != null) return match.group(1)!;
    return '';
  }

  String _removeLabelPrefix(String text) {
    return text.replaceFirst(RegExp(r'^[a-zA-Z0-9]+\.\s*'), '');
  }

  Widget _buildRedTriangleLabel(String label) {
    return SizedBox(
      width: 32,
      height: 26,
      child: Stack(
        children: [
          CustomPaint(size: const Size(32, 26), painter: _RedTrianglePainter()),
          Align(
            alignment: const Alignment(-0.2, 0.55),
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentHeader(Item? headerItem) {
    String headerEnglish =
        widget.content.sections[_currentSectionIndex].heading.english;
    String headerArabic =
        widget.content.sections[_currentSectionIndex].heading.arabic;
    String label = '';

    if (headerItem != null) {
      headerEnglish = headerItem.english ?? '';
      headerArabic = headerItem.arabic ?? '';
      label = _extractLabelFromText(headerEnglish);
      headerEnglish = _removeLabelPrefix(headerEnglish);
      headerArabic = _removeLabelPrefix(headerArabic);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
        border: Border(
          bottom: BorderSide(color: AppColors.primary, width: 2),
          right: BorderSide(color: AppColors.primary, width: 4),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label.isNotEmpty) ...[
            _buildRedTriangleLabel(label),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  headerEnglish,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  headerArabic,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.volume_up, color: AppColors.primary),
            onPressed: () {
              final tts = context.read<TTSService>();
              tts.speak(headerEnglish);
            },
            tooltip: 'نطق الهيدر',
          ),
        ],
      ),
    );
  }

  void _speakCurrentItem(String option) {
    final currentBlock = _blocks[_currentBlockIndex];
    final currentItem = currentBlock.items[_currentItemIndexInBlock];
    final tts = context.read<TTSService>();
    String textToSpeak = '';
    if (option == 'question' || option == 'both') {
      textToSpeak = currentItem.english ?? '';
    }
    if (option == 'answer' || option == 'both') {
      if (currentItem.modelAnswer != null) {
        textToSpeak += ' ${currentItem.modelAnswer!.english}';
      }
    }
    textToSpeak = textToSpeak
        .replaceAll(RegExp(r'\d+'), ' ')
        .replaceAll(RegExp(r'_+'), ' ');
    if (textToSpeak.isNotEmpty) {
      tts.speak(textToSpeak);
    }
  }

  void _speakModelAnswer(Item item) {
    final tts = context.read<TTSService>();
    if (item.modelAnswer != null) {
      String text = item.modelAnswer!.english;
      text = text
          .replaceAll(RegExp(r'\d+'), ' ')
          .replaceAll(RegExp(r'_+'), ' ');
      tts.speak(text);
    }
  }

  // ✅ دالة مساعدة: تحويل النص الإنجليزي إلى كلمات قابلة للنقر (ترجمة + نطق)
  Widget _buildClickableWords(String text, {double fontSize = 15}) {
    final tts = context.read<TTSService>();
    final words = text.split(' ');
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Wrap(
        spacing: 4,
        runSpacing: 6,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: words.map((word) {
          final cleanWord = word.replaceAll(RegExp(r'[.,;:!?"]'), '');
          if (cleanWord.isEmpty) {
            return Text(word, style: TextStyle(fontSize: fontSize));
          }
          return GestureDetector(
            // 👆 نقرة واحدة: نطق + ترجمة
            onTap: () {
              tts.speak(cleanWord);
              showWordDefinition(context, word: cleanWord, isArabic: false);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.blueAccent.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
              ),
              child: Text(
                word,
                style: TextStyle(
                  fontSize: fontSize,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ✅ دالة معدلة: كل كلمة إنجليزية في الإجابة قابلة للنقر (ترجمة + نطق)
  Widget _buildDialogue(String text, {bool isArabic = false}) {
    final lines = text.split('\n');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        if (line.trim().isEmpty) return const SizedBox(height: 8);

        // 🔹 عربي: نص عادي
        if (isArabic) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              line,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black87,
                height: 1.6,
              ),
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
            ),
          );
        }

        // 🔹 إنجليزي: مع كلمات قابلة للنقر
        final match = RegExp(r'^([^:]+):\s*(.*)').firstMatch(line);
        if (match != null) {
          String speaker = match.group(1)!;
          String dialogue = match.group(2)!;

          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$speaker:',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                _buildClickableWords(dialogue),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: _buildClickableWords(line),
        );
      }).toList(),
    );
  }

  Widget _buildModelAnswerContainer(Item item) {
    if (item.modelAnswer == null) return const SizedBox.shrink();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
          icon: const Icon(Icons.volume_up, color: Color(0xFF4CAF50)),
          onPressed: () => _speakModelAnswer(item),
          tooltip: 'نطق الإجابة كاملة',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(top: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🇬🇧 الإجابة الإنجليزية مع كلمات قابلة للنقر
                _buildDialogue(item.modelAnswer!.english, isArabic: false),
                if (item.modelAnswer!.arabic.isNotEmpty) ...[
                  const Divider(height: 16, color: Color(0xFF4CAF50)),
                  // 🇸🇾 الإجابة العربية
                  _buildDialogue(item.modelAnswer!.arabic, isArabic: true),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseContainer(Widget child) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary, width: 1.5),
      ),
      child: child,
    );
  }

  Widget _buildInterleavedBilingualText(String english, String arabic) {
    final englishLines = english.split('\n');
    final arabicLines = arabic.split('\n');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < englishLines.length; i++) ...[
          _buildClickableNumberedText(englishLines[i]),
          const SizedBox(height: 4),
          if (i < arabicLines.length && arabicLines[i].isNotEmpty)
            Text(
              arabicLines[i],
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black54,
                height: 1.5,
              ),
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
            ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  // ✅ دالة معدلة: النقرة الواحدة تنطق وتترجم
  Widget _buildClickableNumberedText(String text) {
    final tts = context.read<TTSService>();
    final lines = text.split('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        if (line.trim().isEmpty) return const SizedBox(height: 8);

        final colonMatch = RegExp(r'^([^:]+):\s*(.*)').firstMatch(line);
        if (colonMatch != null) {
          String prefix = colonMatch.group(1)!;
          String rest = colonMatch.group(2)!;
          return Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.black87,
                  fontFamily: 'Tajawal',
                ),
                children: [
                  TextSpan(
                    text: '$prefix: ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: rest),
                ],
              ),
            ),
          );
        }

        final words = line.split(' ');
        return Padding(
          padding: const EdgeInsets.only(bottom: 4.0),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Wrap(
              spacing: 4,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.start,
              children: words.map((word) {
                final match = RegExp(
                  r'^(\d)(?!st\b|nd\b|rd\b|th\b)([a-zA-Z]+)$',
                  caseSensitive: false,
                ).firstMatch(word);
                String cleanWord = word;
                bool hasRedLine = false;
                if (match != null) {
                  cleanWord = match.group(2)!;
                  hasRedLine = true;
                }
                String wordForSpeak = cleanWord.replaceAll(
                  RegExp(r'[.,;:!?]'),
                  '',
                );
                return GestureDetector(
                  // 👆 نقرة واحدة: نطق + ترجمة
                  onTap: () {
                    if (wordForSpeak.isEmpty) return;
                    tts.speak(wordForSpeak);
                    showWordDefinition(
                      context,
                      word: wordForSpeak,
                      isArabic: false,
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: hasRedLine
                              ? const Color.fromARGB(255, 189, 141, 138)
                              : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                    ),
                    child: Text(
                      cleanWord,
                      style: TextStyle(
                        fontSize: 18,
                        color: hasRedLine ? Colors.blueAccent : Colors.black87,
                        fontWeight: hasRedLine
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNavigationBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.skip_previous, color: AppColors.primary),
                tooltip: 'التمرين السابق',
                onPressed: _currentSectionIndex > 0 ? _goToPrevSection : null,
              ),
              Text(
                'تمرين ${_currentSectionIndex + 1}/${widget.content.sections.length}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.skip_next, color: AppColors.primary),
                tooltip: 'التمرين التالي',
                onPressed:
                    _currentSectionIndex < widget.content.sections.length - 1
                    ? _goToNextSection
                    : null,
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                  size: 18,
                  color: AppColors.secondary,
                ),
                tooltip: 'السؤال السابق',
                onPressed:
                    _currentBlockIndex > 0 || _currentItemIndexInBlock > 0
                    ? _goToPrevItem
                    : null,
              ),
              Text(
                'سؤال ${_currentItemIndexInBlock + 1}/${_blocks[_currentBlockIndex].items.length}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(
                  Icons.arrow_forward_ios,
                  size: 18,
                  color: AppColors.secondary,
                ),
                tooltip: 'السؤال التالي',
                onPressed:
                    _currentBlockIndex < _blocks.length - 1 ||
                        _currentItemIndexInBlock <
                            _blocks[_currentBlockIndex].items.length - 1
                    ? _goToNextItem
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTtsControls(BuildContext context) {
    final tts = context.read<TTSService>();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.speed,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                Row(
                  children: [
                    const Text('بطيء', style: TextStyle(fontSize: 12)),
                    Expanded(
                      child: Slider(
                        value: tts.speed,
                        min: 0.2,
                        max: 1.5,
                        divisions: 13,
                        label: tts.speed.toStringAsFixed(1),
                        onChanged: (value) {
                          tts.setSpeed(value);
                          setState(() {});
                        },
                      ),
                    ),
                    const Text('سريع', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              tts.isSpeaking ? Icons.stop_circle : Icons.volume_up,
              color: AppColors.primary,
            ),
            onPressed: () {
              if (tts.isSpeaking) {
                tts.stop();
              } else {
                _speakCurrentItem(_currentSpeakOption);
              }
              setState(() {});
            },
            tooltip: tts.isSpeaking ? 'إيقاف القراءة' : 'نطق العنصر الحالي',
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final section = widget.content.sections[_currentSectionIndex];
    final tts = context.watch<TTSService>();

    if (_blocks.isEmpty) {
      return const Scaffold(body: Center(child: Text('لا يوجد محتوى')));
    }

    while (_currentBlockIndex < _blocks.length &&
        _blocks[_currentBlockIndex].items.isEmpty) {
      _currentBlockIndex++;
    }
    if (_currentBlockIndex >= _blocks.length) {
      _currentBlockIndex = _blocks.length - 1;
    }

    final currentBlock = _blocks[_currentBlockIndex];
    if (_currentItemIndexInBlock >= currentBlock.items.length) {
      _currentItemIndexInBlock = 0;
    }
    final currentItem = currentBlock.items[_currentItemIndexInBlock];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.content.title.english} - ${section.heading.english}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(tts.isSpeaking ? Icons.stop : Icons.volume_up),
            onPressed: () {
              if (tts.isSpeaking) {
                tts.stop();
              } else {
                _speakCurrentItem(_currentSpeakOption);
              }
              setState(() {});
            },
            tooltip: tts.isSpeaking ? 'إيقاف القراءة' : 'نطق العنصر الحالي',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () =>
                setState(() => _showTtsControls = !_showTtsControls),
            tooltip: 'إعدادات القراءة',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(55.0),
          child: Container(
            width: double.infinity,
            color: AppColors.primary,
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(
              children: [
                Text(
                  '${widget.content.title.arabic} - ${section.heading.arabic}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 8),
                Container(
                  height: 6,
                  width: double.infinity,
                  color: const Color.fromARGB(255, 187, 95, 95),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          if (_showTtsControls) _buildTtsControls(context),
          _buildCurrentHeader(currentBlock.header),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (currentItem.type == 'text' ||
                      currentItem.type == 'exercise')
                    _buildExerciseContainer(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInterleavedBilingualText(
                            currentItem.english ?? '',
                            currentItem.arabic ?? '',
                          ),
                          _buildModelAnswerContainer(currentItem),
                        ],
                      ),
                    )
                  else if (currentItem.type == 'question')
                    QuestionItem(item: currentItem)
                  else
                    ItemRenderer(
                      item: currentItem,
                      isActive: true,
                      isNavigable: currentItem.isNavigable,
                    ),
                ],
              ),
            ),
          ),
          _buildNavigationBar(),
        ],
      ),
    );
  }
}
