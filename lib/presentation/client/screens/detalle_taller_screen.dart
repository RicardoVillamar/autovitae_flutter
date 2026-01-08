import 'package:flutter/material.dart';
import 'package:autovitae/data/models/taller.dart';
import 'package:autovitae/data/models/servicio_taller.dart';
import 'package:autovitae/data/models/categoria_serivicio_taller.dart';
import 'package:autovitae/viewmodels/servicio_taller_viewmodel.dart';
import 'package:autovitae/core/theme/app_colors.dart';
import 'package:autovitae/core/theme/app_fonts.dart';
import 'package:autovitae/presentation/client/screens/agendar_cita_screen.dart';
import 'package:autovitae/presentation/client/screens/programar_mantenimiento_screen.dart';

class DetalleTallerScreen extends StatefulWidget {
  final Taller taller;

  const DetalleTallerScreen({super.key, required this.taller});

  @override
  State<DetalleTallerScreen> createState() =>
      _DetalleTallerScreenState();
}

class _DetalleTallerScreenState extends State<DetalleTallerScreen>
    with SingleTickerProviderStateMixin {
  final ServicioTallerViewModel _servicioViewModel = ServicioTallerViewModel();
  late TabController _tabController;
  bool _isLoading = false;
  CategoriaSerivicioTaller? _selectedCategoria;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadServicios();
  }

  @override
  void dispose() {
    _tabController.dispose();
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.taller.nombre),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.black,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.black,
          labelColor: AppColors.black,
          unselectedLabelColor: AppColors.black.withValues(alpha: 0.6),
          tabs: const [
            Tab(text: 'Información', icon: Icon(Icons.info_outline)),
            Tab(text: 'Servicios', icon: Icon(Icons.build)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildInfoTab(), _buildServicesPage()],
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
                  builder: (context) => ProgramarMantenimientoScreen(taller: widget.taller),
                ),
              );
            },
            backgroundColor: AppColors.warning,
            foregroundColor: AppColors.black,
            icon: const Icon(Icons.build_circle),
            label: const Text('Programar Mantenimiento'),
          ),
          const SizedBox(height: 16),
          FloatingActionButton.extended(
            heroTag: 'cita',
            onPressed: _agendarCita,
            backgroundColor: AppColors.primaryColor,
            foregroundColor: AppColors.black,
            icon: const Icon(Icons.calendar_today),
            label: const Text('Agendar Cita'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header image/icon
          Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.build, size: 64, color: AppColors.primaryColor),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              widget.taller.nombre,
              style: AppTextStyles.headline1,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          // Contact info
          Text('Información de Contacto', style: AppTextStyles.headline1),
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
          const SizedBox(height: 24),
          // Description
          if (widget.taller.descripcion.isNotEmpty) ...[
            Text('Descripción', style: AppTextStyles.headline1),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.grey.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                widget.taller.descripcion,
                style: AppTextStyles.bodyText,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildServicesPage() {
    return Column(
      children: [
        // Category filter
        Container(
          height: 56,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildFilterChip('Todos', null),
              ...CategoriaSerivicioTaller.values.map(
                (cat) => _buildFilterChip(_getCategoriaLabel(cat), cat),
              ),
            ],
          ),
        ),
        // Services list
        Expanded(
          child: _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryColor,
                  ),
                )
              : _serviciosFiltrados.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.build_circle, size: 64, color: AppColors.grey),
                      const SizedBox(height: 16),
                      Text(
                        'No hay servicios disponibles',
                        style: AppTextStyles.bodyText.copyWith(
                          color: AppColors.grey,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _serviciosFiltrados.length,
                  itemBuilder: (context, index) {
                    return _buildServicioCard(_serviciosFiltrados[index]);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, CategoriaSerivicioTaller? categoria) {
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
        selectedColor: AppColors.primaryColor,
        backgroundColor: AppColors.white,
        checkmarkColor: AppColors.black,
        labelStyle: TextStyle(
          color: isSelected ? AppColors.black : AppColors.textColor,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildServicioCard(ServicioTaller servicio) {
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
                color: AppColors.secondaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.build,
                color: AppColors.secondaryColor,
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
                    style: AppTextStyles.bodyText.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (servicio.descripcion?.isNotEmpty == true) ...[
                    const SizedBox(height: 4),
                    Text(
                      servicio.descripcion!,
                      style: AppTextStyles.caption,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 4),
                  Chip(
                    label: Text(_getCategoriaLabel(servicio.categoria)),
                    backgroundColor: AppColors.primaryColor.withValues(
                      alpha: 0.2,
                    ),
                    labelStyle: AppTextStyles.caption.copyWith(fontSize: 11),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
            Text(
              '\$${servicio.precio.toStringAsFixed(2)}',
              style: AppTextStyles.bodyText.copyWith(
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
                color: AppColors.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.primaryColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: AppTextStyles.bodyText.copyWith(
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
