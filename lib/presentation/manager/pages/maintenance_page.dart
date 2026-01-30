import 'package:flutter/material.dart';
import 'package:autovitae/data/models/mantenimiento.dart';
import 'package:autovitae/data/models/estado_mantenimiento.dart';
import 'package:autovitae/viewmodels/mantenimiento_viewmodel.dart';
import 'package:autovitae/core/utils/session_manager.dart';
import 'package:autovitae/presentation/manager/screens/maintenance_detail_screen.dart';
import 'package:autovitae/data/repositories/vehiculo_repository.dart';
import 'package:autovitae/presentation/shared/widgets/cards/generic_list_tile.dart';

class MaintenancePage extends StatefulWidget {
  const MaintenancePage({super.key});

  @override
  State<MaintenancePage> createState() => _MaintenancePageState();
}

class _MaintenancePageState extends State<MaintenancePage> {
  final MantenimientoViewModel _viewModel = MantenimientoViewModel();
  final VehiculoRepository _vehiculoRepository = VehiculoRepository();
  bool _isLoading = false;
  EstadoMantenimiento? _filtroEstado;

  @override
  void initState() {
    super.initState();
    _loadMantenimientos();
  }

  Future<void> _loadMantenimientos() async {
    final gerente = await SessionManager().getGerente();
    if (gerente?.uidTaller == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No tienes un taller asignado')),
        );
      }
      return;
    }

    setState(() => _isLoading = true);
    if (_filtroEstado != null) {
      await _viewModel.cargarMantenimientosPorTallerYEstado(
        gerente!.uidTaller!,
        _filtroEstado!,
      );
    } else {
      await _viewModel.cargarMantenimientosPorTaller(gerente!.uidTaller!);
    }
    setState(() => _isLoading = false);
  }

  Future<void> _changeEstado(Mantenimiento mantenimiento) async {
    final newEstado = await showDialog<EstadoMantenimiento>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cambiar Estado'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: EstadoMantenimiento.values.map((estado) {
            return ListTile(
              title: Text(_getEstadoText(estado)),
              leading: Icon(Icons.circle, color: _getEstadoColor(estado)),
              onTap: () => Navigator.of(context).pop(estado),
            );
          }).toList(),
        ),
      ),
    );

    if (newEstado != null && mounted) {
      final success = await _viewModel.actualizarEstadoMantenimiento(
        mantenimiento.uidMantenimiento!,
        newEstado,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Estado actualizado exitosamente')),
          );
          _loadMantenimientos();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_viewModel.error ?? 'Error al actualizar estado'),
            ),
          );
        }
      }
    }
  }

  Color _getEstadoColor(EstadoMantenimiento estado) {
    switch (estado) {
      case EstadoMantenimiento.pendiente:
        return Colors.orange;
      case EstadoMantenimiento.enProceso:
        return Colors.blue;
      case EstadoMantenimiento.finalizado:
        return Colors.green;
      case EstadoMantenimiento.cancelado:
        return Colors.red;
    }
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<EstadoMantenimiento?>(
                  initialValue: _filtroEstado,
                  decoration: const InputDecoration(
                    labelText: 'Filtrar por estado',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Todos')),
                    ...EstadoMantenimiento.values.map((estado) {
                      return DropdownMenuItem(
                        value: estado,
                        child: Text(_getEstadoText(estado)),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() => _filtroEstado = value);
                    _loadMantenimientos();
                  },
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _viewModel.mantenimientos.isEmpty
                  ? const Center(
                      child: Text('No hay mantenimientos registrados'))
                  : RefreshIndicator(
                      onRefresh: _loadMantenimientos,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _viewModel.mantenimientos.length,
                        itemBuilder: (context, index) {
                          final mantenimiento =
                              _viewModel.mantenimientos[index];
                          return FutureBuilder(
                            future: _vehiculoRepository.getById(
                              mantenimiento.uidVehiculo,
                            ),
                            builder: (context, snapshot) {
                              final vehiculo = snapshot.data;

                              final fechaMostrar = mantenimiento.fechaInicio ??
                                  mantenimiento.fechaProgramada;
                              final date = DateTime.fromMillisecondsSinceEpoch(
                                  fechaMostrar);

                              return GenericListTile(
                                leadingIcon: const Icon(
                                  Icons.build,
                                  color: Colors.white,
                                ),
                                leadingBackgroundColor:
                                    _getEstadoColor(mantenimiento.estado),
                                title: vehiculo != null
                                    ? '${vehiculo.marca ?? ''} ${vehiculo.modelo ?? ''}'
                                    : 'Vehículo',
                                subtitle:
                                    '${vehiculo != null ? 'Placa: ${vehiculo.placa ?? ''}\n' : ''}Fecha: ${date.day}/${date.month}/${date.year}\nEstado: ${_getEstadoText(mantenimiento.estado)}',
                                isThreeLine: true,
                                trailing: PopupMenuButton(
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'view',
                                      child: Row(
                                        children: [
                                          Icon(Icons.visibility),
                                          SizedBox(width: 8),
                                          Text('Ver Detalles'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'change_status',
                                      child: Row(
                                        children: [
                                          Icon(Icons.swap_horiz),
                                          SizedBox(width: 8),
                                          Text('Cambiar Estado'),
                                        ],
                                      ),
                                    ),
                                  ],
                                  onSelected: (value) async {
                                    if (value == 'view') {
                                      await Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              MaintenanceDetailScreen(
                                            mantenimiento: mantenimiento,
                                          ),
                                        ),
                                      );
                                      _loadMantenimientos();
                                    } else if (value == 'change_status') {
                                      _changeEstado(mantenimiento);
                                    }
                                  },
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }
}
