/// Die Form ist unabhängig von der Anzahl der Teile.
enum JigsawShape { easy, hard }

/// Unveränderliches Teil des Gesamtbildes. Die ID entspricht seiner Zielzelle.
/// Kantenwerte: 0 = gerade, 1 = Nase nach außen, -1 = passende Vertiefung.
class JigsawPiece {
  final int id;
  final int row;
  final int column;
  final int top;
  final int right;
  final int bottom;
  final int left;

  const JigsawPiece({
    required this.id,
    required this.row,
    required this.column,
    required this.top,
    required this.right,
    required this.bottom,
    required this.left,
  });
}
