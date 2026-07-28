// ============================================================
//  SONIQ — lib/ui/widgets/alphabet_scrubber.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../database/database.dart';

class AlphabetScrubber extends StatefulWidget {
  final ScrollController scrollController;
  final List<Song> songs;
  final double itemExtent;

  const AlphabetScrubber({
    super.key,
    required this.scrollController,
    required this.songs,
    this.itemExtent = 72.0,
  });

  @override
  State<AlphabetScrubber> createState() => _AlphabetScrubberState();
}

class _AlphabetScrubberState extends State<AlphabetScrubber> {
  final List<String> _alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ#".split("");
  String? _activeLetter;
  bool _isDragging = false;

  void _triggerHaptic() {
    HapticFeedback.selectionClick();
  }

  void _scrollToLetter(String letter) {
    if (widget.songs.isEmpty) return;

    int targetIndex = widget.songs.indexWhere((song) {
      final title = song.title?.trim().toUpperCase() ?? "";
      if (title.isEmpty) return false;
      if (letter == "#") return RegExp(r'^[^A-Z]').hasMatch(title);
      return title.startsWith(letter);
    });

    if (targetIndex != -1) {
      if (_activeLetter != letter) {
        setState(() => _activeLetter = letter);
        _triggerHaptic();
      }
      widget.scrollController.jumpTo(targetIndex * widget.itemExtent);
    }
  }

  void _handleDrag(Offset localPosition, double maxHeight) {
    final double heightPerLetter = maxHeight / _alphabet.length;
    final int index = (localPosition.dy / heightPerLetter).floor().clamp(0, _alphabet.length - 1);
    _scrollToLetter(_alphabet[index]);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          // 🎯 CRITICAL FIX: Forces Flutter to catch touches on the transparent background!
          behavior: HitTestBehavior.opaque,
          onVerticalDragStart: (details) {
            setState(() => _isDragging = true);
            _handleDrag(details.localPosition, constraints.maxHeight);
          },
          onVerticalDragUpdate: (details) => _handleDrag(details.localPosition, constraints.maxHeight),
          onTapDown: (details) {
            setState(() => _isDragging = true);
            _handleDrag(details.localPosition, constraints.maxHeight);
          },
          onTapUp: (_) => setState(() { _isDragging = false; _activeLetter = null; }),
          onVerticalDragEnd: (_) => setState(() { _isDragging = false; _activeLetter = null; }),
          onVerticalDragCancel: () => setState(() { _isDragging = false; _activeLetter = null; }),
          
          child: Container(
            width: 32,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: _isDragging ? colorScheme.surfaceVariant.withOpacity(0.9) : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _alphabet.map((letter) {
                final isActive = _activeLetter == letter;
                return Expanded(
                  child: Center(
                    child: Text(
                      letter,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                        color: isActive ? colorScheme.primary : colorScheme.onBackground.withOpacity(0.6),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}