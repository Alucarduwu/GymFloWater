import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/gym_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gym = context.watch<GymProvider>();
    final monthlyStats = _calculateMonthlyVolume(gym.workouts);
    final thisWeekVol = gym.thisWeekVolume;
    final lastWeekVol = gym.lastWeekVolume;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            backgroundColor: AppTheme.background,
            flexibleSpace: const FlexibleSpaceBar(
              title: Text('ESTADÍSTICAS', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2)),
              centerTitle: false,
              titlePadding: EdgeInsets.only(left: 56, bottom: 20),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildComparisonCard(thisWeekVol, lastWeekVol),
                const SizedBox(height: 24),
                _buildVolumeByMonthChart(monthlyStats),
                const SizedBox(height: 32),
                const SectionTitle(title: 'RESUMEN MENSUAL'),
                const SizedBox(height: 12),
                if (monthlyStats.isEmpty)
                   const Center(child: Padding(
                     padding: EdgeInsets.symmetric(vertical: 40),
                     child: Text('No hay datos suficientes', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                   ))
                else
                  ...monthlyStats.reversed.map((s) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GlassCard(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(s.monthName.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 0.5)),
                              Text('${s.count} ENTRENAMIENTOS', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1)),
                            ],
                          ),
                          Text(
                            '${(s.volume / 1000).toStringAsFixed(1)}k kg',
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

  Widget _buildComparisonCard(double current, double last) {
    bool up = current >= last;
    double diff = last == 0 ? 0 : ((current - last) / last * 100);

    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('COMPARATIVA SEMANAL', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: AppTheme.textSecondary, letterSpacing: 1.5)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _compareCol('ESTA SEMANA', '${(current / 1000).toStringAsFixed(1)}k kg', AppTheme.accent),
              Container(width: 1, height: 40, color: AppTheme.white.withOpacity(0.05)),
              _compareCol('SEMANA PASADA', '${(last / 1000).toStringAsFixed(1)}k kg', AppTheme.textSecondary),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Icon(up ? Icons.trending_up_rounded : Icons.trending_down_rounded, color: up ? AppTheme.success : AppTheme.danger, size: 20),
              const SizedBox(width: 8),
              Text(
                '${up ? '+' : ''}${diff.toStringAsFixed(1)}% vs semana anterior',
                style: TextStyle(color: up ? AppTheme.success : AppTheme.danger, fontWeight: FontWeight.w900, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _compareCol(String label, String val, Color c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: AppTheme.textSecondary, letterSpacing: 1)),
        const SizedBox(height: 4),
        Text(val, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: c)),
      ],
    );
  }

  Widget _buildVolumeByMonthChart(List<_MonthlyStat> stats) {
    if (stats.isEmpty) return const SizedBox.shrink();

    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'VOLUMEN TOTAL POR MES (KG)',
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
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: stats.isEmpty ? 100 : (stats.map((s) => s.volume).reduce((a, b) => a > b ? a : b) * 1.2),
                barGroups: stats.asMap().entries.map((e) {
                  return BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                        toY: e.value.volume,
                        color: AppTheme.accent,
                        width: 20,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: stats.map((s) => s.volume).reduce((a, b) => a > b ? a : b) * 1.2,
                          color: AppTheme.white.withOpacity(0.03),
                        ),
                      ),
                    ],
                  );
                }).toList(),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (val, _) {
                        final idx = val.toInt();
                        if (idx < 0 || idx >= stats.length) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: Text(
                            stats[idx].label,
                            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 8, fontWeight: FontWeight.w900),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<_MonthlyStat> _calculateMonthlyVolume(List<dynamic> workouts) {
    final Map<String, _MonthlyStat> stats = {};
    final dateFormat = DateFormat('MMM yy', 'es');
    final monthNameFormat = DateFormat('MMMM yyyy', 'es');

    for (var w in workouts) {
      final key = '${w.date.year}-${w.date.month}';
      if (!stats.containsKey(key)) {
        stats[key] = _MonthlyStat(
          label: dateFormat.format(w.date).toUpperCase(),
          monthName: monthNameFormat.format(w.date),
          volume: 0,
          count: 0,
        );
      }
      stats[key]!.volume += (w.totalVolume as double);
      stats[key]!.count += 1;
    }

    final sorted = stats.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    
    return sorted.map((e) => e.value).toList();
  }
}

class _MonthlyStat {
  final String label;
  final String monthName;
  double volume;
  int count;

  _MonthlyStat({
    required this.label,
    required this.monthName,
    required this.volume,
    required this.count,
  });
}
