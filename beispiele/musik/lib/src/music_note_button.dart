import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'music_piece.dart';
import 'music_note_style.dart';

/// PointerDown spielt sofort. Der nachfolgende Button-Tap darf keinen zweiten
/// Ton erzeugen; Tastatur und Vorlesehilfe behalten den normalen Button-Weg.
class MusicNoteButton extends StatefulWidget {
  final MusicNote note;
  final ValueChanged<MusicNote> onPressed;
  final Widget? child;
  final ButtonStyle? style;
  final Key? buttonKey;
  final String? semanticLabel;
  const MusicNoteButton({
    super.key,
    required this.note,
    required this.onPressed,
    this.child,
    this.style,
    this.buttonKey,
    this.semanticLabel,
  });

  @override
  State<MusicNoteButton> createState() => _MusicNoteButtonState();
}

class _MusicNoteButtonState extends State<MusicNoteButton> {
  final Set<int> _activePointers = <int>{};

  void _release(PointerEvent event) {
    // Tap wird noch im selben Pointer-Ereignis verarbeitet. Danach endet die
    // Sperre auch beim Abbruch und blockiert keinen späteren Tastaturdruck.
    scheduleMicrotask(() {
      if (mounted) setState(() => _activePointers.remove(event.pointer));
    });
  }

  @override
  Widget build(BuildContext context) => Listener(
    onPointerDown: (event) {
      if (event.buttons != kPrimaryButton) return;
      setState(() => _activePointers.add(event.pointer));
      widget.onPressed(widget.note);
    },
    onPointerUp: _release,
    onPointerCancel: _release,
    child: DecoratedBox(
      key: Key('music-note-active-${widget.note.name}'),
      // Der Rand liegt über der gefüllten Taste und bleibt deshalb sichtbar.
      position: DecorationPosition.foreground,
      decoration: BoxDecoration(
        border: Border.all(
          color: _activePointers.isNotEmpty
              ? Colors.black87
              : Colors.transparent,
          width: 4,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(26)),
      ),
      child: FilledButton(
        key: widget.buttonKey ?? Key('music-note-${widget.note.name}'),
        style:
            widget.style ??
            FilledButton.styleFrom(
              backgroundColor: musicNoteColor(widget.note),
              foregroundColor: musicNoteForeground(widget.note),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(22),
                ),
              ),
            ),
        onPressed: () {
          if (_activePointers.isEmpty) widget.onPressed(widget.note);
        },
        child: Semantics(
          label: widget.semanticLabel ?? 'Ton ${widget.note.label}',
          excludeSemantics: true,
          child:
              widget.child ??
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  widget.note.label,
                  maxLines: 1,
                  softWrap: false,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
        ),
      ),
    ),
  );
}
