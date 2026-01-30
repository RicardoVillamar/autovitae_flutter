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
          const SnackBar(
            content: Text('Factura generada exitosamente'),
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
      SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Generar Factura'),
        backgroundColor: colorScheme.primary,
        foregroundColor: AppColors.black,
        elevation: 0,
      ),
      body: _isLoading && _clienteNombre.isEmpty
          ? Center(
              child: CircularProgressIndicator(color: colorScheme.primary),
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
                        color: colorScheme.secondary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.receipt_long,
                        size: 64,
                        color: colorScheme.secondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      'Nueva Factura',
                      style: textTheme.headlineSmall,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Cliente info
                  Text(
                    'Información del Cliente',
                    style: textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    context: context,
                    icon: Icons.person,
                    title: 'Cliente',
                    value:
                        _clienteNombre.isEmpty ? 'Cargando...' : _clienteNombre,
                  ),
                  const SizedBox(height: 24),

                  // Servicios
                  Text('Servicios Facturados', style: textTheme.headlineSmall),
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
                            color: colorScheme.primary.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.build,
                            color: colorScheme.primary,
                          ),
                        ),
                        title: Text(
                          servicio.nombre,
                          style: textTheme.bodyLarge,
                        ),
                        trailing: Text(
                          '\$${servicio.precio.toStringAsFixed(2)}',
                          style: textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.success,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Método de pago
                  Text('Método de Pago', style: textTheme.headlineSmall),
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
                        selectedColor: colorScheme.primary,
                        backgroundColor: AppColors.white,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? AppColors.black
                              : colorScheme.onSurface,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
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
                        _buildTotalRow(context, 'Subtotal', _subtotal),
                        const SizedBox(height: 12),
                        _buildTotalRow(context, 'IVA (12%)', _iva),
                        const Divider(height: 24),
                        _buildTotalRow(context, 'Total', _total, isTotal: true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Generar button
                  PrimaryButton(
                    text: 'Generar Factura',
                    onPressed: _generarFactura,
                    isLoading: _isLoading,
                    backgroundColor: colorScheme.secondary,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

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
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: colorScheme.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: textTheme.bodyLarge?.copyWith(
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

  Widget _buildTotalRow(BuildContext context, String label, double value,
      {bool isTotal = false}) {
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
              ? textTheme.headlineSmall?.copyWith(color: AppColors.success)
              : textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
