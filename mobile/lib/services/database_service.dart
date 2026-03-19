import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';
import '../models/workout.dart';
import '../models/routine.dart';
import '../models/library_exercise.dart';

class DatabaseService {
  static Database? _database;
  static final DatabaseService instance = DatabaseService._internal();
  DatabaseService._internal();

  Future<Database> get db async {
    _database ??= await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'gymflow.db');

    return await openDatabase(
      path,
      version: 4,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldV, int newV) async {
    if (oldV < 2) {
      await db.execute('''
        CREATE TABLE library_exercises (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          muscle_group TEXT DEFAULT '',
          category TEXT DEFAULT 'Superior'
        )
      ''');
    }
    if (oldV < 3) {
      try {
        await db.execute('ALTER TABLE library_exercises ADD COLUMN category TEXT DEFAULT "Superior"');
      } catch (_) {}
      try {
        await db.execute('ALTER TABLE routine_exercises ADD COLUMN category TEXT DEFAULT "Superior"');
      } catch (_) {}
    }
    if (oldV < 4) {
      try {
        await db.execute('ALTER TABLE routine_exercises ADD COLUMN sets_json TEXT');
      } catch (_) {}
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE workouts (
        id TEXT PRIMARY KEY,
        date TEXT NOT NULL,
        name TEXT NOT NULL,
        duration INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE exercises (
        id TEXT PRIMARY KEY,
        workout_id TEXT NOT NULL,
        name TEXT NOT NULL,
        muscle_group TEXT DEFAULT '',
        FOREIGN KEY (workout_id) REFERENCES workouts(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE workout_sets (
        id TEXT PRIMARY KEY,
        exercise_id TEXT NOT NULL,
        weight REAL NOT NULL,
        reps INTEGER NOT NULL,
        type TEXT DEFAULT 'Normal',
        completed INTEGER DEFAULT 0,
        FOREIGN KEY (exercise_id) REFERENCES exercises(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE routines (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        days_of_week TEXT DEFAULT ''
      )
    ''');

    await db.execute('''
      CREATE TABLE routine_exercises (
        id TEXT PRIMARY KEY,
        routine_id TEXT NOT NULL,
        name TEXT NOT NULL,
        muscle_group TEXT DEFAULT '',
        category TEXT DEFAULT 'Superior',
        sets_json TEXT,
        FOREIGN KEY (routine_id) REFERENCES routines(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE library_exercises (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        muscle_group TEXT DEFAULT '',
        category TEXT DEFAULT 'Superior'
      )
    ''');

    await _seedLibrary(db);
  }

  Future<void> _seedLibrary(Database db) async {
    final uuid = const Uuid();
    final List<Map<String, String>> initial = [
      {'name': 'Press de Banca', 'muscle': 'Pecho', 'cat': 'Superior'},
      {'name': 'Dominadas', 'muscle': 'Espalda', 'cat': 'Superior'},
      {'name': 'Remo con Barra', 'muscle': 'Espalda', 'cat': 'Superior'},
      {'name': 'Press Militar', 'muscle': 'Hombro', 'cat': 'Superior'},
      {'name': 'Curl de Bíceps', 'muscle': 'Bicep', 'cat': 'Superior'},
      {'name': 'Predicador', 'muscle': 'Bicep', 'cat': 'Superior'},
      {'name': 'Press Francés', 'muscle': 'Tricep', 'cat': 'Superior'},
      {'name': 'Copa Tricep', 'muscle': 'Tricep', 'cat': 'Superior'},
      {'name': 'Sentadilla', 'muscle': 'Pierna Completa', 'cat': 'Inferior'},
      {'name': 'Prensa', 'muscle': 'Pierna Completa', 'cat': 'Inferior'},
      {'name': 'Hip Thrust', 'muscle': 'Glúteo', 'cat': 'Inferior'},
      {'name': 'Extensión Cuádriceps', 'muscle': 'Cuádriceps', 'cat': 'Inferior'},
      {'name': 'Curl Femoral', 'muscle': 'Femoral', 'cat': 'Inferior'},
      {'name': 'Elevación Talones', 'muscle': 'Pantorrilla', 'cat': 'Inferior'},
      {'name': 'Crunch Abdominal', 'muscle': 'Abdomen', 'cat': 'Core'},
      {'name': 'Plancha', 'muscle': 'Abdomen', 'cat': 'Core'},
      {'name': 'Encogimientos', 'muscle': 'Trapecio', 'cat': 'Superior'},
      {'name': 'Curl Antebrazo', 'muscle': 'Antebrazo', 'cat': 'Superior'},
    ];

    for (var ex in initial) {
      await db.insert('library_exercises', {
        'id': uuid.v4(),
        'name': ex['name'],
        'muscle_group': ex['muscle'],
        'category': ex['cat'],
      });
    }
  }

  Future<List<LibraryExercise>> getLibraryExercises() async {
    final database = await db;
    final maps = await database.query('library_exercises', orderBy: 'name ASC');
    return maps.map((e) => LibraryExercise.fromMap(e)).toList();
  }

  Future<void> insertLibraryExercise(LibraryExercise ex) async {
    final database = await db;
    await database.insert('library_exercises', ex.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteLibraryExercise(String id) async {
    final database = await db;
    await database.delete('library_exercises', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> insertWorkout(Workout workout) async {
    final database = await db;
    await database.insert('workouts', workout.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);

    for (final exercise in workout.exercises) {
      final res = await database.insert('exercises', exercise.toMap(workout.id),
          conflictAlgorithm: ConflictAlgorithm.replace);
      for (final set in exercise.sets) {
        await database.insert(
            'workout_sets', {...set.toMap(), 'exercise_id': exercise.id},
            conflictAlgorithm: ConflictAlgorithm.replace);
      }
    }
  }

  Future<List<Workout>> getAllWorkouts() async {
    final database = await db;
    final workoutMaps = await database.query('workouts', orderBy: 'date DESC');

    final workouts = <Workout>[];
    for (final wMap in workoutMaps) {
      final workout = Workout.fromMap(wMap);
      final exerciseMaps = await database.query('exercises', where: 'workout_id = ?', whereArgs: [workout.id]);

      for (final exMap in exerciseMaps) {
        final exercise = Exercise.fromMap(exMap);
        final setMaps = await database.query('workout_sets', where: 'exercise_id = ?', whereArgs: [exercise.id]);
        exercise.sets = setMaps.map(WorkoutSet.fromMap).toList();
        workout.exercises.add(exercise);
      }
      workouts.add(workout);
    }
    return workouts;
  }

  Future<void> deleteWorkout(String id) async {
    final database = await db;
    await database.delete('workouts', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> insertRoutine(Routine routine) async {
    final database = await db;
    await database.insert('routines', routine.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);

    await database.delete('routine_exercises',
        where: 'routine_id = ?', whereArgs: [routine.id]);

    for (final exercise in routine.exercises) {
      await database.insert('routine_exercises', exercise.toMap(routine.id),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  Future<List<Routine>> getAllRoutines() async {
    final database = await db;
    final routineMaps = await database.query('routines');

    final routines = <Routine>[];
    for (final rMap in routineMaps) {
      final routine = Routine.fromMap(rMap);
      final exerciseMaps = await database.query('routine_exercises', where: 'routine_id = ?', whereArgs: [routine.id]);
      routine.exercises = exerciseMaps.map(RoutineExercise.fromMap).toList();
      routines.add(routine);
    }
    return routines;
  }

  Future<void> deleteRoutine(String id) async {
    final database = await db;
    await database.delete('routines', where: 'id = ?', whereArgs: [id]);
    await database.delete('routine_exercises',
        where: 'routine_id = ?', whereArgs: [id]);
  }
}
