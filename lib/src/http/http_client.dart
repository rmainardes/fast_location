import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Configuração do Dio para comunicação HTTP com sistemas externos.
///
/// Instância única (lazy) com base URL do ViaCEP, timeouts curtos (o
/// entregador está em campo, com rede instável) e log apenas em debug,
/// sem corpo de resposta — evita expor endereços em logs de produção.
abstract final class AppHttpClient {
  static const String viaCepBaseUrl = 'https://viacep.com.br/ws';

  /// Timeouts em milissegundos (Dio 4.x usa int).
  static const int connectTimeoutMs = 10000;
  static const int receiveTimeoutMs = 10000;

  static Dio? _dio;

  static Dio get dio => _dio ??= _create();

  static Dio _create() {
    final dio = Dio(
      BaseOptions(
        baseUrl: viaCepBaseUrl,
        connectTimeout: connectTimeoutMs,
        receiveTimeout: receiveTimeoutMs,
        responseType: ResponseType.json,
        headers: const {'Accept': 'application/json'},
      ),
    );

    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          request: true,
          requestHeader: false,
          requestBody: false,
          responseHeader: false,
          responseBody: false,
          error: true,
          logPrint: (obj) => debugPrint(obj.toString()),
        ),
      );
    }
    return dio;
  }
}
