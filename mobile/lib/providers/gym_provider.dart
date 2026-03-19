import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/workout.dart';
import '../models/routine.dart';
import '../models/library_exercise.dart';
import '../services/database_service.dart';

class GymProvider extends ChangeNotifier {
  static const List<Map<String, dynamic>> ranks = [
    {'days': 30, 'name': 'Pez Espada', 'emoji': '🗡️'},
    {'days': 10, 'name': 'Pez Globo', 'emoji': '🐡'},
    {'days': 3, 'name': 'Pez Neta', 'emoji': '🐟'},
    {'days': 1, 'name': 'Camarón', 'emoji': '🦐'},
    {'days': 0, 'name': 'Huevo de Pez', 'emoji': '🥚'},
  ];

  List<Workout> _workouts = [];
  List<Routine> _routines = [];
  List<LibraryExercise> _libraryExercises = [];
  String _userName = 'Usuario GymFlow';
  String _userGender = 'hombre';
  bool _isLoading = true;

  List<Workout> get workouts => _workouts;
  List<Routine> get routines => _routines;
  List<LibraryExercise> get libraryExercises => _libraryExercises;
  String get userName => _userName;
  String get userGender => _userGender;
  bool get isLoading => _isLoading;

  int get streak {
    if (_workouts.isEmpty) return 0;
    final sortedDates = _workouts
        .map((w) => DateTime(w.date.year, w.date.month, w.date.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    int count = 0;
    DateTime current = DateTime.now();
    current = DateTime(current.year, current.month, current.day);

    for (final d in sortedDates) {
      if (d == current || d == current.subtract(const Duration(days: 1))) {
        count++;
        current = d.subtract(const Duration(days: 1));
      } else if (count == 0 && d.isAfter(current.subtract(const Duration(days: 1)))) {
        continue;
      } else {
        break;
      }
    }
    return count;
  }

  Set<DateTime> get workoutDays => _workouts
      .map((w) => DateTime(w.date.year, w.date.month, w.date.day))
      .toSet();

  Map<String, dynamic> get currentRank {
    final s = streak;
    return ranks.firstWhere((r) => s >= (r['days'] as int),
        orElse: () => ranks.last);
  }

  double get thisWeekVolume {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final start = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    return _workouts
        .where((w) => w.date.isAfter(start) || w.date.isAtSameMomentAs(start))
        .fold(0.0, (sum, w) => sum + w.totalVolume);
  }

  double get lastWeekVolume {
    final now = DateTime.now();
    final startThisWeek = now.subtract(Duration(days: now.weekday - 1));
    final start = DateTime(startThisWeek.year, startThisWeek.month, startThisWeek.day);
    final startLastWeek = start.subtract(const Duration(days: 7));
    return _workouts
        .where((w) => w.date.isAfter(startLastWeek) && w.date.isBefore(start))
        .fold(0.0, (sum, w) => sum + w.totalVolume);
  }

  Map<String, double> get personalRecords {
    final Map<String, double> records = {};
    for (final workout in _workouts) {
      for (final exercise in workout.exercises) {
        final maxW = exercise.maxWeight;
        if (!records.containsKey(exercise.name) || records[exercise.name]! < maxW) {
          records[exercise.name] = maxW;
        }
      }
    }
    final sorted = Map.fromEntries(
        records.entries.toList()..sort((a, b) => b.value.compareTo(a.value)));
    return sorted;
  }

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();
    _workouts = await DatabaseService.instance.getAllWorkouts();
    _routines = await DatabaseService.instance.getAllRoutines();
    _libraryExercises = await DatabaseService.instance.getLibraryExercises();
    
    final prefs = await SharedPreferences.getInstance();
    _userName = prefs.getString('user_name') ?? 'Usuario GymFlow';
    _userGender = prefs.getString('user_gender') ?? 'hombre';
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateProfile(String name, String gender) async {
    _userName = name;
    _userGender = gender;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
    await prefs.setString('user_gender', gender);
    notifyListeners();
  }

  // Library
  Future<void> addLibraryExercise(LibraryExercise ex) async {
    await DatabaseService.instance.insertLibraryExercise(ex);
    _libraryExercises.add(ex);
    _libraryExercises.sort((a, b) => a.name.compareTo(b.name));
    notifyListeners();
  }

  Future<void> deleteLibraryExercise(String id) async {
    await DatabaseService.instance.deleteLibraryExercise(id);
    _libraryExercises.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  // Workouts
  Future<void> addWorkout(Workout workout) async {
    await DatabaseService.instance.insertWorkout(workout);
    _workouts.insert(0, workout);
    notifyListeners();
  }

  Future<void> deleteWorkout(String id) async {
    await DatabaseService.instance.deleteWorkout(id);
    _workouts.removeWhere((w) => w.id == id);
    notifyListeners();
  }

  // Routines
  Future<void> addRoutine(Routine routine) async {
    await DatabaseService.instance.insertRoutine(routine);
    final idx = _routines.indexWhere((r) => r.id == routine.id);
    if (idx >= 0) {
      _routines[idx] = routine;
    } else {
      _routines.add(routine);
    }
    notifyListeners();
  }

  Future<void> deleteRoutine(String id) async {
    await DatabaseService.instance.deleteRoutine(id);
    _routines.removeWhere((r) => r.id == id);
    notifyListeners();
  }
}
