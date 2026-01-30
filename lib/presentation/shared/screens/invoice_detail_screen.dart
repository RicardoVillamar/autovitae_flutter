import 'package:flutter/material.dart';
import 'package:autovitae/data/models/factura.dart';
import 'package:autovitae/data/models/factura_detalle.dart';
import 'package:autovitae/data/models/metodo_pago.dart';
import 'package:autovitae/viewmodels/factura_viewmodel.dart';
import 'package:autovitae/viewmodels/servicio_taller_viewmodel.dart';
import 'package:autovitae/core/theme/app_colors.dart';
import 'package:autovitae/presentation/shared/widgets/cards/generic_list_tile.dart';

class InvoiceDetailScreen extends StatefulWidget {
  final Factura factura;

  const InvoiceDetailScreen({super.key, required this.factura});

  @override
  State<InvoiceDetailScreen> createState() => _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState extends State<InvoiceDetailScreen> {
  final FacturaViewModel _facturaViewModel = FacturaViewModel();
  final ServicioTallerViewModel _servicioViewModel = ServicioTallerViewModel();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadDetalles();
  }

  Future<void> _loadDetalles() async {
    setState(() => _isLoading = true);
    await _facturaViewModel.cargarDetallesFactura(widget.factura.uidFactura!);
    setState(() => _isLoading = false);
  }

  String _formatDate(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _getMetodoPagoLabel(MetodoPago metodo) {
    switch (metodo) {
      case MetodoPago.efectivo:
        return 'Efectivo';
      case MetodoPago.tarjeta:
        return 'Tarjeta';
      case MetodoPago.transferencia:
        return 'Transferencia';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Factura'),
        backgroundColor: colorScheme.primary,
        foregroundColor: AppColors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Factura',
                                style: textTheme.headlineSmall
                                    ?.copyWith(fontSize: 20),
                              ),
                              Chip(
                                label: Text(
                                  widget.factura.estado.name.toUpperCase(),
                                  style: const TextStyle(
                                      color: AppColors.white, fontSize: 12),
                                ),
                                backgroundColor:
                                    widget.factura.estado.name == 'pagada'
                                        ? AppColors.success
                                        : AppColors.warning,
                                padding: EdgeInsets.zero,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildInfoRow('Fecha',
                              _formatDate(widget.factura.fechaEmision)),
                          const SizedBox(height: 8),
                          _buildInfoRow('Método de Pago',
                              _getMetodoPagoLabel(widget.factura.metodoPago)),
                          const Divider(height: 24),
                          _buildInfoRow(
                            'Total',
                            '\$${widget.factura.total.toStringAsFixed(2)}',
                            isBold: true,
                            valueColor: AppColors.success,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Detalles del Servicio',
                      style: textTheme.headlineSmall?.copyWith(fontSize: 20)),
                  const SizedBox(height: 16),

                  // List of items
                  if (_facturaViewModel.detalles.isEmpty)
                    Text('No hay detalles disponibles',
                        style: textTheme.bodyLarge)
                  else
                    ..._facturaViewModel.detalles
                        .map((detalle) => _buildDetalleItem(detalle)),

                  const SizedBox(height: 24),

                  // Summary
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: AppColors.grey.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      children: [
                        _buildSummaryRow('Subtotal', widget.factura.subtotal),
                        const SizedBox(height: 8),
                        _buildSummaryRow('IVA (12%)', widget.factura.iva),
                        const Divider(height: 24),
                        _buildSummaryRow('Total', widget.factura.total,
                            isTotal: true),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildDetalleItem(FacturaDetalle detalle) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return FutureBuilder(
      future: _servicioViewModel.cargarServicio(detalle.uidServicio),
      builder: (context, snapshot) {
        final servicioName = snapshot.data?.nombre ?? 'Servicio no encontrado';

        return GenericListTile(
          leadingIcon: Icon(Icons.build_circle, color: colorScheme.primary),
          leadingBackgroundColor: colorScheme.primary,
          title: servicioName,
          subtitle:
              'Cantidad: ${detalle.cantidad} x \$${detalle.precioUnitario.toStringAsFixed(2)}',
          trailing: Text(
            '\$${detalle.subtotal.toStringAsFixed(2)}',
            style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value,
      {bool isBold = false, Color? valueColor}) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: textTheme.bodySmall),
        Text(
          value,
          style: textTheme.bodyLarge?.copyWith(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, double value, {bool isTotal = false}) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)
              : textTheme.bodyLarge,
        ),
        Text(
          '\$${value.toStringAsFixed(2)}',
          style: isTotal
              ? textTheme.headlineSmall
                  ?.copyWith(color: AppColors.success, fontSize: 20)
              : textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
