import 'package:flutter/material.dart';

import '../../../shared/colors/app_colors.dart';
import '../../../shared/metrics/app_metrics.dart';

/// Componente de busca vazia: nenhum endereço consultado ainda, ou a última
/// busca não encontrou resultado.
class EmptySearch extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final VoidCallback? onDismiss;

  const EmptySearch({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.search_off,
    this.onDismiss,
  });

  /// Estado inicial, antes de qualquer consulta.
  const EmptySearch.initial({super.key})
      : title = 'Nenhum endereço consultado',
        message = 'Toque em "Nova consulta" para buscar um endereço pelo CEP '
            'ou um CEP pelo endereço.',
        icon = Icons.travel_explore,
        onDismiss = null;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppMetrics.spaceL),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppMetrics.radiusM),
      ),
      child: Column(
        children: [
          Icon(icon, size: AppMetrics.iconL, color: AppColors.textSecondary),
          const SizedBox(height: AppMetrics.spaceM),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppMetrics.spaceS),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          if (onDismiss != null) ...[
            const SizedBox(height: AppMetrics.spaceS),
            TextButton(onPressed: onDismiss, child: const Text('OK')),
          ],
        ],
      ),
    );
  }
}
