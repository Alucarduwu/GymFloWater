import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/routine.dart';
import '../providers/gym_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'workout_logger_screen.dart';
import 'routine_editor_screen.dart';
import 'exercise_library_screen.dart';

class RoutineManagerScreen extends StatefulWidget {
  const RoutineManagerScreen({super.key});

  @override
  State<RoutineManagerScreen> createState() => _RoutineManagerScreenState();
}

class _RoutineManagerScreenState extends State<RoutineManagerScreen> {
  @override
  Widget build(BuildContext context) {
    final gym = context.watch<GymProvider>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: true,
            backgroundColor: AppTheme.background.withOpacity(0.8),
            flexibleSpace: const FlexibleSpaceBar(
              title: Text('MIS RUTINAS', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2)),
              centerTitle: false,
              titlePadding: EdgeInsets.only(left: 20, bottom: 20),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.library_books_rounded, color: AppTheme.textSecondary, size: 22),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExerciseLibraryScreen())),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline_rounded, color: AppTheme.accent, size: 28),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RoutineEditorScreen())),
              ),
              const SizedBox(width: 10),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (gym.routines.isEmpty) _buildEmptyState() 
                else ...gym.routines.map((r) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildRoutineCard(context, gym, r),
                )),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoutineCard(BuildContext context, GymProvider gym, Routine routine) {
    final days = ['D', 'L', 'M', 'M', 'J', 'V', 'S'];
    
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => WorkoutLoggerScreen(routine: routine))),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(color: AppTheme.accent.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.play_arrow_rounded, color: AppTheme.accent, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(routine.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                    Text('${routine.exercises.length} EJERCICIOS', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
                  ]),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: AppTheme.textSecondary, size: 18),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RoutineEditorScreen(initialRoutine: routine))),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.textSecondary, size: 18),
                  onPressed: () => gym.deleteRoutine(routine.id),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: List.generate(7, (i) {
                bool isActive = routine.daysOfWeek.contains(i);
                return Container(
                  margin: const EdgeInsets.only(right: 6),
                  width: 24, height: 24,
                  decoration: BoxDecoration(
                    color: isActive ? AppTheme.accent.withOpacity(0.2) : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: isActive ? AppTheme.accent : AppTheme.white.withOpacity(0.05)),
                  ),
                  child: Center(child: Text(days[i], style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: isActive ? AppTheme.accent : AppTheme.textSecondary.withOpacity(0.3)))),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(Icons.list_alt_rounded, size: 48, color: AppTheme.textSecondary.withOpacity(0.2)),
            const SizedBox(height: 16),
            const Text('Sin rutinas guardadas', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RoutineEditorScreen())),
              child: const Text('CREAR MI PRIMERA RUTINA'),
            ),
          ],
        ),
      ),
    );
  }
}
