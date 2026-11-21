/// Nomes de diretório, boxes e typeIds do armazenamento local (Hive).
abstract final class StorageKeys {
  /// Subdiretório (dentro de Documents do app) onde ficam os arquivos do Hive.
  static const String databaseDirectory = 'fast_location_db';

  /// Box com o histórico de endereços consultados (chave = CEP).
  static const String addressHistoryBox = 'address_history';

  /// typeId do adapter de AddressModel. Nunca reutilizar/alterar após publicado.
  static const int addressModelTypeId = 0;

  /// Limite de registros mantidos no histórico local.
  static const int maxHistoryItems = 100;
}
