import 'dart:async';

import 'package:flutter/material.dart';

import '../../../routes/app_routes.dart';
import '../../../shared/colors/app_colors.dart';
import '../../../shared/metrics/app_metrics.dart';

/// Tela de abertura: animação de entrada e redirecionamento automático
/// para a Home.
class InitialPage extends StatefulWidget {
  /// Tempo total na tela de abertura antes de ir para a Home.
  static const Duration splashDuration = Duration(milliseconds: 2500);

  const InitialPage({super.key});

  @override
  State<InitialPage> createState() => _InitialPageState();
}

class _InitialPageState extends State<InitialPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animation;
  late final Animation<double> _scale;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  Timer? _redirectTimer;

  @override
  void initState() {
    super.initState();
    _animation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _scale = Tween<double>(begin: 0.4, end: 1).animate(
      CurvedAnimation(parent: _animation, curve: Curves.elasticOut),
    );
    _fade = CurvedAnimation(
      parent: _animation,
      curve: const Interval(0, 0.6, curve: Curves.easeIn),
    );
    _slide = Tween<Offset>(begin: const Offset(0, 0.6), end: Offset.zero)
        .animate(
      CurvedAnimation(
        parent: _animation,
        curve: const Interval(0.4, 1, curve: Curves.easeOutCubic),
      ),
    );

    _animation.forward();
    _redirectTimer = Timer(InitialPage.splashDuration, _goHome);
  }

  void _goHome() {
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(AppRoutes.home);
  }

  @override
  void dispose() {
    _redirectTimer?.cancel();
    _animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primary, AppColors.primaryDark],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeTransition(
              opacity: _fade,
              child: ScaleTransition(
                scale: _scale,
                child: Container(
                  padding: const EdgeInsets.all(AppMetrics.spaceL),
                  decoration: const BoxDecoration(
                    color: AppColors.onPrimary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.location_on,
                    size: AppMetrics.iconXL,
                    color: AppColors.accent,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppMetrics.spaceL),
            SlideTransition(
              position: _slide,
              child: FadeTransition(
                opacity: _fade,
                child: const Column(
                  children: [
                    Text(
                      'FastLocation',
                      style: TextStyle(
                        color: AppColors.onPrimary,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(height: AppMetrics.spaceS),
                    Text(
                      'by FastDelivery',
                      style: TextStyle(
                        color: AppColors.onPrimary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppMetrics.spaceXL),
            const SizedBox(
              width: AppMetrics.iconM,
              height: AppMetrics.iconM,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
