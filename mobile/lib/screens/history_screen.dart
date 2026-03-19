import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/gym_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gym = context.watch<GymProvider>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            backgroundColor: AppTheme.background,
            flexibleSpace: const FlexibleSpaceBar(
              title: Text('HISTORIAL', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2)),
              centerTitle: false,
              titlePadding: EdgeInsets.only(left: 56, bottom: 20),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (gym.workouts.isEmpty)
                  _buildEmptyState()
                else
                  ...gym.workouts.map((w) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildWorkoutHistoryCard(context, gym, w),
                  )),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutHistoryCard(BuildContext context, GymProvider gym, dynamic w) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.all(20),
          iconColor: AppTheme.accent,
          collapsedIconColor: AppTheme.textSecondary,
          title: Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(color: AppTheme.accent.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.history_rounded, color: AppTheme.accent, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(w.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                  Text(DateFormat('dd MMMM yyyy • HH:mm', 'es').format(w.date).toUpperCase(), style: const TextStyle(color: AppTheme.textSecondary, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1)),
                ]),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 12, left: 60),
            child: Row(
              children: [
                _miniStat(Icons.fitness_center_rounded, '${w.exercises.length} EJ.'),
                const SizedBox(width: 16),
                _miniStat(Icons.trending_up_rounded, '${(w.totalVolume / 1000).toStringAsFixed(1)}k KG'),
              ],
            ),
          ),
          children: [
            const Divider(height: 1, color: AppTheme.white05),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   ...w.exercises.map<Widget>((ex) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.circle, size: 6, color: AppTheme.accent),
                            const SizedBox(width: 10),
                            Text(ex.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: ex.sets.map<Widget>((s) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: AppTheme.white.withOpacity(0.03), borderRadius: BorderRadius.circular(6)),
                              child: Text('${s.weight}kg x ${s.reps}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10, fontWeight: FontWeight.bold)),
                            )).toList(),
                          ),
                        ),
                      ],
                    ),
                  )).toList(),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => gym.deleteWorkout(w.id),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(Icons.delete_outline_rounded, color: AppTheme.danger, size: 16),
                        SizedBox(width: 4),
                        Text('ELIMINAR REGISTRO', style: TextStyle(color: AppTheme.danger, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniStat(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 12, color: AppTheme.accent.withOpacity(0.5)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
      ],
    );
  }

  Widget _buildEmptyState() {
     return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(Icons.history_rounded, size: 48, color: AppTheme.textSecondary.withOpacity(0.2)),
            const SizedBox(height: 16),
            const Text('Aún no hay registros en el historial', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
