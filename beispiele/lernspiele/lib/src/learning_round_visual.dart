import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Zeichnet die fachliche Bildaufgabe einer Lernspielrunde.
///
/// Die Redaktion liefert für Größenvergleiche bewusst den kompakten Vertrag
/// `Links: Motiv Größe` und `Rechts: Motiv Größe`. Diese Darstellung macht
/// daraus zwei tatsächlich unterschiedlich große Motive. Die korrekte Lösung
/// wird dabei nicht aus dem Widget abgeleitet: Sie bleibt in der vom Server
/// gelieferten Aufgabe hinterlegt und wird ausschließlich dort validiert.
class LearningRoundVisual extends StatelessWidget {
  final String visual;
  final bool isSizeComparison;
  final bool isShapeFind;

  const LearningRoundVisual({
    super.key,
    required this.visual,
    required this.isSizeComparison,
    required this.isShapeFind,
  });

  @override
  Widget build(BuildContext context) {
    final comparison = isSizeComparison
        ? _SizeComparison.tryParse(visual)
        : null;
    if (comparison != null) {
      return _SizeComparisonVisual(comparison: comparison);
    }
    final shape = isShapeFind ? _ShapeKind.tryParse(visual) : null;
    if (shape != null) return _ShapeVisual(shape: shape);
    // Lokale Sterne werden als getrennte Motive gesetzt. Damit hängt die
    // Zählbarkeit nicht von Emoji-Schrift, Ligaturen oder Zeilenbruch ab.
    final stars = visual.runes.where((rune) => rune == 0x2B50).length;
    if (stars > 0 && visual.replaceAll('⭐', '').trim().isEmpty) {
      return Semantics(
        label: '$stars Sterne',
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 12,
          runSpacing: 8,
          children: List.generate(
            stars,
            (_) => const Icon(
              Icons.star_rounded,
              size: 42,
              color: Color(0xFFD89022),
            ),
          ),
        ),
      );
    }
    return Text(
      visual,
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 42, height: 1.45),
    );
  }
}

/// Die Redaktion kann für die ersten Formenstufen klare Unicode-Vorschauen
/// hinterlegen. Diese Zuordnung zeichnet sie als verlässliche Grundform, statt
/// von einer möglicherweise anders dargestellten Emoji-Schrift abzuhängen.
enum _ShapeKind {
  circle('Kreis'),
  square('Quadrat'),
  triangle('Dreieck'),
  rectangle('Rechteck'),
  star('Stern'),
  heart('Herz'),
  oval('Oval');

  final String label;
  const _ShapeKind(this.label);

  static _ShapeKind? tryParse(String visual) => switch (visual.trim()) {
    '●' || '○' => circle,
    '■' || '□' => square,
    '▲' || '△' || '▶' => triangle,
    '▭' || '▬' => rectangle,
    '★' || '✦' => star,
    '♥' || '♡' => heart,
    '⬭' || '⬯' => oval,
    _ => null,
  };
}

class _ShapeVisual extends StatelessWidget {
  final _ShapeKind shape;
  const _ShapeVisual({required this.shape});

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    label: 'Form: ${shape.label}.',
    child: ExcludeSemantics(
      child: Container(
        width: 180,
        height: 148,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .74),
          borderRadius: BorderRadius.circular(24),
        ),
        child: CustomPaint(painter: _ShapePainter(shape)),
      ),
    ),
  );
}

class _ShapePainter extends CustomPainter {
  final _ShapeKind shape;
  const _ShapePainter(this.shape);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF7B5AC9)
      ..style = PaintingStyle.fill;
    final center = Offset(size.width / 2, size.height / 2);
    final shortSide = math.min(size.width, size.height);

    switch (shape) {
      case _ShapeKind.circle:
        canvas.drawCircle(center, shortSide * .30, paint);
      case _ShapeKind.square:
        final side = shortSide * .60;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: center, width: side, height: side),
            const Radius.circular(10),
          ),
          paint,
        );
      case _ShapeKind.triangle:
        final path = Path()
          ..moveTo(center.dx, center.dy - shortSide * .34)
          ..lineTo(center.dx - shortSide * .33, center.dy + shortSide * .28)
          ..lineTo(center.dx + shortSide * .33, center.dy + shortSide * .28)
          ..close();
        canvas.drawPath(path, paint);
      case _ShapeKind.rectangle:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: center,
              width: shortSide * .76,
              height: shortSide * .46,
            ),
            const Radius.circular(10),
          ),
          paint,
        );
      case _ShapeKind.star:
        final path = Path();
        for (var index = 0; index < 10; index++) {
          final radius = index.isEven ? shortSide * .35 : shortSide * .15;
          final angle = -math.pi / 2 + index * math.pi / 5;
          final point = Offset(
            center.dx + math.cos(angle) * radius,
            center.dy + math.sin(angle) * radius,
          );
          if (index == 0) {
            path.moveTo(point.dx, point.dy);
          } else {
            path.lineTo(point.dx, point.dy);
          }
        }
        canvas.drawPath(path..close(), paint);
      case _ShapeKind.heart:
        final path = Path()
          ..moveTo(center.dx, center.dy + shortSide * .34)
          ..cubicTo(
            center.dx - shortSide * .72,
            center.dy - shortSide * .04,
            center.dx - shortSide * .31,
            center.dy - shortSide * .48,
            center.dx,
            center.dy - shortSide * .18,
          )
          ..cubicTo(
            center.dx + shortSide * .31,
            center.dy - shortSide * .48,
            center.dx + shortSide * .72,
            center.dy - shortSide * .04,
            center.dx,
            center.dy + shortSide * .34,
          )
          ..close();
        canvas.drawPath(path, paint);
      case _ShapeKind.oval:
        canvas.drawOval(
          Rect.fromCenter(
            center: center,
            width: shortSide * .76,
            height: shortSide * .44,
          ),
          paint,
        );
    }
  }

  @override
  bool shouldRepaint(covariant _ShapePainter oldDelegate) =>
      oldDelegate.shape != shape;
}

/// Eine klar begrenzte, fehlertolerante Darstellung für die zwei Seiten eines
/// Größenvergleichs. Unvollständige oder anders formatierte Redaktionsdaten
/// fallen oben auf die sichere Textdarstellung zurück.
class _SizeComparison {
  final _SizeItem left;
  final _SizeItem right;

  const _SizeComparison({required this.left, required this.right});

  static _SizeComparison? tryParse(String value) {
    final matches = RegExp(
      r'^(Links|Rechts):\s*(.+?)\s+(klein|mittelgroß|groß)\s*$',
      multiLine: true,
    ).allMatches(value);
    if (matches.length != 2) return null;

    _SizeItem? left;
    _SizeItem? right;
    for (final match in matches) {
      final item = _SizeItem(
        motif: match.group(2)!.trim(),
        size: match.group(3)!,
      );
      if (match.group(1) == 'Links') {
        left = item;
      } else {
        right = item;
      }
    }
    if (left == null || right == null) return null;
    return _SizeComparison(left: left, right: right);
  }
}

class _SizeItem {
  final String motif;
  final String size;
  const _SizeItem({required this.motif, required this.size});

  double get fontSize => switch (size) {
    'klein' => 46,
    'mittelgroß' => 72,
    'groß' => 104,
    _ => 46,
  };
}

class _SizeComparisonVisual extends StatelessWidget {
  final _SizeComparison comparison;
  const _SizeComparisonVisual({required this.comparison});

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    label:
        'Größenvergleich: links ${comparison.left.size}, rechts ${comparison.right.size}.',
    child: ExcludeSemantics(
      child: Row(
        children: [
          _SizeItemTile(label: 'Links', item: comparison.left),
          const SizedBox(width: 12),
          _SizeItemTile(label: 'Rechts', item: comparison.right),
        ],
      ),
    ),
  );
}

class _SizeItemTile extends StatelessWidget {
  final String label;
  final _SizeItem item;
  const _SizeItemTile({required this.label, required this.item});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      height: 148,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .74),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFF5278C5).withValues(alpha: .4),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF405A95),
              fontWeight: FontWeight.w800,
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                item.motif,
                style: TextStyle(fontSize: item.fontSize, height: 1),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
