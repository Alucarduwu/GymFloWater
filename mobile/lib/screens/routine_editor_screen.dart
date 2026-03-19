import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/routine.dart';
import '../models/library_exercise.dart';
import '../providers/gym_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class RoutineEditorScreen extends StatefulWidget {
  final Routine? initialRoutine;

  const RoutineEditorScreen({super.key, this.initialRoutine});

  @override
  State<RoutineEditorScreen> createState() => _RoutineEditorScreenState();
}

class _RoutineEditorScreenState extends State<RoutineEditorScreen> {
  final _uuid = const Uuid();
  late TextEditingController _nameController;
  late List<RoutineExercise> _exercises;
  late List<int> _daysOfWeek;

  final List<String> _days = ['D', 'L', 'M', 'M', 'J', 'V', 'S'];
  final List<String> _setTypes = ['Normal', 'Calentamiento', 'Drop Set', 'Fallo'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialRoutine?.name ?? '');
    _exercises = widget.initialRoutine != null ? List.from(widget.initialRoutine!.exercises) : [];
    _daysOfWeek = widget.initialRoutine != null ? List.from(widget.initialRoutine!.daysOfWeek) : [];
  }

  void _saveRoutine() {
    if (_nameController.text.isEmpty) return;
    final r = Routine(
      id: widget.initialRoutine?.id ?? _uuid.v4(),
      name: _nameController.text,
      daysOfWeek: _daysOfWeek,
      exercises: _exercises,
    );
    context.read<GymProvider>().addRoutine(r);
    Navigator.pop(context);
  }

  void _addExercise() {
    final gym = context.read<GymProvider>();
    final lib = gym.libraryExercises;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: AppTheme.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.white.withOpacity(0.1), borderRadius: BorderRadius.circular(2))),
              const Padding(
                padding: EdgeInsets.all(24),
                child: Text('ELIGE UN EJERCICIO', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 1)),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: lib.length,
                  itemBuilder: (context, index) {
                    final ex = lib[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _exercises.add(RoutineExercise(
                              id: _uuid.v4(),
                              name: ex.name,
                              muscleGroup: ex.muscleGroup,
                              category: ex.category,
                              sets: [RoutineSet(reps: 10, type: 'Normal')],
                            ));
                          });
                          Navigator.pop(context);
                        },
                        child: GlassCard(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              Container(
                                width: 40, height: 40,
                                decoration: BoxDecoration(color: AppTheme.accent.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                                child: const Icon(Icons.add_rounded, color: AppTheme.accent, size: 20),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text(ex.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                                  Text(ex.muscleGroup.toUpperCase(), style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: AppTheme.accent, letterSpacing: 1)),
                                ]),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 100,
            backgroundColor: AppTheme.background,
            flexibleSpace: const FlexibleSpaceBar(
              title: Text('ESTRUCTURA DE RUTINA', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 16)),
              centerTitle: false,
              titlePadding: EdgeInsets.only(left: 56, bottom: 16),
            ),
            actions: [
              TextButton(onPressed: _saveRoutine, child: const Text('GUARDAR', style: TextStyle(color: AppTheme.accent, fontWeight: FontWeight.w900))),
              const SizedBox(width: 8),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SectionTitle(title: 'NOMBRE DE LA RUTINA'),
                const SizedBox(height: 12),
                GlassCard(
                  child: TextField(
                    controller: _nameController,
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                    decoration: const InputDecoration(border: InputBorder.none, filled: false, hintText: 'Ej: Empuje Pesado', contentPadding: EdgeInsets.zero),
                  ),
                ),
                const SizedBox(height: 24),
                const SectionTitle(title: 'DÍAS PROGRAMADOS'),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(7, (i) => GestureDetector(
                    onTap: () => setState(() => _daysOfWeek.contains(i) ? _daysOfWeek.remove(i) : _daysOfWeek.add(i)),
                    child: Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: _daysOfWeek.contains(i) ? AppTheme.accent : AppTheme.white.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _daysOfWeek.contains(i) ? AppTheme.accent : AppTheme.white.withOpacity(0.05)),
                      ),
                      child: Center(child: Text(_days[i], style: TextStyle(fontWeight: FontWeight.w900, color: _daysOfWeek.contains(i) ? Colors.white : AppTheme.textSecondary))),
                    ),
                  )),
                ),
                const SizedBox(height: 32),
                const SectionTitle(title: 'EJERCICIOS Y SERIES'),
                const SizedBox(height: 12),
                ..._exercises.asMap().entries.map((e) => _buildExerciseTile(e.key, e.value)),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _addExercise,
                  icon: const Icon(Icons.library_add_rounded, size: 20),
                  label: const Text('AÑADIR DESDE BIBLIOTECA'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.white.withOpacity(0.04), minimumSize: const Size(double.infinity, 56)),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseTile(int exIdx, RoutineExercise ex) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(width: 40, height: 40, decoration: BoxDecoration(color: AppTheme.accent.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.fitness_center_rounded, color: AppTheme.accent, size: 20)),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(ex.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                  Text(ex.muscleGroup.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, color: AppTheme.accent, fontSize: 8, letterSpacing: 1)),
                ])),
                IconButton(icon: const Icon(Icons.remove_circle_outline_rounded, color: AppTheme.textSecondary.withOpacity(0.3), size: 20), onPressed: () => setState(() => _exercises.removeAt(exIdx))),
              ],
            ),
            const SizedBox(height: 16),
            ...ex.sets.asMap().entries.map((sEntry) => _buildSetRow(ex, exIdx, sEntry.key, sEntry.value)),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () => setState(() => ex.sets.add(RoutineSet(reps: 10, type: 'Normal'))),
              icon: const Icon(Icons.add_circle_outline, size: 16),
              label: const Text('AÑADIR SERIE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900)),
              style: TextButton.styleFrom(foregroundColor: AppTheme.accent),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSetRow(RoutineExercise ex, int exIdx, int sIdx, RoutineSet set) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 24, height: 24,
            decoration: BoxDecoration(color: AppTheme.white.withOpacity(0.05), shape: BoxShape.circle),
            child: Center(child: Text('${sIdx + 1}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.textSecondary))),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(color: AppTheme.white.withOpacity(0.04), borderRadius: BorderRadius.circular(8)),
              child: DropdownButton<String>(
                value: _setTypes.contains(set.type) ? set.type : 'Normal',
                isExpanded: true,
                underline: const SizedBox(),
                dropdownColor: AppTheme.surfaceElevated,
                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                items: _setTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (val) => setState(() => set.type = val!),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 1,
            child: _buildRepsInput(set.reps.toString(), (val) => set.reps = int.tryParse(val) ?? 10),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.close, size: 14, color: AppTheme.textSecondary),
            onPressed: () => setState(() => ex.sets.removeAt(sIdx)),
          ),
        ],
      ),
    );
  }

  Widget _buildRepsInput(String initial, Function(String) onChanged) {
    return Container(
      height: 36,
      child: TextFormField(
        initialValue: initial,
        keyboardType: TextInputType.number,
        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          filled: true, fillColor: AppTheme.white.withOpacity(0.04),
          contentPadding: EdgeInsets.zero,
          hintText: 'Reps',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
