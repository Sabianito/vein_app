import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../workouts/workout_catalog.dart';
import 'models.dart';

class AppSession extends ChangeNotifier {
  SharedPreferences? _prefs;

  UserProfile? _user;
  UserProfile? get user => _user;
  bool get isAuthed => _user != null;

  EquipmentFilter _equipmentFilter = const EquipmentFilter();
  EquipmentFilter get equipmentFilter => _equipmentFilter;

  final List<WorkoutLogEntry> _history = [];
  List<WorkoutLogEntry> get history => List.unmodifiable(_history);

  final Map<String, ExerciseStats> _exerciseStats = {};
  Map<String, ExerciseStats> get exerciseStats => Map.unmodifiable(_exerciseStats);

  bool _ttsEnabled = true;
  bool get ttsEnabled => _ttsEnabled;

  UserPreferences _userPreferences = const UserPreferences();
  UserPreferences get userPreferences => _userPreferences;

  bool _ready = false;
  bool get ready => _ready;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadFromDisk();
    _ready = true;
    notifyListeners();
  }

  Future<void> _loadFromDisk() async {
    final prefs = _prefs;
    if (prefs == null) return;

    final userRaw = prefs.getString(_Keys.user);
    _user = userRaw == null ? null : UserProfile.fromJson(jsonDecode(userRaw));

    final equipRaw = prefs.getString(_Keys.equipment);
    _equipmentFilter = equipRaw == null
        ? const EquipmentFilter()
        : EquipmentFilter.fromJson(jsonDecode(equipRaw));

    _ttsEnabled = prefs.getBool(_Keys.tts) ?? true;

    final prefsRaw = prefs.getString(_Keys.preferences);
    _userPreferences = prefsRaw == null
        ? const UserPreferences()
        : UserPreferences.fromJson(jsonDecode(prefsRaw));

    // ✅ Load per-user history using user id as key
    final userId = _user?.id ?? 'guest';
    final historyRaw = prefs.getStringList('${_Keys.history}_$userId') ?? const <String>[];
    _history
      ..clear()
      ..addAll(historyRaw.map((e) => WorkoutLogEntry.fromJson(jsonDecode(e))));

    final statsRaw = prefs.getStringList('${_Keys.stats}_$userId') ?? const <String>[];
    _exerciseStats
      ..clear()
      ..addEntries(statsRaw.map((e) {
        final map = jsonDecode(e) as Map<String, dynamic>;
        final key = map['key'] as String;
        final value = ExerciseStats.fromJson(map['value'] as Map<String, dynamic>);
        return MapEntry(key, value);
      }));
  }

  Future<void> _save() async {
    final prefs = _prefs;
    if (prefs == null) return;

    if (_user == null) {
      await prefs.remove(_Keys.user);
    } else {
      await prefs.setString(_Keys.user, jsonEncode(_user!.toJson()));
    }

    await prefs.setString(_Keys.equipment, jsonEncode(_equipmentFilter.toJson()));
    await prefs.setBool(_Keys.tts, _ttsEnabled);
    await prefs.setString(_Keys.preferences, jsonEncode(_userPreferences.toJson()));

    // ✅ Save per-user history using user id as key
    final userId = _user?.id ?? 'guest';
    await prefs.setStringList(
      '${_Keys.history}_$userId',
      _history.map((e) => jsonEncode(e.toJson())).toList(growable: false),
    );

    await prefs.setStringList(
      '${_Keys.stats}_$userId',
      _exerciseStats.entries
          .map((e) => jsonEncode({'key': e.key, 'value': e.value.toJson()}))
          .toList(growable: false),
    );

    if (_user != null && !_user!.isGuest) {
      final usersRaw = prefs.getString(_Keys.users);
      final usersMap = usersRaw == null
          ? <String, dynamic>{}
          : (jsonDecode(usersRaw) as Map<String, dynamic>);
      final entry = usersMap[_user!.email] as Map<String, dynamic>?;
      if (entry != null) {
        entry['photoPath'] = _user!.photoPath;
        usersMap[_user!.email] = entry;
        await prefs.setString(_Keys.users, jsonEncode(usersMap));
      }
    }
  }

  Future<AuthResult> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final prefs = _prefs;
    if (prefs == null) return AuthResult.error('Not ready');

    final normalized = email.trim().toLowerCase();
    if (normalized.isEmpty || password.length < 4) {
      return AuthResult.error('Enter a valid email and 4+ char password.');
    }

    final usersRaw = prefs.getString(_Keys.users);
    final usersMap = usersRaw == null
        ? <String, dynamic>{}
        : (jsonDecode(usersRaw) as Map<String, dynamic>);

    if (usersMap.containsKey(normalized)) {
      return AuthResult.error('Account already exists.');
    }

    usersMap[normalized] = {
      'password': password,
      'displayName': (displayName?.trim().isEmpty ?? true) ? 'vein user' : displayName!.trim(),
      'photoPath': null,
      'createdAt': DateTime.now().toIso8601String(),
    };
    await prefs.setString(_Keys.users, jsonEncode(usersMap));

    _user = UserProfile(
      id: normalized,
      email: normalized,
      displayName: (usersMap[normalized]['displayName'] as String),
      isGuest: false,
      photoPath: usersMap[normalized]['photoPath'] as String?,
    );
    // ✅ Clear history when signing up new account
    _history.clear();
    _exerciseStats.clear();
    await _save();
    notifyListeners();
    return AuthResult.ok();
  }

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final prefs = _prefs;
    if (prefs == null) return AuthResult.error('Not ready');
    final normalized = email.trim().toLowerCase();

    final usersRaw = prefs.getString(_Keys.users);
    final usersMap = usersRaw == null
        ? <String, dynamic>{}
        : (jsonDecode(usersRaw) as Map<String, dynamic>);

    final entry = usersMap[normalized];
    if (entry == null) return AuthResult.error('Account not found.');
    if (entry['password'] != password) return AuthResult.error('Wrong password.');

    // ✅ Set user first so _loadFromDisk uses correct user id
    _user = UserProfile(
      id: normalized,
      email: normalized,
      displayName: (entry['displayName'] as String?) ?? 'vein user',
      isGuest: false,
      photoPath: entry['photoPath'] as String?,
    );
    _history.clear();
    _exerciseStats.clear();
    // Now load this user's specific history
    final prefs2 = _prefs;
    if (prefs2 != null) {
      final histRaw = prefs2.getStringList('${_Keys.history}_$normalized') ?? [];
      _history.addAll(histRaw.map((e) => WorkoutLogEntry.fromJson(jsonDecode(e))));
      final statsRaw2 = prefs2.getStringList('${_Keys.stats}_$normalized') ?? [];
      _exerciseStats.addEntries(statsRaw2.map((e) {
        final map = jsonDecode(e) as Map<String, dynamic>;
        return MapEntry(map['key'] as String, ExerciseStats.fromJson(map['value'] as Map<String, dynamic>));
      }));
    }
    await _save();
    notifyListeners();
    return AuthResult.ok();
  }

  Future<void> loginAsGuest() async {
    _user = const UserProfile(
      id: 'guest',
      email: 'guest@vein.local',
      displayName: 'Demo User',
      isGuest: true,
    );
    await _save();
    notifyListeners();
  }

  Future<void> logout() async {
    _user = null;
    // ✅ Clear in-memory history so next user starts fresh
    _history.clear();
    _exerciseStats.clear();
    _userPreferences = const UserPreferences();
    await _save();
    notifyListeners();
  }

  Future<void> setEquipmentFilter(EquipmentFilter filter) async {
    _equipmentFilter = filter;
    await _save();
    notifyListeners();
  }

  Future<void> setTtsEnabled(bool value) async {
    _ttsEnabled = value;
    await _save();
    notifyListeners();
  }

  Future<void> setUserPreferences(UserPreferences preferences) async {
    _userPreferences = preferences;
    await _save();
    notifyListeners();
  }

  Future<void> setUserProfile(UserProfile user) async {
    _user = user;
    await _save();
    notifyListeners();
  }

  WorkoutPlan adaptPlan(WorkoutPlan base) {
    // ✅ Difficulty factor from user preference
    final difficulty = _userPreferences.difficulty;
    double difficultyFactor = switch (difficulty) {
      WorkoutDifficulty.beginner => 1.0,
      WorkoutDifficulty.intermediate => 1.2,
      WorkoutDifficulty.advanced => 1.4,
    };

    // Apply difficulty to blocks
    final blocks = base.blocks.map((b) {
      if (b.kind != WorkoutBlockKind.exercise) return b;
      return b.copyWith(
        work: b.work == null ? null : (b.work! * difficultyFactor).round().clamp(10, 360),
        reps: b.reps == null ? null : (b.reps! * difficultyFactor).round().clamp(3, 50),
      );
    }).toList();

    return base.copyWith(blocks: blocks);
  }

  Future<void> logCompletedWorkout({
    required WorkoutPlan plan,
    required int perceivedEffort,
    required Duration totalTime,
  }) async {
    final entry = WorkoutLogEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      planId: plan.id,
      category: plan.category,
      completedAt: DateTime.now(),
      perceivedEffort: perceivedEffort.clamp(1, 10),
      totalSeconds: totalTime.inSeconds,
    );
    _history.add(entry);

    for (final block in plan.blocks.where((b) => b.kind == WorkoutBlockKind.exercise)) {
      final key = block.exerciseId ?? 'unknown';
      final prev = _exerciseStats[key] ?? const ExerciseStats();
      _exerciseStats[key] = prev.bump(reps: block.reps, seconds: block.work);
    }

    await _save();
    notifyListeners();
  }

  List<WorkoutPlan> visiblePlansFor(WorkoutCategory category) {
    final all = WorkoutCatalog.plansFor(category);
    return all.where((p) => p.requiredEquipment.every(_equipmentFilter.has)).toList();
  }
}

abstract final class _Keys {
  static const users = 'vein_users';
  static const user = 'vein_user';
  static const equipment = 'vein_equipment';
  static const history = 'vein_history';
  static const stats = 'vein_stats';
  static const tts = 'vein_tts';
  static const preferences = 'vein_preferences';
}

class AuthResult {
  const AuthResult._(this.ok, this.message);

  final bool ok;
  final String? message;

  factory AuthResult.ok() => const AuthResult._(true, null);
  factory AuthResult.error(String message) => AuthResult._(false, message);
}