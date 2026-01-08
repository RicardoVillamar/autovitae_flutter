import 'package:flutter/material.dart';
import 'package:autovitae/data/models/mantenimiento.dart';
import 'package:autovitae/data/models/mantenimiento_detalle.dart';
import 'package:autovitae/data/models/cita.dart';
import 'package:autovitae/data/models/vehiculo.dart';
import 'package:autovitae/data/models/usuario.dart';
import 'package:autovitae/data/models/servicio_taller.dart';
import 'package:autovitae/data/models/estado_mantenimiento.dart';
import 'package:autovitae/viewmodels/mantenimiento_viewmodel.dart';
import 'package:autovitae/viewmodels/servicio_taller_viewmodel.dart';
import 'package:autovitae/data/repositories/cita_repository.dart';
import 'package:autovitae/data/repositories/vehiculo_repository.dart';
import 'package:autovitae/data/repositories/cliente_repository.dart';
import 'package:autovitae/data/repositories/usuario_repository.dart';
import 'package:autovitae/data/repositories/mantenimiento_detalle_repository.dart';
import 'package:autovitae/core/theme/app_colors.dart';
import 'package:autovitae/core/theme/app_fonts.dart';
import 'package:autovitae/presentation/shared/widgets/cards/info_card.dart';
import 'package:autovitae/presentation/shared/widgets/buttons/primary_button.dart';
import 'package:autovitae/presentation/manager/screens/generate_invoice_screen.dart';

class MaintenanceDetailScreen extends StatefulWidget {
  final Mantenimiento mantenimiento;

  const MaintenanceDetailScreen({super.key, required this.mantenimiento});

  @override
  State<MaintenanceDetailScreen> createState() =>
      _MaintenanceDetailScreenState();
}

class _MaintenanceDetailScreenState extends State<MaintenanceDetailScreen> {
  final MantenimientoViewModel _viewModel = MantenimientoViewModel();
  final CitaRepository _citaRepository = CitaRepository();
  final VehiculoRepository _vehiculoRepository = VehiculoRepository();
  final ClienteRepository _clienteRepository = ClienteRepository();
  final UsuarioRepository _usuarioRepository = UsuarioRepository();
  final ServicioTallerViewModel _servicioViewModel = ServicioTallerViewModel();
  final MantenimientoDetalleRepository _detalleRepository =
      MantenimientoDetalleRepository();

  bool _isLoading = false;
  Cita? _cita;
  Vehiculo? _vehiculo;
  Usuario? _cliente;
  late Mantenimiento _mantenimiento;
  final List<ServicioTaller> _serviciosSeleccionados = [];
  List<MantenimientoDetalle> _detallesExistentes = [];

  @override
  void initState() {
    super.initState();
    _mantenimiento = widget.mantenimiento;
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      if (_mantenimiento.uidCita != null) {
        _cita = await _citaRepository.getById(_mantenimiento.uidCita!);
      }

      if (_cita != null) {
        _vehiculo = await _vehiculoRepository.getById(_cita!.uidVehiculo);
        final cliente = await _clienteRepository.getById(_cita!.uidCliente);

        if (cliente?.uidUsuario != null) {
          _cliente = await _usuarioRepository.getById(cliente!.uidUsuario!);
        }
      } else {
        // Load from direct references in Mantenimiento
        _vehiculo = await _vehiculoRepository.getById(
          _mantenimiento.uidVehiculo,
        );
        final cliente = await _clienteRepository.getById(
          _mantenimiento.uidCliente,
        );
        if (cliente?.uidUsuario != null) {
          _cliente = await _usuarioRepository.getById(cliente!.uidUsuario!);
        }
      }

      // Load services for the taller
      await _servicioViewModel.cargarServiciosPorTaller(
        _mantenimiento.uidTaller,
      );

      // Load existing mantenimiento detalles
      _detallesExistentes = await _detalleRepository.getByMantenimientoId(
        _mantenimiento.uidMantenimiento!,
      );

      // Preselect services from existing detalles
      for (final detalle in _detallesExistentes) {
        final servicio = _servicioViewModel.servicios
            .where((s) => s.uidServicio == detalle.uidServicio)
            .firstOrNull;
        if (servicio != null && !_serviciosSeleccionados.contains(servicio)) {
          _serviciosSeleccionados.add(servicio);
        }
      }
    } catch (e) {
      _showError('Error al cargar datos: $e');
    }

    setState(() => _isLoading = false);
  }

  Future<void> _cambiarEstado(EstadoMantenimiento nuevoEstado) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar cambio de estado'),
        content: Text(
          '¿Deseas cambiar el estado del mantenimiento a "${_getEstadoText(nuevoEstado)}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    final success = await _viewModel.actualizarEstadoMantenimiento(
      _mantenimiento.uidMantenimiento!,
      nuevoEstado,
    );

    if (success && mounted) {
      setState(() {
        _mantenimiento = Mantenimiento(
          uidMantenimiento: _mantenimiento.uidMantenimiento,
          uidCita: _mantenimiento.uidCita,
          uidTaller: _mantenimiento.uidTaller,
          uidCliente: _mantenimiento.uidCliente,
          uidVehiculo: _mantenimiento.uidVehiculo,
          fechaProgramada: _mantenimiento.fechaProgramada,
          fechaInicio: nuevoEstado == EstadoMantenimiento.enProceso
              ? DateTime.now().millisecondsSinceEpoch
              : _mantenimiento.fechaInicio,
          fechaFin: nuevoEstado == EstadoMantenimiento.finalizado
              ? DateTime.now().millisecondsSinceEpoch
              : _mantenimiento.fechaFin,
          estado: nuevoEstado,
          observaciones: _mantenimiento.observaciones,
          latitud: _mantenimiento.latitud,
          longitud: _mantenimiento.longitud,
          direccion: _mantenimiento.direccion,
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Estado actualizado exitosamente'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      _showError(_viewModel.error ?? 'Error al actualizar estado');
    }

    setState(() => _isLoading = false);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  String _getEstadoText(EstadoMantenimiento estado) {
    switch (estado) {
      case EstadoMantenimiento.pendiente:
        return 'Pendiente';
      case EstadoMantenimiento.enProceso:
        return 'En Proceso';
      case EstadoMantenimiento.finalizado:
        return 'Finalizado';
      case EstadoMantenimiento.cancelado:
        return 'Cancelado';
    }
  }

  Color _getEstadoColor(EstadoMantenimiento estado) {
    switch (estado) {
      case EstadoMantenimiento.pendiente:
        return Colors.orange;
      case EstadoMantenimiento.enProceso:
        return AppColors.warning;
      case EstadoMantenimiento.finalizado:
        return AppColors.success;
      case EstadoMantenimiento.cancelado:
        return AppColors.error;
    }
  }

  Future<void> _guardarServicios() async {
    setState(() => _isLoading = true);

    try {
      // Delete existing detalles
      for (final detalle in _detallesExistentes) {
        await _detalleRepository.delete(detalle.uidDetalle!);
      }

      // Create new detalles for selected services
      for (final servicio in _serviciosSeleccionados) {
        final detalle = MantenimientoDetalle(
          uidMantenimiento: _mantenimiento.uidMantenimiento!,
          uidServicio: servicio.uidServicio!,
          cantidad: 1,
          precioUnitario: servicio.precio,
          subtotal: servicio.precio,
        );
        await _detalleRepository.create(detalle);
      }

      // Reload detalles
      _detallesExistentes = await _detalleRepository.getByMantenimientoId(
        _mantenimiento.uidMantenimiento!,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Servicios guardados exitosamente'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      _showError('Error al guardar servicios: $e');
    }

    setState(() => _isLoading = false);
  }

  void _toggleServicio(ServicioTaller servicio) {
    setState(() {
      if (_serviciosSeleccionados.contains(servicio)) {
        _serviciosSeleccionados.remove(servicio);
      } else {
        _serviciosSeleccionados.add(servicio);
      }
    });
  }

  double get _totalServicios {
    return _serviciosSeleccionados.fold(0.0, (sum, s) => sum + s.precio);
  }

  void _generarFactura() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GenerateInvoiceScreen(
          mantenimiento: _mantenimiento,
          clienteId: _mantenimiento.uidCliente,
          servicios: _serviciosSeleccionados,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Detalle de Mantenimiento'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.black,
        elevation: 0,
      ),
      body: _isLoading && _cita == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Estado actual
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _getEstadoColor(
                        _mantenimiento.estado,
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getEstadoColor(_mantenimiento.estado),
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: _getEstadoColor(_mantenimiento.estado),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Estado Actual',
                                style: AppTextStyles.caption.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                _getEstadoText(_mantenimiento.estado),
                                style: AppTextStyles.bodyText.copyWith(
                                  color: _getEstadoColor(_mantenimiento.estado),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Información del cliente
                  Text(
                    'Información del Cliente',
                    style: AppTextStyles.headline1,
                  ),
                  const SizedBox(height: 16),
                  InfoCard(
                    leadingIcon: Icons.person,
                    title: 'Cliente',
                    subtitle: _cliente != null
                        ? '${_cliente!.nombre} ${_cliente!.apellido}'
                        : (_isLoading ? 'Cargando...' : 'Información no disponible'),
                  ),
                  InfoCard(
                    leadingIcon: Icons.phone,
                    title: 'Teléfono',
                    subtitle: _cliente?.telefono ?? '-',
                  ),
                  InfoCard(
                    leadingIcon: Icons.email,
                    title: 'Email',
                    subtitle: _cliente?.correo ?? '-',
                  ),
                  const SizedBox(height: 24),
                  // Información del vehículo
                  Text(
                    'Información del Vehículo',
                    style: AppTextStyles.headline1,
                  ),
                  const SizedBox(height: 16),
                  InfoCard(
                    leadingIcon: Icons.directions_car,
                    title: 'Vehículo',
                    subtitle: _vehiculo != null
                        ? '${_vehiculo!.marca ?? ''} ${_vehiculo!.modelo ?? ''}'
                        : (_isLoading ? 'Cargando...' : 'Información no disponible'),
                  ),
                  InfoCard(
                    leadingIcon: Icons.confirmation_number,
                    title: 'Placa',
                    subtitle: _vehiculo?.placa ?? '-',
                  ),
                  InfoCard(
                    leadingIcon: Icons.calendar_today,
                    title: 'Año',
                    subtitle: _vehiculo?.anio?.toString() ?? '-',
                  ),
                  const SizedBox(height: 24),
                  // Ubicación (si está disponible)
                  if (_mantenimiento.direccion != null ||
                      (_mantenimiento.latitud != null &&
                          _mantenimiento.longitud != null)) ...[
                    Text('Ubicación del Servicio', style: AppTextStyles.headline1),
                    const SizedBox(height: 16),
                    if (_mantenimiento.direccion != null)
                      InfoCard(
                        leadingIcon: Icons.location_on,
                        title: 'Dirección',
                        subtitle: _mantenimiento.direccion!,
                      ),
                    if (_mantenimiento.latitud != null &&
                        _mantenimiento.longitud != null)
                      InfoCard(
                        leadingIcon: Icons.map,
                        title: 'Coordenadas',
                        subtitle:
                            '${_mantenimiento.latitud!.toStringAsFixed(6)}, ${_mantenimiento.longitud!.toStringAsFixed(6)}',
                      ),
                    const SizedBox(height: 24),
                  ],
                  // Fechas
                  Text('Fechas', style: AppTextStyles.headline1),
                  const SizedBox(height: 16),
                  InfoCard(
                    leadingIcon: Icons.event,
                    title: 'Fecha Programada',
                    subtitle: _formatDate(_mantenimiento.fechaProgramada),
                  ),
                  if (_mantenimiento.fechaInicio != null)
                    InfoCard(
                      leadingIcon: Icons.play_arrow,
                      title: 'Fecha de Inicio',
                      subtitle: _formatDate(_mantenimiento.fechaInicio!),
                    ),
                  if (_mantenimiento.fechaFin != null)
                    InfoCard(
                      leadingIcon: Icons.check_circle,
                      title: 'Fecha de Finalización',
                      subtitle: _formatDate(_mantenimiento.fechaFin!),
                    ),
                  if (_mantenimiento.observaciones?.isNotEmpty == true) ...[
                    const SizedBox(height: 24),
                    Text('Observaciones', style: AppTextStyles.headline1),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.grey.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        _mantenimiento.observaciones!,
                        style: AppTextStyles.bodyText,
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),

                  // Servicios del mantenimiento
                  Text(
                    'Servicios del Mantenimiento',
                    style: AppTextStyles.headline1,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Selecciona los servicios realizados durante el mantenimiento',
                    style: AppTextStyles.caption,
                  ),
                  const SizedBox(height: 16),
                  if (_servicioViewModel.servicios.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'No hay servicios disponibles en este taller',
                        style: AppTextStyles.bodyText,
                      ),
                    )
                  else
                    ..._servicioViewModel.servicios.map((servicio) {
                      final isSelected = _serviciosSeleccionados.contains(
                        servicio,
                      );
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: isSelected
                              ? BorderSide(
                                  color: AppColors.primaryColor,
                                  width: 2,
                                )
                              : BorderSide.none,
                        ),
                        child: CheckboxListTile(
                          value: isSelected,
                          onChanged:
                              _mantenimiento.estado ==
                                  EstadoMantenimiento.cancelado
                              ? null
                              : (value) => _toggleServicio(servicio),
                          activeColor: AppColors.primaryColor,
                          title: Text(
                            servicio.nombre,
                            style: AppTextStyles.bodyText.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            servicio.descripcion ?? '',
                            style: AppTextStyles.caption,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          secondary: Text(
                            '\$${servicio.precio.toStringAsFixed(2)}',
                            style: AppTextStyles.bodyText.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }),
                  if (_serviciosSeleccionados.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primaryColor),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Servicios:',
                            style: AppTextStyles.bodyText.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '\$${_totalServicios.toStringAsFixed(2)}',
                            style: AppTextStyles.headline1.copyWith(
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_mantenimiento.estado !=
                        EstadoMantenimiento.cancelado) ...[
                      const SizedBox(height: 12),
                      PrimaryButton(
                        text: 'Guardar Servicios',
                        onPressed: _guardarServicios,
                        isLoading: _isLoading,
                      ),
                    ],
                  ],

                  const SizedBox(height: 32),
                  // Botones de cambio de estado
                  if (_mantenimiento.estado != EstadoMantenimiento.finalizado &&
                      _mantenimiento.estado !=
                          EstadoMantenimiento.cancelado) ...[
                    Text('Acciones', style: AppTextStyles.headline1),
                    const SizedBox(height: 16),
                    if (_mantenimiento.estado != EstadoMantenimiento.enProceso)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: PrimaryButton(
                          text: 'Iniciar Mantenimiento',
                          onPressed: () =>
                              _cambiarEstado(EstadoMantenimiento.enProceso),
                          backgroundColor: AppColors.warning,
                          isLoading: _isLoading,
                        ),
                      ),
                    if (_mantenimiento.estado == EstadoMantenimiento.enProceso)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: PrimaryButton(
                          text: 'Finalizar Mantenimiento',
                          onPressed: () =>
                              _cambiarEstado(EstadoMantenimiento.finalizado),
                          backgroundColor: AppColors.success,
                          isLoading: _isLoading,
                        ),
                      ),
                    PrimaryButton(
                      text: 'Cancelar Mantenimiento',
                      onPressed: () =>
                          _cambiarEstado(EstadoMantenimiento.cancelado),
                      backgroundColor: AppColors.error,
                      isLoading: _isLoading,
                    ),
                  ],

                  // Generar factura (solo cuando está finalizado)
                  if (_mantenimiento.estado == EstadoMantenimiento.finalizado &&
                      _serviciosSeleccionados.isNotEmpty) ...[
                    Text('Facturación', style: AppTextStyles.headline1),
                    const SizedBox(height: 16),
                    PrimaryButton(
                      text: 'Generar Factura',
                      onPressed: _generarFactura,
                      backgroundColor: AppColors.secondaryColor,
                      isLoading: _isLoading,
                    ),
                  ],
                ],
              ),
            ),
    );
  }



  String _formatDate(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
