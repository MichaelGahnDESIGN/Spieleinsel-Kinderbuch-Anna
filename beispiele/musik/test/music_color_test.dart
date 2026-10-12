import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:beispiel_musik/src/music_piece.dart';
import 'package:beispiel_musik/src/music_note_style.dart';
import 'package:beispiel_musik/src/piano_keyboard.dart';

void main() {
  test('Alle acht Töne haben eigene Farben und lesbare Beschriftung', () {
    expect(dMajorScale.map(musicNoteColor).toSet(), hasLength(8));
    for (final note in dMajorScale) {
      final luminance = musicNoteColor(note).computeLuminance();
      final contrast = musicNoteForeground(note) == Colors.white
          ? 1.05 / (luminance + .05)
          : (luminance + .05) / .05;
      expect(contrast, greaterThanOrEqualTo(3));
    }
  });
  testWidgets(
    'Aktive Taste ist zusätzlich umrandet; Abbruch entfernt Markierung',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: PianoKeyboard(onPressed: (_) {})),
        ),
      );
      Border border() =>
          (tester
                          .widget<DecoratedBox>(
                            find.byKey(const Key('music-note-active-d4')),
                          )
                          .decoration
                      as BoxDecoration)
                  .border!
              as Border;
      expect(
        tester
            .widget<DecoratedBox>(find.byKey(const Key('music-note-active-d4')))
            .position,
        DecorationPosition.foreground,
      );
      expect(border().top.color, Colors.transparent);
      final gesture = await tester.startGesture(
        tester.getCenter(find.byKey(const Key('music-note-d4'))),
        kind: PointerDeviceKind.touch,
      );
      await tester.pump();
      expect(border().top.color, Colors.black87);
      await gesture.cancel();
      await tester.pump();
      expect(border().top.color, Colors.transparent);
    },
  );
}
