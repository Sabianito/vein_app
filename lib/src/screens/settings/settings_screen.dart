import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';

import '../../routing/vein_router.dart';
import '../../state/app_session.dart';
import '../../state/models.dart';
import '../../theme/vein_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.session});

  final AppSession session;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ImagePicker _imagePicker = ImagePicker();

  late EquipmentFilter _filter;
  late bool _tts;
  late UserPreferences _preferences;

  @override
  void initState() {
    super.initState();
    _filter = widget.session.equipmentFilter;
    _tts = widget.session.ttsEnabled;
    _preferences = widget.session.userPreferences;
  }

  Future<void> _pickProfileImage() async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 600,
      maxHeight: 600,
      imageQuality: 85,
    );
    if (picked == null) return;
    final current = widget.session.user;
    if (current == null) return;
    final updated = current.copyWith(photoPath: picked.path);
    await widget.session.setUserProfile(updated);
    if (!mounted) return;
    setState(() {});
  }

  void _viewProfilePhoto(String imagePath) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black87,
        pageBuilder: (_, animation, secondaryAnimation) => _ProfilePhotoViewer(
          imagePath: imagePath,
          displayName: widget.session.user?.displayName ?? 'Vein User',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.session.user;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 32),
          children: [
            _buildProfileSection(context, user),
            const SizedBox(height: 22),

            _SectionLabel(label: 'Preferences'),
            const SizedBox(height: 12),

            _buildOptionGroup(
              context,
              'Workout Difficulty',
              [WorkoutDifficulty.beginner, WorkoutDifficulty.intermediate, WorkoutDifficulty.advanced],
              (d) => d.label,
              _preferences.difficulty,
              (difficulty) => setState(() => _preferences = _preferences.copyWith(difficulty: difficulty)),
              delay: 60,
            ),
            const SizedBox(height: 14),

            _buildOptionGroup(
              context,
              'Rest Timer',
              [RestTimer.thirtySeconds, RestTimer.sixtySeconds, RestTimer.ninetySeconds],
              (r) => r.label,
              _preferences.restTimer,
              (restTimer) => setState(() => _preferences = _preferences.copyWith(restTimer: restTimer)),
              delay: 100,
            ),
            const SizedBox(height: 14),

            _buildOptionGroup(
              context,
              'Daily Goal',
              [DailyGoal.strength, DailyGoal.fatLoss, DailyGoal.consistency],
              (g) => g.label,
              _preferences.dailyGoal,
              (goal) => setState(() => _preferences = _preferences.copyWith(dailyGoal: goal)),
              delay: 140,
            ),
            const SizedBox(height: 14),

            _buildToggleRow(context),
            const SizedBox(height: 28),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      await widget.session.setEquipmentFilter(_filter);
                      await widget.session.setTtsEnabled(_tts);
                      await widget.session.setUserPreferences(_preferences);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Saved')),
                      );
                    },
                    child: const Text('Save', style: TextStyle(letterSpacing: 0.4)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await widget.session.logout();
                      if (!context.mounted) return;
                      Navigator.of(context).pushNamedAndRemoveUntil(VeinRoutes.auth, (r) => false);
                    },
                    child: const Text('Logout', style: TextStyle(letterSpacing: 0.5)),
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 280.ms, duration: 200.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context, UserProfile? user) {
    final t = Theme.of(context).textTheme;
    final imagePath = user?.photoPath;

    return GestureDetector(
      onTap: () {
        if (imagePath != null && !kIsWeb) {
          _viewProfilePhoto(imagePath);
        } else {
          _pickProfileImage();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: VeinTheme.cardWhite.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: VeinTheme.cream.withValues(alpha: 0.14)),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 14, offset: const Offset(0, 5)),
          ],
        ),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: VeinTheme.maroonDeep,
                  child: imagePath != null && !kIsWeb
                      ? ClipOval(child: Image.file(File(imagePath), width: 64, height: 64, fit: BoxFit.cover, key: ValueKey(imagePath)))
                      : const Icon(Icons.person_rounded, color: Colors.white, size: 32),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: GestureDetector(
                    onTap: _pickProfileImage,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: VeinTheme.maroon,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.5),
                      ),
                      child: const Icon(Icons.edit_rounded, size: 11, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user?.displayName ?? 'Vein User',
                      style: t.titleMedium?.copyWith(fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.3)),
                  const SizedBox(height: 3),
                  Text(user?.email ?? '—',
                      style: t.bodySmall?.copyWith(color: VeinTheme.cream.withValues(alpha: 0.60), letterSpacing: 0.1)),
                  if (imagePath != null && !kIsWeb) ...[
                    const SizedBox(height: 4),
                    Text('Tap to view photo',
                        style: t.bodySmall?.copyWith(color: VeinTheme.cream.withValues(alpha: 0.40), fontSize: 10, fontStyle: FontStyle.italic)),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: VeinTheme.cream.withValues(alpha: 0.35), size: 20),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 220.ms);
  }

  Widget _buildToggleRow(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: VeinTheme.cardWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: VeinTheme.maroonDeep.withValues(alpha: 0.10)),
        boxShadow: [BoxShadow(color: VeinTheme.maroonDeep.withValues(alpha: 0.05), blurRadius: 14, offset: const Offset(0, 8))],
      ),
      child: Row(
        children: [
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(color: VeinTheme.maroonDeep.withValues(alpha: 0.07), borderRadius: BorderRadius.circular(9)),
            child: Icon(Icons.record_voice_over_rounded, size: 18, color: VeinTheme.maroonDeep.withValues(alpha: 0.75)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Voice Guidance', style: t.bodyMedium?.copyWith(color: VeinTheme.maroonDeep.withValues(alpha: 0.90), fontWeight: FontWeight.w600, letterSpacing: 0.1)),
                Text('Text-to-speech during workouts', style: t.bodySmall?.copyWith(color: VeinTheme.maroonDeep.withValues(alpha: 0.50))),
              ],
            ),
          ),
          Transform.scale(
            scale: 0.82,
            child: Switch(
              value: _tts,
              onChanged: (v) => setState(() => _tts = v),
              activeThumbColor: VeinTheme.maroon,
              activeTrackColor: VeinTheme.maroon.withValues(alpha: 0.22),
              inactiveThumbColor: VeinTheme.maroonDeep.withValues(alpha: 0.35),
              inactiveTrackColor: VeinTheme.maroonDeep.withValues(alpha: 0.08),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 220.ms, duration: 200.ms);
  }

  Widget _buildOptionGroup<T>(
    BuildContext context,
    String title,
    List<T> options,
    String Function(T) getLabel,
    T selectedValue,
    ValueChanged<T> onChanged, {
    required int delay,
  }) {
    final t = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: t.bodySmall?.copyWith(color: Colors.white.withValues(alpha: 0.60), letterSpacing: 0.5, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Row(
          children: options
              .map((option) => Expanded(child: _buildOptionButton(getLabel(option), option == selectedValue, () => onChanged(option))))
              .toList()
              .fold<List<Widget>>([], (list, w) => list.isEmpty ? [w] : [...list, const SizedBox(width: 8), w]),
        ),
      ],
    ).animate().fadeIn(delay: Duration(milliseconds: delay), duration: const Duration(milliseconds: 200));
  }

  Widget _buildOptionButton(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: isSelected ? VeinTheme.maroon : VeinTheme.cardWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? VeinTheme.maroon : VeinTheme.maroonDeep.withValues(alpha: 0.10)),
          boxShadow: isSelected ? [BoxShadow(color: VeinTheme.maroon.withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 3))] : [],
        ),
        child: Center(
          child: Text(label, style: TextStyle(
            color: isSelected ? Colors.white : VeinTheme.maroonDeep.withValues(alpha: 0.8),
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 12,
            letterSpacing: 0.2,
          )),
        ),
      ),
    );
  }
}

class _ProfilePhotoViewer extends StatelessWidget {
  const _ProfilePhotoViewer({required this.imagePath, required this.displayName});

  final String imagePath;
  final String displayName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(color: Colors.black87),
          ),
          Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(File(imagePath), fit: BoxFit.contain),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Text(displayName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                  const SizedBox(width: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label.toUpperCase(),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.40),
                letterSpacing: 1.4,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
        ),
        const SizedBox(width: 10),
        Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.10), thickness: 1)),
      ],
    );
  }
}