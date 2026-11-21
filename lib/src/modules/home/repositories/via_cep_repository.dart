import 'package:dio/dio.dart';

import '../../../http/http_client.dart';
import '../model/address_exception.dart';
import '../model/address_model.dart';

/// Comunicação com a API pública ViaCEP.
///
/// Converte erros de transporte (DioError) em [AddressException] para que as
/// camadas superiores não dependam do Dio.
class ViaCepRepository {
  final Dio _dio;

  ViaCepRepository({Dio? dio}) : _dio = dio ?? AppHttpClient.dio;

  /// GET /{cep}/json/  — [cep] deve conter exatamente 8 dígitos.
  ///
  /// Retorna `null` quando o CEP tem formato válido, mas não existe.
  Future<AddressModel?> fetchByCep(String cep) async {
    final data = await _get('/$cep/json/');
    if (data is! Map<String, dynamic>) {
      throw const AddressException(
        AddressFailure.unknown,
        'Resposta inesperada do serviço de CEP.',
      );
    }
    if (AddressModel.isNotFoundResponse(data)) return null;
    return _parse(data);
  }

  /// GET /{UF}/{Cidade}/{Logradouro}/json/  — até 50 resultados.
  ///
  /// Cada segmento é codificado com [Uri.encodeComponent], impedindo que um
  /// "/" ou "?" digitado pelo usuário altere o caminho da requisição.
  Future<List<AddressModel>> fetchByAddress({
    required String uf,
    required String city,
    required String street,
  }) async {
    final path = '/${Uri.encodeComponent(uf)}'
        '/${Uri.encodeComponent(city)}'
        '/${Uri.encodeComponent(street)}/json/';

    final data = await _get(path);
    if (data is! List) {
      // A API devolve objeto {"erro": ...} em alguns cenários de busca.
      if (data is Map<String, dynamic> && AddressModel.isNotFoundResponse(data)) {
        return const [];
      }
      throw const AddressException(
        AddressFailure.unknown,
        'Resposta inesperada do serviço de CEP.',
      );
    }
    return data
        .whereType<Map<String, dynamic>>()
        .map(_parseOrNull)
        .whereType<AddressModel>()
        .toList(growable: false);
  }

  Future<dynamic> _get(String path) async {
    try {
      final response = await _dio.get<dynamic>(path);
      return response.data;
    } on DioError catch (e) {
      throw _mapDioError(e);
    }
  }

  AddressModel _parse(Map<String, dynamic> json) {
    try {
      return AddressModel.fromJson(json);
    } on FormatException catch (e) {
      throw AddressException(
        AddressFailure.unknown,
        'Resposta incompleta do serviço de CEP.',
        cause: e,
      );
    }
  }

  AddressModel? _parseOrNull(Map<String, dynamic> json) {
    try {
      return AddressModel.fromJson(json);
    } on FormatException {
      return null; // ignora item malformado sem derrubar a lista inteira
    }
  }

  AddressException _mapDioError(DioError e) {
    switch (e.type) {
      case DioErrorType.connectTimeout:
      case DioErrorType.sendTimeout:
      case DioErrorType.receiveTimeout:
        return AddressException(
          AddressFailure.network,
          'Tempo de conexão esgotado. Verifique sua internet e tente novamente.',
          cause: e,
        );
      case DioErrorType.response:
        final status = e.response?.statusCode ?? 0;
        if (status == 400) {
          return AddressException(
            AddressFailure.invalidInput,
            'Dados de busca inválidos. Confira o CEP ou o endereço informado.',
            cause: e,
          );
        }
        if (status >= 500) {
          return AddressException(
            AddressFailure.network,
            'Serviço de CEP indisponível no momento. Tente novamente em instantes.',
            cause: e,
          );
        }
        return AddressException(
          AddressFailure.unknown,
          'Não foi possível concluir a consulta (HTTP $status).',
          cause: e,
        );
      case DioErrorType.cancel:
        return AddressException(
          AddressFailure.unknown,
          'Consulta cancelada.',
          cause: e,
        );
      case DioErrorType.other:
        return AddressException(
          AddressFailure.network,
          'Sem conexão com a internet. Verifique sua rede e tente novamente.',
          cause: e,
        );
    }
  }
}
