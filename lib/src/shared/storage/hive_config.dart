import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../modules/home/model/address_model.dart';
import 'storage_keys.dart';

/// Configuração do armazenamento local (Hive).
///
/// Os dados ficam no diretório privado do app (Documents/fast_location_db),
/// inacessível a outros apps. Só são gravados dados públicos de endereço
/// (CEP, logradouro, bairro, cidade, UF) e a data da consulta — nenhum dado
/// pessoal do destinatário é persistido (LGPD: minimização de dados).
abstract final class HiveConfig {
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;

    final appDir = await getApplicationDocumentsDirectory();
    Hive.init(p.join(appDir.path, StorageKeys.databaseDirectory));

    if (!Hive.isAdapterRegistered(StorageKeys.addressModelTypeId)) {
      Hive.registerAdapter(AddressModelAdapter());
    }

    await _openBoxSafely<AddressModel>(StorageKeys.addressHistoryBox);
    _initialized = true;
  }

  /// Abre a box; se o arquivo estiver corrompido (ex.: mudança incompatível
  /// de schema), descarta-o e recria, para o app não travar na abertura.
  static Future<Box<T>> _openBoxSafely<T>(String name) async {
    try {
      return await Hive.openBox<T>(name);
    } catch (e) {
      debugPrint('HiveConfig: falha ao abrir box "$name", recriando. ($e)');
      await Hive.deleteBoxFromDisk(name);
      return Hive.openBox<T>(name);
    }
  }

  static Box<AddressModel> get addressHistoryBox =>
      Hive.box<AddressModel>(StorageKeys.addressHistoryBox);
}
