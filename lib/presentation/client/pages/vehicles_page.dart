import 'package:flutter/material.dart';
import 'package:autovitae/data/models/vehiculo.dart';
import 'package:autovitae/viewmodels/vehiculo_viewmodel.dart';
import 'package:autovitae/core/utils/session_manager.dart';
import 'package:autovitae/presentation/shared/widgets/cards/card_vehicle.dart';

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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Stack(
      children: [
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Mis Vehículos', style: textTheme.headlineSmall),
                  Text(
                    '${_viewModel.vehiculos.length} registrados',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: colorScheme.primary,
                      ),
                    )
                  : _viewModel.vehiculos.isEmpty
                      ? _buildEmptyState(colorScheme, textTheme)
                      : RefreshIndicator(
                          onRefresh: _loadVehiculos,
                          color: colorScheme.primary,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _viewModel.vehiculos.length,
                            itemBuilder: (context, index) {
                              final vehiculo = _viewModel.vehiculos[index];
                              return VehicleCard(
                                vehiculo: vehiculo,
                                onEdit: () => _navigateToEditVehiculo(vehiculo),
                                onDelete: () => _deleteVehiculo(vehiculo),
                                onTap: () => _navigateToEditVehiculo(vehiculo),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
        // FAB posicionado abajo a la derecha
        Positioned(
          right: 24,
          bottom: 48,
          child: FloatingActionButton.extended(
            onPressed: _navigateToCreateVehiculo,
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            icon: const Icon(Icons.add),
            label: const Text('Agregar'),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme, TextTheme textTheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.directions_car_outlined,
              size: 64,
              color: colorScheme.primary.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No tienes vehículos registrados',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Agrega tu primer vehículo para comenzar',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 80), // Espacio para el FAB
        ],
      ),
    );
  }
}
