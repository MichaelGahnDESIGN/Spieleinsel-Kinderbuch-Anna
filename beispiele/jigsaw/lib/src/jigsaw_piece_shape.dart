import 'dart:ui';
import 'jigsaw_piece.dart';

/// Erzeugt echte, geschlossene Puzzleteilkonturen. Alle Kanten verwenden
/// dasselbe symmetrische Profil. Umgekehrte Laufrichtung und umgekehrtes
/// Vorzeichen ergeben exakt die Gegenkante des Nachbarteils.
class JigsawPieceShape {
  static Path path(JigsawPiece piece, double cell) {
    final result = Path()..moveTo(0, 0);
    _edge(result, Offset.zero, Offset(cell, 0), piece.top);
    _edge(result, Offset(cell, 0), Offset(cell, cell), piece.right);
    _edge(result, Offset(cell, cell), Offset(0, cell), piece.bottom);
    _edge(result, Offset(0, cell), Offset.zero, piece.left);
    return result..close();
  }

  static void _edge(Path path, Offset start, Offset end, int sign) {
    if (sign == 0) {
      path.lineTo(end.dx, end.dy);
      return;
    }
    final along = end - start;
    final outward = Offset(along.dy, -along.dx) * sign.toDouble();
    Offset point(double position, double height) =>
        start + along * position + outward * height;
    void line(double x, double y) {
      final p = point(x, y);
      path.lineTo(p.dx, p.dy);
    }

    void curve(
      double x1,
      double y1,
      double x2,
      double y2,
      double x3,
      double y3,
    ) {
      final a = point(x1, y1), b = point(x2, y2), c = point(x3, y3);
      path.cubicTo(a.dx, a.dy, b.dx, b.dy, c.dx, c.dy);
    }

    line(.37, 0);
    curve(.45, 0, .43, .06, .40, .10);
    curve(.34, .14, .35, .25, .43, .28);
    curve(.47, .30, .53, .30, .57, .28);
    curve(.65, .25, .66, .14, .60, .10);
    curve(.57, .06, .55, 0, .63, 0);
    line(1, 0);
  }
}
