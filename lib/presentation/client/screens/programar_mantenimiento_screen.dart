import 'package:flutter/material.dart';
import 'package:autovitae/data/models/mantenimiento.dart';
import 'package:autovitae/data/models/vehiculo.dart';
import 'package:autovitae/data/models/taller.dart';
import 'package:autovitae/data/models/servicio_taller.dart';
import 'package:autovitae/data/models/estado_mantenimiento.dart';
import 'package:autovitae/viewmodels/mantenimiento_viewmodel.dart';
import 'package:autovitae/viewmodels/vehiculo_viewmodel.dart';
import 'package:autovitae/viewmodels/servicio_taller_viewmodel.dart';
import 'package:autovitae/core/utils/session_manager.dart';
import 'package:autovitae/core/theme/app_colors.dart';
import 'package:autovitae/presentation/shared/widgets/buttons/primary_button.dart';
import 'package:autovitae/presentation/shared/widgets/buttons/secondary_button.dart';
import 'package:autovitae/presentation/shared/screens/location_picker_screen.dart';
import 'package:autovitae/presentation/shared/widgets/appbar/custom_app_bar.dart';

class ProgramarMantenimientoScreen extends StatefulWidget {
  final Taller taller;

  const ProgramarMantenimientoScreen({super.key, required this.taller});

  @override
  State<ProgramarMantenimientoScreen> createState() =>
      _ProgramarMantenimientoScreenState();
}

class _ProgramarMantenimientoScreenState
    extends State<ProgramarMantenimientoScreen> {
  final MantenimientoViewModel _mantenimientoViewModel =
      MantenimientoViewModel();
  final VehiculoViewModel _vehiculoViewModel = VehiculoViewModel();
  final ServicioTallerViewModel _servicioViewModel = ServicioTallerViewModel();

  Vehiculo? _selectedVehiculo;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final TextEditingController _descripcionController = TextEditingController();

  bool _isLoading = false;
  List<Vehiculo> _vehiculos = [];
  List<ServicioTaller> _serviciosDisponibles = [];
  final List<String> _serviciosSeleccionadosIds = [];

  double? _latitud;
  double? _longitud;
  String? _direccion;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final cliente = await SessionManager().getCliente();
    if (cliente?.uidCliente != null) {
      await _vehiculoViewModel.cargarVehiculosPorCliente(cliente!.uidCliente!);
      setState(() {
        _vehiculos = _vehiculoViewModel.vehiculos;
      });
    }

    if (widget.taller.uidTaller != null) {
      await _loadServicios(widget.taller.uidTaller!);
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadServicios(String uidTaller) async {
    await _servicioViewModel.cargarServiciosActivosPorTaller(uidTaller);
    setState(() {
      _serviciosDisponibles = _servicioViewModel.servicios;
      _isLoading = false;
    });
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      locale: const Locale('es', 'ES'),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }

    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );

    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _selectLocation() async {
    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (context) => const LocationPickerScreen(),
      ),
    );

    if (result != null) {
      setState(() {
        _latitud = result['lat'];
        _longitud = result['lng'];
        _direccion = result['address'];
      });
    }
  }

  Future<void> _programarMantenimiento() async {
    if (_selectedVehiculo == null) {
      _showError('Por favor selecciona un vehículo');
      return;
    }

    if (_selectedDate == null || _selectedTime == null) {
      _showError('Por favor selecciona fecha y hora');
      return;
    }

    if (_serviciosSeleccionadosIds.isEmpty) {
      _showError('Por favor selecciona al menos un servicio');
      return;
    }

    setState(() => _isLoading = true);

    final cliente = await SessionManager().getCliente();
    if (cliente?.uidCliente == null) {
      _showError('Error al obtener datos del cliente');
      setState(() => _isLoading = false);
      return;
    }

    // Combinar fecha y hora
    final fechaProgramada = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    final mantenimiento = Mantenimiento(
      uidTaller: widget.taller.uidTaller!,
      uidCliente: cliente!.uidCliente!,
      uidVehiculo: _selectedVehiculo!.uidVehiculo!,
      fechaProgramada: fechaProgramada.millisecondsSinceEpoch,
      estado: EstadoMantenimiento.pendiente,
      observaciones: _descripcionController.text.trim(),
      latitud: _latitud,
      longitud: _longitud,
      direccion: _direccion,
    );

    // Obtener precios de los servicios seleccionados
    final precios = _serviciosSeleccionadosIds.map((id) {
      return _serviciosDisponibles
          .firstWhere((s) => s.uidServicio == id)
          .precio;
    }).toList();

    final success =
        await _mantenimientoViewModel.registrarMantenimientoConDetalles(
      mantenimiento,
      _serviciosSeleccionadosIds,
      precios,
    );

    setState(() => _isLoading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mantenimiento programado exitosamente'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.of(context).pop(true);
    } else {
      _showError(
        _mantenimientoViewModel.error ?? 'Error al programar mantenimiento',
      );
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
      appBar: CustomAppBar(
        title: 'Mantenimiento - ${widget.taller.nombre}',
        showBackButton: true,
        showMenu: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _vehiculos.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.directions_car_outlined,
                          size: 80,
                          color: AppColors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No tienes vehículos registrados',
                          style: textTheme.headlineSmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Para programar un mantenimiento, primero debes registrar un vehículo en tu perfil.',
                          style: textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        PrimaryButton(
                          text: 'Registrar Vehículo',
                          onPressed: () {
                            Navigator.of(context)
                                .pushNamed('/create_vehiculo')
                                .then((_) => _loadData());
                          },
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Detalles del Mantenimiento',
                        style: textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 24),
                      // Selector de vehículo
                      Text('Vehículo', style: textTheme.headlineSmall),
                      const SizedBox(height: 12),
                      if (_vehiculoViewModel.vehiculos.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.warning),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.warning,
                                  color: AppColors.warning),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'No tienes vehículos registrados. Registra un vehículo primero.',
                                  style: textTheme.bodyLarge,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        ...List.generate(_vehiculoViewModel.vehiculos.length, (
                          index,
                        ) {
                          final vehiculo = _vehiculoViewModel.vehiculos[index];
                          final isSelected = _selectedVehiculo?.uidVehiculo ==
                              vehiculo.uidVehiculo;
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: isSelected
                                  ? BorderSide(
                                      color: colorScheme.primary,
                                      width: 2,
                                    )
                                  : BorderSide.none,
                            ),
                            child: ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: (isSelected
                                          ? colorScheme.primary
                                          : AppColors.grey)
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.directions_car,
                                  color: isSelected
                                      ? colorScheme.primary
                                      : AppColors.grey,
                                ),
                              ),
                              title: Text(
                                '${vehiculo.marca ?? ''} ${vehiculo.modelo ?? ''}',
                                style: textTheme.bodyLarge,
                              ),
                              subtitle: Text(
                                'Placa: ${vehiculo.placa ?? 'Sin placa'}',
                                style: textTheme.bodySmall,
                              ),
                              trailing: isSelected
                                  ? Icon(
                                      Icons.check_circle,
                                      color: colorScheme.primary,
                                    )
                                  : null,
                              onTap: () {
                                setState(() => _selectedVehiculo = vehiculo);
                              },
                            ),
                          );
                        }),
                      const SizedBox(height: 24),

                      const SizedBox(height: 20),
                      // Selector de servicios
                      if (_serviciosDisponibles.isNotEmpty) ...[
                        Text(
                          'Servicios Requeridos *',
                          style: textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _serviciosDisponibles.length,
                          itemBuilder: (context, index) {
                            final servicio = _serviciosDisponibles[index];
                            final isSelected =
                                _serviciosSeleccionadosIds.contains(
                              servicio.uidServicio,
                            );
                            return CheckboxListTile(
                              title: Text(servicio.nombre),
                              subtitle: Text('\$${servicio.precio}'),
                              value: isSelected,
                              activeColor: colorScheme.primary,
                              onChanged: (bool? value) {
                                setState(() {
                                  if (value == true) {
                                    _serviciosSeleccionadosIds.add(
                                      servicio.uidServicio!,
                                    );
                                  } else {
                                    _serviciosSeleccionadosIds.remove(
                                      servicio.uidServicio,
                                    );
                                  }
                                });
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                      ],
                      // Selector de ubicación
                      Text(
                        'Ubicación del Vehículo',
                        style: textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: _selectLocation,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: colorScheme.outlineVariant,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _direccion ??
                                      'Seleccionar ubicación en el mapa',
                                  style: textTheme.bodyLarge?.copyWith(
                                    color: _direccion == null
                                        ? AppColors.grey
                                        : colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Selector de fecha
                      Text(
                        'Fecha *',
                        style: textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: _selectDate,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: colorScheme.outlineVariant,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _selectedDate == null
                                    ? 'Selecciona una fecha'
                                    : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                                style: textTheme.bodyLarge,
                              ),
                              Icon(
                                Icons.calendar_today,
                                color: colorScheme.primary,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Selector de hora
                      Text(
                        'Hora *',
                        style: textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: _selectTime,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: colorScheme.outlineVariant,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _selectedTime == null
                                    ? 'Selecciona una hora'
                                    : _selectedTime!.format(context),
                                style: textTheme.bodyLarge,
                              ),
                              Icon(
                                Icons.access_time,
                                color: colorScheme.primary,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Descripción
                      Text(
                        'Descripción del problema',
                        style: textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _descripcionController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText:
                              'Describe el problema o mantenimiento requerido',
                          filled: true,
                          fillColor: colorScheme.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: AppColors.grey.withValues(alpha: 0.3),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: colorScheme.outlineVariant,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Botones
                      PrimaryButton(
                        text: 'Programar Mantenimiento',
                        onPressed: _programarMantenimiento,
                        isLoading: _isLoading,
                      ),
                      const SizedBox(height: 12),
                      SecondaryButton(
                        text: 'Cancelar',
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
    );
  }
}
