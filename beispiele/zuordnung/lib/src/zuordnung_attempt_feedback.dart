import 'package:flutter/material.dart';

/// Ruhige, eindeutige Rückmeldung nach einer noch falschen Zuordnung.
///
/// Farbe, Symbol und Text vermitteln gemeinsam denselben Zustand. Dadurch ist
/// die Rückmeldung nicht allein von Lesen oder Farbwahrnehmung abhängig.
class ZuordnungAttemptFeedback extends StatelessWidget {
  const ZuordnungAttemptFeedback({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      liveRegion: true,
      label: 'Fast. Das passt noch nicht. Versuch es noch einmal.',
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFFFFE4E0),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFC84D43), width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.refresh_rounded,
                color: Color(0xFF9B332D),
                size: 26,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Fast! Versuch es noch einmal.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: const Color(0xFF7F2924),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
