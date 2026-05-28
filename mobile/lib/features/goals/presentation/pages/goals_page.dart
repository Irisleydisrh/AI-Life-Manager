import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/shared/components/components.dart';

class GoalsPage extends StatefulWidget {
  const GoalsPage({super.key});

  @override
  State<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  bool _isLoading = false;

  final List<Map<String, dynamic>> _goals = [
    {
      'id': '1',
      'title': 'Ahorrar \$5000',
      'description': 'Fondo de emergencia',
      'currentValue': 3250.0,
      'targetValue': 5000.0,
      'category': 'Finanzas',
      'deadline': '2026-12-31',
      'milestones': [
        {'value': 1000.0, 'label': 'Primera meta', 'achieved': true},
        {'value': 2500.0, 'label': 'Mitad de camino', 'achieved': true},
        {'value': 5000.0, 'label': 'Meta completa', 'achieved': false},
      ],
    },
    {
      'id': '2',
      'title': 'Leer 20 libros',
      'description': 'Desarrollo personal',
      'currentValue': 8.0,
      'targetValue': 20.0,
      'category': 'Educación',
      'deadline': '2026-12-31',
      'milestones': [
        {'value': 5.0, 'label': '5 libros', 'achieved': true},
        {'value': 10.0, 'label': '10 libros', 'achieved': false},
        {'value': 20.0, 'label': '20 libros', 'achieved': false},
      ],
    },
    {
      'id': '3',
      'title': 'Run a marathon',
      'description': 'Maratón de Buenos Aires',
      'currentValue': 15.0,
      'targetValue': 42.195,
      'category': 'Salud',
      'deadline': '2026-09-20',
      'milestones': [
        {'value': 10.0, 'label': '10K', 'achieved': true},
        {'value': 21.0, 'label': 'Media maratón', 'achieved': false},
        {'value': 42.195, 'label': 'Maratón', 'achieved': false},
      ],
    },
  ];

  // Simular carga de datos
  Future<void> _refreshGoals() async {
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

    if (_goals.isEmpty) {
      return _buildEmptyState();
    }

    return _buildGoalsList();
  }

  Widget _buildSkeletonLoader() {
    return Shimmer.fromColors(
      baseColor: AppColors.darkSurfaceAlt,
      highlightColor: AppColors.darkBorder,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 3,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Container(
            height: 150,
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
                Icons.flag_rounded,
                size: 40,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Sin metas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'El primer paso hacia tus sueños',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _showAddGoalDialog,
              icon: const Icon(Icons.add),
              label: const Text('Crear Meta'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalsList() {
    return RefreshIndicator(
      onRefresh: _refreshGoals,
      color: AppColors.accentPrimary,
      backgroundColor: AppColors.darkSurface,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _goals.length,
        itemBuilder: (context, index) {
          return _buildGoalCard(_goals[index]);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text('Metas'),
        backgroundColor: AppColors.darkBackground,
      ),
      body: _contentBuilder,
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddGoalDialog,
        backgroundColor: AppColors.accentPrimary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildGoalCard(Map<String, dynamic> goal) {
    final progress =
        (goal['currentValue'] as double) / (goal['targetValue'] as double);
    final categoryColor = _getCategoryColor(goal['category']);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: categoryColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getCategoryIcon(goal['category']),
                  color: categoryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal['title'],
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      goal['description'],
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              CategoryBadge(label: goal['category'], color: categoryColor),
            ],
          ),
          const SizedBox(height: 20),

          // Progress bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${goal['currentValue'].toStringAsFixed(0)} / ${goal['targetValue'].toStringAsFixed(0)}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  color: categoryColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          AnimatedProgressBar(
            progress: progress.clamp(0.0, 1.0),
            gradient: LinearGradient(
              colors: [categoryColor, categoryColor.withOpacity(0.7)],
            ),
            height: 10,
          ),
          const SizedBox(height: 20),

          // Milestones
          const Text(
            'Hitos',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: (goal['milestones'] as List).map((milestone) {
              final isAchieved = milestone['achieved'] as bool;
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isAchieved
                      ? AppColors.accentGreen.withOpacity(0.15)
                      : AppColors.darkSurfaceAlt,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isAchieved
                        ? AppColors.accentGreen
                        : AppColors.darkBorder,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isAchieved
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      size: 14,
                      color: isAchieved
                          ? AppColors.accentGreen
                          : AppColors.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      milestone['label'],
                      style: TextStyle(
                        color: isAchieved
                            ? AppColors.accentGreen
                            : AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight:
                            isAchieved ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Update progress button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _showUpdateProgressDialog(goal),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: categoryColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Actualizar Progreso',
                style: TextStyle(color: categoryColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Finanzas':
        return AppColors.accentGreen;
      case 'Educación':
        return AppColors.accentSecondary;
      case 'Salud':
        return AppColors.accentOrange;
      default:
        return AppColors.accentPrimary;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Finanzas':
        return Icons.account_balance_wallet;
      case 'Educación':
        return Icons.menu_book;
      case 'Salud':
        return Icons.fitness_center;
      default:
        return Icons.flag;
    }
  }

  void _showAddGoalDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final targetController = TextEditingController();
    String category = 'Personal';

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
                    'Nueva Meta',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: titleController,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: const InputDecoration(
                      labelText: 'Título de la meta',
                      labelStyle: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: const InputDecoration(
                      labelText: 'Descripción',
                      labelStyle: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: targetController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: const InputDecoration(
                      labelText: 'Valor objetivo',
                      labelStyle: TextStyle(color: AppColors.textSecondary),
                    ),
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
                          if (titleController.text.isNotEmpty &&
                              targetController.text.isNotEmpty) {
                            setState(() {
                              _goals.add({
                                'id': DateTime.now().toString(),
                                'title': titleController.text,
                                'description': descriptionController.text,
                                'currentValue': 0.0,
                                'targetValue':
                                    double.tryParse(targetController.text) ??
                                        100.0,
                                'category': category,
                                'deadline': '',
                                'milestones': [],
                              });
                            });
                            Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                        ),
                        child: const Text('Crear Meta'),
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

  void _showUpdateProgressDialog(Map<String, dynamic> goal) {
    final controller = TextEditingController(
      text: goal['currentValue'].toString(),
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Actualizar: ${goal['title']}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Nuevo valor',
                  labelStyle: const TextStyle(color: AppColors.textSecondary),
                  suffixText: '/ ${goal['targetValue']}',
                ),
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
                      final newValue = double.tryParse(controller.text);
                      if (newValue != null) {
                        setState(() {
                          goal['currentValue'] = newValue;
                        });
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                    ),
                    child: const Text('Actualizar'),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
