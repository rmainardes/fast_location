import 'package:flutter/material.dart';

import '../../../shared/components/address_tile.dart';
import '../model/address_model.dart';

/// Lista de endereços consultados (ou resultados de busca) da Home.
///
/// Não rola sozinha: é inserida no scroll principal da página.
class AddressList extends StatelessWidget {
  final List<AddressModel> addresses;
  final ValueChanged<AddressModel>? onSelect;
  final bool showDate;

  const AddressList({
    super.key,
    required this.addresses,
    this.onSelect,
    this.showDate = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final address in addresses)
          AddressTile(
            key: ValueKey(address.cepDigits),
            address: address,
            showDate: showDate,
            onTap: onSelect == null ? null : () => onSelect!(address),
          ),
      ],
    );
  }
}
