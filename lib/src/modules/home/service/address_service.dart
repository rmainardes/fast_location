import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart' as geo;

import '../model/address_exception.dart';
import '../model/address_model.dart';
import '../repositories/address_local_repository.dart';
import '../repositories/via_cep_repository.dart';

/// Coordenadas de destino para traçar rota.
class GeoPoint {
  final double latitude;
  final double longitude;

  const GeoPoint(this.latitude, this.longitude);
}

/// Assinatura da geocodificação (endereço -> coordenadas), injetável em testes.
typedef GeocodeFn = Future<GeoPoint?> Function(String address);

/// Regras de negócio da consulta de endereços.
///
/// - valida/normaliza entradas antes de chamar a API;
/// - grava cada consulta bem-sucedida no histórico local;
/// - em falha de rede, usa o histórico local como cache para CEPs já
///   consultados (o entregador continua trabalhando sem sinal);
/// - converte endereço em coordenadas para a rota.
class AddressService {
  static const List<String> ufs = [
    'AC', 'AL', 'AP', 'AM', 'BA', 'CE', 'DF', 'ES', 'GO', 'MA', 'MT', 'MS', //
    'MG', 'PA', 'PB', 'PR', 'PE', 'PI', 'RJ', 'RN', 'RS', 'RO', 'RR', 'SC', //
    'SP', 'SE', 'TO',
  ];

  static const int minSearchLength = 3;

  final ViaCepRepository _remote;
  final AddressLocalRepository _local;
  final GeocodeFn _geocode;

  AddressService({
    required ViaCepRepository remote,
    required AddressLocalRepository local,
    GeocodeFn? geocode,
  })  : _remote = remote,
        _local = local,
        _geocode = geocode ?? _defaultGeocode;

  /// Mantém só dígitos. Retorna `null` se não houver exatamente 8.
  static String? normalizeCep(String input) {
    final digits = input.replaceAll(RegExp(r'\D'), '');
    return digits.length == 8 ? digits : null;
  }

  /// Consulta endereço por CEP.
  ///
  /// Lança [AddressException] com [AddressFailure.invalidInput],
  /// [AddressFailure.notFound], [AddressFailure.network] ou
  /// [AddressFailure.unknown].
  Future<AddressModel> searchByCep(String rawCep) async {
    final cep = normalizeCep(rawCep);
    if (cep == null) {
      throw const AddressException(
        AddressFailure.invalidInput,
        'Informe um CEP válido com 8 dígitos.',
      );
    }

    try {
      final address = await _remote.fetchByCep(cep);
      if (address == null) {
        throw const AddressException(
          AddressFailure.notFound,
          'CEP não encontrado.',
        );
      }
      return _register(address);
    } on AddressException catch (e) {
      if (e.failure == AddressFailure.network) {
        final cached = _local.getByCep(cep);
        if (cached != null) return _register(cached);
      }
      rethrow;
    }
  }

  /// Busca CEPs por endereço completo ou parcial (UF + cidade + logradouro).
  ///
  /// Não grava no histórico: só o endereço que o usuário escolher na lista
  /// (via [select]) vira consulta registrada.
  Future<List<AddressModel>> searchByAddress({
    required String uf,
    required String city,
    required String street,
  }) async {
    final normalizedUf = uf.trim().toUpperCase();
    final normalizedCity = _collapseSpaces(city);
    final normalizedStreet = _collapseSpaces(street);

    if (!ufs.contains(normalizedUf)) {
      throw const AddressException(
        AddressFailure.invalidInput,
        'Selecione uma UF válida.',
      );
    }
    if (normalizedCity.length < minSearchLength ||
        normalizedStreet.length < minSearchLength) {
      throw const AddressException(
        AddressFailure.invalidInput,
        'Cidade e logradouro precisam ter ao menos 3 caracteres.',
      );
    }

    final results = await _remote.fetchByAddress(
      uf: normalizedUf,
      city: normalizedCity,
      street: normalizedStreet,
    );
    if (results.isEmpty) {
      throw const AddressException(
        AddressFailure.notFound,
        'Nenhum CEP encontrado para o endereço informado.',
      );
    }
    return results;
  }

  /// Registra no histórico um endereço escolhido em uma lista.
  Future<AddressModel> select(AddressModel address) => _register(address);

  List<AddressModel> getHistory() => _local.getAll();

  AddressModel? getLastConsulted() => _local.getLast();

  Future<void> clearHistory() => _local.clear();

  /// Coordenadas do endereço para traçar a rota.
  Future<GeoPoint> getCoordinates(AddressModel address) async {
    GeoPoint? point;
    try {
      point = await _geocode(address.fullAddress);
      // Fallback: sem logradouro/bairro, tenta só CEP + cidade.
      point ??= await _geocode('${address.cep}, ${address.cityLine}, Brasil');
    } catch (e) {
      throw AddressException(
        AddressFailure.geocoding,
        'Não foi possível localizar o endereço no mapa.',
        cause: e,
      );
    }
    if (point == null) {
      throw const AddressException(
        AddressFailure.geocoding,
        'Endereço não localizado no mapa.',
      );
    }
    return point;
  }

  Future<AddressModel> _register(AddressModel address) async {
    final stamped = address.copyWith(consultedAt: DateTime.now());
    try {
      await _local.save(stamped);
    } catch (e) {
      // Falha no cache não pode impedir o entregador de ver o endereço.
      debugPrint('AddressService: falha ao gravar histórico ($e)');
    }
    return stamped;
  }

  static String _collapseSpaces(String s) =>
      s.trim().replaceAll(RegExp(r'\s+'), ' ');

  static Future<GeoPoint?> _defaultGeocode(String address) async {
    try {
      final locations = await geo.locationFromAddress(address);
      if (locations.isEmpty) return null;
      return GeoPoint(locations.first.latitude, locations.first.longitude);
    } on geo.NoResultFoundException {
      return null;
    }
  }
}
