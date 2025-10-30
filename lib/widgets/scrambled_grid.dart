import 'package:flutter/material.dart';

class ScrambledGrid extends StatelessWidget {
  final List<String> letters;
  final Function(String) onSwipeLetter;

  const ScrambledGrid({
    super.key,
    required this.letters,
    required this.onSwipeLetter,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 15,
      runSpacing: 15,
      children: letters.map((letter) {
        return GestureDetector(
          onTapDown: (_) => onSwipeLetter(letter), // Tap support
          onPanStart: (_) => onSwipeLetter(letter), // Drag start support
          onPanUpdate: (_) => onSwipeLetter(letter), // Drag across letters
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
