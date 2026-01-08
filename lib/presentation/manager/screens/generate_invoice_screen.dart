import 'package:flutter/material.dart';
import 'package:autovitae/data/models/mantenimiento.dart';
import 'package:autovitae/data/models/servicio_taller.dart';
import 'package:autovitae/data/models/factura.dart';
import 'package:autovitae/data/models/factura_detalle.dart';
import 'package:autovitae/data/models/metodo_pago.dart';
import 'package:autovitae/data/models/estado_factura.dart';
import 'package:autovitae/viewmodels/factura_viewmodel.dart';
import 'package:autovitae/data/repositories/usuario_repository.dart';
import 'package:autovitae/data/repositories/cliente_repository.dart';
import 'package:autovitae/core/theme/app_colors.dart';
import 'package:autovitae/core/theme/app_fonts.dart';
import 'package:autovitae/presentation/shared/widgets/buttons/primary_button.dart';

class GenerateInvoiceScreen extends StatefulWidget {
  final Mantenimiento mantenimiento;
  final String clienteId;
  final List<ServicioTaller> servicios;

  const GenerateInvoiceScreen({
    super.key,
    required this.mantenimiento,
    required this.clienteId,
    required this.servicios,
  });

  @override
  State<GenerateInvoiceScreen> createState() => _GenerateInvoiceScreenState();
}

class _GenerateInvoiceScreenState extends State<GenerateInvoiceScreen> {
  final FacturaViewModel _facturaViewModel = FacturaViewModel();
  final UsuarioRepository _usuarioRepository = UsuarioRepository();
  final ClienteRepository _clienteRepository = ClienteRepository();

  bool _isLoading = false;
  String _clienteNombre = '';
  MetodoPago _selectedMetodoPago = MetodoPago.efectivo;

  @override
  void initState() {
    super.initState();
    _loadClienteInfo();
  }

  Future<void> _loadClienteInfo() async {
    setState(() => _isLoading = true);

    final cliente = await _clienteRepository.getById(widget.clienteId);
    if (cliente != null) {
      final usuario = await _usuarioRepository.getById(cliente.uidUsuario!);
      if (usuario != null) {
        setState(() {
          _clienteNombre = '${usuario.nombre} ${usuario.apellido}';
        });
      }
    }

    setState(() => _isLoading = false);
  }

  double get _subtotal {
    return widget.servicios.fold(0.0, (sum, s) => sum + s.precio);
  }

  double get _iva {
    return _subtotal * 0.12; // 12% IVA
  }

  double get _total {
    return _subtotal + _iva;
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

  Future<void> _generarFactura() async {
    setState(() => _isLoading = true);

    try {
      final factura = Factura(
        uidMantenimiento: widget.mantenimiento.uidMantenimiento!,
        uidCliente: widget.clienteId,
        subtotal: _subtotal,
        iva: _iva,
        total: _total,
        metodoPago: _selectedMetodoPago,
        estado: EstadoFactura.pendiente,
      );

      final detalles = widget.servicios
          .map(
            (servicio) => FacturaDetalle(
              uidFactura: '', // Will be set by viewModel
              uidServicio: servicio.uidServicio!,
              cantidad: 1,
              precioUnitario: servicio.precio,
              subtotal: servicio.precio,
            ),
          )
          .toList();

      final success = await _facturaViewModel.crearFacturaConDetalles(
        factura,
        detalles,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Factura generada exitosamente'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop(true);
      } else {
        _showError(_facturaViewModel.error ?? 'Error al generar factura');
      }
    } catch (e) {
      _showError('Error: $e');
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Generar Factura'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.black,
        elevation: 0,
      ),
      body: _isLoading && _clienteNombre.isEmpty
          ? Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.receipt_long,
                        size: 64,
                        color: AppColors.secondaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      'Nueva Factura',
                      style: AppTextStyles.headline1,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Cliente info
                  Text(
                    'Información del Cliente',
                    style: AppTextStyles.headline1,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    icon: Icons.person,
                    title: 'Cliente',
                    value: _clienteNombre.isEmpty
                        ? 'Cargando...'
                        : _clienteNombre,
                  ),
                  const SizedBox(height: 24),

                  // Servicios
                  Text('Servicios Facturados', style: AppTextStyles.headline1),
                  const SizedBox(height: 16),
                  ...widget.servicios.map(
                    (servicio) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.build,
                            color: AppColors.primaryColor,
                          ),
                        ),
                        title: Text(
                          servicio.nombre,
                          style: AppTextStyles.bodyText,
                        ),
                        trailing: Text(
                          '\$${servicio.precio.toStringAsFixed(2)}',
                          style: AppTextStyles.bodyText.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.success,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Método de pago
                  Text('Método de Pago', style: AppTextStyles.headline1),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    children: MetodoPago.values.map((metodo) {
                      final isSelected = _selectedMetodoPago == metodo;
                      return ChoiceChip(
                        label: Text(_getMetodoPagoLabel(metodo)),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedMetodoPago = metodo);
                          }
                        },
                        selectedColor: AppColors.primaryColor,
                        backgroundColor: AppColors.white,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? AppColors.black
                              : AppColors.textColor,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),

                  // Totales
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.grey.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildTotalRow('Subtotal', _subtotal),
                        const SizedBox(height: 12),
                        _buildTotalRow('IVA (12%)', _iva),
                        const Divider(height: 24),
                        _buildTotalRow('Total', _total, isTotal: true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Generar button
                  PrimaryButton(
                    text: 'Generar Factura',
                    onPressed: _generarFactura,
                    isLoading: _isLoading,
                    backgroundColor: AppColors.secondaryColor,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.primaryColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: AppTextStyles.bodyText.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalRow(String label, double value, {bool isTotal = false}) {
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
              ? AppTextStyles.headline1.copyWith(color: AppColors.success)
              : AppTextStyles.bodyText.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
