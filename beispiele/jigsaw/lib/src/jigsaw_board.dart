import 'dart:math';
import 'jigsaw_piece.dart';

/// Fachlicher Rundenstand ohne Abhängigkeit von Zeigern, Bildschirm oder Server.
/// Jedes Teil gehört eindeutig zu einer Zelle; dadurch ist jedes Brett lösbar.
class JigsawBoard {
  static const allowedCounts = [4, 9, 16, 25];
  final int pieceCount;
  final JigsawShape shape;
  late final int side;
  late final List<JigsawPiece> pieces;
  late final List<int> trayOrder;

  /// Ordnet jedem belegten Zielfeld genau ein Teil zu. Dadurch kann das Modell
  /// auch eine falsche, aber vollständig belegte Anordnung darstellen.
  final Map<int, int> _pieceByTarget = {};
  int _attempts = 0;

  JigsawBoard({required this.pieceCount, required this.shape, Random? random}) {
    if (!allowedCounts.contains(pieceCount)) {
      throw ArgumentError.value(
        pieceCount,
        'pieceCount',
        'Erlaubt sind 4, 9, 16 oder 25 Teile.',
      );
    }
    side = sqrt(pieceCount).toInt();
    final rng = random ?? Random();
    final created = <JigsawPiece>[];
    int edge() => shape == JigsawShape.easy ? 0 : (rng.nextBool() ? 1 : -1);
    for (var id = 0; id < pieceCount; id++) {
      final row = id ~/ side;
      final column = id % side;
      created.add(
        JigsawPiece(
          id: id,
          row: row,
          column: column,
          top: row == 0 ? 0 : -created[id - side].bottom,
          left: column == 0 ? 0 : -created[id - 1].right,
          right: column == side - 1 ? 0 : edge(),
          bottom: row == side - 1 ? 0 : edge(),
        ),
      );
    }
    pieces = List.unmodifiable(created);
    trayOrder = List.unmodifiable(
      List.generate(pieceCount, (i) => i)..shuffle(rng),
    );
  }

  int get attempts => _attempts;
  Set<int> get placedIds => Set.unmodifiable(_pieceByTarget.values.toSet());
  bool get isFull => _pieceByTarget.length == pieceCount;
  bool get isSolved =>
      isFull &&
      _pieceByTarget.entries.every((entry) => entry.key == entry.value);

  /// Bestehende Aufrufer verstehen „vollständig“ als wirklich gelöst.
  bool get isComplete => isSolved;

  int? pieceAtTarget(int targetIndex) => _pieceByTarget[targetIndex];

  Set<int> get incorrectPieceIds => Set.unmodifiable(
    _pieceByTarget.entries
        .where((entry) => entry.key != entry.value)
        .map((entry) => entry.value)
        .toSet(),
  );

  /// Nur ein echtes Ablegen auf einem freien Feld zählt. Die fachliche Prüfung
  /// erfolgt erst bei vollständig belegtem Bild, damit Kinder Teile zunächst
  /// auch an einer falschen Stelle ausprobieren dürfen.
  bool place(int pieceId, int targetIndex) {
    if (isFull ||
        pieceId < 0 ||
        pieceId >= pieceCount ||
        targetIndex < 0 ||
        targetIndex >= pieceCount ||
        _pieceByTarget.containsValue(pieceId) ||
        _pieceByTarget.containsKey(targetIndex)) {
      return false;
    }
    _attempts++;
    _pieceByTarget[targetIndex] = pieceId;
    return true;
  }

  /// Legt ein falsch platziertes Teil wieder in die Ablage zurück.
  ///
  /// Richtige Teile bleiben bewusst liegen: Sie sind für Kinder eine hilfreiche
  /// Orientierung. Das Zurücklegen zählt nicht als neuer Versuch, weil das Kind
  /// lediglich eine eigene Entscheidung korrigiert.
  bool returnIncorrectPieceFromTarget(int targetIndex) {
    final pieceId = _pieceByTarget[targetIndex];
    if (pieceId == null || pieceId == targetIndex) return false;
    _pieceByTarget.remove(targetIndex);
    return true;
  }

  /// Verschiebt ein falsch liegendes Teil auf ein anderes freies Zielfeld.
  ///
  /// Richtige Teile bleiben fest liegen. Das Kind darf eine falsche Idee somit
  /// direkt auf dem Brett weiter ausprobieren, statt das Teil erst zurück in
  /// die Ablage legen zu müssen. Eine echte Bewegung zählt als Versuch.
  bool moveIncorrectPiece(int sourceTargetIndex, int destinationTargetIndex) {
    if (sourceTargetIndex < 0 ||
        sourceTargetIndex >= pieceCount ||
        destinationTargetIndex < 0 ||
        destinationTargetIndex >= pieceCount ||
        sourceTargetIndex == destinationTargetIndex ||
        _pieceByTarget.containsKey(destinationTargetIndex)) {
      return false;
    }
    final pieceId = _pieceByTarget[sourceTargetIndex];
    if (pieceId == null || pieceId == sourceTargetIndex) return false;
    _pieceByTarget
      ..remove(sourceTargetIndex)
      ..[destinationTargetIndex] = pieceId;
    _attempts++;
    return true;
  }

  /// Entfernt nach einer vollständigen Prüfung ausschließlich falsch liegende
  /// Teile. Richtige Teilbilder bleiben als hilfreiche Orientierung erhalten.
  Set<int> resetIncorrect() {
    final removed = incorrectPieceIds.toSet();
    _pieceByTarget.removeWhere((target, piece) => target != piece);
    return Set.unmodifiable(removed);
  }
}
