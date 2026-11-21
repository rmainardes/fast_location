import 'package:flutter/foundation.dart';
import 'package:mobx/mobx.dart';

import '../model/address_exception.dart';
import '../model/address_model.dart';
import '../service/address_service.dart';

part 'home_controller.g.dart';

/// Origem dos itens exibidos na lista da Home.
enum HomeListMode { recent, searchResults }

/// Quantidade de consultas recentes listadas abaixo do card principal.
const int kRecentOnHome = 5;

class HomeController = _HomeControllerBase with _$HomeController;

abstract class _HomeControllerBase with Store {
  final AddressService _service;

  _HomeControllerBase(this._service);

  /// Exibe a tela de loading durante consultas externas.
  @observable
  bool isLoading = false;

  /// Último endereço consultado (card principal + rota).
  @observable
  AddressModel? lastAddress;

  /// Consultas recentes (histórico) ou resultados de busca por endereço.
  @observable
  ObservableList<AddressModel> listItems = ObservableList<AddressModel>();

  @observable
  HomeListMode listMode = HomeListMode.recent;

  /// Mensagem quando a busca não retornou resultado (componente de busca
  /// vazia). `null` = não há busca vazia para mostrar.
  @observable
  String? notFoundMessage;

  /// Mensagem de erro consumida pela page via `reaction` (SnackBar).
  @observable
  String? errorMessage;

  @computed
  bool get hasLastAddress => lastAddress != null;

  @computed
  bool get showEmptyState => notFoundMessage != null || !hasLastAddress;

  /// Carrega o último endereço e as consultas recentes do armazenamento local.
  @action
  void loadFromStorage() {
    lastAddress = _service.getLastConsulted();
    _showRecent();
  }

  @action
  Future<void> searchByCep(String cep) async {
    await _runSearch(() async {
      final address = await _service.searchByCep(cep);
      lastAddress = address;
      notFoundMessage = null;
      _showRecent();
    });
  }

  @action
  Future<void> searchByAddress({
    required String uf,
    required String city,
    required String street,
  }) async {
    await _runSearch(() async {
      final results =
          await _service.searchByAddress(uf: uf, city: city, street: street);
      notFoundMessage = null;
      listMode = HomeListMode.searchResults;
      listItems = ObservableList<AddressModel>.of(results);
    });
  }

  /// Usuário escolheu um endereço na lista (resultado ou histórico).
  @action
  Future<void> selectAddress(AddressModel address) async {
    lastAddress = await _service.select(address);
    notFoundMessage = null;
    _showRecent();
  }

  /// Volta a lista para as consultas recentes.
  @action
  void showRecent() => _showRecent();

  /// Obtém as coordenadas do último endereço para traçar a rota.
  /// Retorna `null` (e preenche [errorMessage]) em caso de falha.
  @action
  Future<GeoPoint?> resolveRouteDestination() async {
    final address = lastAddress;
    if (address == null) {
      errorMessage = 'Consulte um endereço antes de traçar a rota.';
      return null;
    }
    isLoading = true;
    try {
      return await _service.getCoordinates(address);
    } on AddressException catch (e) {
      errorMessage = e.message;
      return null;
    } catch (e) {
      debugPrint('HomeController.resolveRouteDestination: $e');
      errorMessage = 'Não foi possível traçar a rota agora.';
      return null;
    } finally {
      isLoading = false;
    }
  }

  @action
  void setError(String message) => errorMessage = message;

  @action
  void clearError() => errorMessage = null;

  @action
  void dismissNotFound() => notFoundMessage = null;

  void _showRecent() {
    listMode = HomeListMode.recent;
    final recent = _service.getHistory();
    // O primeiro item já aparece no card de "último endereço".
    listItems = ObservableList<AddressModel>.of(recent.skip(1).take(kRecentOnHome));
  }

  Future<void> _runSearch(Future<void> Function() body) async {
    if (isLoading) return; // evita consultas concorrentes (duplo toque)
    isLoading = true;
    errorMessage = null;
    try {
      await body();
    } on AddressException catch (e) {
      if (e.failure == AddressFailure.notFound) {
        notFoundMessage = e.message;
      } else {
        errorMessage = e.message;
      }
    } catch (e) {
      debugPrint('HomeController: erro inesperado na consulta: $e');
      errorMessage = 'Erro inesperado. Tente novamente.';
    } finally {
      isLoading = false;
    }
  }
}
