import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Visuelle Sortieraufgabe für kleine Kinder.
///
/// Ein großer farbiger Gegenstand wird in einen von zwei bis vier Körben
/// sortiert. Das klappt durch Ziehen oder durch direktes Antippen des Korbs.
/// Farbflächen und Touch-Ziele tragen die Aufgabe; Beschriftungen werden nur
/// für Screenreader benötigt und sind deshalb nicht Teil der Kinderansicht.
class ColorSortRound extends StatefulWidget {
  final String target;
  final List<String> options;
  final List<Color> optionColors;
  final ValueChanged<String> onChoose;
  final Color accent;

  /// Optionales Motiv aus der gemeinsamen Mediathek. Die Redaktion kann dadurch den
  /// Platzhalter-Gegenstand austauschen, ohne den Spielcode zu ändern.
  final String? objectImageUrl;

  const ColorSortRound({
    super.key,
    required this.target,
    required this.options,
    required this.optionColors,
    required this.onChoose,
    required this.accent,
    this.objectImageUrl,
  });

  @override
  State<ColorSortRound> createState() => _ColorSortRoundState();
}

class _ColorSortRoundState extends State<ColorSortRound> {
  bool _selected = false;
  late List<_ColorChoice> _choices = _buildChoices();

  @override
  void didUpdateWidget(covariant ColorSortRound oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.target != widget.target ||
        oldWidget.options != widget.options ||
        oldWidget.optionColors != widget.optionColors) {
      _selected = false;
      _choices = _buildChoices();
    }
  }

  Color get _targetColor {
    final index = widget.options.indexOf(widget.target);
    if (index >= 0 && index < widget.optionColors.length) {
      return widget.optionColors[index];
    }
    return _namedColor(widget.target, widget.accent);
  }

  List<_ColorChoice> _buildChoices() {
    final choices = <_ColorChoice>[];
    for (var index = 0; index < widget.options.length; index++) {
      final label = widget.options[index];
      if (choices.any(
        (choice) => choice.label.toLowerCase() == label.toLowerCase(),
      )) {
        continue;
      }
      choices.add(
        _ColorChoice(
          label: label,
          color: index < widget.optionColors.length
              ? widget.optionColors[index]
              : _namedColor(label, widget.accent),
        ),
      );
      if (choices.length == 4) break;
    }
    if (choices.length < 2) {
      choices.add(
        _ColorChoice(
          label: widget.target.toLowerCase() == 'blau' ? 'Rot' : 'Blau',
          color: widget.target.toLowerCase() == 'blau'
              ? const Color(0xFFE85C52)
              : const Color(0xFF4B84D1),
        ),
      );
    }
    choices.shuffle(math.Random());
    return choices;
  }

  void _choose(String label) {
    if (_selected) setState(() => _selected = false);
    widget.onChoose(label);
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final compact = constraints.maxWidth < 600;
      final object = _SortableColorObject(
        color: _targetColor,
        selected: _selected,
        imageUrl: widget.objectImageUrl,
        onTap: () => setState(() => _selected = !_selected),
      );
      final baskets = _ColorBasketGrid(
        choices: _choices,
        accent: widget.accent,
        selected: _selected,
        onChoose: _choose,
      );

      if (compact) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [object, const SizedBox(height: 10), baskets],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(flex: 4, child: object),
          const SizedBox(width: 24),
          Expanded(flex: 6, child: baskets),
        ],
      );
    },
  );
}

class _ColorChoice {
  final String label;
  final Color color;
  const _ColorChoice({required this.label, required this.color});
}

Color _namedColor(String label, Color fallback) =>
    switch (label.trim().toLowerCase()) {
      'rot' => const Color(0xFFE85C52),
      'blau' => const Color(0xFF4B84D1),
      'gelb' => const Color(0xFFF2C63D),
      'grün' || 'gruen' => const Color(0xFF66A96B),
      'orange' => const Color(0xFFF09338),
      'lila' || 'violett' => const Color(0xFF8A62C7),
      _ => fallback,
    };

class _SortableColorObject extends StatelessWidget {
  final Color color;
  final bool selected;
  final String? imageUrl;
  final VoidCallback onTap;

  const _SortableColorObject({
    required this.color,
    required this.selected,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final object = _ColorObject(color: color, imageUrl: imageUrl);
    final card = AnimatedContainer(
      key: selected ? const Key('color-object-selected') : null,
      duration: const Duration(milliseconds: 130),
      constraints: const BoxConstraints(minHeight: 136),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: selected ? color.withValues(alpha: .18) : Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: selected ? color : color.withValues(alpha: .55),
          width: selected ? 5 : 3,
        ),
      ),
      child: Center(child: object),
    );

    return Semantics(
      button: true,
      selected: selected,
      label: 'Farbigen Gegenstand auswählen',
      child: GestureDetector(
        key: const Key('color-sort-object'),
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: LongPressDraggable<String>(
          data: 'object',
          delay: const Duration(milliseconds: 180),
          feedback: Material(color: Colors.transparent, child: object),
          childWhenDragging: Opacity(opacity: .30, child: card),
          child: card,
        ),
      ),
    );
  }
}

class _ColorObject extends StatelessWidget {
  final Color color;
  final String? imageUrl;

  const _ColorObject({required this.color, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final url = imageUrl?.trim();
    return ExcludeSemantics(
      child: Container(
        width: 116,
        height: 116,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: .28),
              blurRadius: 20,
              offset: const Offset(0, 9),
            ),
          ],
        ),
        child: url == null || url.isEmpty
            ? const Icon(Icons.toys_rounded, color: Colors.white, size: 68)
            : ClipOval(
                child: Image.network(
                  url,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.toys_rounded,
                    color: Colors.white,
                    size: 68,
                  ),
                ),
              ),
      ),
    );
  }
}

class _ColorBasketGrid extends StatelessWidget {
  final List<_ColorChoice> choices;
  final Color accent;
  final bool selected;
  final ValueChanged<String> onChoose;

  const _ColorBasketGrid({
    required this.choices,
    required this.accent,
    required this.selected,
    required this.onChoose,
  });

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final columns = constraints.maxWidth < 250 ? 1 : 2;
      final width = columns == 1
          ? constraints.maxWidth
          : math.max(128.0, (constraints.maxWidth - 12) / 2);
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          for (final choice in choices)
            SizedBox(
              width: width,
              child: _ColorBasket(
                choice: choice,
                accent: accent,
                selected: selected,
                onChoose: onChoose,
              ),
            ),
        ],
      );
    },
  );
}

class _ColorBasket extends StatelessWidget {
  final _ColorChoice choice;
  final Color accent;
  final bool selected;
  final ValueChanged<String> onChoose;

  const _ColorBasket({
    required this.choice,
    required this.accent,
    required this.selected,
    required this.onChoose,
  });

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: 'In den ${choice.label}en Korb sortieren',
    child: GestureDetector(
      key: Key('color-basket-${choice.label.toLowerCase()}'),
      behavior: HitTestBehavior.opaque,
      onTap: () => onChoose(choice.label),
      child: DragTarget<String>(
        onWillAcceptWithDetails: (details) => details.data == 'object',
        onAcceptWithDetails: (_) => onChoose(choice.label),
        builder: (context, candidates, _) {
          final highlighted = candidates.isNotEmpty || selected;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 130),
            height: 108,
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            decoration: BoxDecoration(
              color: choice.color.withValues(alpha: highlighted ? .23 : .12),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: choice.color,
                width: highlighted ? 5 : 3,
              ),
            ),
            child: ExcludeSemantics(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_rounded,
                    color: choice.color,
                    size: 60,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 62,
                    height: 10,
                    decoration: BoxDecoration(
                      color: choice.color,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ),
  );
}
