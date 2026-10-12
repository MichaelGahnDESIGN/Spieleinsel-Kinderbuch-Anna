import 'package:flutter/material.dart';

/// Die zwei verständlichen Schritte der ersten begleiteten Paarung.
enum ZuordnungGuideStep { chooseAnimal, chooseSound }

/// Kurze, auch von Screenreadern angekündigte Hilfe für den Rundenbeginn.
///
/// Die Hilfe löst nichts automatisch. Das Kind führt weiterhin beide
/// Auswahlen selbst aus und behält dadurch den ersten eigenen Spielerfolg.
class ZuordnungFirstPairGuide extends StatelessWidget {
  final ZuordnungGuideStep step;
  final String animalLabel;

  const ZuordnungFirstPairGuide({
    super.key,
    required this.step,
    required this.animalLabel,
  });

  @override
  Widget build(BuildContext context) {
    final choosesAnimal = step == ZuordnungGuideStep.chooseAnimal;
    final visibleText = choosesAnimal
        ? 'Wir üben zusammen: Tippe auf das markierte Tier.'
        : 'Prima! Tippe jetzt auf den markierten Laut.';
    final spokenText = choosesAnimal
        ? 'Start-Hilfe. Tippe auf das markierte Tier $animalLabel.'
        : 'Prima. Tippe jetzt auf den markierten passenden Laut.';

    return Semantics(
      key: const ValueKey('zuordnung-first-pair-guide'),
      container: true,
      liveRegion: true,
      label: spokenText,
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFFFFF1C7),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE9922D), width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              const Icon(
                Icons.touch_app_rounded,
                color: Color(0xFF7B2AA8),
                size: 28,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  visibleText,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: const Color(0xFF4B2A45),
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
