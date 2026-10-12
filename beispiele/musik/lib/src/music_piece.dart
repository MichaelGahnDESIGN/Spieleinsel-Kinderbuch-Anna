/// Eine konkrete, lokal abspielbare Klaviertaste.
///
/// Namen und Frequenzen sind gleichstufige Stimmung mit A4 = 440 Hz. Dadurch
/// ist das Piano technisch richtig gestimmt, ohne dass eine Online-API oder
/// personenbezogene Daten nötig sind.
enum MusicNote {
  c4('C', 'c4.wav'),
  cis4('Cis', 'cis4.wav'),
  d4('D', 'd4.wav'),
  dis4('D♯', 'dis4.wav'),
  e4('E', 'e4.wav'),
  f4('F', 'f4.wav'),
  fis4('Fis', 'fis4.wav'),
  g4('G', 'g4.wav'),
  gis4('G♯', 'gis4.wav'),
  a4('A', 'a4.wav'),
  ais4('A♯', 'ais4.wav'),
  h4('H', 'h4.wav'),
  c5('C', 'c5.wav'),
  cis5('Cis', 'cis5.wav'),
  d5('D', 'd5.wav');

  final String label;
  final String assetFile;

  const MusicNote(this.label, this.assetFile);
}

/// D-Dur: D, E, Fis, G, A, H, Cis, D. Alle leichten Stücke verwenden nur
/// diese Töne, damit die einfache Oberfläche nie eine erforderliche Taste
/// versteckt.
const dMajorScale = <MusicNote>[
  MusicNote.d4,
  MusicNote.e4,
  MusicNote.fis4,
  MusicNote.g4,
  MusicNote.a4,
  MusicNote.h4,
  MusicNote.cis5,
  MusicNote.d5,
];

/// Redaktionell überprüfte Stückbeschreibung.
class MusicPiece {
  final String id;
  final String title;
  final String composer;
  final String licenseNote;
  final String coverAsset;
  final List<MusicNote> notes;

  const MusicPiece({
    required this.id,
    required this.title,
    required this.composer,
    required this.licenseNote,
    required this.coverAsset,
    required this.notes,
  });
}

/// Eigene synthetische Übungsfolge ohne Produktionscover oder Audiodateien.
const musicPieces = <MusicPiece>[
  MusicPiece(id: 'demo', title: 'Drei Töne', composer: 'Entwicklerbeispiel',
    licenseNote: 'Eigene Übungsfolge, MIT', coverAsset: '',
    notes: [MusicNote.d4, MusicNote.e4, MusicNote.fis4]),
];
