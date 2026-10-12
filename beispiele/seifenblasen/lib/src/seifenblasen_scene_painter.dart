import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'seifenblasen_round.dart';
import 'seifenblasen_color.dart';

/// Malt nur die interaktiven Blasen über eine lokale Hintergrund-Illustration.
/// Das Bild selbst wird als Widget eingebunden, damit es vollständig sichtbar
/// bleibt und nicht durch einen Canvas-Zuschnitt verfälscht wird.
class SeifenblasenScenePainter extends CustomPainter {
  final List<Seifenblase> blasen;
  final SeifenblasenFarbe farbe;
  final Seifenblase? platzendeBlase;
  final Size feldgroesse;
  final double sekunden;
  final double platzFortschritt;

  const SeifenblasenScenePainter({
    required this.blasen,
    this.farbe = SeifenblasenFarbe.bunt,
    required this.feldgroesse,
    required this.sekunden,
    this.platzendeBlase,
    this.platzFortschritt = 1,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final blase in blasen) {
      _maleBlase(canvas, blase, blase.sichtbarePosition(sekunden, feldgroesse));
    }
    if (platzendeBlase != null && platzFortschritt < 1) {
      _malePlatzen(
        canvas,
        platzendeBlase!.sichtbarePosition(sekunden, feldgroesse),
      );
    }
  }

  void _maleBlase(Canvas canvas, Seifenblase blase, Offset position) {
    final radius = blase.radiusImFeld(feldgroesse);
    final color = farbe.fuerBlase(blase.id);
    final bounds = Rect.fromCircle(center: position, radius: radius);
    // Eine Seifenhaut färbt vor allem den Rand. Die fast klare Mitte lässt
    // die Illustration sichtbar und verhindert den Eindruck eines Ballons.
    final fill = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withValues(alpha: .015),
          color.withValues(alpha: .035),
          color.withValues(alpha: .18),
        ],
        stops: const [0, .72, 1],
      ).createShader(bounds);
    canvas.drawCircle(position, radius, fill);

    // Dünne, wechselnde Farbsäume bilden die schillernde Seifenhaut ab.
    // Die gewählte Spielfarbe bleibt dabei die stärkste Randfarbe.
    final rim = Paint()
      ..shader = SweepGradient(
        colors: [
          color.withValues(alpha: .8),
          const Color(0xFFBDEEFF).withValues(alpha: .85),
          const Color(0xFFFFBDEB).withValues(alpha: .8),
          color.withValues(alpha: .8),
          Colors.white.withValues(alpha: .9),
          color.withValues(alpha: .8),
        ],
      ).createShader(bounds)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    canvas.drawCircle(position, radius, rim);

    // Gebogene Reflexe folgen der Kugelform statt eines massiven Glanzpunkts.
    final reflection = Paint()
      ..color = Colors.white.withValues(alpha: .9)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3;
    canvas.drawArc(
      Rect.fromCircle(center: position, radius: radius * .84),
      math.pi * 1.12,
      math.pi * .32,
      false,
      reflection,
    );
    reflection
      ..color = Colors.white.withValues(alpha: .5)
      ..strokeWidth = 1.5;
    canvas.drawArc(
      Rect.fromCircle(center: position, radius: radius * .9),
      math.pi * .15,
      math.pi * .2,
      false,
      reflection,
    );
  }

  /// Sichtbare Plopp-Animation: Kreis löst sich auf, acht Tropfen fliegen aus.
  void _malePlatzen(Canvas canvas, Offset point) {
    final progress = platzFortschritt.clamp(0.0, 1.0).toDouble();
    final radius = 22 + 22 * progress;
    final rim = Paint()
      ..color = Colors.white.withValues(alpha: 1 - progress)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawCircle(point, radius, rim);

    final drop = Paint()
      ..color = farbe
          .fuerBlase(platzendeBlase!.id)
          .withValues(alpha: 1 - progress);
    for (var i = 0; i < 8; i++) {
      final angle = i * math.pi / 4;
      final distance = 18 + 42 * progress;
      final offset = Offset.fromDirection(angle, distance);
      canvas.drawCircle(point + offset, 5 * (1 - progress), drop);
    }
  }

  @override
  bool shouldRepaint(covariant SeifenblasenScenePainter oldDelegate) => true;
}
