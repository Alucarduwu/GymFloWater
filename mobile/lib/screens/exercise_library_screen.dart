import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/library_exercise.dart';
import '../providers/gym_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class ExerciseLibraryScreen extends StatefulWidget {
  const ExerciseLibraryScreen({super.key});

  @override
  State<ExerciseLibraryScreen> createState() => _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends State<ExerciseLibraryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final gym = context.watch<GymProvider>();
    final exercises = gym.libraryExercises.where((e) => 
      e.name.toLowerCase().contains(_searchQuery.toLowerCase()) || 
      e.muscleGroup.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            pinned: true,
            expandedHeight: 140,
            backgroundColor: AppTheme.background,
            flexibleSpace: const FlexibleSpaceBar(
              title: Text('BIBLIOTECA', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 16)),
              centerTitle: false,
              titlePadding: EdgeInsets.only(left: 56, bottom: 60),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    hintText: 'Buscar ejercicio o músculo...',
                    prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.accent, size: 20),
                    filled: true,
                    fillColor: AppTheme.white.withOpacity(0.04),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverAppBarDelegate(
              TabBar(
                controller: _tabController,
                indicatorColor: AppTheme.accent,
                labelColor: Colors.white,
                unselectedLabelColor: AppTheme.textSecondary,
                labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1),
                tabs: const [
                  Tab(text: 'SUPERIOR'),
                  Tab(text: 'INFERIOR'),
                  Tab(text: 'CORE'),
                ],
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildExerciseList(exercises.where((e) => e.category == 'Superior').toList(), gym),
            _buildExerciseList(exercises.where((e) => e.category == 'Inferior').toList(), gym),
            _buildExerciseList(exercises.where((e) => e.category == 'Core').toList(), gym),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context, gym),
        backgroundColor: AppTheme.accent,
        label: const Text('NUEVO EJERCICIO', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Colors.white)),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildExerciseList(List<LibraryExercise> list, GymProvider gym) {
    if (list.isEmpty) {
      return const Center(child: Text('No hay ejercicios en esta categoría', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)));
    }

    // Group by muscle group
    final Map<String, List<LibraryExercise>> grouped = {};
    for (var ex in list) {
      grouped.putIfAbsent(ex.muscleGroup, () => []).add(ex);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      children: grouped.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 12, top: 20),
              child: Text(entry.key.toUpperCase(), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: AppTheme.accent, letterSpacing: 2)),
            ),
            ...entry.value.map((ex) => _buildExerciseRow(ex, gym)),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildExerciseRow(LibraryExercise ex, GymProvider gym) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: AppTheme.white.withOpacity(0.03), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.fitness_center_rounded, color: AppTheme.textSecondary, size: 18),
            ),
            const SizedBox(width: 16),
            Expanded(child: Text(ex.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14))),
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: AppTheme.textSecondary, size: 18),
              onPressed: () => _showAddDialog(context, gym, initialExercise: ex),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.textSecondary, size: 18),
              onPressed: () => gym.deleteLibraryExercise(ex.id),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddDialog(BuildContext context, GymProvider gym, {LibraryExercise? initialExercise}) {
    String name = initialExercise?.name ?? '';
    String muscle = initialExercise?.muscleGroup ?? 'Pierna Completa';
    String category = initialExercise?.category ?? 'Inferior';

    final muscleGroups = [
      'Pierna Completa', 'Glúteo', 'Femoral', 'Abductor', 'Aductor', 
      'Pantorrilla', 'Abdomen', 'Trapecio', 'Bíceps', 'Antebrazo', 
      'Tríceps', 'Cuádriceps', 'Hombro', 'Espalda', 'Pecho'
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.surfaceElevated,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('NUEVO EJERCICIO', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: TextEditingController(text: name)..selection = TextSelection.fromPosition(TextPosition(offset: name.length)),
                onChanged: (v) => name = v,
                decoration: const InputDecoration(labelText: 'Nombre del ejercicio'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: category,
                items: ['Superior', 'Inferior', 'Core'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setDialogState(() => category = v!),
                decoration: const InputDecoration(labelText: 'Categoría'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: muscle,
                items: muscleGroups.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                onChanged: (v) => setDialogState(() => muscle = v!),
                decoration: const InputDecoration(labelText: 'Grupo Muscular'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR')),
            ElevatedButton(
              onPressed: () {
                if (name.isEmpty) return;
                final newEx = LibraryExercise(
                  id: initialExercise?.id ?? const Uuid().v4(), 
                  name: name, 
                  muscleGroup: muscle, 
                  category: category
                );
                // addLibraryExercise does an UPSERT (replace) if ID exists
                gym.addLibraryExercise(newEx);
                Navigator.pop(context);
              },
              child: Text(initialExercise != null ? 'GUARDAR' : 'AÑADIR'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);
  final TabBar _tabBar;
  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: AppTheme.background, child: _tabBar);
  }
  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}
