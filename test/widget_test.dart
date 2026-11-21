import 'package:fast_location/src/modules/home/components/empty_search.dart';
import 'package:fast_location/src/modules/home/model/address_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AddressModel', () {
    test('converte o JSON do ViaCEP', () {
      final model = AddressModel.fromJson(const {
        'cep': '01001-000',
        'logradouro': 'Praça da Sé',
        'complemento': 'lado ímpar',
        'bairro': 'Sé',
        'localidade': 'São Paulo',
        'uf': 'SP',
        'ibge': '3550308',
        'ddd': '11',
      });

      expect(model.cep, '01001-000');
      expect(model.cepDigits, '01001000');
      expect(model.cityLine, 'São Paulo - SP');
      expect(model.streetLine, 'Praça da Sé, Sé');
      expect(model.fullAddress, contains('Brasil'));
    });

    test('reconhece "erro" como string e como boolean', () {
      expect(AddressModel.isNotFoundResponse(const {'erro': 'true'}), isTrue);
      expect(AddressModel.isNotFoundResponse(const {'erro': true}), isTrue);
      expect(AddressModel.isNotFoundResponse(const {'cep': '1'}), isFalse);
    });

    test('rejeita resposta sem campos obrigatórios', () {
      expect(
        () => AddressModel.fromJson(const {'cep': '01001-000'}),
        throwsFormatException,
      );
    });
  });

  testWidgets('EmptySearch exibe título e mensagem', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: EmptySearch(title: 'Nada encontrado', message: 'CEP não encontrado.'),
        ),
      ),
    );

    expect(find.text('Nada encontrado'), findsOneWidget);
    expect(find.text('CEP não encontrado.'), findsOneWidget);
  });
}
