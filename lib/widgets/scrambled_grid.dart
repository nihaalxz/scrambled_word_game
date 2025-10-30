import 'package:flutter/material.dart';

class ScrambledGrid extends StatelessWidget {
  final List<String> letters;
  final List<int> selectedIndices;
  final Function(int index, String letter) onLetterSelected;

  const ScrambledGrid({
    super.key,
    required this.letters,
    required this.selectedIndices,
    required this.onLetterSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 15,
      runSpacing: 15,
      alignment: WrapAlignment.center,
      children: letters.asMap().entries.map((entry) {
        final index = entry.key;
        final letter = entry.value;
        final isSelected = selectedIndices.contains(index);
        
        return AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: isSelected ? 0.0 : 1.0,
          child: AnimatedScale(
            duration: const Duration(milliseconds: 200),
            scale: isSelected ? 0.0 : 1.0,
            child: GestureDetector(
              onTap: () {
                if (!isSelected) {
                  onLetterSelected(index, letter);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.pink.shade300,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.pink.shade400,
                    width: 3,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  letter.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}