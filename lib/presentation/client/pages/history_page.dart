import 'package:flutter/material.dart';
import 'package:autovitae/viewmodels/cita_viewmodel.dart';
import 'package:autovitae/viewmodels/factura_viewmodel.dart';
import 'package:autovitae/core/utils/session_manager.dart';
import 'package:autovitae/data/models/estado_cita.dart';
import 'package:autovitae/core/theme/app_colors.dart';
import 'package:autovitae/core/theme/app_fonts.dart';
import 'package:autovitae/presentation/shared/screens/invoice_detail_screen.dart';
import 'package:autovitae/presentation/shared/widgets/cards/generic_list_tile.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> with SingleTickerProviderStateMixin {
  final CitaViewModel _citaViewModel = CitaViewModel();
  final FacturaViewModel _facturaViewModel = FacturaViewModel();
  late TabController _tabController;
  bool _isLoading = false;

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
    final cliente = await SessionManager().getCliente();
    if (cliente == null) return;

    setState(() => _isLoading = true);
    await Future.wait([
      _citaViewModel.cargarCitasPorCliente(cliente.uidCliente!),
      _facturaViewModel.cargarFacturasPorCliente(cliente.uidCliente!),
    ]);
    setState(() => _isLoading = false);
  }

  Color _getEstadoColor(EstadoCita estado) {
    switch (estado) {
      case EstadoCita.pendiente:
        return AppColors.warning;
      case EstadoCita.confirmada:
        return AppColors.success;
      case EstadoCita.rechazada:
        return AppColors.error;
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

  String _formatDate(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: AppColors.background,
          child: TabBar(
            controller: _tabController,
            labelColor: AppColors.primaryColor,
            unselectedLabelColor: AppColors.grey,
            indicatorColor: AppColors.primaryColor,
            tabs: const [
              Tab(text: 'Citas', icon: Icon(Icons.calendar_today)),
              Tab(text: 'Facturas', icon: Icon(Icons.receipt)),
            ],
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildCitasTab(),
                    _buildFacturasTab(),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildCitasTab() {
    return _citaViewModel.citas.isEmpty
        ? const Center(child: Text('No tienes citas programadas'))
        : RefreshIndicator(
            onRefresh: _loadData,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _citaViewModel.citas.length,
              itemBuilder: (context, index) {
                final cita = _citaViewModel.citas[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: _getEstadoColor(cita.estado),
                      child: const Icon(
                        Icons.event,
                        color: AppColors.white,
                      ),
                    ),
                    title: Text(
                      'Cita del ${_formatDate(cita.fechaCita)}',
                      style: AppTextStyles.bodyText.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        if (cita.descripcion?.isNotEmpty == true)
                          Text(
                            cita.descripcion!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        const SizedBox(height: 4),
                        Chip(
                          label: Text(
                            _getEstadoText(cita.estado),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.white,
                            ),
                          ),
                          backgroundColor: _getEstadoColor(cita.estado),
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
          );
  }

  Widget _buildFacturasTab() {
    return _facturaViewModel.facturas.isEmpty
        ? const Center(child: Text('No tienes facturas registradas'))
        : RefreshIndicator(
            onRefresh: _loadData,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _facturaViewModel.facturas.length,
              itemBuilder: (context, index) {
                final factura = _facturaViewModel.facturas[index];
                return GenericListTile(
                  leadingIcon: const Icon(Icons.receipt, color: AppColors.white),
                  leadingBackgroundColor: AppColors.secondaryColor,
                  title: 'Factura #${factura.uidFactura?.substring(0, 8) ?? '---'}',
                  subtitle: 'Fecha: ${_formatDate(factura.fechaEmision)}\nTotal: \$${factura.total.toStringAsFixed(2)}',
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_right, color: AppColors.grey),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => InvoiceDetailScreen(factura: factura),
                      ),
                    );
                  },
                );
              },
            ),
          );
  }
}
