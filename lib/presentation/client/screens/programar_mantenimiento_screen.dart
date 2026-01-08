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
import 'package:autovitae/core/theme/app_fonts.dart';
import 'package:autovitae/presentation/shared/widgets/buttons/primary_button.dart';
import 'package:autovitae/presentation/shared/widgets/buttons/secondary_button.dart';
import 'package:autovitae/presentation/shared/screens/location_picker_screen.dart';

class ProgramarMantenimientoScreen extends StatefulWidget {
  final Taller taller;

  const ProgramarMantenimientoScreen({super.key, required this.taller});

  @override
  State<ProgramarMantenimientoScreen> createState() =>
      _ProgramarMantenimientoScreenState();
}

class _ProgramarMantenimientoScreenState
    extends State<ProgramarMantenimientoScreen> {
  final MantenimientoViewModel _mantenimientoViewModel = MantenimientoViewModel();
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
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: AppColors.black,
              onSurface: AppColors.textColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: AppColors.black,
              onSurface: AppColors.textColor,
            ),
          ),
          child: child!,
        );
      },
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
      uidCita: null,
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
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Programar Mantenimiento - ${widget.taller.nombre}'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.black,
        elevation: 0,
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
                          style: AppTextStyles.headline1,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Para programar un mantenimiento, primero debes registrar un vehículo en tu perfil.',
                          style: AppTextStyles.bodyText,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        PrimaryButton(
                          text: 'Registrar Vehículo',
                          onPressed: () {
                             Navigator.of(context).pushNamed('/create_vehiculo').then((_) => _loadData());
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
                        style: AppTextStyles.headline1,
                      ),
                      const SizedBox(height: 24),
                      // Selector de vehículo
                      Text(
                        'Vehículo *',
                        style: AppTextStyles.bodyText.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.grey.withValues(alpha: 0.3),
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<Vehiculo>(
                            value: _selectedVehiculo,
                            isExpanded: true,
                            hint: const Text('Selecciona tu vehículo'),
                            items: _vehiculos.map((vehiculo) {
                              return DropdownMenuItem<Vehiculo>(
                                value: vehiculo,
                                child: Text(
                                  '${vehiculo.marca ?? ''} ${vehiculo.modelo ?? ''} - ${vehiculo.placa ?? ''}',
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() => _selectedVehiculo = value);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Selector de servicios
                      if (_serviciosDisponibles.isNotEmpty) ...[
                        Text(
                          'Servicios Requeridos *',
                          style: AppTextStyles.bodyText.copyWith(
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
                            final isSelected = _serviciosSeleccionadosIds.contains(
                              servicio.uidServicio,
                            );
                            return CheckboxListTile(
                              title: Text(servicio.nombre),
                              subtitle: Text('\$${servicio.precio}'),
                              value: isSelected,
                              activeColor: AppColors.primaryColor,
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
                    style: AppTextStyles.bodyText.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _selectLocation,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.grey.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: AppColors.primaryColor,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _direccion ?? 'Seleccionar ubicación en el mapa',
                              style: AppTextStyles.bodyText.copyWith(
                                color:
                                    _direccion == null
                                        ? AppColors.grey
                                        : AppColors.textColor,
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
                    style: AppTextStyles.bodyText.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _selectDate,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.grey.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedDate == null
                                ? 'Selecciona una fecha'
                                : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                            style: AppTextStyles.bodyText,
                          ),
                          const Icon(
                            Icons.calendar_today,
                            color: AppColors.primaryColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Selector de hora
                  Text(
                    'Hora *',
                    style: AppTextStyles.bodyText.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _selectTime,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.grey.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedTime == null
                                ? 'Selecciona una hora'
                                : _selectedTime!.format(context),
                            style: AppTextStyles.bodyText,
                          ),
                          const Icon(
                            Icons.access_time,
                            color: AppColors.primaryColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Descripción
                  Text(
                    'Descripción del problema',
                    style: AppTextStyles.bodyText.copyWith(
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
                      fillColor: AppColors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: AppColors.grey.withValues(alpha: 0.3),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: AppColors.grey.withValues(alpha: 0.3),
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
                ],
              ),
            ),
    );
  }
}