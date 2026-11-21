import 'package:flutter/material.dart';

import '../colors/app_colors.dart';
import '../metrics/app_metrics.dart';

/// Tela de loading exibida sobre o conteúdo durante consultas externas.
///
/// Bloqueia toques (ModalBarrier) para evitar ações concorrentes.
class AppLoading extends StatelessWidget {
  final String message;

  const AppLoading({super.key, this.message = 'Consultando...'});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const ModalBarrier(dismissible: false, color: AppColors.loadingOverlay),
        Center(
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppMetrics.radiusM),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppMetrics.spaceXL,
                vertical: AppMetrics.spaceL,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: AppColors.primary),
                  const SizedBox(height: AppMetrics.spaceM),
                  Text(
                    message,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
