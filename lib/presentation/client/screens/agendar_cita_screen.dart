import 'package:flutter/material.dart';
import 'package:autovitae/data/models/taller.dart';
import 'package:autovitae/data/models/vehiculo.dart';
import 'package:autovitae/data/models/cita.dart';
import 'package:autovitae/data/models/estado_cita.dart';
import 'package:autovitae/viewmodels/vehiculo_viewmodel.dart';
import 'package:autovitae/viewmodels/cita_viewmodel.dart';
import 'package:autovitae/core/utils/session_manager.dart';
import 'package:autovitae/core/theme/app_colors.dart';
import 'package:autovitae/core/theme/app_fonts.dart';
import 'package:autovitae/presentation/shared/widgets/buttons/primary_button.dart';

class AgendarCitaScreen extends StatefulWidget {
  final Taller taller;

  const AgendarCitaScreen({super.key, required this.taller});

  @override
  State<AgendarCitaScreen> createState() => _AgendarCitaScreenState();
}

class _AgendarCitaScreenState extends State<AgendarCitaScreen> {
  final _formKey = GlobalKey<FormState>();
  final VehiculoViewModel _vehiculoViewModel = VehiculoViewModel();
  final CitaViewModel _citaViewModel = CitaViewModel();
  final TextEditingController _descripcionController = TextEditingController();

  bool _isLoading = false;
  String? _clienteId;
  Vehiculo? _selectedVehiculo;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);

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
    if (cliente != null) {
      _clienteId = cliente.uidCliente;
      await _vehiculoViewModel.cargarVehiculosPorCliente(cliente.uidCliente!);
    }

    setState(() => _isLoading = false);
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
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (time != null) {
      setState(() => _selectedTime = time);
    }
  }

  Future<void> _agendarCita() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedVehiculo == null) {
      _showError('Por favor selecciona un vehículo');
      return;
    }

    if (_clienteId == null) {
      _showError('Error de sesión');
      return;
    }

    setState(() => _isLoading = true);

    final fechaCita = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final cita = Cita(
      uidCliente: _clienteId!,
      uidVehiculo: _selectedVehiculo!.uidVehiculo!,
      uidTaller: widget.taller.uidTaller!,
      fechaCita: fechaCita.millisecondsSinceEpoch,
      estado: EstadoCita.pendiente,
      descripcion: _descripcionController.text.trim(),
    );

    final success = await _citaViewModel.registrarCita(cita);

    setState(() => _isLoading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Cita agendada exitosamente'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.of(context).pop(true);
    } else {
      _showError(_citaViewModel.error ?? 'Error al agendar cita');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Agendar Cita'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.black,
        elevation: 0,
      ),
      body: _isLoading && _vehiculoViewModel.vehiculos.isEmpty
          ? Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Taller info
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primaryColor),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.build, color: AppColors.primaryColor),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Taller', style: AppTextStyles.caption),
                                Text(
                                  widget.taller.nombre,
                                  style: AppTextStyles.bodyText.copyWith(
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

                    // Vehicle selection
                    Text('Vehículo', style: AppTextStyles.headline1),
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
                            Icon(Icons.warning, color: AppColors.warning),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'No tienes vehículos registrados. Registra un vehículo primero.',
                                style: AppTextStyles.bodyText,
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
                        final isSelected =
                            _selectedVehiculo?.uidVehiculo ==
                            vehiculo.uidVehiculo;
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
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color:
                                    (isSelected
                                            ? AppColors.primaryColor
                                            : AppColors.grey)
                                        .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.directions_car,
                                color: isSelected
                                    ? AppColors.primaryColor
                                    : AppColors.grey,
                              ),
                            ),
                            title: Text(
                              '${vehiculo.marca ?? ''} ${vehiculo.modelo ?? ''}',
                              style: AppTextStyles.bodyText,
                            ),
                            subtitle: Text(
                              'Placa: ${vehiculo.placa ?? 'Sin placa'}',
                              style: AppTextStyles.caption,
                            ),
                            trailing: isSelected
                                ? Icon(
                                    Icons.check_circle,
                                    color: AppColors.primaryColor,
                                  )
                                : null,
                            onTap: () {
                              setState(() => _selectedVehiculo = vehiculo);
                            },
                          ),
                        );
                      }),
                    const SizedBox(height: 24),

                    // Date and time
                    Text('Fecha y Hora', style: AppTextStyles.headline1),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: _selectDate,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.grey.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    color: AppColors.primaryColor,
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Fecha',
                                        style: AppTextStyles.caption,
                                      ),
                                      Text(
                                        _formatDate(_selectedDate),
                                        style: AppTextStyles.bodyText.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InkWell(
                            onTap: _selectTime,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.grey.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    color: AppColors.primaryColor,
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Hora',
                                        style: AppTextStyles.caption,
                                      ),
                                      Text(
                                        _formatTime(_selectedTime),
                                        style: AppTextStyles.bodyText.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Description
                    Text(
                      'Descripción (Opcional)',
                      style: AppTextStyles.headline1,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _descripcionController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText:
                            'Describe el problema o servicio que necesitas...',
                        hintStyle: AppTextStyles.caption,
                        filled: true,
                        fillColor: AppColors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.grey.withValues(alpha: 0.3),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.primaryColor,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Submit button
                    PrimaryButton(
                      text: 'Agendar Cita',
                      onPressed: _vehiculoViewModel.vehiculos.isNotEmpty
                          ? _agendarCita
                          : null,
                      isLoading: _isLoading,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
