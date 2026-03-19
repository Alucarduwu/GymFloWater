import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/gym_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class ExerciseProgressScreen extends StatefulWidget {
  final String exerciseName;
  const ExerciseProgressScreen({super.key, required this.exerciseName});

  @override
  State<ExerciseProgressScreen> createState() => _ExerciseProgressScreenState();
}

class _ExerciseProgressScreenState extends State<ExerciseProgressScreen> {
  @override
  Widget build(BuildContext context) {
    final gym = context.watch<GymProvider>();
    final data = _getExerciseData(gym.workouts, widget.exerciseName);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            backgroundColor: AppTheme.background,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(widget.exerciseName.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 16)),
              centerTitle: false,
              titlePadding: const EdgeInsets.only(left: 56, bottom: 20),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildProgressChart(data),
                const SizedBox(height: 32),
                const SectionTitle(title: 'HISTORIAL DE PESO'),
                const SizedBox(height: 12),
                if (data.isEmpty)
                   const Center(child: Padding(
                     padding: EdgeInsets.symmetric(vertical: 40),
                     child: Text('No hay registros para este ejercicio', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                   ))
                else
                  ...data.reversed.map((d) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: GlassCard(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(DateFormat('dd MMMM yyyy', 'es').format(d.date).toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.5)),
                              Text(DateFormat('HH:mm').format(d.date), style: const TextStyle(color: AppTheme.textSecondary, fontSize: 9, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Text(
                            '${d.weight.toStringAsFixed(1)} kg',
                            style: const TextStyle(fontWeight: FontWeight.w900, color: AppTheme.accent, fontSize: 18),
                          ),
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

  Widget _buildProgressChart(List<_ExerciseEntry> data) {
    if (data.length < 2) {
      return const GlassCard(
        padding: EdgeInsets.all(40),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.show_chart_rounded, size: 48, color: AppTheme.white05),
              SizedBox(height: 16),
              Text('Necesitas al menos 2 registros para ver progreso', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      );
    }

    final spots = data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.weight)).toList();

    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PROGRESO DE CARGA (KG)',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppTheme.accent,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                        radius: 5,
                        color: AppTheme.accent,
                        strokeWidth: 3,
                        strokeColor: AppTheme.surfaceElevated,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [AppTheme.accent.withOpacity(0.3), AppTheme.accent.withOpacity(0)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<_ExerciseEntry> _getExerciseData(List<dynamic> workouts, String name) {
    final List<_ExerciseEntry> entries = [];
    final sorted = [...workouts]..sort((a, b) => a.date.compareTo(b.date));
    
    for (var w in sorted) {
      for (var ex in w.exercises) {
        if (ex.name.toLowerCase() == name.toLowerCase()) {
          entries.add(_ExerciseEntry(date: w.date, weight: ex.maxWeight));
        }
      }
    }
    return entries;
  }
}

class _ExerciseEntry {
  final DateTime date;
  final double weight;
  _ExerciseEntry({required this.date, required this.weight});
}
