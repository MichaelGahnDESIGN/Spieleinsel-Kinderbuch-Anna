import 'package:flutter/material.dart';

import 'music_piece.dart';
import 'music_note_button.dart';

/// Eine einzige, große D-Dur-Tastatur für alle Piano-Spielarten.
///
/// Die acht Farbtasten sind für Kinder schneller erfassbar als ein zweites,
/// kleineres Keyboard mit schwarzen Tasten. Alle Bild-Lieder nutzen genau
/// diesen Notenvorrat.
class PianoKeyboard extends StatelessWidget {
  final ValueChanged<MusicNote> onPressed;

  const PianoKeyboard({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Piano mit acht bunten D-Dur-Tönen',
    child: LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 600 ? 8 : 4;
        const gap = 8.0;
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        final height = columns == 8
            ? (width * 2.4).clamp(190.0, 320.0)
            : (width * 1.7).clamp(120.0, 200.0);
        // Auf Tablets liegen alle Töne nebeneinander. Schmale Fenster erhalten
        // zwei geordnete Reihen mit großen Zielen statt winziger Tasten.
        return Wrap(
          key: const Key('music-piano-keyboard'),
          spacing: gap,
          runSpacing: gap,
          children: dMajorScale
              .map(
                (note) => SizedBox(
                  width: width,
                  height: height,
                  child: MusicNoteButton(note: note, onPressed: onPressed),
                ),
              )
              .toList(growable: false),
        );
      },
    ),
  );
}
