import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/theme/app_theme.dart';

/// Onboarding Premium - Ultra PRO
/// 3 pantallas con microinteracciones, gradientes y diseño IA futurista
class OnboardingPremium extends StatefulWidget {
  const OnboardingPremium({super.key});

  @override
  State<OnboardingPremium> createState() => _OnboardingPremiumState();
}

class _OnboardingPremiumState extends State<OnboardingPremium> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Lista de páginas del onboarding con animaciones Lottie
  final List<OnboardingPageData> _pages = [
    OnboardingPageData(
      icon: Icons.psychology,
      lottieAsset: 'assets/animations/brain_ai.json',
      title: 'Tu vida, optimizada con IA',
      subtitle:
          'Una inteligencia adaptativa que aprende de vos y se adapta a tu ritmo de vida',
      gradient: AppColors.gradientAI,
    ),
    OnboardingPageData(
      icon: Icons.bolt,
      lottieAsset: 'assets/animations/automation.json',
      title: 'Menos estrés. Más control.',
      subtitle:
          'Automatiza tareas, recibe recordatorios inteligentes y enfócate en lo importante',
      gradient: AppColors.gradientPrimary,
    ),
    OnboardingPageData(
      icon: Icons.rocket_launch,
      lottieAsset: 'assets/animations/rocket.json',
      title: 'Empieza en segundos',
      subtitle:
          'Crea tu cuenta y toma el control de tu día desde el primer momento',
      gradient: AppColors.gradientSuccess,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    } else {
      _goToPersonalization();
    }
  }

  void _skip() {
    _goToPersonalization();
  }

  Future<void> _goToPersonalization() async {
    // Guardar que ya vio el onboarding
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seen_onboarding', true);

    if (mounted) {
      context.go('/onboarding/personalization');
    }
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
            children: [
              // Skip button
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _skip,
                      child: Text(
                        'Saltar',
                        style: TextStyle(
                          color: AppColors.textSecondary.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Page content
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemBuilder: (context, index) {
                    return _OnboardingPage(
                      data: _pages[index],
                      isActive: index == _currentPage,
                    );
                  },
                ),
              ),

              // Indicator + Button
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Indicators
                    Row(
                      children: List.generate(
                        _pages.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentPage == index ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            gradient: _currentPage == index
                                ? AppColors.gradientPrimary
                                : null,
                            color: _currentPage == index
                                ? null
                                : AppColors.darkBorder,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),

                    // Next / Get Started Button
                    _NextButton(
                      isLast: _currentPage == _pages.length - 1,
                      onTap: _nextPage,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Pantalla individual del onboarding
class _OnboardingPage extends StatelessWidget {
  final OnboardingPageData data;
  final bool isActive;

  const _OnboardingPage({
    required this.data,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Lottie Animation o Icono con gradiente
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              gradient: data.gradient,
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: data.gradient.colors.first.withOpacity(0.4),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: data.lottieAsset != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: Lottie.asset(
                      data.lottieAsset!,
                      fit: BoxFit.cover,
                    ),
                  )
                : Icon(
                    data.icon,
                    size: 70,
                    color: Colors.white,
                  ),
          )
              .animate(target: isActive ? 1 : 0)
              .scale(
                begin: const Offset(0.8, 0.8),
                end: const Offset(1, 1),
                duration: 500.ms,
                curve: Curves.easeOutCubic,
              )
              .fadeIn(duration: 400.ms),

          const SizedBox(height: 48),

          // Título
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
              height: 1.2,
            ),
          )
              .animate(target: isActive ? 1 : 0)
              .fadeIn(delay: 200.ms, duration: 400.ms)
              .slideY(begin: 0.3, end: 0, delay: 200.ms, duration: 400.ms),

          const SizedBox(height: 16),

          // Subtítulo
          Text(
            data.subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary.withOpacity(0.9),
              height: 1.5,
            ),
          )
              .animate(target: isActive ? 1 : 0)
              .fadeIn(delay: 350.ms, duration: 400.ms)
              .slideY(begin: 0.3, end: 0, delay: 350.ms, duration: 400.ms),
        ],
      ),
    );
  }
}

/// Botón next con animación
class _NextButton extends StatefulWidget {
  final bool isLast;
  final VoidCallback onTap;

  const _NextButton({
    required this.isLast,
    required this.onTap,
  });

  @override
  State<_NextButton> createState() => _NextButtonState();
}

class _NextButtonState extends State<_NextButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: AppColors.gradientPrimary,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.accentPrimary.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(
            widget.isLast ? Icons.check : Icons.arrow_forward,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }
}

/// Modelo de datos para cada página
class OnboardingPageData {
  final IconData icon;
  final String? lottieAsset;
  final String title;
  final String subtitle;
  final LinearGradient gradient;

  OnboardingPageData({
    required this.icon,
    this.lottieAsset,
    required this.title,
    required this.subtitle,
    required this.gradient,
  });
}
