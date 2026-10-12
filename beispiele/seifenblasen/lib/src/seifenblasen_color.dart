import 'package:flutter/material.dart';

/// Rein lokale Farbauswahl: Bunt verteilt die Farben stabil nach Blasen-ID.
/// Ein Wechsel betrifft sofort vorhandene und anschließend erzeugte Blasen.
enum SeifenblasenFarbe {
  bunt('Bunt', null),
  rot('Rot', Color(0xFFED2546)),
  blau('Blau', Color(0xFF176BEE)),
  gelb('Gelb', Color(0xFFFFD600)),
  gruen('Grün', Color(0xFF17AD56)),
  lila('Lila', Color(0xFF973DE0));

  const SeifenblasenFarbe(this.titel, this.farbe);
  final String titel;
  final Color? farbe;

  Color fuerBlase(int id) =>
      farbe ?? values[1 + (id - 1) % (values.length - 1)].farbe!;
}
