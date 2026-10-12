import 'package:flutter/material.dart';

class StickerEditControls extends StatelessWidget {
  final bool selected, busy;
  final VoidCallback onMove, onSmaller, onLarger, onDelete, onDone;
  const StickerEditControls({
    super.key,
    required this.selected,
    required this.busy,
    required this.onMove,
    required this.onSmaller,
    required this.onLarger,
    required this.onDelete,
    required this.onDone,
  });
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 64,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _button(
          'sticker_move_by_tap',
          'Sticker versetzen',
          Icons.open_with_rounded,
          onMove,
        ),
        _button(
          'sticker_smaller',
          'Sticker kleiner',
          Icons.remove_circle_outline,
          onSmaller,
        ),
        _button(
          'sticker_larger',
          'Sticker größer',
          Icons.add_circle_outline,
          onLarger,
        ),
        _button(
          'sticker_delete',
          'Sticker entfernen',
          Icons.delete_outline,
          onDelete,
        ),
        _button(
          'sticker_done',
          'Fertig',
          Icons.check_circle_outline_rounded,
          onDone,
        ),
      ],
    ),
  );
  Widget _button(
    String key,
    String label,
    IconData icon,
    VoidCallback action,
  ) => SizedBox(
    width: 64,
    height: 64,
    child: IconButton(
      key: Key(key),
      tooltip: label,
      onPressed: !selected || busy ? null : action,
      icon: Icon(icon, size: 32),
    ),
  );
}
