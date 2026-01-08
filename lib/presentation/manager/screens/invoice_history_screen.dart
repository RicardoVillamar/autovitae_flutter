import 'package:flutter/material.dart';
import 'package:autovitae/data/models/factura.dart';
import 'package:autovitae/viewmodels/factura_viewmodel.dart';
import 'package:autovitae/viewmodels/mantenimiento_viewmodel.dart';
import 'package:autovitae/core/utils/session_manager.dart';
import 'package:autovitae/core/theme/app_colors.dart';
import 'package:autovitae/presentation/shared/screens/invoice_detail_screen.dart';
import 'package:autovitae/presentation/shared/widgets/cards/generic_list_tile.dart';

class InvoiceHistoryScreen extends StatefulWidget {
  const InvoiceHistoryScreen({super.key});

  @override
  State<InvoiceHistoryScreen> createState() =>
      _InvoiceHistoryScreenState();
}

class _InvoiceHistoryScreenState
    extends State<InvoiceHistoryScreen> {
  final FacturaViewModel _facturaViewModel = FacturaViewModel();
  final MantenimientoViewModel _mantenimientoViewModel =
      MantenimientoViewModel();
  bool _isLoading = false;
  List<Factura> _facturas = [];

  @override
  void initState() {
    super.initState();
    _loadFacturas();
  }

  Future<void> _loadFacturas() async {
    final gerente = await SessionManager().getGerente();
    if (gerente?.uidTaller == null) return;

    setState(() => _isLoading = true);

    try {
      // 1. Cargar mantenimientos del taller
      await _mantenimientoViewModel.cargarMantenimientosPorTaller(
        gerente!.uidTaller!,
      );

      List<Factura> loadedFacturas = [];

      // 2. Para cada mantenimiento, buscar su factura
      // Nota: Esto no es óptimo para producción (N+1 queries), pero cumple con la estructura actual
      for (var mantenimiento in _mantenimientoViewModel.mantenimientos) {
        if (mantenimiento.uidMantenimiento != null) {
          await _facturaViewModel.cargarFacturasPorMantenimiento(
            mantenimiento.uidMantenimiento!,
          );
          if (_facturaViewModel.facturas.isNotEmpty) {
            loadedFacturas.addAll(_facturaViewModel.facturas);
          }
        }
      }

      // Ordenar por fecha de emisión descendente
      loadedFacturas.sort((a, b) => b.fechaEmision.compareTo(a.fechaEmision));

      setState(() {
        _facturas = loadedFacturas;
      });
    } catch (e) {
      debugPrint('Error cargando facturas: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _formatDate(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Historial de Facturas'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            )
          : _facturas.isEmpty
          ? const Center(child: Text('No hay facturas registradas'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _facturas.length,
              itemBuilder: (context, index) {
                final factura = _facturas[index];
                return GenericListTile(
                  leadingIcon: const Icon(
                    Icons.receipt,
                    color: AppColors.white,
                  ),
                  leadingBackgroundColor: AppColors.secondaryColor,
                  title:
                      'Factura #${factura.uidFactura?.substring(0, 8) ?? '---'}',
                  subtitle:
                      'Fecha: ${_formatDate(factura.fechaEmision)}\nTotal: \$${factura.total.toStringAsFixed(2)}',
                  isThreeLine: true,
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: AppColors.grey,
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            InvoiceDetailScreen(factura: factura),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
