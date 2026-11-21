import 'package:flutter/material.dart';

import '../../../shared/colors/app_colors.dart';
import '../../../shared/components/app_primary_button.dart';
import '../../../shared/metrics/app_metrics.dart';
import '../model/address_model.dart';

/// Card com o último endereço consultado e a ação de traçar rota.
class LastAddressCard extends StatelessWidget {
  final AddressModel address;
  final VoidCallback onRoute;

  const LastAddressCard({
    super.key,
    required this.address,
    required this.onRoute,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppMetrics.radiusM),
        boxShadow: const [
          BoxShadow(color: AppColors.shadow, blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      padding: const EdgeInsets.all(AppMetrics.spaceM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_shipping_outlined, color: AppColors.accent),
              const SizedBox(width: AppMetrics.spaceS),
              const Expanded(
                child: Text(
                  'Último endereço consultado',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppMetrics.spaceS,
                  vertical: AppMetrics.spaceXS,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppMetrics.radiusS),
                ),
                child: Text(
                  address.cep,
                  style: const TextStyle(
                    color: AppColors.onPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppMetrics.spaceM),
          _InfoRow(label: 'Logradouro', value: address.logradouro),
          if (address.complemento.isNotEmpty)
            _InfoRow(label: 'Complemento', value: address.complemento),
          _InfoRow(label: 'Bairro', value: address.bairro),
          _InfoRow(label: 'Cidade/UF', value: address.cityLine),
          if (address.ddd.isNotEmpty) _InfoRow(label: 'DDD', value: address.ddd),
          const SizedBox(height: AppMetrics.spaceM),
          AppPrimaryButton(
            label: 'Traçar rota',
            icon: Icons.directions,
            backgroundColor: AppColors.accent,
            onPressed: onRoute,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppMetrics.spaceXS),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '—' : value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
