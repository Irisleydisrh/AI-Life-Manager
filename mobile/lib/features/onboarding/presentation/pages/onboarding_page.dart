import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _backgroundController;
  late Animation<double> _backgroundAnimation;

  final List<OnboardingContent> _pages = [
    OnboardingContent(
      icon: Icons.psychology,
      title: 'Tu Asistente IA',
      subtitle:
          'Una inteligencia artificial diseñada para ayudarte a gestionar tu vida diaria de manera inteligente',
      gradient: AppColors.gradientAI,
    ),
    OnboardingContent(
      icon: Icons.task_alt,
      title: 'Gestión de Tareas',
      subtitle:
          'Organiza tus tareas con prioridades y categorías. La IA te ayudará a priorizarlas estratégicamente',
      gradient: AppColors.gradientPrimary,
    ),
    OnboardingContent(
      icon: Icons.track_changes,
      title: 'Hábitos y Metas',
      subtitle:
          'Construye hábitos positivos y alcanza tus metas con seguimiento de progreso y rachas',
      gradient: AppColors.gradientSuccess,
    ),
    OnboardingContent(
      icon: Icons.account_balance_wallet,
      title: 'Control Financiero',
      subtitle:
          'Gestiona tus finanzas, establece presupuestos y analiza tus patrones de gasto',
      gradient: const LinearGradient(
        colors: [Color(0xFF00E676), Color(0xFF00D4FF)],
      ),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
    _backgroundAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _backgroundController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _completeOnboarding() {
    context.go('/auth/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated background
          AnimatedBuilder(
            animation: _backgroundAnimation,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(
                      _backgroundAnimation.value * 0.2 - 0.1,
                      _backgroundAnimation.value * 0.2 - 0.1,
                    ),
                    end: Alignment(
                      1 - _backgroundAnimation.value * 0.2,
                      1 - _backgroundAnimation.value * 0.2,
                    ),
                    colors: const [
                      Color(0xFF0A0A0F),
                      Color(0xFF141420),
                      Color(0xFF0A0A0F),
                    ],
                  ),
                ),
              );
            },
          ),
          // Page content
          SafeArea(
            child: Column(
              children: [
                // Skip button
                Align(
                  alignment: Alignment.topRight,
                  child: TextButton(
                    onPressed: _completeOnboarding,
                    child: const Text(
                      'Saltar',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ),
                // Pages
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _pages.length,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                    },
                    itemBuilder: (context, index) {
                      return _buildPage(_pages[index]);
                    },
                  ),
                ),
                // Indicators
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppColors.accentPrimary
                              : AppColors.darkBorder,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),
                // Next button
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: SizedBox(
                    width: double.infinity,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: AppColors.gradientPrimary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ElevatedButton(
                        onPressed: _nextPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          _currentPage == _pages.length - 1
                              ? 'Comenzar'
                              : 'Continuar',
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(OnboardingContent content) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon with gradient background
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: content.gradient,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: content.gradient.colors.first.withOpacity(0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(content.icon, size: 60, color: Colors.white),
          ),
          const SizedBox(height: 48),
          Text(
            content.title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            content.subtitle,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class OnboardingContent {
  final IconData icon;
  final String title;
  final String subtitle;
  final LinearGradient gradient;

  OnboardingContent({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
  });
}
