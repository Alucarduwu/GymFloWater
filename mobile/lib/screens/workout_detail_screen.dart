import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:gymflow/providers/gym_provider.dart';
import 'package:gymflow/models/workout.dart';
import 'package:gymflow/theme/app_theme.dart';
import 'package:gymflow/widgets/common_widgets.dart';
import 'package:gymflow/screens/workout_logger_screen.dart';

class WorkoutDetailScreen extends StatelessWidget {
  final Workout workout;

  const WorkoutDetailScreen({super.key, required this.workout});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 120,
            backgroundColor: AppTheme.background,
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: Colors.white70),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => WorkoutLoggerScreen(initialWorkout: workout)));
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: Colors.white70),
                onPressed: () {
                  context.read<GymProvider>().deleteWorkout(workout.id);
                  Navigator.pop(context);
                },
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                workout.name.toUpperCase(),
                style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 16),
              ),
              centerTitle: false,
              titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, color: AppTheme.accent, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        DateFormat('EEEE, d MMM yyyy • HH:mm', 'es').format(workout.date).toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const SectionTitle(title: 'EJERCICIOS REALIZADOS'),
                const SizedBox(height: 12),
                if (workout.exercises.isEmpty)
                  const Text('No se registraron ejercicios', style: TextStyle(color: AppTheme.textSecondary))
                else
                  ...workout.exercises.map((ex) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: GlassCard(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    ex.name.toUpperCase(),
                                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppTheme.accent, letterSpacing: 1),
                                  ),
                                  Text(
                                    '% ${ex.totalVolume.toStringAsFixed(1)} kg',
                                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppTheme.accent),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              ...ex.sets.map((set) => Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'SERIE ${ex.sets.indexOf(set) + 1} • ${set.type.toUpperCase()}',
                                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.textSecondary),
                                      ),
                                      Text(
                                        '${set.weight} kg  ×  ${set.reps} reps',
                                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                                      ),
                                    ],
                                  )),
                            ],
                          ),
                        ),
                      )),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
