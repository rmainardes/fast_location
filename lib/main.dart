import 'package:flutter/material.dart';

import 'src/app.dart';
import 'src/shared/storage/hive_config.dart';

/// Ponto de entrada do FastLocation.
///
/// Garante a inicialização dos bindings do Flutter e do armazenamento local
/// (Hive) antes de subir a árvore de widgets, para que os repositórios já
/// encontrem as boxes abertas.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveConfig.init();
  runApp(const FastLocationApp());
}
