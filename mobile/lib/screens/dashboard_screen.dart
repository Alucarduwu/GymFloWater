import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:gymflow/providers/gym_provider.dart';
import 'package:gymflow/theme/app_theme.dart';
import 'package:gymflow/widgets/common_widgets.dart';
import 'package:gymflow/models/workout.dart';
import 'package:gymflow/models/routine.dart';
import 'package:gymflow/screens/workout_logger_screen.dart';
import 'package:gymflow/screens/routine_editor_screen.dart';
import 'package:gymflow/screens/workout_detail_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final gym = context.watch<GymProvider>();
    final streak = gym.streak;
    final rank = gym.currentRank;
    final thisWeek = gym.thisWeekVolume;
    final today = DateTime.now().weekday % 7;
    

    final todayRoutines = gym.routines.where((r) => r.daysOfWeek.contains(today)).toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: _buildHeader(gym.userName, gym.userGender),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 10),
                  _buildBentoStats(streak, thisWeek, gym.workouts.length),
                  const SizedBox(height: 24),
                  _buildTrainingToday(todayRoutines, gym),
                  const SizedBox(height: 24),
                  _buildProgressSection(gym),
                  const SizedBox(height: 24),
                  _buildCalendarSection(gym.workoutDays),
                  const SizedBox(height: 24),
                  const SectionTitle(title: 'ENTRENAMIENTOS DEL DÍA SELECCIONADO'),
                  const SizedBox(height: 12),
                  if (gym.workouts.where((w) => isSameDay(w.date, _selectedDay ?? DateTime.now())).isEmpty) 
                    _buildEmptyState() 
                  else 
                    ...gym.workouts.where((w) => isSameDay(w.date, _selectedDay ?? DateTime.now())).map((w) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildWorkoutCard(context, w),
                  )),
                  const SizedBox(height: 48),
                  Center(
                    child: GestureDetector(
                      onTap: () async {
                        final url = Uri.parse('https://www.linkedin.com/in/anahi-lozano-de-lira-a4213a187');
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url, mode: LaunchMode.externalApplication);
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Text(
                          'A.B.L.DL (C)', 
                          style: TextStyle(color: AppTheme.textSecondary.withOpacity(0.2), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5)
                        ),
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String name, String gender) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'HOLA, ${name.toUpperCase()}',
                style: const TextStyle(
                  color: AppTheme.accent,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Bienvenido de vuelta',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.surfaceElevated,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.white.withOpacity(0.05)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                gender == 'mujer' ? '👩' : '👨',
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBentoStats(int streak, double volume, int totalWorkouts) {
    return Row(
      children: [
        Expanded(
          child: StatChip(
            label: 'Racha',
            value: '$streak Días',
            icon: Icons.local_fire_department_rounded,
            color: AppTheme.accentSecondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatChip(
            label: 'Kilos Reales',
            value: '${(volume).toStringAsFixed(1)} kg',
            icon: Icons.trending_up_rounded,
            color: AppTheme.accent,
          ),
        ),
      ],
    );
  }

  Widget _buildTrainingToday(List<Routine> routines, GymProvider gym) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SectionTitle(title: 'ENTRENAR HOY'),
            GestureDetector(
              onTap: () => _showRoutineSelector(context, gym),
              child: const Text('VER TODAS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.accent, letterSpacing: 1)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (routines.isEmpty)
          GestureDetector(
            onTap: () {
              _showRoutineSelector(context, gym);
            },
            child: GlassCard(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                   Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.add_rounded, color: AppTheme.accent, size: 28),
                  ),
                  const SizedBox(width: 20),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ELEGIR RUTINA', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                        Text('Sin rutina programada para hoy', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, color: AppTheme.textSecondary, size: 14),
                ],
              ),
            ),
          )
        else
          ...routines.map((r) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => WorkoutLoggerScreen(routine: r)),
                );
              },
              child: GlassCard(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.accent, AppTheme.accentSecondary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(Icons.play_arrow_rounded, color: Color(0xFF010204), size: 32),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(r.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                          Text('${r.exercises.length} EJERCICIOS • SUGERIDO', style: const TextStyle(color: AppTheme.accent, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )),
      ],
    );
  }

  Widget _buildProgressSection(GymProvider gym) {
    final spots = _getChartSpots(gym.workouts);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'ANÁLISIS DE PROGRESO'),
        const SizedBox(height: 12),
        GlassCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('PROMEDIO KILOS REALES', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppTheme.textSecondary, letterSpacing: 1.5)),
              const SizedBox(height: 24),
              SizedBox(
                height: 150,
                child: spots.isEmpty ? 
                  const Center(child: Text('Sin datos suficientes', style: TextStyle(color: AppTheme.textSecondary))) :
                  LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: false),
                      titlesData: const FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          gradient: const LinearGradient(colors: [AppTheme.accent, AppTheme.accentSecondary]),
                          barWidth: 6,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [AppTheme.accent.withOpacity(0.3), AppTheme.accentSecondary.withOpacity(0)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarSection(Set<DateTime> workoutDays) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'CALENDARIO'),
        const SizedBox(height: 12),
        GlassCard(
          padding: const EdgeInsets.all(12),
          child: TableCalendar(
            firstDay: DateTime.now().subtract(const Duration(days: 365)),
            lastDay: DateTime.now().add(const Duration(days: 30)),
            focusedDay: _focusedDay,
            calendarFormat: CalendarFormat.month,
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(color: AppTheme.accent.withOpacity(0.2), shape: BoxShape.circle, border: Border.all(color: AppTheme.accent)),
              selectedDecoration: const BoxDecoration(color: AppTheme.accent, shape: BoxShape.circle),
              markerDecoration: const BoxDecoration(color: AppTheme.accent, shape: BoxShape.circle),
              markersMaxCount: 1,
            ),
            selectedDayPredicate: (day) => isSameDay(_selectedDay ?? DateTime.now(), day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            eventLoader: (day) => workoutDays.contains(DateTime(day.year, day.month, day.day)) ? [true] : [],
          ),
        ),
      ],
    );
  }

  Widget _buildWorkoutCard(BuildContext context, Workout workout) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => WorkoutDetailScreen(workout: workout)));
      },
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.history_rounded, color: AppTheme.accent, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(workout.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(DateFormat('dd MMM • HH:mm').format(workout.date).toUpperCase(), 
                    style: const TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1)),
                ],
              ),
            ),
            Text('${(workout.totalVolume).toStringAsFixed(1)} kg', 
              style: const TextStyle(color: AppTheme.accent, fontWeight: FontWeight.w900, fontSize: 16)),
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
            Icon(Icons.waves_rounded, size: 48, color: AppTheme.textSecondary.withOpacity(0.2)),
            const SizedBox(height: 16),
            const Text('Aún no hay registros', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  void _showRoutineSelector(BuildContext context, GymProvider gym) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceElevated,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(24),
                child: Text('ELIGE UNA RUTINA', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
              ),
              if (gym.routines.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No tienes rutinas creadas', style: TextStyle(color: AppTheme.textSecondary)),
                )
              else
                ...gym.routines.map((r) => ListTile(
                  title: Text(r.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  subtitle: Text('${r.exercises.length} ejercicios', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.accent),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => WorkoutLoggerScreen(routine: r)));
                  },
                )),
              const Divider(color: Colors.white12),
              ListTile(
                leading: const Icon(Icons.add_rounded, color: AppTheme.accent),
                title: const Text('CREAR NUEVA RUTINA', style: TextStyle(color: AppTheme.accent, fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => RoutineEditorScreen()));
                },
              ),
            ],
          ),
        );
      },
    );
  }

  List<FlSpot> _getChartSpots(List<Workout> workouts) {
    if (workouts.isEmpty) return [];
    final sorted = [...workouts]..sort((a, b) => a.date.compareTo(b.date));
    final recent = sorted.length > 7 ? sorted.sublist(sorted.length - 7) : sorted;
    return recent.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.totalVolume)).toList();
  }
}
