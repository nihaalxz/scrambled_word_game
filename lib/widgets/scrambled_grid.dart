import 'package:flutter/material.dart';

class ScrambledGrid extends StatelessWidget {
  final List<String> letters;
  final Function(int index, String letter) onLetterSelected;

  const ScrambledGrid({
    super.key,
    required this.letters,
    required this.onLetterSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 15,
      runSpacing: 15,
      children: letters.asMap().entries.map((entry) {
        final index = entry.key;
        final letter = entry.value;
        
        return GestureDetector(
          onTapDown: (_) => onLetterSelected(index, letter),
          onPanStart: (_) => onLetterSelected(index, letter),
          onPanUpdate: (_) => onLetterSelected(index, letter),
          child: Container(
            padding: const EdgeInsets.all(26),
            decoration: BoxDecoration(
              color: Colors.pink.shade300,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(2, 2),
                ),
              ],
            ),
            child: Text(
              letter,
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}