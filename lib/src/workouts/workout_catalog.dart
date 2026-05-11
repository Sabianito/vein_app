class WorkoutCatalog {
  static List<WorkoutPlan> plansFor(WorkoutCategory category) {
    return switch (category) {
      WorkoutCategory.push => _push,
      WorkoutCategory.pull => _pull,
      WorkoutCategory.legs => _legs,
    };
  }

  static const _push = <WorkoutPlan>[
    WorkoutPlan(
      id: 'push_day',
      title: 'Push Exercises',
      category: WorkoutCategory.push,
      requiredEquipment: [Equipment.bodyweight, Equipment.benchOrChair],
      blocks: [
        WorkoutBlock.exercise(
          exerciseId: 'incline_pushups',
          title: 'Incline Push-ups',
          work: 35,
          rest: 25,
          tips: [
            'Keep ribs down; squeeze glutes.',
            'Lower with control, press fast.',
          ],
        ),
        WorkoutBlock.exercise(
          exerciseId: 'chair_dips',
          title: 'Chair Dips',
          reps: 10,
          rest: 40,
          tips: [
            'Keep shoulders away from ears.',
            'Stop if front-shoulder pinch appears.',
          ],
        ),
        WorkoutBlock.exercise(
          exerciseId: 'pike_pushups',
          title: 'Pike Push-ups',
          reps: 8,
          rest: 45,
          tips: [
            'Think “head to the floor”.',
            'Hips high; elbows slightly in.',
          ],
        ),
        WorkoutBlock.exercise(
          exerciseId: 'shoulder_taps',
          title: 'Shoulder Taps',
          work: 30,
          rest: 35,
          tips: [
            'Keep hips steady.',
            'Touch each shoulder softly.',
          ],
        ),
        WorkoutBlock.exercise(
          exerciseId: 'bench_pushups',
          title: 'Bench Push-ups',
          reps: 12,
          rest: 40,
          tips: [
            'Hands on the bench.',
            'Keep shoulders over wrists.',
          ],
        ),
        WorkoutBlock.restOnly(title: 'Cool down', rest: 45),
      ],
    ),
  ];

  static const _pull = <WorkoutPlan>[
    WorkoutPlan(
      id: 'pull_day',
      title: 'Pull Exercises',
      category: WorkoutCategory.pull,
      requiredEquipment: [Equipment.pullUpBar, Equipment.bodyweight],
      blocks: [
        WorkoutBlock.exercise(
          exerciseId: 'dead_hang',
          title: 'Dead Hang',
          work: 30,
          rest: 35,
          tips: ['Long spine; breathe slowly.', 'Keep shoulders active.'],
        ),
        WorkoutBlock.exercise(
          exerciseId: 'negative_pullups',
          title: 'Negative Pull-ups',
          reps: 6,
          rest: 55,
          tips: ['Lower for 3–5 seconds.', 'Start at top with chin over bar.'],
        ),
        WorkoutBlock.exercise(
          exerciseId: 'inverted_rows',
          title: 'Inverted Rows',
          reps: 10,
          rest: 40,
          tips: ['Keep body straight.', 'Pull chest toward the bar.'],
        ),
        WorkoutBlock.exercise(
          exerciseId: 'scapular_pulls',
          title: 'Scapular Pulls',
          reps: 12,
          rest: 35,
          tips: ['Use shoulders, not arms.', 'Keep elbows soft.'],
        ),
        WorkoutBlock.exercise(
          exerciseId: 'towel_curls',
          title: 'Towel Curls',
          reps: 14,
          rest: 35,
          tips: ['Slow tempo.', 'Squeeze at the top.'],
        ),
        WorkoutBlock.restOnly(title: 'Cool down', rest: 45),
      ],
    ),
  ];

  static const _legs = <WorkoutPlan>[
    WorkoutPlan(
      id: 'legs_day',
      title: 'Leg Exercises',
      category: WorkoutCategory.legs,
      requiredEquipment: [Equipment.bodyweight, Equipment.yogaMat],
      blocks: [
        WorkoutBlock.exercise(
          exerciseId: 'air_squats',
          title: 'Air Squats',
          reps: 14,
          rest: 35,
          tips: ['Knees track toes.', 'Keep heels down.'],
        ),
        WorkoutBlock.exercise(
          exerciseId: 'reverse_lunges',
          title: 'Reverse Lunges',
          reps: 12,
          rest: 45,
          tips: ['Soft knee touch is optional.', 'Stay tall.'],
        ),
        WorkoutBlock.exercise(
          exerciseId: 'glute_bridge',
          title: 'Glute Bridge',
          reps: 16,
          rest: 35,
          tips: ['Posterior tilt first.', 'Pause at top.'],
        ),
        WorkoutBlock.exercise(
          exerciseId: 'wall_sit',
          title: 'Wall Sit',
          work: 35,
          rest: 40,
          tips: ['Knees ~90°.', 'Press back into wall.'],
        ),
        WorkoutBlock.exercise(
          exerciseId: 'calf_raises',
          title: 'Calf Raises',
          reps: 16,
          rest: 40,
          tips: ['Pause at top.', 'Control the descent.'],
        ),
        WorkoutBlock.restOnly(title: 'Cool down', rest: 45),
      ],
    ),
  ];
}

enum WorkoutCategory { push, pull, legs }

enum Equipment {
  bodyweight,
  dumbbells,
  pullUpBar,
  resistanceBand,
  benchOrChair,
  yogaMat,
}

class WorkoutPlan {
  const WorkoutPlan({
    required this.id,
    required this.title,
    required this.category,
    required this.requiredEquipment,
    required this.blocks,
  });

  final String id;
  final String title;
  final WorkoutCategory category;
  final List<Equipment> requiredEquipment;
  final List<WorkoutBlock> blocks;

  WorkoutPlan copyWith({
    List<WorkoutBlock>? blocks,
  }) {
    return WorkoutPlan(
      id: id,
      title: title,
      category: category,
      requiredEquipment: requiredEquipment,
      blocks: blocks ?? this.blocks,
    );
  }
}

enum WorkoutBlockKind { exercise, rest }

class WorkoutBlock {
  const WorkoutBlock._({
    required this.kind,
    required this.title,
    required this.exerciseId,
    required this.work,
    required this.reps,
    required this.rest,
    required this.tips,
  });

  final WorkoutBlockKind kind;
  final String title;
  final String? exerciseId;
  final int? work; // seconds
  final int? reps;
  final int rest; // seconds after block
  final List<String> tips;

  const WorkoutBlock.exercise({
    required String exerciseId,
    required String title,
    int? work,
    int? reps,
    required int rest,
    List<String> tips = const [],
  }) : this._(
          kind: WorkoutBlockKind.exercise,
          title: title,
          exerciseId: exerciseId,
          work: work,
          reps: reps,
          rest: rest,
          tips: tips,
        );

  const WorkoutBlock.restOnly({
    required String title,
    required int rest,
  }) : this._(
          kind: WorkoutBlockKind.rest,
          title: title,
          exerciseId: null,
          work: null,
          reps: null,
          rest: rest,
          tips: const [],
        );

  WorkoutBlock copyWith({
    int? work,
    int? reps,
  }) {
    return WorkoutBlock._(
      kind: kind,
      title: title,
      exerciseId: exerciseId,
      work: work ?? this.work,
      reps: reps ?? this.reps,
      rest: rest,
      tips: tips,
    );
  }
}

