import 'package:flutter/material.dart';

/// Große, direkt antippbare Gegenüberstellung für Mengen und Größen.
///
/// Kinder müssen hier weder „Links“ noch „Rechts“ lesen: Beide Seiten sind
/// gleich große, farbige Touch-Flächen. Die räumliche Lage ist die Antwort.
class LearningComparisonRound extends StatelessWidget {
  final String visual;
  final ValueChanged<String> onChoose;
  final Color accent;
  final bool isSizeComparison;
  final String? imageUrl;

  const LearningComparisonRound({
    super.key,
    required this.visual,
    required this.onChoose,
    required this.accent,
    required this.isSizeComparison,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final comparison = _Comparison.tryParse(visual, isSizeComparison);
    if (comparison == null) {
      return const SizedBox.shrink();
    }
    return Semantics(
      container: true,
      label: isSizeComparison
          ? 'Zwei unterschiedlich große Motive. Tippe auf die passende Seite.'
          : 'Zwei Mengen. Tippe auf die passende Seite.',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 360;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _ComparisonTile(
                  side: 'Links',
                  value: comparison.left,
                  accent: accent,
                  compact: compact,
                  isSizeComparison: isSizeComparison,
                  size: comparison.leftSize,
                  imageUrl: imageUrl,
                  onTap: () => onChoose('Links'),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _ComparisonTile(
                  side: 'Rechts',
                  value: comparison.right,
                  accent: accent,
                  compact: compact,
                  isSizeComparison: isSizeComparison,
                  size: comparison.rightSize,
                  imageUrl: imageUrl,
                  onTap: () => onChoose('Rechts'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Comparison {
  final String left;
  final String right;
  final String? leftSize;
  final String? rightSize;

  const _Comparison({
    required this.left,
    required this.right,
    this.leftSize,
    this.rightSize,
  });

  static _Comparison? tryParse(String visual, bool isSizeComparison) {
    final lines = visual.split('\n');
    if (lines.length != 2) return null;
    final left = RegExp(r'^Links:\s*(.+)$').firstMatch(lines[0]);
    final right = RegExp(r'^Rechts:\s*(.+)$').firstMatch(lines[1]);
    if (left == null || right == null) return null;
    if (!isSizeComparison) {
      return _Comparison(left: left.group(1)!, right: right.group(1)!);
    }
    final leftParts = RegExp(
      r'^(.*?)\s+(klein|mittelgroß|groß)$',
    ).firstMatch(left.group(1)!.trim());
    final rightParts = RegExp(
      r'^(.*?)\s+(klein|mittelgroß|groß)$',
    ).firstMatch(right.group(1)!.trim());
    if (leftParts == null || rightParts == null) return null;
    return _Comparison(
      left: leftParts.group(1)!,
      right: rightParts.group(1)!,
      leftSize: leftParts.group(2)!,
      rightSize: rightParts.group(2)!,
    );
  }
}

class _ComparisonTile extends StatelessWidget {
  final String side;
  final String value;
  final String? size;
  final Color accent;
  final bool compact;
  final bool isSizeComparison;
  final String? imageUrl;
  final VoidCallback onTap;

  const _ComparisonTile({
    required this.side,
    required this.value,
    required this.accent,
    required this.compact,
    required this.isSizeComparison,
    required this.onTap,
    this.size,
    this.imageUrl,
  });

  int get _quantity => value.runes
      .where((rune) => rune != 0xFE0F && rune != 0x20)
      .length
      .clamp(1, 10);

  double get _fontSize {
    if (!isSizeComparison) return compact ? 40 : 52;
    return switch (size) {
      'klein' => compact ? 52 : 64,
      'mittelgroß' => compact ? 72 : 86,
      'groß' => compact ? 94 : 118,
      _ => 52,
    };
  }

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: isSizeComparison
        ? '$side, ${size ?? 'Motiv'} auswählen'
        : '$side, $_quantity Gegenstände auswählen',
    child: Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(26),
      child: InkWell(
        key: Key('comparison-choice-${side.toLowerCase()}'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(26),
        child: Container(
          constraints: const BoxConstraints(minHeight: 184),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: accent.withValues(alpha: .72), width: 4),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                accent.withValues(alpha: .13),
                accent.withValues(alpha: .05),
              ],
            ),
          ),
          child: Center(
            child: ExcludeSemantics(
              child: imageUrl == null
                  ? Text(
                      value,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: _fontSize, height: 1.18),
                    )
                  : _ComparisonImageMotif(
                      imageUrl: imageUrl!,
                      fallback: value,
                      quantity: isSizeComparison ? 1 : _quantity,
                      size: isSizeComparison ? _fontSize : null,
                    ),
            ),
          ),
        ),
      ),
    ),
  );
}

/// Zeigt ein vom Admin gewähltes Motiv direkt in beiden Vergleichsflächen.
/// Bei Mengen wird dasselbe Motiv mehrfach dargestellt; bei Größen bleibt es
/// einmal sichtbar und erhält entsprechend der Aufgabe eine andere Größe.
class _ComparisonImageMotif extends StatelessWidget {
  final String imageUrl;
  final String fallback;
  final int quantity;
  final double? size;

  const _ComparisonImageMotif({
    required this.imageUrl,
    required this.fallback,
    required this.quantity,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    final itemSize = size == null ? 58.0 : (size! * .82).clamp(48.0, 108.0);
    final fallbackRunes = fallback.runes
        .where((rune) => rune != 0xFE0F && rune != 0x20)
        .toList(growable: false);
    final fallbackToken = fallbackRunes.isEmpty
        ? '●'
        : String.fromCharCode(fallbackRunes.first);
    return Wrap(
      alignment: WrapAlignment.center,
      runAlignment: WrapAlignment.center,
      spacing: 5,
      runSpacing: 5,
      children: [
        for (var index = 0; index < quantity; index++)
          Image.network(
            imageUrl,
            width: itemSize,
            height: itemSize,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) =>
                Text(fallbackToken, style: TextStyle(fontSize: size ?? 44)),
          ),
      ],
    );
  }
}
