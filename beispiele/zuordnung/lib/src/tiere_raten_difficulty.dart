/// Fest definierte Schwierigkeitsstufen für „Tiere Raten“.
///
/// Die Werte sind absichtlich nicht redaktionell veränderbar: Ein Kind soll
/// nach der Auswahl immer dieselbe, verlässliche Spielgröße vorfinden.
enum TiereRatenDifficulty {
  easy(
    label: 'Leicht',
    subtitle: '5 Tiere · 3 Bilder',
    rounds: 5,
    optionCount: 3,
    icon: '🌱',
  ),
  medium(
    label: 'Mittel',
    subtitle: '10 Tiere · 4 Bilder',
    rounds: 10,
    optionCount: 4,
    icon: '🌤️',
  ),
  hard(
    label: 'Schwer',
    subtitle: '15 Tiere · 4 Bilder',
    rounds: 15,
    optionCount: 4,
    icon: '⭐',
  );

  final String label;
  final String subtitle;
  final int rounds;
  final int optionCount;
  final String icon;

  const TiereRatenDifficulty({
    required this.label,
    required this.subtitle,
    required this.rounds,
    required this.optionCount,
    required this.icon,
  });
}
