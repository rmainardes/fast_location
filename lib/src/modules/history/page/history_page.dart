import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';

import '../../../shared/colors/app_colors.dart';
import '../../../shared/components/address_tile.dart';
import '../../../shared/metrics/app_metrics.dart';
import '../../home/repositories/address_local_repository.dart';
import '../controller/history_controller.dart';

/// Histórico de endereços consultados.
///
/// Ao tocar em um item, devolve o endereço para a Home (vira o último
/// endereço consultado, pronto para traçar rota).
class HistoryPage extends StatefulWidget {
  final HistoryController? controller;

  const HistoryPage({super.key, this.controller});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late final HistoryController _controller;
  late final ReactionDisposer _errorDisposer;

  @override
  void initState() {
    super.initState();
    _controller =
        widget.controller ?? HistoryController(AddressLocalRepository());

    _errorDisposer = reaction<String?>((_) => _controller.errorMessage, (msg) {
      if (msg == null || !mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: AppColors.error),
      );
      _controller.clearError();
    });

    // Carregamento automático ao acessar a página.
    _controller.loadHistory();
  }

  @override
  void dispose() {
    _errorDisposer();
    super.dispose();
  }

  Future<void> _confirmClear() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Limpar histórico'),
        content: const Text(
          'Todos os endereços consultados serão removidos deste aparelho.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Limpar'),
          ),
        ],
      ),
    );
    if (confirmed == true) await _controller.clearHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de consultas'),
        actions: [
          Observer(
            builder: (_) => IconButton(
              tooltip: 'Limpar histórico',
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: _controller.isEmpty ? null : _confirmClear,
            ),
          ),
        ],
      ),
      body: Observer(
        builder: (_) {
          if (_controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (_controller.isEmpty) {
            return const _EmptyHistory();
          }
          final items = _controller.items.toList();
          return RefreshIndicator(
            onRefresh: _controller.loadHistory,
            child: ListView.builder(
              padding: const EdgeInsets.all(AppMetrics.spaceM),
              itemCount: items.length,
              itemBuilder: (_, i) => AddressTile(
                key: ValueKey(items[i].cepDigits),
                address: items[i],
                showDate: true,
                onTap: () => Navigator.of(context).pop(items[i]),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(AppMetrics.spaceL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.history_toggle_off,
              size: AppMetrics.iconL,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: AppMetrics.spaceM),
            Text(
              'Nenhuma consulta no histórico',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: AppMetrics.spaceS),
            Text(
              'Os endereços consultados ficam salvos neste aparelho.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
