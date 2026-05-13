import '../features/workout/data/workout_catalog.dart';

class UserProfile {
  const UserProfile({
    required this.id,
    required this.email,
    required this.displayName,
    required this.isGuest,
    this.photoPath,
  });

  final String id;
  final String email;
  final String displayName;
  final bool isGuest;
  final String? photoPath;

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'displayName': displayName,
        'isGuest': isGuest,
        'photoPath': photoPath,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'] as String,
        email: json['email'] as String,
        displayName: json['displayName'] as String,
        isGuest: json['isGuest'] as bool,
        photoPath: json['photoPath'] as String?,
      );

  UserProfile copyWith({
    String? id,
    String? email,
    String? displayName,
    bool? isGuest,
    String? photoPath,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      isGuest: isGuest ?? this.isGuest,
      photoPath: photoPath ?? this.photoPath,
    );
  }
}

class EquipmentFilter {
  const EquipmentFilter({
    this.dumbbells = false,
    this.pullUpBar = false,
    this.resistanceBand = false,
    this.benchOrChair = true,
    this.yogaMat = true,
  });

  final bool dumbbells;
  final bool pullUpBar;
  final bool resistanceBand;
  final bool benchOrChair;
  final bool yogaMat;

  bool has(Equipment e) {
    return switch (e) {
      Equipment.bodyweight => true,
      Equipment.dumbbells => dumbbells,
      Equipment.pullUpBar => pullUpBar,
      Equipment.resistanceBand => resistanceBand,
      Equipment.benchOrChair => benchOrChair,
      Equipment.yogaMat => yogaMat,
    };
  }

  Map<String, dynamic> toJson() => {
        'dumbbells': dumbbells,
        'pullUpBar': pullUpBar,
        'resistanceBand': resistanceBand,
        'benchOrChair': benchOrChair,
        'yogaMat': yogaMat,
      };

  factory EquipmentFilter.fromJson(Map<String, dynamic> json) => EquipmentFilter(
        dumbbells: json['dumbbells'] as bool? ?? false,
        pullUpBar: json['pullUpBar'] as bool? ?? false,
        resistanceBand: json['resistanceBand'] as bool? ?? false,
        benchOrChair: json['benchOrChair'] as bool? ?? true,
        yogaMat: json['yogaMat'] as bool? ?? true,
      );

  EquipmentFilter copyWith({
    bool? dumbbells,
    bool? pullUpBar,
    bool? resistanceBand,
    bool? benchOrChair,
    bool? yogaMat,
  }) {
    return EquipmentFilter(
      dumbbells: dumbbells ?? this.dumbbells,
      pullUpBar: pullUpBar ?? this.pullUpBar,
      resistanceBand: resistanceBand ?? this.resistanceBand,
      benchOrChair: benchOrChair ?? this.benchOrChair,
      yogaMat: yogaMat ?? this.yogaMat,
    );
  }
}

class WorkoutLogEntry {
  const WorkoutLogEntry({
    required this.id,
    required this.planId,
    required this.category,
    required this.completedAt,
    required this.perceivedEffort,
    required this.totalSeconds,
  });

  final String id;
  final String planId;
  final WorkoutCategory category;
  final DateTime completedAt;
  final int perceivedEffort;
  final int totalSeconds;

  Map<String, dynamic> toJson() => {
        'id': id,
        'planId': planId,
        'category': category.name,
        'completedAt': completedAt.toIso8601String(),
        'perceivedEffort': perceivedEffort,
        'totalSeconds': totalSeconds,
      };

  factory WorkoutLogEntry.fromJson(Map<String, dynamic> json) => WorkoutLogEntry(
        id: json['id'] as String,
        planId: json['planId'] as String,
        category: WorkoutCategory.values.firstWhere(
          (c) => c.name == (json['category'] as String),
          orElse: () => WorkoutCategory.push,
        ),
        completedAt: DateTime.parse(json['completedAt'] as String),
        perceivedEffort: (json['perceivedEffort'] as num).toInt(),
        totalSeconds: (json['totalSeconds'] as num).toInt(),
      );
}

class ExerciseStats {
  const ExerciseStats({
    this.sessions = 0,
    this.totalReps = 0,
    this.totalSeconds = 0,
  });

  final int sessions;
  final int totalReps;
  final int totalSeconds;

  ExerciseStats bump({int? reps, int? seconds}) {
    return ExerciseStats(
      sessions: sessions + 1,
      totalReps: totalReps + (reps ?? 0),
      totalSeconds: totalSeconds + (seconds ?? 0),
    );
  }

  Map<String, dynamic> toJson() => {
        'sessions': sessions,
        'totalReps': totalReps,
        'totalSeconds': totalSeconds,
      };

  factory ExerciseStats.fromJson(Map<String, dynamic> json) => ExerciseStats(
        sessions: (json['sessions'] as num?)?.toInt() ?? 0,
        totalReps: (json['totalReps'] as num?)?.toInt() ?? 0,
        totalSeconds: (json['totalSeconds'] as num?)?.toInt() ?? 0,
      );
}

enum WorkoutDifficulty {
  beginner('Beginner'),
  intermediate('Intermediate'),
  advanced('Advanced');

  const WorkoutDifficulty(this.label);
  final String label;
}

enum WorkoutDuration {
  tenMins('10 mins', 10),
  twentyMins('20 mins', 20),
  thirtyMins('30 mins', 30);

  const WorkoutDuration(this.label, this.minutes);
  final String label;
  final int minutes;
}

enum RestTimer {
  thirtySeconds('30s', 30),
  sixtySeconds('60s', 60),
  ninetySeconds('90s', 90);

  const RestTimer(this.label, this.seconds);
  final String label;
  final int seconds;
}

enum DailyGoal {
  strength('Strength'),
  fatLoss('Fat Loss'),
  consistency('Consistency');

  const DailyGoal(this.label);
  final String label;
}

class UserPreferences {
  const UserPreferences({
    this.difficulty = WorkoutDifficulty.beginner,
    this.duration = WorkoutDuration.twentyMins,
    this.restTimer = RestTimer.sixtySeconds,
    this.dailyGoal = DailyGoal.consistency,
  });

  final WorkoutDifficulty difficulty;
  final WorkoutDuration duration;
  final RestTimer restTimer;
  final DailyGoal dailyGoal;

  Map<String, dynamic> toJson() => {
        'difficulty': difficulty.name,
        'duration': duration.name,
        'restTimer': restTimer.name,
        'dailyGoal': dailyGoal.name,
      };

  factory UserPreferences.fromJson(Map<String, dynamic> json) => UserPreferences(
        difficulty: WorkoutDifficulty.values.firstWhere(
          (d) => d.name == json['difficulty'],
          orElse: () => WorkoutDifficulty.beginner,
        ),
        duration: WorkoutDuration.values.firstWhere(
          (d) => d.name == json['duration'],
          orElse: () => WorkoutDuration.twentyMins,
        ),
        restTimer: RestTimer.values.firstWhere(
          (r) => r.name == json['restTimer'],
          orElse: () => RestTimer.sixtySeconds,
        ),
        dailyGoal: DailyGoal.values.firstWhere(
          (g) => g.name == json['dailyGoal'],
          orElse: () => DailyGoal.consistency,
        ),
      );

  UserPreferences copyWith({
    WorkoutDifficulty? difficulty,
    WorkoutDuration? duration,
    RestTimer? restTimer,
    DailyGoal? dailyGoal,
  }) {
    return UserPreferences(
      difficulty: difficulty ?? this.difficulty,
      duration: duration ?? this.duration,
      restTimer: restTimer ?? this.restTimer,
      dailyGoal: dailyGoal ?? this.dailyGoal,
    );
  }
}
