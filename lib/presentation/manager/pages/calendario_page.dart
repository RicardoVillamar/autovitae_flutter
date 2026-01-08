import 'package:flutter/material.dart';
import 'package:autovitae/data/models/cita.dart';
import 'package:autovitae/data/models/estado_cita.dart';
import 'package:autovitae/viewmodels/cita_viewmodel.dart';
import 'package:autovitae/data/repositories/vehiculo_repository.dart';
import 'package:autovitae/data/repositories/cliente_repository.dart';
import 'package:autovitae/data/repositories/usuario_repository.dart';
import 'package:autovitae/core/utils/session_manager.dart';
import 'package:autovitae/presentation/shared/widgets/cards/generic_list_tile.dart';

class CalendarioPage extends StatefulWidget {
  const CalendarioPage({super.key});

  @override
  State<CalendarioPage> createState() =>
      _CalendarioPageState();
}

class _CalendarioPageState extends State<CalendarioPage> {
  final CitaViewModel _viewModel = CitaViewModel();
  final VehiculoRepository _vehiculoRepository = VehiculoRepository();
  final ClienteRepository _clienteRepository = ClienteRepository();
  final UsuarioRepository _usuarioRepository = UsuarioRepository();
  bool _isLoading = false;
  EstadoCita? _filtroEstado;

  @override
  void initState() {
    super.initState();
    _loadCitas();
  }

  Future<void> _loadCitas() async {
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
      await _viewModel.cargarCitasPorTallerYEstado(
        gerente!.uidTaller!,
        _filtroEstado!,
      );
    } else {
      await _viewModel.cargarCitasPorTaller(gerente!.uidTaller!);
    }
    setState(() => _isLoading = false);
  }

  Future<void> _changeEstado(Cita cita) async {
    final newEstado = await showDialog<EstadoCita>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cambiar Estado'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: EstadoCita.values.map((estado) {
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
      final success = await _viewModel.actualizarEstadoCita(
        cita.uidCita!,
        newEstado,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Estado actualizado exitosamente')),
          );
          _loadCitas();
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

  Color _getEstadoColor(EstadoCita estado) {
    switch (estado) {
      case EstadoCita.pendiente:
        return Colors.orange;
      case EstadoCita.confirmada:
        return Colors.green;
      case EstadoCita.rechazada:
        return Colors.red;
    }
  }

  String _getEstadoText(EstadoCita estado) {
    switch (estado) {
      case EstadoCita.pendiente:
        return 'Pendiente';
      case EstadoCita.confirmada:
        return 'Confirmada';
      case EstadoCita.rechazada:
        return 'Rechazada';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: DropdownButtonFormField<EstadoCita?>(
            initialValue: _filtroEstado,
            decoration: const InputDecoration(
              labelText: 'Filtrar por estado',
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem(value: null, child: Text('Todos')),
              ...EstadoCita.values.map((estado) {
                return DropdownMenuItem(
                  value: estado,
                  child: Text(_getEstadoText(estado)),
                );
              }),
            ],
            onChanged: (value) {
              setState(() => _filtroEstado = value);
              _loadCitas();
            },
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _viewModel.citas.isEmpty
              ? const Center(child: Text('No hay citas programadas'))
              : RefreshIndicator(
                  onRefresh: _loadCitas,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _viewModel.citas.length,
                    itemBuilder: (context, index) {
                      final cita = _viewModel.citas[index];
                      return FutureBuilder(
                        future: Future.wait([
                          _vehiculoRepository.getById(cita.uidVehiculo),
                          _clienteRepository.getById(cita.uidCliente),
                        ]),
                        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
                          if (!snapshot.hasData) {
                            return const SizedBox.shrink();
                          }

                          final vehiculo = snapshot.data![0];
                          final cliente = snapshot.data![1];

                          return FutureBuilder(
                            future: cliente != null
                                ? _usuarioRepository.getById(cliente.uidUsuario)
                                : Future.value(null),
                            builder: (context, usuarioSnapshot) {
                              final usuario = usuarioSnapshot.data;

                              return GenericListTile(
                                leadingIcon: const Icon(
                                  Icons.calendar_today,
                                  color: Colors.white,
                                ),
                                leadingBackgroundColor: _getEstadoColor(cita.estado),
                                title: usuario != null
                                    ? '${usuario.nombre} ${usuario.apellido}'
                                    : 'Cliente',
                                subtitle:
                                    '${vehiculo != null ? '${vehiculo.marca} ${vehiculo.modelo} - ${vehiculo.placa}\n' : ''}Fecha: ${DateTime.fromMillisecondsSinceEpoch(cita.fechaCita).day}/${DateTime.fromMillisecondsSinceEpoch(cita.fechaCita).month}/${DateTime.fromMillisecondsSinceEpoch(cita.fechaCita).year}\nHora: ${DateTime.fromMillisecondsSinceEpoch(cita.fechaCita).hour}:${DateTime.fromMillisecondsSinceEpoch(cita.fechaCita).minute.toString().padLeft(2, '0')}\n${_getEstadoText(cita.estado)}',
                                isThreeLine: true,
                                trailing: PopupMenuButton(
                                  itemBuilder: (context) => [
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
                                    if (cita.estado != EstadoCita.rechazada)
                                      const PopupMenuItem(
                                        value: 'cancel',
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.cancel,
                                              color: Colors.red,
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              'Cancelar',
                                              style: TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                  onSelected: (value) {
                                    if (value == 'change_status') {
                                      _changeEstado(cita);
                                    } else if (value == 'cancel') {
                                      _viewModel
                                          .cancelarCita(cita.uidCita!)
                                          .then((success) {
                                            if (success && context.mounted) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Cita cancelada',
                                                  ),
                                                ),
                                              );
                                              _loadCitas();
                                            }
                                          });
                                    }
                                  },
                                ),
                              );
                            },
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
