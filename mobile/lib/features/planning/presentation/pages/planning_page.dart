import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../tasks/presentation/pages/tasks_page.dart';
import '../../../habits/presentation/pages/habits_page.dart';
import '../../../goals/presentation/pages/goals_page.dart';

/// Planning Page - Agrupa Tareas, Hábitos y Metas en tabs internos
class PlanningPage extends StatefulWidget {
  const PlanningPage({super.key});

  @override
  State<PlanningPage> createState() => _PlanningPageState();
}

class _PlanningPageState extends State<PlanningPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkBackground,
        elevation: 0,
        title: const Text(
          'Planificación',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.accentPrimary,
          indicatorWeight: 3,
          labelColor: AppColors.accentPrimary,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
          tabs: const [
            Tab(
              text: 'Tareas',
              icon: Icon(Icons.task_alt_rounded, size: 20),
            ),
            Tab(
              text: 'Hábitos',
              icon: Icon(Icons.check_circle_outline_rounded, size: 20),
            ),
            Tab(
              text: 'Metas',
              icon: Icon(Icons.flag_rounded, size: 20),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          TasksPage(),
          HabitsPage(),
          GoalsPage(),
        ],
      ),
    );
  }
}
