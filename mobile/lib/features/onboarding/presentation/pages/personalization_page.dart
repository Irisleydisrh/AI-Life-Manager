import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/theme/app_theme.dart';

/// Página de Personalización - Ultra PRO
/// El usuario selecciona qué quiere mejorar para una experiencia personalizada
class PersonalizationPage extends StatefulWidget {
  const PersonalizationPage({super.key});

  @override
  State<PersonalizationPage> createState() => _PersonalizationPageState();
}

class _PersonalizationPageState extends State<PersonalizationPage> {
  final List<GoalItem> _goals = [
    GoalItem(
      id: 'productivity',
      icon: Icons.work_outline,
      title: 'Productividad',
      description: 'Gestión de tareas y tiempo',
    ),
    GoalItem(
      id: 'habits',
      icon: Icons.check_circle_outline,
      title: 'Hábitos',
      description: 'Crear rutinas positivas',
    ),
    GoalItem(
      id: 'health',
      icon: Icons.favorite_outline,
      title: 'Salud',
      description: 'Bienestar físico y mental',
    ),
    GoalItem(
      id: 'finance',
      icon: Icons.account_balance_wallet_outlined,
      title: 'Finanzas',
      description: 'Ahorro y control de gastos',
    ),
  ];

  final Set<String> _selectedGoals = {};
  bool _isLoading = false;

  Future<void> _continue() async {
    if (_selectedGoals.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona al menos un objetivo'),
          backgroundColor: AppColors.accentRed,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Guardar preferencias del usuario
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('user_goals', _selectedGoals.toList());
      await prefs.setBool('setup_complete', true);

      if (mounted) {
        context.go('/auth/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.accentRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _toggleGoal(String goalId) {
    setState(() {
      if (_selectedGoals.contains(goalId)) {
        _selectedGoals.remove(goalId);
      } else {
        _selectedGoals.add(goalId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A0A0F),
              Color(0xFF141420),
              Color(0xFF0A0A0F),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '¿Qué quieres mejorar?',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 400.ms)
                        .slideX(begin: -0.2, end: 0, duration: 400.ms),
                    const SizedBox(height: 8),
                    Text(
                      'Selecciona uno o más objetivos para personalizar tu experiencia',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary.withOpacity(0.8),
                        height: 1.5,
                      ),
                    ).animate().fadeIn(delay: 150.ms, duration: 400.ms),
                  ],
                ),
              ),

              // Goals Grid
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.1,
                    ),
                    itemCount: _goals.length,
                    itemBuilder: (context, index) {
                      final goal = _goals[index];
                      final isSelected = _selectedGoals.contains(goal.id);

                      return _GoalCard(
                        goal: goal,
                        isSelected: isSelected,
                        onTap: () => _toggleGoal(goal.id),
                      )
                          .animate(delay: (100 * index).ms)
                          .fadeIn(duration: 400.ms)
                          .scale(
                            begin: const Offset(0.9, 0.9),
                            end: const Offset(1, 1),
                            duration: 400.ms,
                          );
                    },
                  ),
                ),
              ),

              // Continue Button
              Padding(
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  width: double.infinity,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: _selectedGoals.isEmpty
                          ? null
                          : AppColors.gradientPrimary,
                      color: _selectedGoals.isEmpty
                          ? AppColors.darkSurfaceAlt
                          : null,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _continue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        disabledBackgroundColor: Colors.transparent,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              _selectedGoals.isEmpty
                                  ? 'Selecciona un objetivo'
                                  : 'Continuar (${_selectedGoals.length})',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ),
              )
                  .animate()
                  .fadeIn(delay: 500.ms, duration: 400.ms)
                  .slideY(begin: 0.3, end: 0, delay: 500.ms, duration: 400.ms),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tarjeta de objetivo seleccionable
class _GoalCard extends StatefulWidget {
  final GoalItem goal;
  final bool isSelected;
  final VoidCallback onTap;

  const _GoalCard({
    required this.goal,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_GoalCard> createState() => _GoalCardState();
}

class _GoalCardState extends State<_GoalCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: widget.isSelected
                ? AppColors.accentPrimary.withOpacity(0.15)
                : AppColors.darkSurface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.isSelected
                  ? AppColors.accentPrimary
                  : AppColors.darkBorder,
              width: widget.isSelected ? 2 : 1,
            ),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: AppColors.accentPrimary.withOpacity(0.2),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient:
                        widget.isSelected ? AppColors.gradientPrimary : null,
                    color: widget.isSelected ? null : AppColors.darkSurfaceAlt,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    widget.goal.icon,
                    color: widget.isSelected
                        ? Colors.white
                        : AppColors.textSecondary,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.goal.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: widget.isSelected
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.goal.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Modelo de datos para objetivo
class GoalItem {
  final String id;
  final IconData icon;
  final String title;
  final String description;

  GoalItem({
    required this.id,
    required this.icon,
    required this.title,
    required this.description,
  });
}
