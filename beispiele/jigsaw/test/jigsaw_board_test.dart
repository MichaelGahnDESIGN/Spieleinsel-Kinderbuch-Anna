import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:beispiel_jigsaw/src/jigsaw_board.dart';
import 'package:beispiel_jigsaw/src/jigsaw_piece.dart';
import 'package:beispiel_jigsaw/src/jigsaw_clock.dart';

void main() {
  for (final count in [4, 9, 16, 25]) {
    for (final shape in JigsawShape.values) {
      test(
        '$count Teile, $shape: eindeutige Teile und passende Nachbarkanten',
        () {
          final board = JigsawBoard(
            pieceCount: count,
            shape: shape,
            random: Random(5),
          );
          expect(board.pieces.map((p) => p.id).toSet().length, count);
          final side = sqrt(count).toInt();
          for (final p in board.pieces) {
            expect(p.row, p.id ~/ side);
            expect(p.column, p.id % side);
            if (p.row == 0) expect(p.top, 0);
            if (p.row == side - 1) expect(p.bottom, 0);
            if (p.column == 0) expect(p.left, 0);
            if (p.column == side - 1) expect(p.right, 0);
            if (p.column < side - 1) {
              expect(p.right, -board.pieces[p.id + 1].left);
              expect(p.right.abs(), shape == JigsawShape.hard ? 1 : 0);
            }
            if (p.row < side - 1) {
              expect(p.bottom, -board.pieces[p.id + side].top);
            }
          }
          for (final p in board.pieces) {
            expect(board.place(p.id, p.id), isTrue);
          }
          expect(board.isComplete, isTrue);
          expect(board.attempts, count);
        },
      );
    }
  }

  test('Falsche Vollbelegung setzt nur falsche Teile zurück', () {
    final board = JigsawBoard(pieceCount: 4, shape: JigsawShape.easy);
    expect(board.place(0, 0), isTrue);
    expect(board.place(1, 2), isTrue);
    expect(board.place(2, 1), isTrue);
    expect(board.place(3, 3), isTrue);

    expect(board.isFull, isTrue);
    expect(board.isSolved, isFalse);
    expect(board.isComplete, isFalse);
    expect(board.pieceAtTarget(2), 1);
    expect(board.incorrectPieceIds, {1, 2});
    expect(board.resetIncorrect(), {1, 2});
    expect(board.placedIds, {0, 3});
    expect(board.isFull, isFalse);
    expect(board.attempts, 4);

    expect(board.place(1, 1), isTrue);
    expect(board.place(2, 2), isTrue);
    expect(board.isSolved, isTrue);
    expect(board.isComplete, isTrue);
    expect(board.attempts, 6);
  });

  test('Nur freie Felder und noch nicht verwendete Teile zählen', () {
    final board = JigsawBoard(pieceCount: 4, shape: JigsawShape.easy);
    expect(board.place(-1, 0), isFalse);
    expect(board.place(1, 5), isFalse);
    expect(board.attempts, 0);
    expect(board.place(0, 1), isTrue);
    expect(board.place(0, 2), isFalse);
    expect(board.place(1, 1), isFalse);
    expect(board.attempts, 1);
    expect(board.placedIds, {0});
    expect(() => board.placedIds.add(3), throwsUnsupportedError);
  });

  test(
    'Ein falsch erkanntes Teil kann ohne neuen Versuch zurück in die Ablage',
    () {
      final board = JigsawBoard(
        pieceCount: 4,
        shape: JigsawShape.easy,
        random: Random(1),
      );
      expect(board.place(1, 0), isTrue);
      expect(board.attempts, 1);
      expect(board.returnIncorrectPieceFromTarget(0), isTrue);
      expect(board.pieceAtTarget(0), isNull);
      expect(board.placedIds, isEmpty);
      expect(board.attempts, 1);
      expect(board.place(0, 0), isTrue);
      expect(board.returnIncorrectPieceFromTarget(0), isFalse);
    },
  );

  test('Falsch liegendes Teil kann auf ein freies Feld verschoben werden', () {
    final board = JigsawBoard(pieceCount: 4, shape: JigsawShape.easy);
    expect(board.place(1, 0), isTrue);
    expect(board.moveIncorrectPiece(0, 2), isTrue);
    expect(board.pieceAtTarget(0), isNull);
    expect(board.pieceAtTarget(2), 1);
    expect(board.attempts, 2);

    // Richtige Teile und bereits belegte Zielfelder bleiben geschützt.
    expect(board.place(0, 0), isTrue);
    expect(board.moveIncorrectPiece(0, 3), isFalse);
    expect(board.moveIncorrectPiece(2, 0), isFalse);
  });

  test('Nicht unterstützte Teilezahlen werden abgewiesen', () {
    for (final count in [0, 1, 3, 8, 100]) {
      expect(
        () => JigsawBoard(pieceCount: count, shape: JigsawShape.easy),
        throwsArgumentError,
      );
    }
  });

  test('Spieluhr zählt aktive Zeit und friert bei Pause und Abschluss ein', () {
    var now = DateTime(2026);
    final clock = JigsawClock(now: () => now);
    clock.start();
    now = now.add(const Duration(seconds: 3));
    expect(clock.elapsed.inSeconds, 3);
    clock.pause();
    now = now.add(const Duration(seconds: 20));
    expect(clock.elapsed.inSeconds, 3);
    clock.start();
    now = now.add(const Duration(seconds: 4));
    clock.finish();
    clock.start();
    now = now.add(const Duration(seconds: 9));
    expect(clock.elapsed.inSeconds, 7);
  });
}
