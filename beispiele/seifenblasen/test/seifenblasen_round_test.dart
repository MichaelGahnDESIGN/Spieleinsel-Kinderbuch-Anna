import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:beispiel_seifenblasen/seifenblasen.dart';

void main() {
  test('Ein Tipp erzeugt eine Blase und ein Treffer lässt sie platzen', () {
    final runde = SeifenblasenRunde(maximaleBlasen: 3, radius: 30);

    expect(runde.tippen(const Offset(80, 90)), isNull);
    expect(runde.blasen, hasLength(1));
    expect(runde.tippen(const Offset(90, 90)), isNotNull);
    expect(runde.blasen, isEmpty);
  });

  test('Bei vollem Feld macht die älteste Blase Platz', () {
    final runde = SeifenblasenRunde(maximaleBlasen: 2, radius: 10);
    runde.tippen(const Offset(10, 10));
    runde.tippen(const Offset(50, 10));
    runde.tippen(const Offset(90, 10));

    expect(runde.blasen, hasLength(2));
    expect(
      runde.blasen.map((blase) => blase.position),
      containsAll(<Offset>[const Offset(50, 10), const Offset(90, 10)]),
    );
  });

  test('Schweben bleibt innerhalb des sichtbaren Spielfelds', () {
    final runde = SeifenblasenRunde(maximaleBlasen: 2, radius: 30);
    runde.tippen(const Offset(35, 35));

    final position = runde.blasen.single.sichtbarePosition(
      2.5,
      const Size(200, 150),
    );

    expect(position.dx, inInclusiveRange(30, 170));
    expect(position.dy, inInclusiveRange(30, 120));
  });
}
