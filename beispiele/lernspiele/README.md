# Farben, Formen und Vergleichen – Entwicklerbeispiel

Dieses eigenständige Flutter-Paket zeigt ausgewählte Spielmechaniken und Touch-Komponenten. Es ist ein Quellcodebeispiel, keine vollständige Produktions-App und kein fertig integriertes Plattformplugin.

## Enthalten

- `lib/src/color_sort_round.dart`
- `lib/src/shape_match_round.dart`
- `lib/src/learning_comparison_round.dart`
- `lib/src/learning_round_visual.dart`

## Verwendung

Flutter mit Dart ab 3.11 verwenden. Im Paket `flutter pub get`, danach `flutter analyze` ausführen. Widgets in eine eigene `MaterialApp`/`Scaffold` einbetten; Modelle lassen sich direkt aufrufen. Optionale Bild-URLs bleiben für lokale Beispiele `null`. Produktionsbilder, Audio und Schriftdateien sind nicht enthalten; eigene, freigegebene Medien verwenden.

## Tests

`flutter test` prüft die enthaltenen lokalen Modell- beziehungsweise Touch-Tests.

## Plattformanbindung

Siehe [API-Dokumentation](../../docs/api.md) und [Plugin-Vertrag](../../docs/plugin-vertrag.md). Anmeldung, Rechte, Profile, Speicherung und Freischaltung übernimmt ausschließlich die private Plattform. Dieses Beispiel enthält keinen API-Client, keine Zugangsdaten und keine Nutzerdaten. Integration und SDK-Zugriff erfolgen nach Entwicklerfreigabe.

## Lizenz

Der Beispielcode unterliegt der [MIT-Lizenz](../../LICENSE). Figuren, Marken und Produktionsmedien sind nicht Teil dieser Freigabe.
