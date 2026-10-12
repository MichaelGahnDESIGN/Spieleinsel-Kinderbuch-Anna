# API-Dokumentation für Spielentwickler

Die öffentlichen Beispiele zeigen lokale Spiellogik und Touch-Bedienung. Für die Plattformintegration gilt der [Plugin-Vertrag](plugin-vertrag.md) mit dem [Manifest-Beispiel](codebeispiele/spielmanifest.md).

## Vertrag und Datenfluss

Die Plattform übergibt einem freigegebenen Spiel einen begrenzten Datenclient. Das Spiel lädt nur die für seine technische Spiel-ID freigegebenen Inhalte und übermittelt nur die vereinbarten Rundenergebnisse. Es implementiert keine eigene Anmeldung und verwendet keine eingebauten Zugangstokens oder Serverpasswörter.

Die API prüft Anmeldung, Rollen, Profilzugehörigkeit und Ressourcenzugriff bei jeder geschützten Anfrage. Ein Manifest, eine lokale Punktzahl oder ein Client-Flag verleiht keine Berechtigung. Zahlungs- und Abofreigaben werden ausschließlich serverseitig entschieden.

Die konkrete, versionierte Schnittstellenbeschreibung und die private SDK-Vorlage stehen freigeschalteten Entwicklern in der Entwicklerdokumentation der [Spieleinsel](https://spiele.kinderbuch-anna.de/) zur Verfügung. Nach Anmeldung den Entwicklerbereich und dort die Dokumentation öffnen. Öffentliche Beispiele benötigen keinen Produktionszugang.

## Lokale Entwicklung

Mit eigenen anonymen Beispieldaten arbeiten. Keine echten Kinderprofile, Familiennamen, Medien-URLs, Cookies oder Tokens in Code, Tests, Issues oder Git speichern. Netzwerkanfragen in lokalen Beispielen durch eigene Testdaten ersetzen. Fehlerberichte enthalten weder Zugangswerte noch personenbezogene Antwortdaten.

Die öffentliche Dokumentation beschreibt den Integrationsvertrag. Sie ist kein vollständiger REST-Endpunktkatalog; die freigegebenen konkreten Endpunkte werden in der geschützten Dokumentation bereitgestellt.
