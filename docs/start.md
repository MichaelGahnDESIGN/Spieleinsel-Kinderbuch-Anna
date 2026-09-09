# Startleitfaden

Spieleinsel ist keine Plattform für hochgeladene Browser-Dateien. Jedes Spiel wird als klar abgegrenztes Modul entwickelt, geprüft und erst nach einer bewussten Freigabe in einen getesteten Plattform-Build aufgenommen.

## Der sichere Ablauf

1. **Idee:** Moderatorinnen, Moderatoren und Entwickler reichen eine Idee in der Werkstatt ein.
2. **Privates Repository:** Freigeschaltete Entwickler erstellen ihr eigenes privates Spielrepository aus der Vorlage.
3. **Entwicklung:** Das Spiel hält den Plugin-Vertrag ein und nutzt nur freigegebene Medien.
4. **Prüfung:** Automatische Tests und menschliche Prüfung dokumentieren Verständlichkeit, Kinderschutz und Bedienbarkeit.
5. **Staging:** Ein Admin übernimmt einen ausdrücklich geprüften Commit in einen getrennten Test-Build.
6. **Freigabe:** Nur ein Admin veröffentlicht nach der Abnahme.

Der Produktionsserver lädt nie beliebigen Code direkt aus einem Repository. Das schützt Familien und verhindert, dass ein Pull Request unbemerkt live geht.
