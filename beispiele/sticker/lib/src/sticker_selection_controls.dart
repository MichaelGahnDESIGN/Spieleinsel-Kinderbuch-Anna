import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Auch ein kleiner Sticker braucht getrennte 56px-Tippflächen für vier Ecken
/// und zwei Ebenenknöpfe. Nur der Auswahlrahmen wächst; das Motiv bleibt an
/// seinem Platz und behält seine Größe. Am Bildrand bleibt der Rahmen sichtbar.
Rect stickerSelectionRect(Size canvas, Rect sticker) {
  final width = math.min(canvas.width, math.max(168.0, sticker.width));
  final height = math.min(canvas.height, math.max(168.0, sticker.height));
  return Rect.fromLTWH(
    (sticker.center.dx - width / 2).clamp(0.0, canvas.width - width),
    (sticker.center.dy - height / 2).clamp(0.0, canvas.height - height),
    width,
    height,
  );
}

/// Die Ebenensteuerung liegt über allen Motiven und wird beim PNG-Export
/// vollständig entfernt. Die leere Rahmenfläche fängt keine Bildgesten ab.
class StickerSelectionControls extends StatelessWidget {
  const StickerSelectionControls({
    super.key,
    required this.frame,
    required this.canvasSize,
    this.showLayerButtons = true,
    this.onLower,
    this.onRaise,
    this.canStartLayerChange,
  });
  final Rect frame;
  final Size canvasSize;
  final bool showLayerButtons;
  final VoidCallback? onLower, onRaise;
  final bool Function()? canStartLayerChange;

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      Positioned.fromRect(
        rect: frame,
        child: IgnorePointer(
          child: DecoratedBox(
            key: const Key('sticker_selection_frame'),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF8A4EAA), width: 3),
            ),
          ),
        ),
      ),
      if (showLayerButtons) ...[
        _button(false, onLower),
        _button(true, onRaise),
      ],
    ],
  );

  Widget _button(bool raise, VoidCallback? action) => Positioned(
    left: ((raise ? frame.right : frame.left) - 28).clamp(
      0.0,
      canvasSize.width - 56,
    ),
    top: (frame.center.dy - 28).clamp(0.0, canvasSize.height - 56),
    width: 56,
    height: 56,
    // Auch ein deaktivierter Knopf muss den Tipp aufnehmen: Sonst würde
    // er den darunterliegenden Sticker auswählen oder einen neuen platzieren.
    child: _LayerPointerGuard(
      canStart: canStartLayerChange,
      action: action,
      builder: (guardedAction) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        excludeFromSemantics: true,
        onTap: () {},
        child: IconButton(
          key: Key(raise ? 'sticker_layer_raise' : 'sticker_layer_lower'),
          tooltip: raise ? 'Ganz nach vorne' : 'Ganz nach hinten',
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
            disabledBackgroundColor: Colors.white,
            foregroundColor: const Color(0xFF75448E),
            disabledForegroundColor: const Color(0xFFB3A5B9),
            side: BorderSide(
              color: action == null
                  ? const Color(0xFFD9CFDE)
                  : const Color(0xFF8A4EAA),
              width: 2,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: guardedAction,
          icon: Icon(
            raise ? Icons.flip_to_front_rounded : Icons.flip_to_back_rounded,
            size: 28,
          ),
        ),
      ),
    ),
  );
}

/// Die Freigabe wird beim Aufsetzen des Fingers festgehalten. Endet ein
/// anderer Zug vor diesem Tipp, wird daraus trotzdem kein nachträglicher
/// Ebenenwechsel. State bleibt bei Positions-/Rahmenupdates erhalten.
class _LayerPointerGuard extends StatefulWidget {
  const _LayerPointerGuard({required this.builder, this.canStart, this.action});
  final Widget Function(VoidCallback?) builder;
  final bool Function()? canStart;
  final VoidCallback? action;
  @override
  State<_LayerPointerGuard> createState() => _LayerPointerGuardState();
}

class _LayerPointerGuardState extends State<_LayerPointerGuard> {
  bool _allowed = true;
  @override
  Widget build(BuildContext context) => Listener(
    onPointerDown: (_) => _allowed = widget.canStart?.call() ?? true,
    onPointerCancel: (_) => _allowed = true,
    child: widget.builder(
      widget.action == null
          ? null
          : () {
              final allowed = _allowed;
              _allowed = true;
              if (allowed) widget.action?.call();
            },
    ),
  );
}
