import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../models/workout.dart';
import '../models/routine.dart';
import '../providers/gym_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class WorkoutLoggerScreen extends StatefulWidget {
  final Routine? routine;
  final Workout? initialWorkout;

  const WorkoutLoggerScreen({super.key, this.routine, this.initialWorkout});

  @override
  State<WorkoutLoggerScreen> createState() => _WorkoutLoggerScreenState();
}

class _WorkoutLoggerScreenState extends State<WorkoutLoggerScreen> {
  final _uuid = const Uuid();
  late String _name;
  final List<Exercise> _exercises = [];
  final DateTime _startTime = DateTime.now();
  int _elapsedSeconds = 0;
  Timer? _timer;
  

  int _restSeconds = 0;
  Timer? _restTimer;
  bool _showRestTimer = false;

  String? _workoutIdToEdit;
  DateTime? _workoutDateToEdit;

  @override
  void initState() {
    super.initState();
    if (widget.initialWorkout != null) {
      _name = widget.initialWorkout!.name;
      _workoutIdToEdit = widget.initialWorkout!.id;
      _workoutDateToEdit = widget.initialWorkout!.date;
      _elapsedSeconds = widget.initialWorkout!.duration;
      for (var re in widget.initialWorkout!.exercises) {
        _exercises.add(Exercise(
          id: re.id,
          name: re.name,
          muscleGroup: re.muscleGroup,
          sets: re.sets.map((rs) => WorkoutSet(
            id: rs.id,
            weight: rs.weight,
            reps: rs.reps,
            type: rs.type,
            completed: rs.completed,
          )).toList(),
        ));
      }
    } else {
      _name = widget.routine?.name ?? 'Nuevo Entrenamiento';
      if (widget.routine != null) {
        for (var re in widget.routine!.exercises) {
          _exercises.add(Exercise(
            id: _uuid.v4(),
            name: re.name,
            muscleGroup: re.muscleGroup,
            sets: re.sets.map((rs) => WorkoutSet(
              id: _uuid.v4(),
              weight: 0.0,
              reps: rs.reps,
              type: rs.type,
              completed: false,
            )).toList(),
          ));
        }
      }
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _elapsedSeconds++);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _restTimer?.cancel();
    super.dispose();
  }

  void _startRestTimer() {
    _restTimer?.cancel();
    _restSeconds = 60;
    setState(() => _showRestTimer = true);
    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_restSeconds > 0) {
        setState(() => _restSeconds--);
      } else {
        _stopRestTimer();
      }
    });
  }

  void _stopRestTimer() {
    _restTimer?.cancel();
    setState(() => _showRestTimer = false);
  }

  double get _totalVolume {
    return _exercises.fold(0, (sum, ex) => sum + ex.totalVolume);
  }

  void _finishWorkout() {
    if (_exercises.isEmpty) return;
    
    final workout = Workout(
      id: _workoutIdToEdit ?? _uuid.v4(),
      date: _workoutDateToEdit ?? DateTime.now(),
      name: _name,
      exercises: _exercises,
      duration: _elapsedSeconds,
    );

    context.read<GymProvider>().addWorkout(workout);
    Navigator.pop(context);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('¡Entrenamiento guardado! Volumen: ${_totalVolume.toStringAsFixed(0)} kg'),
        backgroundColor: AppTheme.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 120,
                floating: true,
                pinned: true,
                backgroundColor: AppTheme.background.withOpacity(0.8),
                flexibleSpace: FlexibleSpaceBar(
                  title: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                      Row(
                        children: [
                          const Icon(Icons.timer_outlined, size: 10, color: AppTheme.accent),
                          const SizedBox(width: 4),
                          Text(
                            '${_elapsedSeconds ~/ 60}:${(_elapsedSeconds % 60).toString().padLeft(2, '0')}',
                            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: AppTheme.accent),
                          ),
                          const SizedBox(width: 12),
                          const Icon(Icons.fitness_center_rounded, size: 10, color: AppTheme.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            '${_totalVolume.toStringAsFixed(0)} KG',
                            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                  centerTitle: false,
                  titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
                ),
                actions: [
                  TextButton(
                    onPressed: _finishWorkout,
                    child: const Text('FINALIZAR', style: TextStyle(color: AppTheme.accent, fontWeight: FontWeight.w900, fontSize: 11)),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      ..._exercises.asMap().entries.map((e) => _buildExerciseCard(e.value, e.key)),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _finishWorkout,
                        child: Text(widget.initialWorkout != null ? 'GUARDAR CAMBIOS' : 'GUARDAR Y FINALIZAR'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (_showRestTimer) _buildRestOverlay(),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(Exercise ex, int exIdx) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(color: AppTheme.accent.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.fitness_center_rounded, color: AppTheme.accent, size: 16),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(ex.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Colors.white)),
                        Text('% ${ex.totalVolume.toStringAsFixed(1)} kg (Promedio)', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: AppTheme.accent)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert_rounded, color: AppTheme.textSecondary, size: 18),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppTheme.white05),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Expanded(flex: 1, child: Text('SET', style: _labelStyle)),
                  const Expanded(flex: 2, child: Text('TIPO', style: _labelStyle)),
                  const Expanded(flex: 2, child: Text('KG', style: _labelStyle)),
                  const Expanded(flex: 2, child: Text('REPS', style: _labelStyle)),
                  const SizedBox(width: 44),
                ],
              ),
            ),
            ...ex.sets.asMap().entries.map((sEntry) => _buildSetRow(ex, exIdx, sEntry.key, sEntry.value)),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildSetRow(Exercise ex, int exIdx, int sIdx, WorkoutSet set) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text('${sIdx + 1}', style: const TextStyle(fontWeight: FontWeight.w900, color: AppTheme.textSecondary, fontSize: 12)),
          ),
          Expanded(
            flex: 2,
            child: Text(set.type.toUpperCase(), style: const TextStyle(fontSize: 7, fontWeight: FontWeight.w900, color: AppTheme.accent, letterSpacing: 0.5)),
          ),
          Expanded(
            flex: 2,
            child: _buildInput(
              initialValue: set.weight == 0 ? '' : set.weight.toString(),
              onChanged: (val) {
                set.weight = double.tryParse(val) ?? 0;
                if (set.weight > 0) set.completed = true;
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Center(
              child: Text('${set.reps}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              setState(() => set.completed = !set.completed);
              if (set.completed) {
                _startRestTimer();
              }
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: set.completed ? AppTheme.success : AppTheme.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: set.completed ? AppTheme.success : AppTheme.white.withOpacity(0.05)),
              ),
              child: Icon(Icons.check_rounded, size: 20, color: set.completed ? Colors.white : AppTheme.textSecondary.withOpacity(0.2)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput({required String initialValue, required Function(String) onChanged}) {
    return Container(
      height: 36,
      child: TextFormField(
        initialValue: initialValue,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
        decoration: InputDecoration(
          filled: true,
          fillColor: AppTheme.white.withOpacity(0.03),
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          hintText: '0',
          hintStyle: TextStyle(color: AppTheme.textSecondary.withOpacity(0.2)),
        ),
        onChanged: (val) {
          onChanged(val);
          setState(() {}); 
        },
      ),
    );
  }

  Widget _buildRestOverlay() {
    return Positioned(
      bottom: 40,
      left: 20,
      right: 20,
      child: GestureDetector(
        onTap: _stopRestTimer,
        child: GlassCard(
          padding: const EdgeInsets.all(20),
          borderRadius: 30,
          borderColor: AppTheme.accent.withOpacity(0.5),
          gradient: const [AppTheme.accent, AppTheme.accentDark],
          child: Row(
            children: [
              const Icon(Icons.timer_rounded, color: Colors.white, size: 28),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('TIEMPO DE DESCANSO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.5)),
                    Text('0:${_restSeconds.toString().padLeft(2, '0')}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 28, height: 1)),
                  ],
                ),
              ),
              const Icon(Icons.close_rounded, color: Colors.white, size: 24),
            ],
          ),
        ),
      ),
    );
  }

  static const _labelStyle = TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: AppTheme.textSecondary, letterSpacing: 1.5);
}
