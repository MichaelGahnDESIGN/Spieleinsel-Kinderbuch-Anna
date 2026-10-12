/// Aufwärts laufende Uhr. Verdeckte Ansichten und bewusste Pausen zählen nicht.
/// Die Zeit ist eine Spielanzeige und kein serverseitiger Berechtigungsnachweis.
class JigsawClock {
  final DateTime Function() _now;
  DateTime? _started;
  Duration _accumulated = Duration.zero;
  bool _finished = false;

  JigsawClock({DateTime Function()? now}) : _now = now ?? DateTime.now;

  Duration get elapsed {
    final extra = _started == null
        ? Duration.zero
        : _now().difference(_started!);
    return _accumulated + (extra.isNegative ? Duration.zero : extra);
  }

  void start() {
    if (!_finished) _started ??= _now();
  }

  void pause() {
    _accumulated = elapsed;
    _started = null;
  }

  void finish() {
    pause();
    _finished = true;
  }
}
