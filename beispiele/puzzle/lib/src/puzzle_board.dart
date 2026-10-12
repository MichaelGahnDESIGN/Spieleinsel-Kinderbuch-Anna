import 'dart:math';

/// Verwaltet die Kacheln eines stets lösbaren Schiebepuzzles.
///
/// board[i] beschreibt die Kachel an Position i, zeilenweise ab null.
/// board[emptyPos] == -1 markiert das freie Feld.
/// Im Ziel gilt board[i] == i; das letzte Feld ist frei.
class PuzzleBoard {
  final int gridSize;
  late List<int> _board;
  late int _emptyPos;
  int _moves = 0;

  PuzzleBoard({required this.gridSize}) {
    if (![3, 4, 5].contains(gridSize)) {
      throw ArgumentError.value(
        gridSize,
        'gridSize',
        'Erlaubt sind 3, 4 oder 5.',
      );
    }
    _reset();
    _shuffleByMoves(moves: gridSize == 3 ? 8 : (gridSize == 4 ? 30 : 60));
  }

  int get moves => _moves;
  int get emptyPos => _emptyPos;
  int get total => gridSize * gridSize;
  List<int> get board => List.unmodifiable(_board);

  void _reset() {
    _board = List.generate(total, (i) => i);
    _board[total - 1] = -1;
    _emptyPos = total - 1;
    _moves = 0;
  }

  // Nur legale Schiebezüge mischen die Kacheln; dadurch bleibt das Puzzle lösbar.
  void _shuffleByMoves({required int moves}) {
    final rng = Random();
    int prev = -1;
    for (int i = 0; i < moves; i++) {
      final neighbors = _adjacentToEmpty().where((n) => n != prev).toList();
      final next = neighbors[rng.nextInt(neighbors.length)];
      prev = _emptyPos;
      _doSwap(next);
    }
    // Auch ein zufälliger Weg kann zum Ziel zurückführen. Die Runde muss
    // mit mindestens einem noch nötigen, legalen Zug starten.
    if (isSolved) _doSwap(_adjacentToEmpty().first);
    _moves = 0;
  }

  /// Liefert die Positionen direkt neben dem freien Feld.
  List<int> _adjacentToEmpty() {
    final row = _emptyPos ~/ gridSize;
    final col = _emptyPos % gridSize;
    final result = <int>[];
    if (row > 0) result.add(_emptyPos - gridSize);
    if (row < gridSize - 1) result.add(_emptyPos + gridSize);
    if (col > 0) result.add(_emptyPos - 1);
    if (col < gridSize - 1) result.add(_emptyPos + 1);
    return result;
  }

  void _doSwap(int pos) {
    _board[_emptyPos] = _board[pos];
    _board[pos] = -1;
    _emptyPos = pos;
  }

  /// Prüft, ob die gewählte Position neben dem freien Feld liegt.
  bool canMove(int pos) => _adjacentToEmpty().contains(pos);

  /// Schiebt eine benachbarte Kachel ins freie Feld und zählt den gültigen Zug.
  bool move(int pos) {
    if (!canMove(pos)) return false;
    _doSwap(pos);
    _moves++;
    return true;
  }

  bool get isSolved {
    for (int i = 0; i < total; i++) {
      if (_board[i] != -1 && _board[i] != i) return false;
    }
    return _emptyPos == total - 1;
  }
}
