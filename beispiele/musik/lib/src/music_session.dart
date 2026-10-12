import 'music_piece.dart';

/// Instrumente mit einer jeweils kindgerechten, visuellen Spieloberfläche.
enum MusicInstrument { piano, drums, banjo, bells }

/// Die drei vom Kind wählbaren Spielarten.
enum MusicMode { free, easy, hard }

/// Reine Spiellogik ohne Flutter-Abhängigkeit. Dadurch lassen sich Notenfolge
/// und Fortschritt zuverlässig testen und später mit echter Audioausgabe
/// erweitern, ohne den Spielvertrag zu verändern.
class MusicSession {
  final MusicInstrument instrument;
  final MusicMode mode;
  final MusicPiece? piece;
  int _position = 0;
  int _mistakes = 0;

  MusicSession({required this.instrument, required this.mode, this.piece})
    : assert(mode == MusicMode.free || piece != null);

  int get position => _position;
  int get mistakes => _mistakes;
  int get noteCount => piece?.notes.length ?? 0;
  bool get isFinished => mode != MusicMode.free && _position >= noteCount;
  MusicNote? get expectedNote =>
      isFinished || mode == MusicMode.free ? null : piece!.notes[_position];

  /// Leicht erlaubt einen neuen Versuch an derselben Stelle. Schwer zählt
  /// falsche Noten ebenfalls, verrät aber die Farbe nicht automatisch.
  bool play(MusicNote note) {
    if (mode == MusicMode.free || isFinished) return true;
    if (note == expectedNote) {
      _position++;
      return true;
    }
    _mistakes++;
    return false;
  }

  void restart() {
    _position = 0;
    _mistakes = 0;
  }
}
