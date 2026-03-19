class WorkoutSet {
  final String id;
  double weight;
  int reps;
  final String type; 
  bool completed;

  WorkoutSet({
    required this.id,
    required this.weight,
    required this.reps,
    this.type = 'Normal',
    this.completed = false,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'weight': weight,
        'reps': reps,
        'type': type,
        'completed': completed ? 1 : 0,
      };

  factory WorkoutSet.fromMap(Map<String, dynamic> map) => WorkoutSet(
        id: map['id'],
        weight: map['weight'],
        reps: map['reps'],
        type: map['type'] ?? 'Normal',
        completed: map['completed'] == 1,
      );
}

class Exercise {
  final String id;
  String name;
  String muscleGroup;
  List<WorkoutSet> sets;

  Exercise({
    required this.id,
    required this.name,
    required this.muscleGroup,
    required this.sets,
  });

  double get maxWeight => sets.isEmpty
      ? 0
      : sets.map((s) => s.weight).reduce((a, b) => a > b ? a : b);

  double get totalVolume =>
      sets.fold(0, (sum, s) => sum + (s.weight * s.reps));

  Map<String, dynamic> toMap(String workoutId) => {
        'id': id,
        'workout_id': workoutId,
        'name': name,
        'muscle_group': muscleGroup,
      };

  factory Exercise.fromMap(Map<String, dynamic> map) => Exercise(
        id: map['id'],
        name: map['name'],
        muscleGroup: map['muscle_group'] ?? '',
        sets: [],
      );
}

class Workout {
  final String id;
  final DateTime date;
  final String name;
  List<Exercise> exercises;
  int duration; 

  Workout({
    required this.id,
    required this.date,
    required this.name,
    required this.exercises,
    this.duration = 0,
  });

  double get totalVolume =>
      exercises.fold(0.0, (sum, ex) => sum + ex.totalVolume);

  Map<String, dynamic> toMap() => {
        'id': id,
        'date': date.toIso8601String(),
        'name': name,
        'duration': duration,
      };

  factory Workout.fromMap(Map<String, dynamic> map) => Workout(
        id: map['id'],
        date: DateTime.parse(map['date']),
        name: map['name'],
        exercises: [],
        duration: map['duration'] ?? 0,
      );
}
