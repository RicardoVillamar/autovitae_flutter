import 'package:flutter/material.dart';
import 'package:autovitae/data/models/factura.dart';
import 'package:autovitae/data/models/factura_detalle.dart';
import 'package:autovitae/data/models/metodo_pago.dart';
import 'package:autovitae/viewmodels/factura_viewmodel.dart';
import 'package:autovitae/viewmodels/servicio_taller_viewmodel.dart';
import 'package:autovitae/core/theme/app_colors.dart';
import 'package:autovitae/core/theme/app_fonts.dart';
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Detalle de Factura'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryColor))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                                style: AppTextStyles.headline1.copyWith(fontSize: 20),
                              ),
                              Chip(
                                label: Text(
                                  widget.factura.estado.name.toUpperCase(),
                                  style: const TextStyle(color: AppColors.white, fontSize: 12),
                                ),
                                backgroundColor: widget.factura.estado.name == 'pagada'
                                    ? AppColors.success
                                    : AppColors.warning,
                                padding: EdgeInsets.zero,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildInfoRow('Fecha', _formatDate(widget.factura.fechaEmision)),
                          const SizedBox(height: 8),
                          _buildInfoRow('Método de Pago', _getMetodoPagoLabel(widget.factura.metodoPago)),
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
                  Text('Detalles del Servicio', style: AppTextStyles.headline1.copyWith(fontSize: 20)),
                  const SizedBox(height: 16),
                  
                  // List of items
                  if (_facturaViewModel.detalles.isEmpty)
                    const Text('No hay detalles disponibles', style: AppTextStyles.bodyText)
                  else
                    ..._facturaViewModel.detalles.map((detalle) => _buildDetalleItem(detalle)),

                  const SizedBox(height: 24),
                  
                  // Summary
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.grey.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      children: [
                        _buildSummaryRow('Subtotal', widget.factura.subtotal),
                        const SizedBox(height: 8),
                        _buildSummaryRow('IVA (12%)', widget.factura.iva),
                        const Divider(height: 24),
                        _buildSummaryRow('Total', widget.factura.total, isTotal: true),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildDetalleItem(FacturaDetalle detalle) {
    return FutureBuilder(
      future: _servicioViewModel.cargarServicio(detalle.uidServicio),
      builder: (context, snapshot) {
        final servicioName = snapshot.data?.nombre ?? 'Servicio no encontrado';
        
        return GenericListTile(
          leadingIcon: const Icon(Icons.build_circle, color: AppColors.primaryColor),
          leadingBackgroundColor: AppColors.primaryColor,
          title: servicioName,
          subtitle: 'Cantidad: ${detalle.cantidad} x \$${detalle.precioUnitario.toStringAsFixed(2)}',
          trailing: Text(
            '\$${detalle.subtotal.toStringAsFixed(2)}',
            style: AppTextStyles.bodyText.copyWith(fontWeight: FontWeight.bold),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.caption),
        Text(
          value,
          style: AppTextStyles.bodyText.copyWith(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, double value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? AppTextStyles.bodyText.copyWith(fontWeight: FontWeight.bold)
              : AppTextStyles.bodyText,
        ),
        Text(
          '\$${value.toStringAsFixed(2)}',
          style: isTotal
              ? AppTextStyles.headline1.copyWith(color: AppColors.success, fontSize: 20)
              : AppTextStyles.bodyText.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
