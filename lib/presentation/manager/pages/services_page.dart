import 'package:flutter/material.dart';
import 'package:autovitae/data/models/servicio_taller.dart';
import 'package:autovitae/data/models/categoria_serivicio_taller.dart';
import 'package:autovitae/viewmodels/servicio_taller_viewmodel.dart';
import 'package:autovitae/core/utils/session_manager.dart';
import 'package:autovitae/presentation/manager/screens/register_service_screen.dart';

class ServicesPage extends StatefulWidget {
  const ServicesPage({super.key});

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  final ServicioTallerViewModel _viewModel = ServicioTallerViewModel();
  bool _isLoading = false;
  CategoriaSerivicioTaller? _filtroCategoria;

  @override
  void initState() {
    super.initState();
    _loadServicios();
  }

  Future<void> _loadServicios() async {
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
    await _viewModel.cargarServiciosActivosPorTaller(gerente!.uidTaller!);
    setState(() => _isLoading = false);
  }

  Future<void> _toggleServicioStatus(ServicioTaller servicio) async {
    final action = servicio.estado == 1 ? 'desactivar' : 'activar';
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('¿$action servicio?'),
        content: Text(
          '¿Estás seguro de que deseas $action "${servicio.nombre}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(action.toUpperCase()),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final success = servicio.estado == 1
          ? await _viewModel.eliminarServicio(servicio.uidServicio!)
          : await _viewModel.activarServicio(servicio.uidServicio!);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Servicio ${action}do exitosamente')),
          );
          _loadServicios();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_viewModel.error ?? 'Error al $action servicio'),
            ),
          );
        }
      }
    }
  }

  String _getCategoriaText(CategoriaSerivicioTaller categoria) {
    switch (categoria) {
      case CategoriaSerivicioTaller.mecanica:
        return 'Mecánica';
      case CategoriaSerivicioTaller.limpieza:
        return 'Limpieza';
      case CategoriaSerivicioTaller.pulido:
        return 'Pulido';
      case CategoriaSerivicioTaller.remolque:
        return 'Remolque';
      case CategoriaSerivicioTaller.cambioLlantas:
        return 'Cambio de Llantas';
      case CategoriaSerivicioTaller.otros:
        return 'Otros';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<CategoriaSerivicioTaller?>(
                  initialValue: _filtroCategoria,
                  decoration: const InputDecoration(
                    labelText: 'Filtrar por categoría',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Todos')),
                    ...CategoriaSerivicioTaller.values.map((categoria) {
                      return DropdownMenuItem(
                        value: categoria,
                        child: Text(_getCategoriaText(categoria)),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() => _filtroCategoria = value);
                    _loadServicios();
                  },
                ),
              ),
              const SizedBox(width: 8),
              FloatingActionButton(
                onPressed: () async {
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const RegisterServiceScreen(),
                    ),
                  );
                  if (result == true) {
                    _loadServicios();
                  }
                },
                child: const Icon(Icons.add),
              ),
            ],
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _viewModel.servicios.isEmpty
                  ? const Center(child: Text('No hay servicios registrados'))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _viewModel.servicios
                          .where(
                            (s) =>
                                _filtroCategoria == null ||
                                s.categoria == _filtroCategoria,
                          )
                          .length,
                      itemBuilder: (context, index) {
                        final serviciosFiltrados = _viewModel.servicios
                            .where(
                              (s) =>
                                  _filtroCategoria == null ||
                                  s.categoria == _filtroCategoria,
                            )
                            .toList();
                        final servicio = serviciosFiltrados[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: servicio.estado == 1
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey,
                              child: const Icon(
                                Icons.construction,
                                color: Colors.white,
                              ),
                            ),
                            title: Text(servicio.nombre),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getCategoriaText(servicio.categoria),
                                  style: const TextStyle(
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                if (servicio.descripcion != null)
                                  Text(
                                    servicio.descripcion!,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                Text(
                                  '\$${servicio.precio.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            trailing: PopupMenuButton(
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit),
                                      SizedBox(width: 8),
                                      Text('Editar'),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'toggle',
                                  child: Row(
                                    children: [
                                      Icon(
                                        servicio.estado == 1
                                            ? Icons.delete
                                            : Icons.check,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        servicio.estado == 1
                                            ? 'Desactivar'
                                            : 'Activar',
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              onSelected: (value) async {
                                if (value == 'edit') {
                                  final result =
                                      await Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          RegisterServiceScreen(
                                              servicio: servicio),
                                    ),
                                  );
                                  if (result == true) {
                                    _loadServicios();
                                  }
                                } else if (value == 'toggle') {
                                  _toggleServicioStatus(servicio);
                                }
                              },
                            ),
                            isThreeLine: true,
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}
