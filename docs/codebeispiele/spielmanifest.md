# Beispiel: Spielmanifest

```json
{
  "id": "farbenreise_v1",
  "title": "Gullivers Farbenreise",
  "age_range": [3, 6],
  "content_types": ["card_sets", "media_ids"],
  "settings": {
    "round_count": { "type": "integer", "min": 3, "max": 10 }
  }
}
```

Das Manifest beschreibt Fähigkeiten. Es ist keine Freigabe: Aktivierung, Inhalte und Spielzugriff werden vom Server geprüft.
