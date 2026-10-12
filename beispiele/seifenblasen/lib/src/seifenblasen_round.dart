import 'dart:math' as math;
import 'dart:ui';

/// Eine einzelne Blase im lokalen Spielfeld.
///
/// Es werden ausschließlich Anzeige-Koordinaten gehalten. Sie beschreiben
/// weder ein Profil noch ein Kind und werden nicht an einen Server übertragen.
class Seifenblase {
  final int id;
  final Offset position;
  final double radius;

  const Seifenblase({
    required this.id,
    required this.position,
    required this.radius,
  });

  bool trifft(Offset tippposition) =>
      (tippposition - position).distance <= radius;

  /// Sanftes, deterministisches Schweben. Das Modell bleibt absichtlich rein
  /// lokal und berechenbar, damit Malfläche und unsichtbare Touch-Fläche stets
  /// exakt dieselbe Position verwenden.
  /// Nach Drehung oder im kleinen Browserfenster darf kein Kreis größer als
  /// das Feld sein. Malfläche und Touchziel verwenden denselben Radius.
  double radiusImFeld(Size feldgroesse) => math.min(
    radius,
    math.max(0, math.min(feldgroesse.width, feldgroesse.height) / 2),
  );

  Offset sichtbarePosition(double sekunden, Size feldgroesse) {
    final sichtbarerRadius = radiusImFeld(feldgroesse);
    final phase = id * 1.73;
    final drift = Offset(
      math.sin(sekunden * 1.2 + phase) * (5 + id % 5),
      math.cos(sekunden * .9 + phase) * (4 + id % 4),
    );
    return Offset(
      (position.dx + drift.dx)
          .clamp(sichtbarerRadius, feldgroesse.width - sichtbarerRadius)
          .toDouble(),
      (position.dy + drift.dy)
          .clamp(sichtbarerRadius, feldgroesse.height - sichtbarerRadius)
          .toDouble(),
    );
  }
}

/// Lokale Spielregel für Hinzufügen und Platzenlassen.
///
/// Die UI delegiert Treffer vollständig hierher, damit die zentrale kindliche
/// Interaktion ohne Widget-Baum und ohne Zufall getestet werden kann.
class SeifenblasenRunde {
  final int maximaleBlasen;
  final double radius;
  final List<Seifenblase> _blasen = [];
  int _naechsteId = 1;

  SeifenblasenRunde({required this.maximaleBlasen, required this.radius})
    : assert(maximaleBlasen > 0),
      assert(radius > 0);

  List<Seifenblase> get blasen => List.unmodifiable(_blasen);

  /// Tippt das Kind auf eine vorhandene Blase, wird genau diese entfernt.
  /// Andernfalls entsteht eine neue Blase. Bei vollem Feld verschwindet die
  /// älteste Blase zuerst, damit jeder Tipp weiterhin eine sichtbare Reaktion
  /// auslöst und kein unerklärliches "geht nicht" entsteht.
  Seifenblase? tippen(Offset position) {
    for (final blase in _blasen.reversed) {
      if (blase.trifft(position)) {
        _blasen.remove(blase);
        return blase;
      }
    }
    if (_blasen.length >= maximaleBlasen) _blasen.removeAt(0);
    _blasen.add(
      Seifenblase(id: _naechsteId++, position: position, radius: radius),
    );
    return null;
  }

  void leeren() => _blasen.clear();
}
