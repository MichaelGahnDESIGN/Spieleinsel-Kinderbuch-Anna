import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Kindgerechtes Formen-Legepuzzle mit Ziehen und Antipp-Alternative.
///
/// Links beziehungsweise oben wartet ein großes Zielfeld. Daneben stehen vier
/// vertraute Gegenstände: Ball, Segel, Buch und Sternkissen. Die Gegenstände
/// besitzen die gesuchte Grundform, sodass ein Kind die Aufgabe ohne Lesetext
/// lösen kann. Auf Touch-Geräten klappt derselbe Ablauf in zwei Schritten:
/// Gegenstand antippen und anschließend das Zielfeld antippen.
class ShapeMatchRound extends StatefulWidget {
  final String target;
  final List<String> options;
  final ValueChanged<String> onChoose;
  final Color accent;

  /// Optionale, redaktionell hochgeladene Motive pro Form. Das Bild wird in
  /// die jeweilige Silhouette geschnitten; damit bleibt die Form erkennbar.
  /// Der gegenwärtige Lernaufgaben-Vertrag liefert nur ein einzelnes Bild.
  /// Sobald der Server vier Medien-IDs unterstützt, kann die Plattform hier
  /// alle vier URLs zuordnen, ohne dieses Widget erneut umzubauen.
  final Map<String, String> optionImageUrls;

  const ShapeMatchRound({
    super.key,
    required this.target,
    required this.options,
    required this.onChoose,
    required this.accent,
    this.optionImageUrls = const {},
  });

  @override
  State<ShapeMatchRound> createState() => _ShapeMatchRoundState();
}

class _ShapeMatchRoundState extends State<ShapeMatchRound> {
  String? _selected;
  late List<String> _roundChoices = _buildChoices();

  /// Eine Runde behält ihre Positionen beim Antippen; erst neue Aufgaben
  /// mischen neu und verwerfen die Auswahl aus der vorherigen Aufgabe.
  @override
  void didUpdateWidget(covariant ShapeMatchRound oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.target != widget.target ||
        oldWidget.options != widget.options) {
      _selected = null;
      _roundChoices = _buildChoices();
    }
  }

  void _select(String shape) => setState(() => _selected = shape);

  void _place(String shape) {
    setState(() => _selected = null);
    widget.onChoose(shape);
  }

  List<String> _buildChoices() {
    final choices = <String>[];
    for (final shape in [
      widget.target,
      ...widget.options,
      ..._fallbackShapes,
    ]) {
      final normalized = _normalizedShape(shape);
      if (!choices.any((entry) => _normalizedShape(entry) == normalized)) {
        choices.add(shape);
      }
      if (choices.length == 4) break;
    }
    return choices..shuffle(math.Random());
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final compact = constraints.maxWidth < 610;
      final target = _TargetShapeField(
        target: widget.target,
        selected: _selected,
        accent: widget.accent,
        onAccept: _place,
      );
      final choices = _ShapeChoiceGrid(
        options: _roundChoices,
        selected: _selected,
        accent: widget.accent,
        optionImageUrls: widget.optionImageUrls,
        onSelect: _select,
      );

      if (compact) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [target, const SizedBox(height: 18), choices],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(flex: 5, child: target),
          const SizedBox(width: 24),
          Expanded(flex: 4, child: choices),
        ],
      );
    },
  );
}

const _fallbackShapes = ['Kreis', 'Dreieck', 'Rechteck', 'Stern'];

String _normalizedShape(String value) => value.trim().toLowerCase();

class _TargetShapeField extends StatelessWidget {
  final String target;
  final String? selected;
  final Color accent;
  final ValueChanged<String> onAccept;

  const _TargetShapeField({
    required this.target,
    required this.selected,
    required this.accent,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    final active = selected != null;
    return Semantics(
      button: active,
      label: active
          ? 'Zielfeld. Ausgewählten Gegenstand hier ablegen.'
          : 'Zielfeld für $target. Passenden Gegenstand hineinziehen.',
      child: GestureDetector(
        key: const Key('shape-target'),
        behavior: HitTestBehavior.opaque,
        onTap: active ? () => onAccept(selected!) : null,
        child: DragTarget<String>(
          onWillAcceptWithDetails: (details) => details.data.isNotEmpty,
          onAcceptWithDetails: (details) => onAccept(details.data),
          builder: (context, candidates, _) {
            final highlighted = candidates.isNotEmpty || active;
            return AnimatedContainer(
              key: highlighted ? const Key('shape-target-selected') : null,
              duration: const Duration(milliseconds: 140),
              constraints: const BoxConstraints(minHeight: 112),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: highlighted
                    ? accent.withValues(alpha: .17)
                    : const Color(0xFFFFFDF8),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: highlighted ? accent : accent.withValues(alpha: .48),
                  width: highlighted ? 5 : 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: accent.withValues(alpha: .10),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.touch_app_rounded,
                    color: accent.withValues(alpha: .75),
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  _ShapeSlot(shape: target, color: accent, size: 80),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ShapeChoiceGrid extends StatelessWidget {
  final List<String> options;
  final String? selected;
  final Color accent;
  final Map<String, String> optionImageUrls;
  final ValueChanged<String> onSelect;

  const _ShapeChoiceGrid({
    required this.options,
    required this.selected,
    required this.accent,
    required this.optionImageUrls,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final itemWidth = math.max(118.0, (constraints.maxWidth - 12) / 2);
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          for (final shape in options)
            SizedBox(
              width: itemWidth,
              child: _ShapeChoice(
                shape: shape,
                selected:
                    _normalizedShape(shape) == _normalizedShape(selected ?? ''),
                accent: accent,
                imageUrl: optionImageUrls[shape],
                onSelect: () => onSelect(shape),
              ),
            ),
        ],
      );
    },
  );
}

class _ShapeChoice extends StatelessWidget {
  final String shape;
  final bool selected;
  final Color accent;
  final String? imageUrl;
  final VoidCallback onSelect;

  const _ShapeChoice({
    required this.shape,
    required this.selected,
    required this.accent,
    required this.imageUrl,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final object = _ShapeObject(
      shape: shape,
      color: _objectColor(shape),
      size: 68,
      imageUrl: imageUrl,
    );
    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      height: 96,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: selected ? accent.withValues(alpha: .18) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: selected ? accent : accent.withValues(alpha: .38),
          width: selected ? 5 : 2,
        ),
      ),
      child: Center(child: object),
    );

    return Semantics(
      button: true,
      selected: selected,
      label: '${_objectName(shape)} auswählen',
      child: GestureDetector(
        key: Key('shape-option-$shape'),
        behavior: HitTestBehavior.opaque,
        onTap: onSelect,
        child: Draggable<String>(
          data: shape,
          feedback: Material(color: Colors.transparent, child: object),
          childWhenDragging: Opacity(opacity: .30, child: card),
          child: card,
        ),
      ),
    );
  }
}

String _objectName(String shape) => switch (_normalizedShape(shape)) {
  'kreis' => 'Ball',
  'dreieck' => 'Segel',
  'rechteck' => 'Buch',
  'quadrat' => 'Geschenk',
  'herz' => 'Herzkissen',
  'oval' => 'Ei',
  _ => 'Sternkissen',
};

Color _objectColor(String shape) => switch (_normalizedShape(shape)) {
  'kreis' => const Color(0xFFE85C52),
  'dreieck' => const Color(0xFF4B90D6),
  'rechteck' => const Color(0xFFF0A62E),
  'quadrat' => const Color(0xFF67A969),
  'herz' => const Color(0xFFE85C87),
  'oval' => const Color(0xFF9B72CF),
  _ => const Color(0xFFF2C83B),
};

class _ShapeSlot extends StatelessWidget {
  final String shape;
  final Color color;
  final double size;

  const _ShapeSlot({
    required this.shape,
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _ShapePainter(shape, color, outline: true)),
    ),
  );
}

class _ShapeObject extends StatelessWidget {
  final String shape;
  final Color color;
  final double size;
  final String? imageUrl;

  const _ShapeObject({
    required this.shape,
    required this.color,
    required this.size,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final url = imageUrl?.trim();
    if (url != null && url.isNotEmpty) {
      return ExcludeSemantics(
        child: SizedBox(
          width: size,
          height: size,
          child: ClipPath(
            clipper: _ShapeClipper(shape),
            child: Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  _PaintedShapeObject(shape: shape, color: color, size: size),
            ),
          ),
        ),
      );
    }
    return _PaintedShapeObject(shape: shape, color: color, size: size);
  }
}

class _PaintedShapeObject extends StatelessWidget {
  final String shape;
  final Color color;
  final double size;

  const _PaintedShapeObject({
    required this.shape,
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _ShapePainter(shape, color)),
    ),
  );
}

Path _shapePath(String shape, Size size) {
  final center = Offset(size.width / 2, size.height / 2);
  final side = math.min(size.width, size.height);
  switch (_normalizedShape(shape)) {
    case 'kreis':
      return Path()
        ..addOval(Rect.fromCircle(center: center, radius: side * .38));
    case 'dreieck':
      return Path()
        ..moveTo(center.dx, center.dy - side * .40)
        ..lineTo(center.dx - side * .39, center.dy + side * .35)
        ..lineTo(center.dx + side * .39, center.dy + side * .35)
        ..close();
    case 'rechteck':
      return Path()..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: center,
            width: side * .86,
            height: side * .56,
          ),
          const Radius.circular(13),
        ),
      );
    case 'quadrat':
      return Path()..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: center,
            width: side * .72,
            height: side * .72,
          ),
          const Radius.circular(13),
        ),
      );
    case 'oval':
      return Path()..addOval(
        Rect.fromCenter(center: center, width: side * .62, height: side * .86),
      );
    case 'herz':
      return Path()
        ..moveTo(center.dx, center.dy + side * .40)
        ..cubicTo(
          center.dx - side * .12,
          center.dy + side * .28,
          center.dx - side * .43,
          center.dy + side * .05,
          center.dx - side * .43,
          center.dy - side * .16,
        )
        ..cubicTo(
          center.dx - side * .43,
          center.dy - side * .43,
          center.dx - side * .10,
          center.dy - side * .47,
          center.dx,
          center.dy - side * .25,
        )
        ..cubicTo(
          center.dx + side * .10,
          center.dy - side * .47,
          center.dx + side * .43,
          center.dy - side * .43,
          center.dx + side * .43,
          center.dy - side * .16,
        )
        ..cubicTo(
          center.dx + side * .43,
          center.dy + side * .05,
          center.dx + side * .12,
          center.dy + side * .28,
          center.dx,
          center.dy + side * .40,
        )
        ..close();
    default:
      final path = Path();
      for (var index = 0; index < 10; index++) {
        final radius = index.isEven ? side * .41 : side * .19;
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
      return path..close();
  }
}

class _ShapeClipper extends CustomClipper<Path> {
  final String shape;
  const _ShapeClipper(this.shape);

  @override
  Path getClip(Size size) => _shapePath(shape, size);

  @override
  bool shouldReclip(covariant _ShapeClipper oldClipper) =>
      oldClipper.shape != shape;
}

class _ShapePainter extends CustomPainter {
  final String shape;
  final Color color;
  final bool outline;

  const _ShapePainter(this.shape, this.color, {this.outline = false});

  @override
  void paint(Canvas canvas, Size size) {
    final path = _shapePath(shape, size);
    final paint = Paint()
      ..color = outline ? color.withValues(alpha: .62) : color
      ..style = outline ? PaintingStyle.stroke : PaintingStyle.fill
      ..strokeWidth = outline ? 8 : 1
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, paint);

    if (outline) return;
    final detail = Paint()
      ..color = Colors.white.withValues(alpha: .75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    final normalized = _normalizedShape(shape);
    if (normalized == 'kreis') {
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(size.width * .50, size.height * .50),
          width: size.width * .55,
          height: size.height * .70,
        ),
        -.8,
        1.6,
        false,
        detail,
      );
    } else if (normalized == 'rechteck') {
      canvas.drawLine(
        Offset(size.width * .50, size.height * .25),
        Offset(size.width * .50, size.height * .75),
        detail,
      );
    } else if (normalized == 'quadrat') {
      canvas.drawLine(
        Offset(size.width * .50, size.height * .18),
        Offset(size.width * .50, size.height * .82),
        detail,
      );
      canvas.drawLine(
        Offset(size.width * .18, size.height * .50),
        Offset(size.width * .82, size.height * .50),
        detail,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ShapePainter oldDelegate) =>
      oldDelegate.shape != shape ||
      oldDelegate.color != color ||
      oldDelegate.outline != outline;
}
