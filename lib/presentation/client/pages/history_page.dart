import 'package:flutter/material.dart';
import 'package:autovitae/viewmodels/cita_viewmodel.dart';
import 'package:autovitae/viewmodels/factura_viewmodel.dart';
import 'package:autovitae/core/utils/session_manager.dart';
import 'package:autovitae/data/models/estado_cita.dart';
import 'package:autovitae/core/theme/app_colors.dart';
import 'package:autovitae/presentation/shared/screens/invoice_detail_screen.dart';
import 'package:autovitae/presentation/shared/widgets/cards/generic_list_tile.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage>
    with SingleTickerProviderStateMixin {
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

  Color _getEstadoColor(BuildContext context, EstadoCita estado) {
    switch (estado) {
      case EstadoCita.pendiente:
        return AppColors.warning;
      case EstadoCita.confirmada:
        return AppColors.success;
      case EstadoCita.rechazada:
        return Theme.of(context).colorScheme.error;
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
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        TabBar(
          controller: _tabController,
          labelColor: colorScheme.primary,
          unselectedLabelColor: AppColors.grey,
          indicatorColor: colorScheme.primary,
          tabs: const [
            Tab(text: 'Citas', icon: Icon(Icons.calendar_today)),
            Tab(text: 'Facturas', icon: Icon(Icons.receipt)),
          ],
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
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

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
                      backgroundColor: _getEstadoColor(context, cita.estado),
                      child: Icon(
                        Icons.event,
                        color: colorScheme.onPrimary,
                      ),
                    ),
                    title: Text(
                      'Cita del ${_formatDate(cita.fechaCita)}',
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          cita.descripcion!.isNotEmpty
                              ? cita.descripcion!
                              : 'Sin descripción',
                          maxLines: 2,
                          style: textTheme.bodyMedium
                              ?.copyWith(color: colorScheme.onSurfaceVariant),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Chip(
                          label: Text(
                            _getEstadoText(cita.estado),
                            style: TextStyle(
                              fontSize: 16,
                              color: colorScheme.onPrimary,
                            ),
                          ),
                          backgroundColor:
                              _getEstadoColor(context, cita.estado),
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
    final colorScheme = Theme.of(context).colorScheme;

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
                  leadingIcon: Icon(Icons.receipt, color: colorScheme.tertiary),
                  leadingBackgroundColor: colorScheme.secondary,
                  title:
                      'Factura #${factura.uidFactura?.substring(0, 8) ?? '---'}',
                  subtitle:
                      'Fecha: ${_formatDate(factura.fechaEmision)}\nTotal: \$${factura.total.toStringAsFixed(2)}',
                  isThreeLine: true,
                  trailing: Icon(Icons.chevron_right,
                      color: colorScheme.onSurfaceVariant),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            InvoiceDetailScreen(factura: factura),
                      ),
                    );
                  },
                );
              },
            ),
          );
  }
}
