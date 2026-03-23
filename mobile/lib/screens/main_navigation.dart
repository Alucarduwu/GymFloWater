import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:gymflow/providers/gym_provider.dart';
import 'package:gymflow/theme/app_theme.dart';
import 'package:gymflow/widgets/common_widgets.dart';
import 'package:gymflow/screens/dashboard_screen.dart';
import 'package:gymflow/screens/routine_manager_screen.dart';
import 'package:gymflow/screens/workout_logger_screen.dart';
import 'package:gymflow/screens/statistics_screen.dart';
import 'package:gymflow/screens/history_screen.dart';
import 'package:gymflow/screens/exercise_progress_screen.dart';
import 'package:gymflow/screens/routine_editor_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const RoutineManagerScreen(),
    const StatisticsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
          _buildBottomNav(context),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(top: 24.0),
        child: FloatingActionButton(
          elevation: 12,
          backgroundColor: AppTheme.accent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: const Icon(Icons.add_rounded, size: 36, color: Colors.white),
          onPressed: () => _showRoutineSelector(context, context.read<GymProvider>()),
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Positioned(
      bottom: bottomPadding > 0 ? bottomPadding : 16,
      left: 16,
      right: 16,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          borderRadius: 32,
          borderColor: AppTheme.white.withOpacity(0.05),
          child: SizedBox(
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _navItem(0, Icons.dashboard_rounded, 'INICIO'),
                _navItem(1, Icons.list_alt_rounded, 'RUTINAS'),
                const SizedBox(width: 64),
                _navItem(2, Icons.bar_chart_rounded, 'STATS'),
                _navItem(3, Icons.person_rounded, 'PERFIL'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    bool isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? AppTheme.accent : AppTheme.textSecondary,
            size: isActive ? 24 : 20,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: isActive ? AppTheme.accent : AppTheme.textSecondary,
              fontSize: 8,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
        ],
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
                child: Text('¿QUÉ VAMOS A ENTRENAR HOY?', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
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
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  void _editProfile(BuildContext context, GymProvider gym) {
    final nameController = TextEditingController(text: gym.userName);
    String selectedGender = gym.userGender;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.surfaceElevated,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          title: const Text('EDITAR PERFIL', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nombre Completo'),
              ),
              const SizedBox(height: 24),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('GÉNERO', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.accent, letterSpacing: 1.5)),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _genderOption('hombre', '👨', selectedGender, (val) => setDialogState(() => selectedGender = val)),
                  _genderOption('mujer', '👩', selectedGender, (val) => setDialogState(() => selectedGender = val)),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR', style: TextStyle(color: AppTheme.textSecondary))),
            ElevatedButton(
              onPressed: () {
                gym.updateProfile(nameController.text, selectedGender);
                Navigator.pop(context);
              },
              child: const Text('GUARDAR'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _genderOption(String value, String emoji, String current, Function(String) onTap) {
    bool isSelected = current == value;
    return GestureDetector(
      onTap: () => onTap(value),
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.accent.withOpacity(0.1) : AppTheme.white05,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppTheme.accent : AppTheme.white05, width: 2),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 8),
            Text(value.toUpperCase(), style: TextStyle(color: isSelected ? AppTheme.accent : AppTheme.textSecondary, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gym = context.watch<GymProvider>();
    final records = gym.personalRecords;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppTheme.background,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.accent.withOpacity(0.1), AppTheme.background],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      GestureDetector(
                        onTap: () => _editProfile(context, gym),
                        child: Stack(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceElevated,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppTheme.accent, width: 3),
                                boxShadow: [BoxShadow(color: AppTheme.accent.withOpacity(0.3), blurRadius: 20)],
                              ),
                              child: Center(child: Text(gym.userGender == 'mujer' ? '👩' : '👨', style: const TextStyle(fontSize: 50))),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(color: AppTheme.accent, shape: BoxShape.circle),
                                child: const Icon(Icons.edit_rounded, size: 16, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(gym.userName.toUpperCase(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 1)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen())),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    decoration: BoxDecoration(
                      color: AppTheme.white.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppTheme.white.withOpacity(0.1)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.history_rounded, color: AppTheme.accent),
                            SizedBox(width: 16),
                            Text(
                              'HISTORIAL DE ENTRENAMIENTOS',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                        Icon(Icons.arrow_forward_ios_rounded, color: AppTheme.textSecondary, size: 14),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                const SectionTitle(title: 'RÉCORDS PERSONALES (MAX KG)'),
                const SizedBox(height: 12),
                if (records.isEmpty)
                  const Center(child: Text('Aún no hay récords registrados', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)))
                else
                  ...records.entries.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ExerciseProgressScreen(exerciseName: e.key))),
                      child: GlassCard(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(e.key, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                            Text('${e.value.toStringAsFixed(1)} kg', style: const TextStyle(fontWeight: FontWeight.w900, color: AppTheme.accent, fontSize: 18)),
                          ],
                        ),
                      ),
                    ),
                  )),
                const SizedBox(height: 60),
                Center(
                  child: GestureDetector(
                    onTap: () async {
                      final url = Uri.parse('https://www.linkedin.com/in/anahi-lozano-de-lira-a4213a187');
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url, mode: LaunchMode.externalApplication);
                      }
                    },
                    child: Text(
                      'A.B.L.DL (C)', 
                      style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 2)
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
