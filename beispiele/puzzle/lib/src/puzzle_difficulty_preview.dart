import 'package:flutter/material.dart';

/// Kleine Kachelbilder erklären die Teilmenge ohne mathematische Schreibweise.
/// Die Vorschau ist Dekoration; Beschriftung und Semantik liegen beim Button.
class PuzzleDifficultyPreview extends StatelessWidget {
  final int columns;
  final Color color;
  const PuzzleDifficultyPreview({
    super.key,
    required this.columns,
    required this.color,
  });
  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox(
      width: 42,
      height: 42,
      child: CustomPaint(painter: _GridPainter(columns, color)),
    ),
  );
}

class _GridPainter extends CustomPainter {
  final int columns;
  final Color color;
  const _GridPainter(this.columns, this.color);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final side = size.width / columns;
    for (var row = 0; row < columns; row++) {
      for (var column = 0; column < columns; column++) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              column * side + 1,
              row * side + 1,
              side - 2,
              side - 2,
            ),
            const Radius.circular(2),
          ),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) =>
      oldDelegate.columns != columns || oldDelegate.color != color;
}
