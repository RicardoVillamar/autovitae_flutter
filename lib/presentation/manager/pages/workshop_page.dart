import 'package:flutter/material.dart';
import 'package:autovitae/data/models/taller.dart';
import 'package:autovitae/data/models/servicio_taller.dart';
import 'package:autovitae/data/models/categoria_serivicio_taller.dart';
import 'package:autovitae/core/utils/session_manager.dart';
import 'package:autovitae/core/theme/app_colors.dart';
import 'package:autovitae/data/repositories/taller_repository.dart';
import 'package:autovitae/viewmodels/servicio_taller_viewmodel.dart';
import 'package:autovitae/presentation/manager/screens/register_service_screen.dart';
import 'package:autovitae/presentation/manager/screens/invoice_history_screen.dart';

class WorkshopPage extends StatefulWidget {
  const WorkshopPage({super.key});

  @override
  State<WorkshopPage> createState() => _WorkshopPageState();
}

class _WorkshopPageState extends State<WorkshopPage>
    with SingleTickerProviderStateMixin {
  final TallerRepository _tallerRepository = TallerRepository();
  final ServicioTallerViewModel _servicioViewModel = ServicioTallerViewModel();
  Taller? _taller;
  bool _isLoading = false;
  late TabController _tabController;
  CategoriaSerivicioTaller? _filtroCategoria;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final gerente = await SessionManager().getGerente();

    if (gerente?.uidTaller != null) {
      _taller = await _tallerRepository.getById(gerente!.uidTaller!);
      await _servicioViewModel.cargarServiciosActivosPorTaller(
        gerente.uidTaller!,
      );
    }

    setState(() => _isLoading = false);
  }

  Future<void> _toggleServicioStatus(ServicioTaller servicio) async {
    final colorScheme = Theme.of(context).colorScheme;
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
          ? await _servicioViewModel.eliminarServicio(servicio.uidServicio!)
          : await _servicioViewModel.activarServicio(servicio.uidServicio!);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Servicio ${action}do exitosamente'),
              backgroundColor: AppColors.success,
            ),
          );
          _loadData();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _servicioViewModel.error ?? 'Error al $action servicio',
              ),
              backgroundColor: colorScheme.error,
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_taller == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.store_mall_directory,
                size: 64, color: AppColors.grey),
            const SizedBox(height: 16),
            Text(
              'No tienes un taller asignado',
              style: textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Contacta al administrador para asignar un taller',
              style: textTheme.bodySmall,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Container(
          color: colorScheme.surface,
          child: TabBar(
            controller: _tabController,
            labelColor: colorScheme.primary,
            unselectedLabelColor: AppColors.grey,
            indicatorColor: colorScheme.primary,
            tabs: const [
              Tab(icon: Icon(Icons.info), text: 'Información'),
              Tab(icon: Icon(Icons.construction), text: 'Servicios'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [_buildTallerInfo(), _buildServiciosList()],
          ),
        ),
      ],
    );
  }

  Widget _buildTallerInfo() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.store, size: 80, color: colorScheme.primary),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              _taller!.nombre,
              style: textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Información del Taller',
                    style: textTheme.headlineSmall,
                  ),
                  const Divider(height: 24),
                  _buildInfoRow(
                    Icons.location_on,
                    'Dirección',
                    _taller!.direccion,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(Icons.phone, 'Teléfono', _taller!.telefono),
                  const SizedBox(height: 16),
                  _buildInfoRow(Icons.email, 'Email', _taller!.correo),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    Icons.circle,
                    'Estado',
                    _taller!.estado == 1 ? 'Activo' : 'Inactivo',
                    color: _taller!.estado == 1
                        ? AppColors.success
                        : colorScheme.error,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.receipt_long, color: colorScheme.secondary),
              ),
              title: Text('Historial de Facturas', style: textTheme.bodyLarge),
              trailing: const Icon(Icons.chevron_right, color: AppColors.grey),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const InvoiceHistoryScreen(),
                  ),
                );
              },
            ),
          ),
          if (_taller!.descripcion.isNotEmpty) ...[
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Descripción', style: textTheme.headlineSmall),
                    const Divider(height: 24),
                    Text(_taller!.descripcion, style: textTheme.bodyLarge),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildServiciosList() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.2,
                      ),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<CategoriaSerivicioTaller?>(
                      isExpanded: true,
                      value: _filtroCategoria,
                      hint: const Text('Filtrar por categoría'),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('Todas las categorías'),
                        ),
                        ...CategoriaSerivicioTaller.values.map((categoria) {
                          return DropdownMenuItem(
                            value: categoria,
                            child: Text(_getCategoriaText(categoria)),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        setState(() => _filtroCategoria = value);
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              FloatingActionButton(
                onPressed: () async {
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const RegisterServiceScreen(),
                    ),
                  );
                  if (result == true) {
                    _loadData();
                  }
                },
                backgroundColor: colorScheme.primary,
                child: const Icon(Icons.add, color: AppColors.black),
              ),
            ],
          ),
        ),
        Expanded(
          child: _servicioViewModel.servicios.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.construction,
                          size: 64, color: AppColors.grey),
                      const SizedBox(height: 16),
                      Text(
                        'No hay servicios registrados',
                        style: textTheme.bodyLarge,
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  color: colorScheme.primary,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _servicioViewModel.servicios
                        .where(
                          (s) =>
                              _filtroCategoria == null ||
                              s.categoria == _filtroCategoria,
                        )
                        .length,
                    itemBuilder: (context, index) {
                      final servicios = _servicioViewModel.servicios
                          .where(
                            (s) =>
                                _filtroCategoria == null ||
                                s.categoria == _filtroCategoria,
                          )
                          .toList();
                      final servicio = servicios[index];
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
                              color: servicio.estado == 1
                                  ? colorScheme.primary.withValues(
                                      alpha: 0.1,
                                    )
                                  : AppColors.grey.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.construction,
                              color: servicio.estado == 1
                                  ? colorScheme.primary
                                  : AppColors.grey,
                            ),
                          ),
                          title: Text(
                            servicio.nombre,
                            style: textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                _getCategoriaText(servicio.categoria),
                                style: textTheme.bodySmall?.copyWith(
                                  fontStyle: FontStyle.italic,
                                  color: colorScheme.primary,
                                ),
                              ),
                              if (servicio.descripcion != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  servicio.descripcion!,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: textTheme.bodySmall,
                                ),
                              ],
                              const SizedBox(height: 4),
                              Text(
                                '\$${servicio.precio.toStringAsFixed(2)}',
                                style: textTheme.bodyLarge?.copyWith(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          trailing: PopupMenuButton(
                            icon: const Icon(Icons.more_vert,
                                color: AppColors.grey),
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.edit,
                                      color: colorScheme.primary,
                                    ),
                                    const SizedBox(width: 12),
                                    const Text('Editar'),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'toggle',
                                child: Row(
                                  children: [
                                    Icon(
                                      servicio.estado == 1
                                          ? Icons.cancel
                                          : Icons.check_circle,
                                      color: servicio.estado == 1
                                          ? colorScheme.error
                                          : AppColors.success,
                                    ),
                                    const SizedBox(width: 12),
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
                                final result = await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => RegisterServiceScreen(
                                      servicio: servicio,
                                    ),
                                  ),
                                );
                                if (result == true) {
                                  _loadData();
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
        ),
      ],
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    Color? color,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: color ?? colorScheme.primary),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: textTheme.bodySmall),
              const SizedBox(height: 4),
              Text(
                value,
                style: textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
