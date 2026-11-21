import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:mobx/mobx.dart';

import '../../../routes/app_routes.dart';
import '../../../shared/colors/app_colors.dart';
import '../../../shared/components/app_loading.dart';
import '../../../shared/components/section_title.dart';
import '../../../shared/metrics/app_metrics.dart';
import '../components/address_list.dart';
import '../components/empty_search.dart';
import '../components/last_address_card.dart';
import '../components/search_form_sheet.dart';
import '../controller/home_controller.dart';
import '../model/address_model.dart';
import '../repositories/address_local_repository.dart';
import '../repositories/via_cep_repository.dart';
import '../service/address_service.dart';

class HomePage extends StatefulWidget {
  /// Permite injetar o controller (testes). Em produção é criado aqui.
  final HomeController? controller;

  const HomePage({super.key, this.controller});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeController _controller;
  final List<ReactionDisposer> _disposers = [];

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ??
        HomeController(
          AddressService(
            remote: ViaCepRepository(),
            local: AddressLocalRepository(),
          ),
        );
    _controller.loadFromStorage();

    // Reação do MobX: toda vez que surgir um erro, mostra SnackBar e limpa.
    _disposers.add(
      reaction<String?>((_) => _controller.errorMessage, (message) {
        if (message == null || !mounted) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        _controller.clearError();
      }),
    );
  }

  @override
  void dispose() {
    for (final d in _disposers) {
      d();
    }
    super.dispose();
  }

  // ---------------------------------------------------------------- ações

  Future<void> _newSearch() async {
    final request = await SearchFormSheet.show(context);
    if (request == null) return;
    switch (request) {
      case CepSearchRequest(:final cep):
        await _controller.searchByCep(cep);
      case AddressSearchRequest(:final uf, :final city, :final street):
        await _controller.searchByAddress(uf: uf, city: city, street: street);
    }
  }

  Future<void> _openHistory() async {
    final selected = await Navigator.of(context).pushNamed(AppRoutes.history);
    if (selected is AddressModel) {
      await _controller.selectAddress(selected);
    } else {
      // O histórico pode ter sido limpo: recarrega estado local.
      _controller.loadFromStorage();
    }
  }

  Future<void> _traceRoute() async {
    final address = _controller.lastAddress;
    final destination = await _controller.resolveRouteDestination();
    if (destination == null || address == null || !mounted) return;

    try {
      final maps = await MapLauncher.installedMaps;
      if (!mounted) return;
      if (maps.isEmpty) {
        _controller.setError('Nenhum aplicativo de mapas instalado no aparelho.');
        return;
      }
      final map = maps.length == 1 ? maps.first : await _pickMap(maps);
      if (map == null) return;

      // Sem "origin": o app de mapas usa a localização atual do aparelho.
      await map.showDirections(
        destination: Coords(destination.latitude, destination.longitude),
        destinationTitle: '${address.streetLine} - ${address.cityLine}',
        directionsMode: DirectionsMode.driving,
      );
    } catch (e) {
      debugPrint('HomePage._traceRoute: $e');
      _controller.setError('Não foi possível abrir o aplicativo de mapas.');
    }
  }

  Future<AvailableMap?> _pickMap(List<AvailableMap> maps) {
    return showModalBottomSheet<AvailableMap>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(
              title: Text(
                'Abrir rota com',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            for (final m in maps)
              ListTile(
                leading: const Icon(Icons.map_outlined, color: AppColors.primary),
                title: Text(m.mapName),
                onTap: () => Navigator.of(ctx).pop(m),
              ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------- UI

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FastLocation'),
        actions: [
          IconButton(
            tooltip: 'Histórico de consultas',
            icon: const Icon(Icons.history),
            onPressed: _openHistory,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _newSearch,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        icon: const Icon(Icons.search),
        label: const Text('Nova consulta'),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Observer(builder: (_) => _buildContent()),
          Observer(
            builder: (_) => _controller.isLoading
                ? const AppLoading()
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final last = _controller.lastAddress;
    final notFound = _controller.notFoundMessage;
    final items = _controller.listItems.toList();
    final isSearchResult = _controller.listMode == HomeListMode.searchResults;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppMetrics.spaceM,
        AppMetrics.spaceM,
        AppMetrics.spaceM,
        AppMetrics.spaceXL * 3, // espaço para o FAB
      ),
      children: [
        if (notFound != null) ...[
          EmptySearch(
            title: 'Nada encontrado',
            message: notFound,
            onDismiss: _controller.dismissNotFound,
          ),
          const SizedBox(height: AppMetrics.spaceM),
        ],
        if (last != null)
          LastAddressCard(address: last, onRoute: _traceRoute)
        else if (notFound == null)
          const EmptySearch.initial(),
        if (items.isNotEmpty) ...[
          SectionTitle(
            title: isSearchResult
                ? 'Resultados da busca (${items.length})'
                : 'Consultas recentes',
            trailing: isSearchResult
                ? TextButton(
                    onPressed: _controller.showRecent,
                    child: const Text('Fechar'),
                  )
                : TextButton(
                    onPressed: _openHistory,
                    child: const Text('Ver todas'),
                  ),
          ),
          if (isSearchResult)
            const Padding(
              padding: EdgeInsets.only(bottom: AppMetrics.spaceS),
              child: Text(
                'Toque em um endereço para defini-lo como consulta atual.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          AddressList(
            addresses: items,
            showDate: !isSearchResult,
            onSelect: _controller.selectAddress,
          ),
        ],
      ],
    );
  }
}
