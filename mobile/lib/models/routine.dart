import 'dart:convert';

class RoutineSet {
  int reps;
  String type; // Normal, Calentamiento, Drop Set, Fallo

  RoutineSet({this.reps = 10, this.type = 'Normal'});

  Map<String, dynamic> toMap() => {'reps': reps, 'type': type};
  factory RoutineSet.fromMap(Map<String, dynamic> map) => RoutineSet(
    reps: map['reps'] ?? 10,
    type: map['type'] ?? 'Normal',
  );
}

class RoutineExercise {
  final String id;
  final String name;
  final String muscleGroup;
  final String category;
  List<RoutineSet> sets;

  RoutineExercise({
    required this.id,
    required this.name,
    required this.muscleGroup,
    required this.category,
    required this.sets,
  });

  Map<String, dynamic> toMap(String routineId) => {
        'id': id,
        'routine_id': routineId,
        'name': name,
        'muscle_group': muscleGroup,
        'category': category,
        'sets_json': jsonEncode(sets.map((s) => s.toMap()).toList()),
      };

  factory RoutineExercise.fromMap(Map<String, dynamic> map) {
    List<RoutineSet> setsList = [];
    if (map['sets_json'] != null) {
      final decoded = jsonDecode(map['sets_json']) as List;
      setsList = decoded.map((s) => RoutineSet.fromMap(s)).toList();
    } else {
      // Fallback if old data format (v2/v3)
      setsList = List.generate(map['default_sets'] ?? 3, (i) => RoutineSet(reps: map['default_reps'] ?? 10));
    }

    return RoutineExercise(
      id: map['id'],
      name: map['name'],
      muscleGroup: map['muscle_group'] ?? '',
      category: map['category'] ?? 'Superior',
      sets: setsList,
    );
  }
}

class Routine {
  final String id;
  final String name;
  final List<int> daysOfWeek;
  List<RoutineExercise> exercises;

  Routine({
    required this.id,
    required this.name,
    required this.daysOfWeek,
    required this.exercises,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'days_of_week': daysOfWeek.join(','),
      };

  factory Routine.fromMap(Map<String, dynamic> map) => Routine(
        id: map['id'],
        name: map['name'],
        daysOfWeek: (map['days_of_week'] as String)
            .split(',')
            .where((s) => s.isNotEmpty)
            .map(int.parse)
            .toList(),
        exercises: [],
      );
}
