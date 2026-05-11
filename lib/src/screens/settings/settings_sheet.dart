import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../routing/vein_router.dart';
import '../../state/app_session.dart';
import '../../theme/vein_theme.dart';

class SettingsSheet extends StatefulWidget {
  const SettingsSheet({super.key, required this.session});

  final AppSession session;

  @override
  State<SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends State<SettingsSheet> {
  late bool _tts;

  @override
  void initState() {
    super.initState();
    _tts = widget.session.ttsEnabled;
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: VeinTheme.maroonDeep.withValues(alpha: 0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        border: Border.all(color: VeinTheme.cream.withValues(alpha: 0.12)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: VeinTheme.cream.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text('Settings', style: t.titleLarge?.copyWith(letterSpacing: 0.6))
                .animate().fadeIn(duration: 180.ms),
            const SizedBox(height: 14),
            Text('Guidance', style: t.titleMedium?.copyWith(letterSpacing: 0.4)),
            const SizedBox(height: 8),
            _toggle('Voice guidance (TTS)', _tts, (v) => setState(() => _tts = v)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close', style: TextStyle(letterSpacing: 0.4)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await widget.session.setTtsEnabled(_tts);
                      if (!context.mounted) return;
                      Navigator.of(context).pop();
                    },
                    child: const Text('Save', style: TextStyle(letterSpacing: 0.6)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () async {
                  await widget.session.logout();
                  if (!context.mounted) return;
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    VeinRoutes.auth,
                    (r) => false,
                  );
                },
                child: Text(
                  'Log out',
                  style: TextStyle(
                    color: VeinTheme.cream.withValues(alpha: 0.9),
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _toggle(String label, bool value, ValueChanged<bool> onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: VeinTheme.cream.withValues(alpha: 0.12)),
        color: VeinTheme.maroon.withValues(alpha: 0.25),
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        activeThumbColor: VeinTheme.cream,
        activeTrackColor: VeinTheme.cream.withValues(alpha: 0.22),
        inactiveThumbColor: VeinTheme.cream.withValues(alpha: 0.55),
        inactiveTrackColor: VeinTheme.cream.withValues(alpha: 0.12),
        title: Text(label, style: const TextStyle(letterSpacing: 0.3)),
      ),
    );
  }
}