import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Animated background with particles (stars/nebula effect)
class AnimatedBackground extends StatefulWidget {
  final Widget child;
  final int particleCount;
  final Color particleColor;

  const AnimatedBackground({
    super.key,
    required this.child,
    this.particleCount = 50,
    this.particleColor = const Color(0xFF6C63FF),
  });

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Particle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    _particles = List.generate(widget.particleCount, (index) {
      return Particle(
        x: (index * 17 % 100) / 100,
        y: (index * 23 % 100) / 100,
        size: (index % 3 + 1) * 0.5 + 0.5,
        speed: (index % 5 + 1) * 0.2,
        opacity: (index % 7 + 3) / 10,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Gradient base
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0A0A0F), Color(0xFF141420), Color(0xFF0A0A0F)],
            ),
          ),
        ),
        // Particles
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: ParticlePainter(
                particles: _particles,
                progress: _controller.value,
                color: widget.particleColor,
              ),
              size: Size.infinite,
            );
          },
        ),
        // Content
        widget.child,
      ],
    );
  }
}

class Particle {
  double x;
  double y;
  double size;
  double speed;
  double opacity;

  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
  });
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double progress;
  final Color color;

  ParticlePainter({
    required this.particles,
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final paint = Paint()
        ..color = color.withOpacity(
          particle.opacity *
              (0.3 + 0.7 * ((particle.y + progress * particle.speed) % 1)),
        )
        ..style = PaintingStyle.fill;

      final x = particle.x * size.width;
      final y = ((particle.y + progress * particle.speed) % 1) * size.height;

      canvas.drawCircle(Offset(x, y), particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) => true;
}

/// Pulse button with wave animation on press
class PulseButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;
  final Color? color;
  final double borderRadius;

  const PulseButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.color,
    this.borderRadius = 12,
  });

  @override
  State<PulseButton> createState() => _PulseButtonState();
}

class _PulseButtonState extends State<PulseButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _opacityAnimation = Tween<double>(
      begin: 0.5,
      end: 0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onPressed();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            children: [
              // Wave ripple
              if (_controller.isAnimating)
                Transform.scale(
                  scale: _scaleAnimation.value + 0.1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: (widget.color ??
                              Theme.of(context).colorScheme.primary)
                          .withOpacity(_opacityAnimation.value),
                      borderRadius: BorderRadius.circular(widget.borderRadius),
                    ),
                  ),
                ),
              // Main button
              Transform.scale(
                scale: _scaleAnimation.value,
                child: widget.child,
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Confetti overlay for celebrations
class ConfettiOverlay extends StatefulWidget {
  final bool isPlaying;
  final VoidCallback? onComplete;
  final Duration duration;

  const ConfettiOverlay({
    super.key,
    required this.isPlaying,
    this.onComplete,
    this.duration = const Duration(seconds: 3),
  });

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<ConfettiPiece> _pieces;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _pieces = List.generate(50, (index) {
      return ConfettiPiece(
        x: (index * 13 % 100) / 100,
        startY: -0.1,
        endY: 1.1,
        size: (index % 4 + 2) * 1.5,
        color: [
          const Color(0xFF6C63FF),
          const Color(0xFF00D4FF),
          const Color(0xFFFF6B9D),
          const Color(0xFF00E676),
          const Color(0xFFFF9800),
        ][index % 5],
        rotation: index * 0.5,
        delay: index * 0.02,
      );
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });
  }

  @override
  void didUpdateWidget(ConfettiOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !oldWidget.isPlaying) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isPlaying && _controller.status != AnimationStatus.forward) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: ConfettiPainter(
            pieces: _pieces,
            progress: _controller.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class ConfettiPiece {
  double x;
  double startY;
  double endY;
  double size;
  Color color;
  double rotation;
  double delay;

  ConfettiPiece({
    required this.x,
    required this.startY,
    required this.endY,
    required this.size,
    required this.color,
    required this.rotation,
    required this.delay,
  });
}

class ConfettiPainter extends CustomPainter {
  final List<ConfettiPiece> pieces;
  final double progress;

  ConfettiPainter({required this.pieces, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (var piece in pieces) {
      final adjustedProgress = (progress - piece.delay).clamp(0.0, 1.0);
      if (adjustedProgress <= 0) continue;

      final paint = Paint()
        ..color = piece.color.withOpacity(1 - adjustedProgress * 0.5)
        ..style = PaintingStyle.fill;

      final x = piece.x * size.width;
      final y = piece.startY + (piece.endY - piece.startY) * adjustedProgress;

      canvas.save();
      canvas.translate(x, y * size.height);
      canvas.rotate(piece.rotation * adjustedProgress * 10);

      // Draw rectangle confetti
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: piece.size,
          height: piece.size * 0.6,
        ),
        paint,
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant ConfettiPainter oldDelegate) => true;
}

/// Celebration animation for completing all habits
class StreakCelebration extends StatefulWidget {
  final bool show;
  final VoidCallback? onComplete;

  const StreakCelebration({super.key, required this.show, this.onComplete});

  @override
  State<StreakCelebration> createState() => _StreakCelebrationState();
}

class _StreakCelebrationState extends State<StreakCelebration>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.2), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 30),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 30),
    ]).animate(_controller);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });
  }

  @override
  void didUpdateWidget(StreakCelebration oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.show && !oldWidget.show) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.show && _controller.status != AnimationStatus.forward) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Center(
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFFFF6B9D)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6C63FF).withOpacity(0.5),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.celebration, size: 64, color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      '¡Día completado!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Todos los hábitos realizados',
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Compact mode toggle
class CompactModeToggle extends StatelessWidget {
  final bool isCompact;
  final ValueChanged<bool> onChanged;

  const CompactModeToggle({
    super.key,
    required this.isCompact,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!isCompact),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isCompact
              ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
              : AppColors.darkSurfaceAlt,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isCompact
                ? Theme.of(context).colorScheme.primary
                : AppColors.darkBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.view_agenda,
              size: 16,
              color: isCompact
                  ? Theme.of(context).colorScheme.primary
                  : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              isCompact ? 'Compacto' : 'Normal',
              style: TextStyle(
                fontSize: 12,
                color: isCompact
                    ? Theme.of(context).colorScheme.primary
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Date and time header widget
class DateHeader extends StatelessWidget {
  const DateHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final weekdays = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo',
    ];
    final months = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.darkSurface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.calendar_today,
            size: 16,
            color: AppColors.accentSecondary,
          ),
          const SizedBox(width: 8),
          Text(
            '${weekdays[now.weekday - 1]}, ${now.day} ${months[now.month - 1]}',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 16),
          Container(width: 1, height: 16, color: AppColors.darkBorder),
          const SizedBox(width: 16),
          Text(
            _formatTime(now),
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.accentPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

/// Tilt card for 3D perspective effect
class TiltCard extends StatefulWidget {
  final Widget child;
  final double maxRotation;
  final VoidCallback? onTap;

  const TiltCard({
    super.key,
    required this.child,
    this.maxRotation = 5.0,
    this.onTap,
  });

  @override
  State<TiltCard> createState() => _TiltCardState();
}

class _TiltCardState extends State<TiltCard> {
  double _rotateX = 0;
  double _rotateY = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          _rotateY = (details.delta.dx / 100).clamp(
            -widget.maxRotation,
            widget.maxRotation,
          );
          _rotateX = (-details.delta.dy / 100).clamp(
            -widget.maxRotation,
            widget.maxRotation,
          );
        });
      },
      onPanEnd: (_) {
        setState(() {
          _rotateX = 0;
          _rotateY = 0;
        });
      },
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateX(_rotateX * 0.0174533)
          ..rotateY(_rotateY * 0.0174533),
        child: widget.child,
      ),
    );
  }
}

/// Custom animated toast
class CustomToast extends StatefulWidget {
  final String message;
  final ToastType type;
  final VoidCallback? onDismiss;
  final Duration duration;

  const CustomToast({
    super.key,
    required this.message,
    this.type = ToastType.success,
    this.onDismiss,
    this.duration = const Duration(seconds: 3),
  });

  @override
  State<CustomToast> createState() => _CustomToastState();
}

class _CustomToastState extends State<CustomToast>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();

    Future.delayed(widget.duration, () {
      if (mounted) {
        _controller.reverse().then((_) {
          widget.onDismiss?.call();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = _getColors();

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.border),
            boxShadow: [
              BoxShadow(
                color: colors.primary.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(colors.icon, color: colors.primary, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.message,
                  style: TextStyle(
                    color: colors.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  _controller.reverse().then((_) {
                    widget.onDismiss?.call();
                  });
                },
                child: Icon(
                  Icons.close,
                  color: colors.text.withOpacity(0.5),
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _ToastColors _getColors() {
    switch (widget.type) {
      case ToastType.success:
        return _ToastColors(
          background: const Color(0xFF1A2E1A),
          border: const Color(0xFF00E676),
          primary: const Color(0xFF00E676),
          icon: Icons.check_circle,
          text: Colors.white,
        );
      case ToastType.error:
        return _ToastColors(
          background: const Color(0xFF2E1A1A),
          border: const Color(0xFFFF5252),
          primary: const Color(0xFFFF5252),
          icon: Icons.error,
          text: Colors.white,
        );
      case ToastType.warning:
        return _ToastColors(
          background: const Color(0xFF2E2A1A),
          border: const Color(0xFFFF9800),
          primary: const Color(0xFFFF9800),
          icon: Icons.warning,
          text: Colors.white,
        );
      case ToastType.info:
        return _ToastColors(
          background: const Color(0xFF1A1E2E),
          border: const Color(0xFF00D4FF),
          primary: const Color(0xFF00D4FF),
          icon: Icons.info,
          text: Colors.white,
        );
    }
  }
}

class _ToastColors {
  final Color background;
  final Color border;
  final Color primary;
  final IconData icon;
  final Color text;

  _ToastColors({
    required this.background,
    required this.border,
    required this.primary,
    required this.icon,
    required this.text,
  });
}

enum ToastType { success, error, warning, info }
