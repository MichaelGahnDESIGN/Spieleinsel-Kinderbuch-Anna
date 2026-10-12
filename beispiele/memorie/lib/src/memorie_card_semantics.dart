import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';

import 'memory_card.dart';

/// Beschreibt genau eine Flame-Karte für Screenreader und Tastatur.
///
/// Die sichtbare Karte bleibt im Canvas. Diese kleine, getrennte Datenklasse
/// spiegelt nur Position und Zustand, damit Flutter darüber eine bedienbare
/// Semantikfläche an derselben Stelle aufbauen kann.
class MemorieCardSemanticData {
  final int index;
  final int pairId;
  final Rect rect;
  final CardState state;
  final bool canActivate;

  const MemorieCardSemanticData({
    required this.index,
    required this.pairId,
    required this.rect,
    required this.state,
    required this.canActivate,
  });

  String get label => switch (state) {
    CardState.faceDown => 'Karte ${index + 1}, verdeckt',
    CardState.faceUp => 'Karte ${index + 1}, aufgedeckt, Motiv ${pairId + 1}',
    CardState.matched =>
      'Karte ${index + 1}, Paar gefunden, Motiv ${pairId + 1}',
  };

  String get hint => switch (state) {
    CardState.faceDown => 'Doppeltippen oder Enter drücken zum Aufdecken.',
    CardState.faceUp => 'Aufgedeckt. Wähle eine zweite verdeckte Karte.',
    CardState.matched => 'Dieses Paar wurde bereits gefunden.',
  };
}

/// Legt fokussierbare Flutter-Flächen deckungsgleich über das Flame-Spielfeld.
///
/// Die leeren Flächen besitzen selbst keine sichtbaren Inhalte. Nur bei einer
/// Tastaturfokussierung erscheint ein schmaler Rahmen als notwendige
/// Orientierung. [ExcludeSemantics] verhindert dabei einen zweiten, vom
/// inneren Gestenbereich erzeugten Semantikknoten.
class MemorieCardSemanticsLayer extends StatelessWidget {
  final ValueListenable<List<MemorieCardSemanticData>> cards;
  final ValueChanged<int> onActivate;

  const MemorieCardSemanticsLayer({
    super.key,
    required this.cards,
    required this.onActivate,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<MemorieCardSemanticData>>(
      valueListenable: cards,
      builder: (context, currentCards, _) => Stack(
        fit: StackFit.expand,
        children: [
          for (final card in currentCards)
            Positioned.fromRect(
              rect: card.rect,
              child: _MemorieSemanticCardSurface(
                key: ValueKey('memorie-card-${card.index}'),
                card: card,
                onActivate: () => onActivate(card.index),
              ),
            ),
        ],
      ),
    );
  }
}

class _MemorieSemanticCardSurface extends StatefulWidget {
  final MemorieCardSemanticData card;
  final VoidCallback onActivate;

  const _MemorieSemanticCardSurface({
    super.key,
    required this.card,
    required this.onActivate,
  });

  @override
  State<_MemorieSemanticCardSurface> createState() =>
      _MemorieSemanticCardSurfaceState();
}

class _MemorieSemanticCardSurfaceState
    extends State<_MemorieSemanticCardSurface> {
  final FocusNode _focusNode = FocusNode();
  bool _showFocus = false;

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _activate() {
    if (!widget.card.canActivate) return;
    _focusNode.requestFocus();
    widget.onActivate();
  }

  @override
  Widget build(BuildContext context) {
    final card = widget.card;
    return Semantics(
      container: true,
      sortKey: OrdinalSortKey(card.index.toDouble()),
      button: true,
      enabled: card.canActivate,
      focusable: card.canActivate,
      focused: _showFocus,
      label: card.label,
      hint: card.hint,
      onTap: card.canActivate ? _activate : null,
      child: ExcludeSemantics(
        child: FocusableActionDetector(
          focusNode: _focusNode,
          enabled: card.canActivate,
          shortcuts: const {
            SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
            SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
          },
          actions: {
            ActivateIntent: CallbackAction<ActivateIntent>(
              onInvoke: (_) {
                _activate();
                return null;
              },
            ),
          },
          onShowFocusHighlight: (show) {
            if (_showFocus != show) setState(() => _showFocus = show);
          },
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: card.canActivate ? _activate : null,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: _showFocus
                    ? Border.all(color: const Color(0xFF691B96), width: 3)
                    : null,
              ),
              child: const SizedBox.expand(),
            ),
          ),
        ),
      ),
    );
  }
}
