import 'package:flutter/material.dart';
import 'package:autovitae/data/models/vehiculo.dart';
import 'package:autovitae/viewmodels/vehiculo_viewmodel.dart';
import 'package:autovitae/core/utils/session_manager.dart';
import 'package:autovitae/core/theme/app_colors.dart';
import 'package:autovitae/core/theme/app_fonts.dart';

class VehiclesPage extends StatefulWidget {
  const VehiclesPage({super.key});

  @override
  State<VehiclesPage> createState() => _VehiclesPageState();
}

class _VehiclesPageState extends State<VehiclesPage> {
  final VehiculoViewModel _viewModel = VehiculoViewModel();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadVehiculos();
  }

  Future<void> _loadVehiculos() async {
    final cliente = await SessionManager().getCliente();
    if (cliente == null) return;

    setState(() => _isLoading = true);
    await _viewModel.cargarVehiculosPorCliente(cliente.uidCliente!);
    setState(() => _isLoading = false);
  }

  Future<void> _navigateToCreateVehiculo() async {
    final result = await Navigator.of(context).pushNamed('/create_vehiculo');
    if (result == true) {
      _loadVehiculos();
    }
  }

  Future<void> _navigateToEditVehiculo(Vehiculo vehiculo) async {
    final result = await Navigator.of(
      context,
    ).pushNamed('/edit_vehiculo', arguments: vehiculo);
    if (result == true) {
      _loadVehiculos();
    }
  }

  Future<void> _deleteVehiculo(Vehiculo vehiculo) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Vehículo'),
        content: Text(
          '¿Estás seguro de que deseas eliminar el vehículo ${vehiculo.placa}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final success = await _viewModel.eliminarVehiculo(vehiculo.uidVehiculo!);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vehículo eliminado exitosamente')),
          );
          _loadVehiculos();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_viewModel.error ?? 'Error al eliminar vehículo'),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Mis Vehículos', style: AppTextStyles.headline1),
              FloatingActionButton(
                onPressed: _navigateToCreateVehiculo,
                backgroundColor: AppColors.primaryColor,
                child: const Icon(Icons.add, color: AppColors.black),
              ),
            ],
          ),
        ),
        Expanded(
          child: _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryColor,
                  ),
                )
              : _viewModel.vehiculos.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.directions_car,
                        size: 64,
                        color: AppColors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No tienes vehículos registrados',
                        style: AppTextStyles.bodyText,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Presiona + para agregar uno',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadVehiculos,
                  color: AppColors.primaryColor,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _viewModel.vehiculos.length,
                    itemBuilder: (context, index) {
                      final vehiculo = _viewModel.vehiculos[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.directions_car,
                              color: AppColors.primaryColor,
                              size: 28,
                            ),
                          ),
                          title: Text(
                            '${vehiculo.marca} ${vehiculo.modelo}',
                            style: AppTextStyles.bodyText.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                'Placa: ${vehiculo.placa}',
                                style: AppTextStyles.caption,
                              ),
                              Text(
                                'Año: ${vehiculo.anio}',
                                style: AppTextStyles.caption,
                              ),
                              Text(
                                'Kilometraje: ${vehiculo.kilometraje} km',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          trailing: PopupMenuButton(
                            icon: Icon(Icons.more_vert, color: AppColors.grey),
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.edit,
                                      color: AppColors.primaryColor,
                                    ),
                                    SizedBox(width: 12),
                                    Text('Editar'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, color: AppColors.error),
                                    SizedBox(width: 12),
                                    Text('Eliminar'),
                                  ],
                                ),
                              ),
                            ],
                            onSelected: (value) {
                              if (value == 'edit') {
                                _navigateToEditVehiculo(vehiculo);
                              } else if (value == 'delete') {
                                _deleteVehiculo(vehiculo);
                              }
                            },
                          ),
                          isThreeLine: true,
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }
}
