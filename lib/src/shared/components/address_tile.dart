import 'package:flutter/material.dart';

import '../../modules/home/model/address_model.dart';
import '../colors/app_colors.dart';
import '../metrics/app_metrics.dart';

/// Item de endereço reutilizado na lista da Home e no Histórico.
class AddressTile extends StatelessWidget {
  final AddressModel address;
  final VoidCallback? onTap;
  final bool showDate;

  const AddressTile({
    super.key,
    required this.address,
    this.onTap,
    this.showDate = false,
  });

  @override
  Widget build(BuildContext context) {
    final date = address.consultedAt;
    final subtitle = StringBuffer(address.cityLine);
    if (showDate && date != null) {
      subtitle.write('  •  ${_formatDate(date)}');
    }

    return Card(
      margin: const EdgeInsets.only(bottom: AppMetrics.spaceS),
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppMetrics.radiusS),
      ),
      child: ListTile(
        onTap: onTap,
        leading: const CircleAvatar(
          backgroundColor: AppColors.background,
          child: Icon(Icons.place_outlined, color: AppColors.primary),
        ),
        title: Text(
          address.streetLine,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(subtitle.toString()),
        trailing: Text(
          address.cep,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  static String _formatDate(DateTime d) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year} ${two(d.hour)}:${two(d.minute)}';
  }
}
