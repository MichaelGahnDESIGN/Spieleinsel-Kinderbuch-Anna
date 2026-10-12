import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:beispiel_lernspiele/src/color_sort_round.dart';
import 'package:beispiel_lernspiele/src/shape_match_round.dart';

void main() {
  testWidgets('Farben sortieren bietet große Körbe und Antipp-Ablauf', (
    tester,
  ) async {
    String? answer;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ColorSortRound(
            target: 'Rot',
            options: const ['Rot', 'Blau', 'Gelb'],
            optionColors: const [
              Color(0xFFE85C52),
              Color(0xFF4B84D1),
              Color(0xFFF2C63D),
            ],
            accent: const Color(0xFFD35F7B),
            onChoose: (value) => answer = value,
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('color-sort-object')), findsOneWidget);
    expect(find.byKey(const Key('color-basket-rot')), findsOneWidget);
    expect(find.byKey(const Key('color-basket-blau')), findsOneWidget);
    expect(find.byKey(const Key('color-basket-gelb')), findsOneWidget);

    await tester.tap(find.byKey(const Key('color-sort-object')));
    await tester.pump();
    expect(find.byKey(const Key('color-object-selected')), findsOneWidget);
    await tester.tap(find.byKey(const Key('color-basket-rot')));
    expect(answer, 'Rot');
  });

  testWidgets('Formen finden zeigt Zielfeld und vier vertraute Objekte', (
    tester,
  ) async {
    String? answer;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ShapeMatchRound(
            target: 'Kreis',
            options: const ['Kreis', 'Dreieck', 'Rechteck', 'Stern'],
            accent: const Color(0xFF7B5AC9),
            onChoose: (value) => answer = value,
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('shape-target')), findsOneWidget);
    expect(find.bySemanticsLabel('Ball auswählen'), findsOneWidget);
    expect(find.bySemanticsLabel('Segel auswählen'), findsOneWidget);
    expect(find.bySemanticsLabel('Buch auswählen'), findsOneWidget);
    expect(find.bySemanticsLabel('Sternkissen auswählen'), findsOneWidget);

    await tester.tap(find.byKey(const Key('shape-option-Kreis')));
    await tester.pump();
    expect(find.byKey(const Key('shape-target-selected')), findsOneWidget);
    await tester.tap(find.byKey(const Key('shape-target')));
    expect(answer, 'Kreis');
  });

  testWidgets('Formen finden bleibt auf Smartphone-Breite bedienbar', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(393, 852));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ShapeMatchRound(
              target: 'Dreieck',
              options: const ['Dreieck', 'Kreis', 'Rechteck', 'Stern'],
              accent: const Color(0xFF7B5AC9),
              onChoose: (_) {},
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('shape-option-Dreieck')), findsOneWidget);
  });
}
