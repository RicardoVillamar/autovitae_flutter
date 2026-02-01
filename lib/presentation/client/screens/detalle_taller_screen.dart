import 'package:flutter/material.dart';
import 'package:autovitae/data/models/taller.dart';
import 'package:autovitae/data/models/servicio_taller.dart';
import 'package:autovitae/data/models/categoria_serivicio_taller.dart';
import 'package:autovitae/viewmodels/servicio_taller_viewmodel.dart';
import 'package:autovitae/core/theme/app_colors.dart';
import 'package:autovitae/presentation/client/screens/agendar_cita_screen.dart';
import 'package:autovitae/presentation/client/screens/programar_mantenimiento_screen.dart';
import 'package:autovitae/presentation/shared/widgets/appbar/custom_app_bar.dart';

class DetalleTallerScreen extends StatefulWidget {
  final Taller taller;

  const DetalleTallerScreen({super.key, required this.taller});

  @override
  State<DetalleTallerScreen> createState() => _DetalleTallerScreenState();
}

class _DetalleTallerScreenState extends State<DetalleTallerScreen> {
  final ServicioTallerViewModel _servicioViewModel = ServicioTallerViewModel();
  bool _isLoading = false;
  CategoriaSerivicioTaller? _selectedCategoria;

  @override
  void initState() {
    super.initState();
    _loadServicios();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadServicios() async {
    setState(() => _isLoading = true);
    await _servicioViewModel.cargarServiciosPorTaller(widget.taller.uidTaller!);
    setState(() => _isLoading = false);
  }

  List<ServicioTaller> get _serviciosFiltrados {
    if (_selectedCategoria == null) {
      return _servicioViewModel.servicios;
    }
    return _servicioViewModel.servicios
        .where((s) => s.categoria == _selectedCategoria)
        .toList();
  }

  void _agendarCita() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AgendarCitaScreen(taller: widget.taller),
      ),
    );
  }

  String _getCategoriaLabel(CategoriaSerivicioTaller categoria) {
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

    return Scaffold(
      appBar: CustomAppBar(
        title: widget.taller.nombre,
        showBackButton: true,
        showMenu: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header image/icon
            Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colorScheme.tertiary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.build, size: 64, color: colorScheme.tertiary),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                widget.taller.nombre,
                style: textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),

            // Contact info
            Text('Información de Contacto', style: textTheme.titleLarge),
            const SizedBox(height: 16),
            _buildInfoCard(
              icon: Icons.location_on,
              title: 'Dirección',
              value: widget.taller.direccion,
            ),
            _buildInfoCard(
              icon: Icons.phone,
              title: 'Teléfono',
              value: widget.taller.telefono,
            ),
            _buildInfoCard(
              icon: Icons.email,
              title: 'Correo',
              value: widget.taller.correo,
            ),

            // Description
            if (widget.taller.descripcion.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text('Descripción', style: textTheme.titleLarge),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.outlineVariant,
                    width: 1,
                  ),
                ),
                child: Text(
                  widget.taller.descripcion,
                  style: textTheme.bodyLarge,
                ),
              ),
            ],

            const SizedBox(height: 32),
            Text('Servicios Disponibles', style: textTheme.titleLarge),
            const SizedBox(height: 12),

            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildFilterChip('Todos', null),
                  ...CategoriaSerivicioTaller.values.map(
                    (cat) => _buildFilterChip(_getCategoriaLabel(cat), cat),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Services list
            if (_isLoading)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: CircularProgressIndicator(color: colorScheme.primary),
                ),
              )
            else if (_serviciosFiltrados.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(Icons.build_circle,
                          size: 48, color: colorScheme.outline),
                      const SizedBox(height: 12),
                      Text(
                        'No hay servicios disponibles',
                        style: textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ..._serviciosFiltrados
                  .map((servicio) => _buildServicioCard(servicio)),

            // Espacio para los FABs
            const SizedBox(height: 180),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'mantenimiento',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      ProgramarMantenimientoScreen(taller: widget.taller),
                ),
              );
            },
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            icon: const Icon(Icons.build_circle),
            label: const Text('Programar Mantenimiento'),
          ),
          const SizedBox(height: 16),
          FloatingActionButton.extended(
            heroTag: 'cita',
            onPressed: _agendarCita,
            backgroundColor: colorScheme.tertiary,
            foregroundColor: colorScheme.onTertiary,
            icon: const Icon(Icons.calendar_today),
            label: const Text('Agendar Cita'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, CategoriaSerivicioTaller? categoria) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = _selectedCategoria == categoria;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCategoria = selected ? categoria : null;
          });
        },
        selectedColor: colorScheme.primary,
        backgroundColor: colorScheme.surfaceContainerHigh,
        checkmarkColor: colorScheme.onPrimary,
        labelStyle: TextStyle(
          color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildServicioCard(ServicioTaller servicio) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.build,
                color: colorScheme.secondary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    servicio.nombre,
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (servicio.descripcion?.isNotEmpty == true) ...[
                    const SizedBox(height: 4),
                    Text(
                      servicio.descripcion!,
                      style: textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 4),
                  Chip(
                    label: Text(_getCategoriaLabel(servicio.categoria)),
                    backgroundColor: colorScheme.primary.withValues(
                      alpha: 0.2,
                    ),
                    labelStyle: textTheme.bodySmall?.copyWith(fontSize: 11),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
            Text(
              '\$${servicio.precio.toStringAsFixed(2)}',
              style: textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.success,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: colorScheme.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
