# Musikinsel – Entwicklerbeispiel

Dieses eigenständige Flutter-Paket zeigt ausgewählte Spielmechaniken und Touch-Komponenten. Es ist ein Quellcodebeispiel, keine vollständige Produktions-App und kein fertig integriertes Plattformplugin.

## Enthalten

- `lib/src/music_piece.dart`
- `lib/src/music_session.dart`
- `lib/src/music_note_style.dart`
- `lib/src/music_note_button.dart`
- `lib/src/piano_keyboard.dart`

Die Auswahl zeigt Notenlogik und Farbtasten. Eine Audioausgabe ist nicht enthalten.

## Verwendung

Flutter mit Dart ab 3.11 verwenden. Im Paket `flutter pub get`, danach `flutter analyze` ausführen. Widgets in eine eigene `MaterialApp`/`Scaffold` einbetten; Modelle lassen sich direkt aufrufen. Optionale Bild-URLs bleiben für lokale Beispiele `null`. Produktionsbilder, Audio und Schriftdateien sind nicht enthalten; eigene, freigegebene Medien verwenden.

## Tests

`flutter test` prüft die enthaltenen lokalen Modell- beziehungsweise Touch-Tests.

## Plattformanbindung

Siehe [API-Dokumentation](../../docs/api.md) und [Plugin-Vertrag](../../docs/plugin-vertrag.md). Anmeldung, Rechte, Profile, Speicherung und Freischaltung übernimmt ausschließlich die private Plattform. Dieses Beispiel enthält keinen API-Client, keine Zugangsdaten und keine Nutzerdaten. Integration und SDK-Zugriff erfolgen nach Entwicklerfreigabe.

## Lizenz

Der Beispielcode unterliegt der [MIT-Lizenz](../../LICENSE). Figuren, Marken und Produktionsmedien sind nicht Teil dieser Freigabe.
