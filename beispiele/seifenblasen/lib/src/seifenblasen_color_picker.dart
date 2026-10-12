import 'package:flutter/material.dart';

import 'seifenblasen_color.dart';

/// Farben selbst sind das Hauptsignal; Texte dienen nur Semantik und Tooltip.
/// Auf Handys liegen alle sechs großen Tippziele in zwei Reihen ohne Scrollen.
class SeifenblasenFarbauswahl extends StatelessWidget {
  const SeifenblasenFarbauswahl({
    super.key,
    required this.selected,
    required this.onSelected,
  });
  final SeifenblasenFarbe selected;
  final ValueChanged<SeifenblasenFarbe> onSelected;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final columns = constraints.maxWidth >= 440 ? 6 : 3;
      final width = (constraints.maxWidth - 24 - (columns - 1) * 8) / columns;
      return Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final option in SeifenblasenFarbe.values)
              SizedBox(
                width: width,
                height: 56,
                child: Semantics(
                  button: true,
                  selected: selected == option,
                  label: 'Seifenblasenfarbe: ${option.titel}',
                  excludeSemantics: true,
                  child: Tooltip(
                    message: option.titel,
                    child: OutlinedButton(
                      key: Key('bubble_color_${option.name}'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.all(5),
                        backgroundColor: Colors.white,
                        side: BorderSide(
                          color: selected == option
                              ? const Color(0xFF4B246C)
                              : const Color(0xFFD8CEE2),
                          width: selected == option ? 3 : 1,
                        ),
                      ),
                      onPressed: () => onSelected(option),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: option.farbe,
                          gradient: option == SeifenblasenFarbe.bunt
                              ? SweepGradient(
                                  colors: [
                                    for (final color
                                        in SeifenblasenFarbe.values.skip(1))
                                      color.farbe!,
                                    SeifenblasenFarbe.rot.farbe!,
                                  ],
                                )
                              : null,
                        ),
                        child: selected == option
                            ? const Icon(
                                Icons.check_circle,
                                color: Colors.white,
                                shadows: [
                                  Shadow(color: Colors.black87, blurRadius: 3),
                                ],
                              )
                            : null,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    },
  );
}
