import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../shared/colors/app_colors.dart';
import '../../../shared/components/app_primary_button.dart';
import '../../../shared/metrics/app_metrics.dart';
import '../service/address_service.dart';

/// Pedido de consulta devolvido pelo formulário.
sealed class SearchRequest {
  const SearchRequest();
}

class CepSearchRequest extends SearchRequest {
  final String cep;
  const CepSearchRequest(this.cep);
}

class AddressSearchRequest extends SearchRequest {
  final String uf;
  final String city;
  final String street;
  const AddressSearchRequest({
    required this.uf,
    required this.city,
    required this.street,
  });
}

/// Componente com os campos de consulta: por CEP ou por endereço
/// (completo ou parcial). Abre como bottom sheet e devolve um
/// [SearchRequest] via `Navigator.pop`.
class SearchFormSheet extends StatefulWidget {
  const SearchFormSheet({super.key});

  static Future<SearchRequest?> show(BuildContext context) {
    return showModalBottomSheet<SearchRequest>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppMetrics.radiusL),
        ),
      ),
      builder: (_) => const SearchFormSheet(),
    );
  }

  @override
  State<SearchFormSheet> createState() => _SearchFormSheetState();
}

class _SearchFormSheetState extends State<SearchFormSheet>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final _cepFormKey = GlobalKey<FormState>();
  final _addressFormKey = GlobalKey<FormState>();
  final _cepController = TextEditingController();
  final _cityController = TextEditingController();
  final _streetController = TextEditingController();
  String _uf = 'SC';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _cepController.dispose();
    _cityController.dispose();
    _streetController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_tabController.index == 0) {
      if (!(_cepFormKey.currentState?.validate() ?? false)) return;
      Navigator.of(context).pop(CepSearchRequest(_cepController.text));
    } else {
      if (!(_addressFormKey.currentState?.validate() ?? false)) return;
      Navigator.of(context).pop(
        AddressSearchRequest(
          uf: _uf,
          city: _cityController.text,
          street: _streetController.text,
        ),
      );
    }
  }

  String? _validateCep(String? value) {
    return AddressService.normalizeCep(value ?? '') == null
        ? 'Informe os 8 dígitos do CEP'
        : null;
  }

  String? _validateMin(String? value, String field) {
    return (value ?? '').trim().length < AddressService.minSearchLength
        ? '$field: mínimo de ${AddressService.minSearchLength} caracteres'
        : null;
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(
        left: AppMetrics.spaceM,
        right: AppMetrics.spaceM,
        top: AppMetrics.spaceM,
        bottom: bottomInset + AppMetrics.spaceM,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Nova consulta',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppMetrics.spaceS),
            TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              indicatorColor: AppColors.primary,
              tabs: const [
                Tab(icon: Icon(Icons.pin_drop_outlined), text: 'Por CEP'),
                Tab(icon: Icon(Icons.signpost_outlined), text: 'Por endereço'),
              ],
            ),
            const SizedBox(height: AppMetrics.spaceM),
            if (_tabController.index == 0) _buildCepForm() else _buildAddressForm(),
            const SizedBox(height: AppMetrics.spaceM),
            AppPrimaryButton(
              label: 'Consultar',
              icon: Icons.search,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCepForm() {
    return Form(
      key: _cepFormKey,
      child: TextFormField(
        controller: _cepController,
        autofocus: true,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.search,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(8),
        ],
        decoration: const InputDecoration(
          labelText: 'CEP',
          hintText: 'Somente números, ex.: 89010025',
          prefixIcon: Icon(Icons.markunread_mailbox_outlined),
          border: OutlineInputBorder(),
        ),
        validator: _validateCep,
        onFieldSubmitted: (_) => _submit(),
      ),
    );
  }

  Widget _buildAddressForm() {
    return Form(
      key: _addressFormKey,
      child: Column(
        children: [
          InputDecorator(
            decoration: const InputDecoration(
              labelText: 'UF',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(
                horizontal: AppMetrics.spaceM,
                vertical: AppMetrics.spaceXS,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _uf,
                isExpanded: true,
                items: [
                  for (final uf in AddressService.ufs)
                    DropdownMenuItem(value: uf, child: Text(uf)),
                ],
                onChanged: (v) => setState(() => _uf = v ?? _uf),
              ),
            ),
          ),
          const SizedBox(height: AppMetrics.spaceM),
          TextFormField(
            controller: _cityController,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            inputFormatters: [LengthLimitingTextInputFormatter(60)],
            decoration: const InputDecoration(
              labelText: 'Cidade',
              hintText: 'Ex.: Blumenau',
              prefixIcon: Icon(Icons.location_city_outlined),
              border: OutlineInputBorder(),
            ),
            validator: (v) => _validateMin(v, 'Cidade'),
          ),
          const SizedBox(height: AppMetrics.spaceM),
          TextFormField(
            controller: _streetController,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.search,
            inputFormatters: [LengthLimitingTextInputFormatter(80)],
            decoration: const InputDecoration(
              labelText: 'Logradouro (completo ou parcial)',
              hintText: 'Ex.: XV de Novembro',
              prefixIcon: Icon(Icons.signpost_outlined),
              border: OutlineInputBorder(),
            ),
            validator: (v) => _validateMin(v, 'Logradouro'),
            onFieldSubmitted: (_) => _submit(),
          ),
        ],
      ),
    );
  }
}
