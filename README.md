# FastLocation

Aplicativo Flutter (Android e iOS) da **FastDelivery** para que os entregadores consultem
**endereço por CEP** e **CEP por endereço completo ou parcial**, mantenham um histórico local
das consultas e **tracem a rota** da localização atual até o último endereço consultado.

Desafio 2 — Desenvolvimento de Sistemas Móveis.

## Funcionalidades

| Requisito | Onde está |
|---|---|
| Comunicação com API pública de CEP ([ViaCEP](https://viacep.com.br)) | `lib/src/http/http_client.dart`, `modules/home/repositories/via_cep_repository.dart` |
| Armazenamento local para consultas recorrentes (Hive) | `shared/storage/`, `modules/home/repositories/address_local_repository.dart` |
| Gerenciamento de estado reativo (MobX) | `modules/*/controller/*_controller.dart` + `Observer` nas pages |
| Campos para consulta de CEP / endereço | `modules/home/components/search_form_sheet.dart` |
| Retorno dos dados consultados | `modules/home/components/last_address_card.dart`, `address_list.dart` |
| Tela de loading durante a consulta | `shared/components/app_loading.dart` |
| Resultado não encontrado | `modules/home/components/empty_search.dart` |
| Histórico de endereços consultados | `modules/history/` |
| Traçar rota (localização atual → último endereço) | `geocoding` + `map_launcher` em `home_page.dart` / `address_service.dart` |
| Tela de abertura animada com redirecionamento | `modules/initial/page/initial_page.dart` |

## Estrutura

```
lib/
├── main.dart                     # main() refatorado: inicializa Hive e sobe o app
└── src/
    ├── app.dart                  # MaterialApp, tema e rotas
    ├── http/http_client.dart     # configuração do Dio (base URL, timeouts, log em debug)
    ├── routes/app_routes.dart    # nomes das rotas
    ├── shared/
    │   ├── colors/               # AppColors
    │   ├── components/           # AppLoading, AppPrimaryButton, SectionTitle, AddressTile
    │   ├── metrics/              # AppMetrics (espaçamentos, raios, tamanhos)
    │   └── storage/              # HiveConfig, StorageKeys
    └── modules/
        ├── initial/page/         # splash com animação
        ├── home/
        │   ├── components/       # lista, último endereço, busca vazia, formulário
        │   ├── controller/       # HomeController (MobX)
        │   ├── model/            # AddressModel (ViaCEP + Hive), AddressException
        │   ├── page/             # HomePage (Observer + reaction)
        │   ├── repositories/     # ViaCepRepository (API) e AddressLocalRepository (Hive)
        │   └── service/          # AddressService (regras de negócio)
        └── history/
            ├── controller/       # HistoryController (MobX)
            └── page/             # HistoryPage (carga automática)
```

Fluxo: **Page → Controller (MobX) → Service → Repositories (Dio / Hive)**.

## Pré-requisitos

- Flutter SDK com Dart **3.8.1 ou superior** (Flutter 3.32+). Ver [Compatibilidade](#compatibilidade).
- Android SDK + um emulador ou aparelho Android (iOS exige macOS + Xcode).
- `python3` (usado só pelo `setup.sh` para ajustar o AndroidManifest/Info.plist).

## Como executar

```bash
git clone <URL-DO-REPOSITORIO>
cd fast_location
bash setup.sh        # pastas nativas, permissões, pub get, codegen, analyze e testes
flutter run
```

O `setup.sh` faz, nesta ordem:

1. `flutter create --platforms=android,ios .` — gera **somente** Android e iOS (não sobrescreve
   `lib/`, `test/` nem o `pubspec.yaml`) e remove pastas de outras plataformas, se existirem;
2. adiciona `android.permission.INTERNET` no `AndroidManifest.xml` (necessária no build de release)
   e `LSApplicationQueriesSchemes` (Google Maps / Waze) no `Info.plist`;
3. `flutter pub get`;
4. `dart run build_runner build --delete-conflicting-outputs` (MobX + Hive);
5. `flutter analyze` e `flutter test`.

Passo a passo manual, se preferir:

```bash
flutter create --platforms=android,ios --org br.com.fastdelivery --project-name fast_location .
# AndroidManifest.xml: <uses-permission android:name="android.permission.INTERNET" />
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

### CEPs para teste

| CEP | Resultado esperado |
|---|---|
| `01001000` | Praça da Sé, São Paulo/SP |
| `89010025` | Endereço em Blumenau/SC |
| `99999999` | Componente de "não encontrado" |
| Busca por endereço: `SC` / `Blumenau` / `XV de Novembro` | Lista de CEPs (toque em um para selecioná-lo) |

### Como usar

1. Após a abertura animada, a Home mostra o último endereço consultado (ou o estado vazio).
2. **Nova consulta** → aba *Por CEP* ou *Por endereço*.
3. **Traçar rota** abre o app de mapas instalado (Google Maps, Waze...) com a rota da posição
   atual até o endereço. Se houver mais de um app, o usuário escolhe.
4. Ícone de relógio → **Histórico** (carregado automaticamente). Tocar num item o torna o endereço
   atual; o ícone de lixeira limpa o histórico.

## Dependências

Todas as versões da especificação estão em `dependencies` / `dev_dependencies` do `pubspec.yaml`.

| Pacote | Uso |
|---|---|
| `dio` | HTTP com a API ViaCEP |
| `mobx`, `flutter_mobx`, `mobx_codegen` | estado reativo (`@observable`, `@action`, `@computed`, `Observer`, `reaction`) |
| `hive`, `hive_flutter`, `hive_generator` | banco local do histórico (TypeAdapter gerado de `AddressModel`) |
| `path`, `path_provider` (+ `_android`, `_ios`) | diretório do banco do Hive |
| `geocoding` | converte o endereço em latitude/longitude |
| `map_launcher` | abre a rota no app de mapas do aparelho |
| `build_runner` | executa o codegen |

### Compatibilidade

- **`map_launcher`**: a faixa `^2.2.1+1` da especificação para na **2.5.0+1**, cujo código Android
  ainda usa a *v1 embedding* (`PluginRegistry.Registrar`, removida do Flutter 3.29), AGP 3.5 e não
  declara `namespace` (obrigatório no AGP 8). Com o Flutter atual o build Android **não compila**.
  Por isso há um override `map_launcher: ^4.6.0` em `dependency_overrides` — a última versão com **a mesma API**
  usada no app (`MapLauncher.installedMaps`, `showDirections`, `Coords`). Se o professor exigir a
  versão literal e você usar um Flutter antigo (≤ 3.27), basta remover o override.
- **`geocoding`**: a faixa `^2.1.1` resolve para o `geocoding_android 3.3.1`, compilado com
  `compileSdk 33`. O Gradle reprova o build na tarefa `checkDebugAarMetadata`, porque as
  dependências AndroidX atuais exigem `compileSdk` 34 ou maior. O override `geocoding: ^4.0.0`
  (`geocoding_android 4.x`, `compileSdk 36`) resolve isso, e a API usada no app
  (`locationFromAddress`) é a mesma.
- **`path_provider_ios`** foi descontinuado (substituído por `path_provider_foundation`, que o
  próprio `path_provider` já usa). Mantido só por exigência da especificação.
- **Arquivos `*.g.dart` versionados**: `hive_generator 2.x` limita o `analyzer` a `< 7`, o que
  pode impedir o `build_runner` de rodar em SDKs muito novos. Os arquivos gerados estão no
  repositório, então o app compila e roda mesmo que o codegen falhe. Se alterar um `@observable`
  ou `@HiveField`, rode o `build_runner` novamente.

## Segurança e privacidade (LGPD)

- Só dados **públicos de endereço** (CEP, logradouro, bairro, cidade, UF, DDD, IBGE) e a data da
  consulta são gravados — nenhum dado do destinatário (nome, telefone, pedido).
- O banco fica no diretório privado do app; o histórico é limitado a 100 registros e pode ser
  apagado pelo usuário a qualquer momento.
- Entradas são validadas antes da requisição (CEP com 8 dígitos, UF da lista, mínimo de 3
  caracteres) e cada segmento da URL é codificado (`Uri.encodeComponent`), impedindo que `/` ou
  `?` digitados alterem o caminho chamado.
- Log HTTP só em modo debug e sem corpo de resposta; erros técnicos nunca são exibidos ao
  usuário — viram mensagens amigáveis (`AddressException`).
- Somente HTTPS; timeouts de 10 s; sem rede, CEPs já consultados são servidos do cache local.

## Testes

```bash
flutter test
```

Cobrem o parse do modelo (inclusive `"erro": "true"`/`true` do ViaCEP), validação de entradas,
fallback para o cache sem rede e o `HomeController` (loading, erro, resultados), usando
repositórios falsos — sem rede e sem Hive.

## Demonstração

<!-- arraste aqui o demo.mp4 pelo editor do GitHub -->

Roteiro gravado: abertura animada → consulta por CEP (01001000) → CEP inexistente (99999999)
→ busca por endereço (SC / Blumenau / XV de Novembro) → histórico → traçar rota → consulta offline.

https://github.com/user-attachments/assets/73f9fca5-3bdb-40e5-884a-d62601757367


