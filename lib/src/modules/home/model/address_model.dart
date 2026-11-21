import 'package:hive/hive.dart';

import '../../../shared/storage/storage_keys.dart';

part 'address_model.g.dart';

/// Estrutura de dados do retorno da API ViaCEP (https://viacep.com.br/ws).
///
/// Também é o tipo persistido no Hive (histórico de consultas).
@HiveType(typeId: StorageKeys.addressModelTypeId)
class AddressModel {
  @HiveField(0)
  final String cep;

  @HiveField(1)
  final String logradouro;

  @HiveField(2)
  final String complemento;

  @HiveField(3)
  final String bairro;

  @HiveField(4)
  final String localidade;

  @HiveField(5)
  final String uf;

  @HiveField(6)
  final String ddd;

  @HiveField(7)
  final String ibge;

  /// Momento da consulta (local). Não vem da API.
  @HiveField(8)
  final DateTime? consultedAt;

  const AddressModel({
    required this.cep,
    this.logradouro = '',
    this.complemento = '',
    this.bairro = '',
    required this.localidade,
    required this.uf,
    this.ddd = '',
    this.ibge = '',
    this.consultedAt,
  });

  /// Converte o JSON do ViaCEP. Lança [FormatException] se faltar campo
  /// essencial — protege a UI de respostas inesperadas.
  factory AddressModel.fromJson(Map<String, dynamic> json) {
    final cep = _str(json['cep']);
    final localidade = _str(json['localidade']);
    final uf = _str(json['uf']);
    if (cep.isEmpty || localidade.isEmpty || uf.isEmpty) {
      throw const FormatException('Resposta do ViaCEP sem campos obrigatórios.');
    }
    return AddressModel(
      cep: cep,
      logradouro: _str(json['logradouro']),
      complemento: _str(json['complemento']),
      bairro: _str(json['bairro']),
      localidade: localidade,
      uf: uf,
      ddd: _str(json['ddd']),
      ibge: _str(json['ibge']),
    );
  }

  /// O ViaCEP sinaliza CEP inexistente com `"erro": "true"` (string, API
  /// atual) ou `"erro": true` (boolean, versões anteriores).
  static bool isNotFoundResponse(Map<String, dynamic> json) {
    final erro = json['erro'];
    return erro == true || erro?.toString().toLowerCase() == 'true';
  }

  static String _str(dynamic value) => (value ?? '').toString().trim();

  /// CEP somente com dígitos (chave do histórico).
  String get cepDigits => cep.replaceAll(RegExp(r'\D'), '');

  /// Ex.: "Rua XV de Novembro, Centro"
  String get streetLine {
    final parts = [logradouro, bairro].where((s) => s.isNotEmpty);
    return parts.isEmpty ? 'Logradouro não informado' : parts.join(', ');
  }

  /// Ex.: "Blumenau - SC"
  String get cityLine => '$localidade - $uf';

  /// Endereço completo usado na geocodificação para traçar a rota.
  String get fullAddress {
    final parts = [
      logradouro,
      bairro,
      '$localidade - $uf',
      cep,
      'Brasil',
    ].where((s) => s.trim().isNotEmpty);
    return parts.join(', ');
  }

  AddressModel copyWith({DateTime? consultedAt}) => AddressModel(
        cep: cep,
        logradouro: logradouro,
        complemento: complemento,
        bairro: bairro,
        localidade: localidade,
        uf: uf,
        ddd: ddd,
        ibge: ibge,
        consultedAt: consultedAt ?? this.consultedAt,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AddressModel && other.cepDigits == cepDigits;

  @override
  int get hashCode => cepDigits.hashCode;

  @override
  String toString() => 'AddressModel($cep, $localidade-$uf)';
}
