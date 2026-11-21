import 'package:flutter/foundation.dart';
import 'package:mobx/mobx.dart';

import '../../home/model/address_model.dart';
import '../../home/repositories/address_local_repository.dart';

part 'history_controller.g.dart';

class HistoryController = _HistoryControllerBase with _$HistoryController;

/// Controla a tela de histórico, carregando os dados do armazenamento local.
abstract class _HistoryControllerBase with Store {
  final AddressLocalRepository _local;

  _HistoryControllerBase(this._local);

  @observable
  bool isLoading = false;

  @observable
  ObservableList<AddressModel> items = ObservableList<AddressModel>();

  @observable
  String? errorMessage;

  @computed
  bool get isEmpty => items.isEmpty;

  @action
  Future<void> loadHistory() async {
    isLoading = true;
    errorMessage = null;
    try {
      // Leitura do Hive é síncrona (box já aberta); o Future mantém a API
      // pronta para uma eventual fonte assíncrona.
      items = ObservableList<AddressModel>.of(_local.getAll());
    } catch (e) {
      debugPrint('HistoryController.loadHistory: $e');
      errorMessage = 'Não foi possível carregar o histórico.';
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> clearHistory() async {
    try {
      await _local.clear();
      items = ObservableList<AddressModel>();
    } catch (e) {
      debugPrint('HistoryController.clearHistory: $e');
      errorMessage = 'Não foi possível limpar o histórico.';
    }
  }

  @action
  void clearError() => errorMessage = null;
}
