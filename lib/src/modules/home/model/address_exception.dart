/// Tipos de falha tratados pela camada de serviço/controller.
enum AddressFailure {
  /// Entrada inválida (CEP com formato errado, campos curtos etc.).
  invalidInput,

  /// A API respondeu, mas não há endereço para o critério informado.
  notFound,

  /// Sem conexão, timeout ou servidor indisponível.
  network,

  /// Não foi possível obter coordenadas do endereço para a rota.
  geocoding,

  /// Nenhum app de mapas disponível no aparelho.
  noMapApp,

  /// Qualquer outra falha inesperada.
  unknown,
}

/// Exceção de domínio com mensagem já pronta para o usuário (pt-BR).
///
/// A [cause] original fica disponível para log/depuração, mas nunca é
/// exibida na tela.
class AddressException implements Exception {
  final AddressFailure failure;
  final String message;
  final Object? cause;

  const AddressException(this.failure, this.message, {this.cause});

  @override
  String toString() => 'AddressException(${failure.name}): $message';
}
