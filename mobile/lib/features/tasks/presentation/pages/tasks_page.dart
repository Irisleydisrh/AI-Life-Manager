import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/shared/components/components.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  String _filter = 'all';
  bool _isLoading = false;
  final List<Map<String, dynamic>> _tasks = [
    {
      'id': '1',
      'title': 'Revisar proyecto',
      'priority': Priority.high,
      'completed': false,
      'category': 'Trabajo',
    },
    {
      'id': '2',
      'title': 'Enviar informe',
      'priority': Priority.medium,
      'completed': false,
      'category': 'Trabajo',
    },
    {
      'id': '3',
      'title': 'Actualizar documentación',
      'priority': Priority.low,
      'completed': true,
      'category': 'Personal',
    },
    {
      'id': '4',
      'title': 'Reunión con equipo',
      'priority': Priority.urgent,
      'completed': false,
      'category': 'Trabajo',
    },
    {
      'id': '5',
      'title': 'Comprar insumos',
      'priority': Priority.medium,
      'completed': false,
      'category': 'Personal',
    },
  ];

  // Simular carga de datos
  Future<void> _refreshTasks() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1)); // Simular API call
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  // Mostrar skeleton loader
  Widget get _contentBuilder {
    if (_isLoading) {
      return _buildSkeletonLoader();
    }

    if (_filteredTasks.isEmpty) {
      return _buildEmptyState();
    }

    return _buildTaskList();
  }

  Widget _buildSkeletonLoader() {
    return Shimmer.fromColors(
      baseColor: AppColors.darkSurfaceAlt,
      highlightColor: AppColors.darkBorder,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            height: 80,
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
                Icons.task_alt_rounded,
                size: 40,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No hay tareas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Crea tu primera tarea para comenzar',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _showAddTaskDialog,
              icon: const Icon(Icons.add),
              label: const Text('Crear Tarea'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskList() {
    return RefreshIndicator(
      onRefresh: _refreshTasks,
      color: AppColors.accentPrimary,
      backgroundColor: AppColors.darkSurface,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredTasks.length,
        itemBuilder: (context, index) {
          return _buildTaskCard(_filteredTasks[index]);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text('Tareas'),
        backgroundColor: AppColors.darkBackground,
        actions: [IconButton(icon: const Icon(Icons.search), onPressed: () {})],
      ),
      body: Column(
        children: [
          // Filters
          _buildFilters(),

          // Task list / skeleton / empty
          Expanded(
            child: _contentBuilder,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        backgroundColor: AppColors.accentPrimary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('all', 'Todas'),
            const SizedBox(width: 8),
            _buildFilterChip('pending', 'Pendientes'),
            const SizedBox(width: 8),
            _buildFilterChip('completed', 'Completadas'),
            const SizedBox(width: 8),
            _buildFilterChip('high', 'Alta prioridad'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _filter == value;
    return GestureDetector(
      onTap: () => setState(() => _filter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accentPrimary : AppColors.darkSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.accentPrimary : AppColors.darkBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> get _filteredTasks {
    switch (_filter) {
      case 'pending':
        return _tasks.where((t) => !t['completed']).toList();
      case 'completed':
        return _tasks.where((t) => t['completed']).toList();
      case 'high':
        return _tasks
            .where(
              (t) =>
                  t['priority'] == Priority.high ||
                  t['priority'] == Priority.urgent,
            )
            .toList();
      default:
        return _tasks;
    }
  }

  Widget _buildTaskCard(Map<String, dynamic> task) {
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
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Checkbox
                GestureDetector(
                  onTap: () {
                    setState(() {
                      task['completed'] = !task['completed'];
                    });
                  },
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: task['completed']
                          ? AppColors.accentGreen
                          : Colors.transparent,
                      border: Border.all(
                        color: task['completed']
                            ? AppColors.accentGreen
                            : AppColors.darkBorder,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: task['completed']
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                ),
                const SizedBox(width: 16),

                // Task content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task['title'],
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          decoration: task['completed']
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          CategoryBadge(
                            label: task['category'],
                            color: AppColors.accentSecondary,
                          ),
                          const SizedBox(width: 8),
                          PriorityBadge(
                            priority: task['priority'],
                            showLabel: false,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Actions
                PopupMenuButton(
                  icon: const Icon(
                    Icons.more_vert,
                    color: AppColors.textSecondary,
                  ),
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('Editar')),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Eliminar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddTaskDialog() {
    final titleController = TextEditingController();
    Priority selectedPriority = Priority.medium;
    String selectedCategory = 'Personal';

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
                    'Nueva Tarea',
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
                      labelText: 'Título de la tarea',
                      labelStyle: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Prioridad',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildPriorityOption(
                        Priority.low,
                        setModalState,
                        selectedPriority,
                      ),
                      _buildPriorityOption(
                        Priority.medium,
                        setModalState,
                        selectedPriority,
                      ),
                      _buildPriorityOption(
                        Priority.high,
                        setModalState,
                        selectedPriority,
                      ),
                      _buildPriorityOption(
                        Priority.urgent,
                        setModalState,
                        selectedPriority,
                      ),
                    ],
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
                          if (titleController.text.isNotEmpty) {
                            setState(() {
                              _tasks.add({
                                'id': DateTime.now().toString(),
                                'title': titleController.text,
                                'priority': selectedPriority,
                                'completed': false,
                                'category': selectedCategory,
                              });
                            });
                            Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                        ),
                        child: const Text('Agregar Tarea'),
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

  Widget _buildPriorityOption(
    Priority priority,
    StateSetter setModalState,
    Priority selected,
  ) {
    final isSelected = selected == priority;
    return Expanded(
      child: GestureDetector(
        onTap: () => setModalState(() => selected = priority),
        child: Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? _getPriorityColor(priority).withOpacity(0.2)
                : AppColors.darkSurfaceAlt,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? _getPriorityColor(priority)
                  : AppColors.darkBorder,
            ),
          ),
          child: Center(child: PriorityBadge(priority: priority)),
        ),
      ),
    );
  }

  Color _getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.low:
        return AppColors.accentGreen;
      case Priority.medium:
        return AppColors.accentSecondary;
      case Priority.high:
        return AppColors.accentOrange;
      case Priority.urgent:
        return AppColors.accentRed;
    }
  }
}
