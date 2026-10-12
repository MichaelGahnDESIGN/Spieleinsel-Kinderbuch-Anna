import 'package:flutter/material.dart';

import 'music_piece.dart';

/// Die acht D-Dur-Töne behalten in jedem Lernmodus dieselbe Farbe.
Color musicNoteColor(MusicNote note) => switch (note) {
  MusicNote.d4 => const Color(0xFFE53935),
  MusicNote.e4 => const Color(0xFFFFD600),
  MusicNote.fis4 => const Color(0xFF1565C0),
  MusicNote.g4 => const Color(0xFF1B9E48),
  MusicNote.a4 => const Color(0xFF8E24AA),
  MusicNote.h4 => const Color(0xFFFF8F00),
  MusicNote.cis5 => const Color(0xFF00BCD4),
  MusicNote.d5 => const Color(0xFFEC407A),
  _ => const Color(0xFFECEFF1),
};

/// Beschriftung folgt der Helligkeit der jeweiligen Farbe statt einer festen
/// dunklen Schrift, damit auch Blau und Lila gut lesbar bleiben.
Color musicNoteForeground(MusicNote note) =>
    musicNoteColor(note).computeLuminance() < .3
    ? Colors.white
    : Colors.black87;
