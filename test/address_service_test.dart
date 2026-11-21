import 'package:fast_location/src/modules/home/controller/home_controller.dart';
import 'package:fast_location/src/modules/home/model/address_exception.dart';
import 'package:fast_location/src/modules/home/model/address_model.dart';
import 'package:fast_location/src/modules/home/repositories/address_local_repository.dart';
import 'package:fast_location/src/modules/home/repositories/via_cep_repository.dart';
import 'package:fast_location/src/modules/home/service/address_service.dart';
import 'package:flutter_test/flutter_test.dart';

/// Fakes sem rede e sem Hive.
class FakeViaCepRepository implements ViaCepRepository {
  AddressModel? cepResult;
  List<AddressModel> addressResults = const [];
  AddressException? error;
  String? lastCep;

  @override
  Future<AddressModel?> fetchByCep(String cep) async {
    lastCep = cep;
    if (error != null) throw error!;
    return cepResult;
  }

  @override
  Future<List<AddressModel>> fetchByAddress({
    required String uf,
    required String city,
    required String street,
  }) async {
    if (error != null) throw error!;
    return addressResults;
  }
}

class FakeLocalRepository implements AddressLocalRepository {
  final Map<String, AddressModel> store = {};

  @override
  List<AddressModel> getAll() {
    final items = store.values.toList()
      ..sort((a, b) => b.consultedAt!.compareTo(a.consultedAt!));
    return items;
  }

  @override
  AddressModel? getLast() {
    final all = getAll();
    return all.isEmpty ? null : all.first;
  }

  @override
  AddressModel? getByCep(String cepDigits) => store[cepDigits];

  @override
  Future<void> save(AddressModel address) async =>
      store[address.cepDigits] = address;

  @override
  Future<void> clear() async => store.clear();
}

const _blumenau = AddressModel(
  cep: '89010-025',
  logradouro: 'Rua XV de Novembro',
  bairro: 'Centro',
  localidade: 'Blumenau',
  uf: 'SC',
);

void main() {
  late FakeViaCepRepository remote;
  late FakeLocalRepository local;
  late AddressService service;

  setUp(() {
    remote = FakeViaCepRepository();
    local = FakeLocalRepository();
    service = AddressService(
      remote: remote,
      local: local,
      geocode: (_) async => const GeoPoint(-26.9, -49.07),
    );
  });

  group('AddressService', () {
    test('normaliza CEP com máscara', () {
      expect(AddressService.normalizeCep('89010-025'), '89010025');
      expect(AddressService.normalizeCep('8901002'), isNull);
      expect(AddressService.normalizeCep('abc'), isNull);
    });

    test('CEP inválido não chama a API', () async {
      await expectLater(
        service.searchByCep('123'),
        throwsA(isA<AddressException>().having(
            (e) => e.failure, 'failure', AddressFailure.invalidInput)),
      );
      expect(remote.lastCep, isNull);
    });

    test('consulta por CEP grava no histórico', () async {
      remote.cepResult = _blumenau;
      final result = await service.searchByCep('89010-025');

      expect(remote.lastCep, '89010025');
      expect(result.consultedAt, isNotNull);
      expect(local.getByCep('89010025'), isNotNull);
    });

    test('CEP inexistente gera notFound', () async {
      remote.cepResult = null;
      await expectLater(
        service.searchByCep('99999999'),
        throwsA(isA<AddressException>()
            .having((e) => e.failure, 'failure', AddressFailure.notFound)),
      );
    });

    test('sem rede usa o histórico local como cache', () async {
      await local.save(_blumenau.copyWith(consultedAt: DateTime(2026)));
      remote.error = const AddressException(AddressFailure.network, 'offline');

      final result = await service.searchByCep('89010025');
      expect(result.localidade, 'Blumenau');
    });

    test('busca por endereço valida tamanho mínimo', () async {
      await expectLater(
        service.searchByAddress(uf: 'SC', city: 'Bl', street: 'XV de'),
        throwsA(isA<AddressException>().having(
            (e) => e.failure, 'failure', AddressFailure.invalidInput)),
      );
    });

    test('busca por endereço sem resultado gera notFound', () async {
      remote.addressResults = const [];
      await expectLater(
        service.searchByAddress(uf: 'SC', city: 'Blumenau', street: 'Inexistente'),
        throwsA(isA<AddressException>()
            .having((e) => e.failure, 'failure', AddressFailure.notFound)),
      );
    });
  });

  group('HomeController', () {
    test('consulta por CEP atualiza último endereço e loading', () async {
      remote.cepResult = _blumenau;
      final controller = HomeController(service);

      final future = controller.searchByCep('89010025');
      expect(controller.isLoading, isTrue);
      await future;

      expect(controller.isLoading, isFalse);
      expect(controller.lastAddress?.cep, '89010-025');
      expect(controller.errorMessage, isNull);
    });

    test('erro de rede sem cache vira errorMessage', () async {
      remote.error = const AddressException(AddressFailure.network, 'offline');
      final controller = HomeController(service);

      await controller.searchByCep('89010025');
      expect(controller.errorMessage, 'offline');
      expect(controller.lastAddress, isNull);
    });

    test('busca por endereço preenche resultados', () async {
      remote.addressResults = const [_blumenau];
      final controller = HomeController(service);

      await controller.searchByAddress(uf: 'SC', city: 'Blumenau', street: 'XV');
      // "XV" tem menos de 3 caracteres -> inválido
      expect(controller.errorMessage, isNotNull);

      await controller.searchByAddress(
          uf: 'SC', city: 'Blumenau', street: 'XV de Novembro');
      expect(controller.listMode, HomeListMode.searchResults);
      expect(controller.listItems, hasLength(1));
    });
  });
}
