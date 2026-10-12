import 'package:flutter/material.dart';

/// Barrierearm beschriftete Stummschaltung für die aktuelle Spielrunde.
class ZuordnungSoundToggle extends StatelessWidget {
  final bool isMuted;
  final ValueChanged<bool> onChanged;

  const ZuordnungSoundToggle({
    super.key,
    required this.isMuted,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final tooltip = isMuted ? 'Ton einschalten' : 'Ton ausschalten';
    return IconButton(
      key: const ValueKey('zuordnung-sound-toggle'),
      tooltip: tooltip,
      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
      icon: Icon(isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded),
      onPressed: () => onChanged(!isMuted),
    );
  }
}
