import 'package:hive/hive.dart';

import '../../../shared/storage/hive_config.dart';
import '../../../shared/storage/storage_keys.dart';
import '../model/address_model.dart';

/// Acesso ao armazenamento local (Hive) do histórico de consultas.
///
/// A chave de cada registro é o CEP (só dígitos): consultar o mesmo CEP de
/// novo atualiza o registro e a data, sem duplicar.
class AddressLocalRepository {
  final Box<AddressModel>? _injectedBox;

  /// [box] opcional permite injetar uma box em testes.
  AddressLocalRepository({Box<AddressModel>? box}) : _injectedBox = box;

  Box<AddressModel> get _box => _injectedBox ?? HiveConfig.addressHistoryBox;

  /// Histórico ordenado da consulta mais recente para a mais antiga.
  List<AddressModel> getAll() {
    final items = _box.values.toList();
    items.sort((a, b) {
      final da = a.consultedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final db = b.consultedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return db.compareTo(da);
    });
    return items;
  }

  AddressModel? getLast() {
    final all = getAll();
    return all.isEmpty ? null : all.first;
  }

  AddressModel? getByCep(String cepDigits) => _box.get(cepDigits);

  Future<void> save(AddressModel address) async {
    await _box.put(address.cepDigits, address);
    await _trimToLimit();
  }

  Future<void> clear() => _box.clear();

  /// Mantém só os [StorageKeys.maxHistoryItems] registros mais recentes.
  Future<void> _trimToLimit() async {
    if (_box.length <= StorageKeys.maxHistoryItems) return;
    final toRemove = getAll()
        .skip(StorageKeys.maxHistoryItems)
        .map((a) => a.cepDigits)
        .toList();
    await _box.deleteAll(toRemove);
  }
}
