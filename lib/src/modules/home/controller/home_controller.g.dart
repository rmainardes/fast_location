// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$HomeController on _HomeControllerBase, Store {
  Computed<bool>? _$hasLastAddressComputed;

  @override
  bool get hasLastAddress =>
      (_$hasLastAddressComputed ??= Computed<bool>(() => super.hasLastAddress,
              name: '_HomeControllerBase.hasLastAddress'))
          .value;
  Computed<bool>? _$showEmptyStateComputed;

  @override
  bool get showEmptyState =>
      (_$showEmptyStateComputed ??= Computed<bool>(() => super.showEmptyState,
              name: '_HomeControllerBase.showEmptyState'))
          .value;

  late final _$isLoadingAtom =
      Atom(name: '_HomeControllerBase.isLoading', context: context);

  @override
  bool get isLoading {
    _$isLoadingAtom.reportRead();
    return super.isLoading;
  }

  @override
  set isLoading(bool value) {
    _$isLoadingAtom.reportWrite(value, super.isLoading, () {
      super.isLoading = value;
    });
  }

  late final _$lastAddressAtom =
      Atom(name: '_HomeControllerBase.lastAddress', context: context);

  @override
  AddressModel? get lastAddress {
    _$lastAddressAtom.reportRead();
    return super.lastAddress;
  }

  @override
  set lastAddress(AddressModel? value) {
    _$lastAddressAtom.reportWrite(value, super.lastAddress, () {
      super.lastAddress = value;
    });
  }

  late final _$listItemsAtom =
      Atom(name: '_HomeControllerBase.listItems', context: context);

  @override
  ObservableList<AddressModel> get listItems {
    _$listItemsAtom.reportRead();
    return super.listItems;
  }

  @override
  set listItems(ObservableList<AddressModel> value) {
    _$listItemsAtom.reportWrite(value, super.listItems, () {
      super.listItems = value;
    });
  }

  late final _$listModeAtom =
      Atom(name: '_HomeControllerBase.listMode', context: context);

  @override
  HomeListMode get listMode {
    _$listModeAtom.reportRead();
    return super.listMode;
  }

  @override
  set listMode(HomeListMode value) {
    _$listModeAtom.reportWrite(value, super.listMode, () {
      super.listMode = value;
    });
  }

  late final _$notFoundMessageAtom =
      Atom(name: '_HomeControllerBase.notFoundMessage', context: context);

  @override
  String? get notFoundMessage {
    _$notFoundMessageAtom.reportRead();
    return super.notFoundMessage;
  }

  @override
  set notFoundMessage(String? value) {
    _$notFoundMessageAtom.reportWrite(value, super.notFoundMessage, () {
      super.notFoundMessage = value;
    });
  }

  late final _$errorMessageAtom =
      Atom(name: '_HomeControllerBase.errorMessage', context: context);

  @override
  String? get errorMessage {
    _$errorMessageAtom.reportRead();
    return super.errorMessage;
  }

  @override
  set errorMessage(String? value) {
    _$errorMessageAtom.reportWrite(value, super.errorMessage, () {
      super.errorMessage = value;
    });
  }

  late final _$searchByCepAsyncAction =
      AsyncAction('_HomeControllerBase.searchByCep', context: context);

  @override
  Future<void> searchByCep(String cep) {
    return _$searchByCepAsyncAction.run(() => super.searchByCep(cep));
  }

  late final _$searchByAddressAsyncAction =
      AsyncAction('_HomeControllerBase.searchByAddress', context: context);

  @override
  Future<void> searchByAddress(
      {required String uf, required String city, required String street}) {
    return _$searchByAddressAsyncAction
        .run(() => super.searchByAddress(uf: uf, city: city, street: street));
  }

  late final _$selectAddressAsyncAction =
      AsyncAction('_HomeControllerBase.selectAddress', context: context);

  @override
  Future<void> selectAddress(AddressModel address) {
    return _$selectAddressAsyncAction.run(() => super.selectAddress(address));
  }

  late final _$resolveRouteDestinationAsyncAction = AsyncAction(
      '_HomeControllerBase.resolveRouteDestination',
      context: context);

  @override
  Future<GeoPoint?> resolveRouteDestination() {
    return _$resolveRouteDestinationAsyncAction
        .run(() => super.resolveRouteDestination());
  }

  late final _$_HomeControllerBaseActionController =
      ActionController(name: '_HomeControllerBase', context: context);

  @override
  void loadFromStorage() {
    final _$actionInfo = _$_HomeControllerBaseActionController.startAction(
        name: '_HomeControllerBase.loadFromStorage');
    try {
      return super.loadFromStorage();
    } finally {
      _$_HomeControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void showRecent() {
    final _$actionInfo = _$_HomeControllerBaseActionController.startAction(
        name: '_HomeControllerBase.showRecent');
    try {
      return super.showRecent();
    } finally {
      _$_HomeControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setError(String message) {
    final _$actionInfo = _$_HomeControllerBaseActionController.startAction(
        name: '_HomeControllerBase.setError');
    try {
      return super.setError(message);
    } finally {
      _$_HomeControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearError() {
    final _$actionInfo = _$_HomeControllerBaseActionController.startAction(
        name: '_HomeControllerBase.clearError');
    try {
      return super.clearError();
    } finally {
      _$_HomeControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void dismissNotFound() {
    final _$actionInfo = _$_HomeControllerBaseActionController.startAction(
        name: '_HomeControllerBase.dismissNotFound');
    try {
      return super.dismissNotFound();
    } finally {
      _$_HomeControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
isLoading: ${isLoading},
lastAddress: ${lastAddress},
listItems: ${listItems},
listMode: ${listMode},
notFoundMessage: ${notFoundMessage},
errorMessage: ${errorMessage},
hasLastAddress: ${hasLastAddress},
showEmptyState: ${showEmptyState}
    ''';
  }
}
