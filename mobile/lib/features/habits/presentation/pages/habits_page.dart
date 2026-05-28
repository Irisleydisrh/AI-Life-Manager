import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/shared/components/components.dart';

class HabitsPage extends StatefulWidget {
  const HabitsPage({super.key});

  @override
  State<HabitsPage> createState() => _HabitsPageState();
}

class _HabitsPageState extends State<HabitsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _habits = [
    {
      'id': '1',
      'name': 'Ejercicio',
      'frequency': 'Diario',
      'streak': 5,
      'completionRate': 0.7,
      'completedToday': true,
    },
    {
      'id': '2',
      'name': 'Meditación',
      'frequency': 'Diario',
      'streak': 12,
      'completionRate': 0.9,
      'completedToday': true,
    },
    {
      'id': '3',
      'name': 'Lectura',
      'frequency': 'Días laborales',
      'streak': 3,
      'completionRate': 0.5,
      'completedToday': false,
    },
    {
      'id': '4',
      'name': 'Beber agua',
      'frequency': 'Diario',
      'streak': 15,
      'completionRate': 0.85,
      'completedToday': false,
    },
    {
      'id': '5',
      'name': 'Dormir temprano',
      'frequency': 'Diario',
      'streak': 7,
      'completionRate': 0.6,
      'completedToday': true,
    },
  ];

  // Simular carga de datos
  Future<void> _refreshHabits() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  // Contenido con skeleton y empty state
  Widget get _contentBuilder {
    if (_isLoading) {
      return _buildSkeletonLoader();
    }

    if (_habits.isEmpty) {
      return _buildEmptyState();
    }

    return _buildHabitsList();
  }

  Widget _buildSkeletonLoader() {
    return Shimmer.fromColors(
      baseColor: AppColors.darkSurfaceAlt,
      highlightColor: AppColors.darkBorder,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 4,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.darkSurfaceAlt,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.check_circle_outline_rounded,
                size: 40,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Sin hábitos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Los hábitos positivos transforman tu día',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text('Crear Hábito'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitsList() {
    return RefreshIndicator(
      onRefresh: _refreshHabits,
      color: AppColors.accentPrimary,
      backgroundColor: AppColors.darkSurface,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _habits.length,
        itemBuilder: (context, index) {
          return _buildHabitCard(_habits[index], isToday: false);
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  double get _overallCompletion {
    final completed = _habits.where((h) => h['completedToday']).length;
    return completed / _habits.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text('Hábitos'),
        backgroundColor: AppColors.darkBackground,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.accentPrimary,
          labelColor: AppColors.accentPrimary,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(text: 'Hoy'),
            Tab(text: 'Todos'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Completion summary
          _buildCompletionSummary(),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildTodayTab(), _buildAllHabitsTab()],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddHabitDialog,
        backgroundColor: AppColors.accentPrimary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCompletionSummary() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.gradientPrimary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Progreso de Hoy',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_habits.where((h) => h['completedToday']).length}/${_habits.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: _overallCompletion,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(_overallCompletion * 100).toInt()}% completado',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayTab() {
    final todayHabits = _habits.take(5).toList();
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: todayHabits.length,
      itemBuilder: (context, index) {
        return _buildHabitCard(todayHabits[index], isToday: true);
      },
    );
  }

  Widget _buildAllHabitsTab() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _habits.length,
      itemBuilder: (context, index) {
        return _buildHabitCard(_habits[index], isToday: false);
      },
    );
  }

  Widget _buildHabitCard(Map<String, dynamic> habit, {required bool isToday}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: isToday ? () => _toggleHabit(habit) : null,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Completion checkbox (only for today)
                if (isToday)
                  GestureDetector(
                    onTap: () => _toggleHabit(habit),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: habit['completedToday']
                            ? AppColors.accentGreen
                            : Colors.transparent,
                        border: Border.all(
                          color: habit['completedToday']
                              ? AppColors.accentGreen
                              : AppColors.darkBorder,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: habit['completedToday']
                          ? const Icon(
                              Icons.check,
                              size: 18,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ),
                if (isToday) const SizedBox(width: 16),

                // Habit info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habit['name'],
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          decoration: isToday && habit['completedToday']
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        habit['frequency'],
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                // Streak badge
                if (habit['streak'] > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accentOrange.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.local_fire_department,
                          size: 14,
                          color: AppColors.accentOrange,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${habit['streak']}',
                          style: const TextStyle(
                            color: AppColors.accentOrange,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _toggleHabit(Map<String, dynamic> habit) {
    setState(() {
      habit['completedToday'] = !habit['completedToday'];
      if (habit['completedToday']) {
        habit['streak'] = (habit['streak'] as int) + 1;
      }
    });
  }

  void _showAddHabitDialog() {
    final nameController = TextEditingController();
    String frequency = 'Diario';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nuevo Hábito',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: nameController,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: const InputDecoration(
                      labelText: 'Nombre del hábito',
                      labelStyle: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Frecuencia',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ['Diario', 'Días laborales', 'Semanal']
                        .map(
                          (f) => GestureDetector(
                            onTap: () => setModalState(() => frequency = f),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: frequency == f
                                    ? AppColors.accentPrimary.withOpacity(0.2)
                                    : AppColors.darkSurfaceAlt,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: frequency == f
                                      ? AppColors.accentPrimary
                                      : AppColors.darkBorder,
                                ),
                              ),
                              child: Text(
                                f,
                                style: TextStyle(
                                  color: frequency == f
                                      ? AppColors.accentPrimary
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: AppColors.gradientPrimary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          if (nameController.text.isNotEmpty) {
                            setState(() {
                              _habits.add({
                                'id': DateTime.now().toString(),
                                'name': nameController.text,
                                'frequency': frequency,
                                'streak': 0,
                                'completionRate': 0.0,
                                'completedToday': false,
                              });
                            });
                            Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                        ),
                        child: const Text('Agregar Hábito'),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
