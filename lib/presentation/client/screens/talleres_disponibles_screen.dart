import 'package:flutter/material.dart';
import 'package:autovitae/data/models/taller.dart';
import 'package:autovitae/viewmodels/taller_viewmodel.dart';
import 'package:autovitae/core/theme/app_colors.dart';
import 'package:autovitae/presentation/client/screens/detalle_taller_screen.dart';
import 'package:autovitae/presentation/shared/widgets/cards/generic_list_tile.dart';
import 'package:autovitae/presentation/shared/widgets/appbar/custom_app_bar.dart';

class TalleresDisponiblesScreen extends StatefulWidget {
  const TalleresDisponiblesScreen({super.key});

  @override
  State<TalleresDisponiblesScreen> createState() =>
      _TalleresDisponiblesScreenState();
}

class _TalleresDisponiblesScreenState extends State<TalleresDisponiblesScreen> {
  final TallerViewModel _viewModel = TallerViewModel();
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadTalleres();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTalleres() async {
    setState(() => _isLoading = true);
    await _viewModel.cargarTalleresActivos();
    setState(() => _isLoading = false);
  }

  Future<void> _searchTalleres(String query) async {
    if (query.isEmpty) {
      await _loadTalleres();
    } else {
      setState(() => _isLoading = true);
      await _viewModel.buscarPorNombre(query);
      setState(() => _isLoading = false);
    }
  }

  void _navigateToDetalle(Taller taller) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DetalleTallerScreen(taller: taller),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Talleres Disponibles',
        showBackButton: true,
        showMenu: true,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar taller...',
                hintStyle: textTheme.bodyLarge,
                prefixIcon: Icon(Icons.search, color: colorScheme.primary),
                filled: true,
                fillColor: colorScheme.primary.withValues(alpha: 0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: colorScheme.primary,
                    width: 2,
                  ),
                ),
              ),
              onChanged: _searchTalleres,
            ),
          ),
          // List
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: colorScheme.primary,
                    ),
                  )
                : _viewModel.talleres.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.store_mall_directory,
                              size: 64,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No hay talleres disponibles',
                              style: textTheme.bodyLarge?.copyWith(
                                color: AppColors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadTalleres,
                        color: colorScheme.primary,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _viewModel.talleres.length,
                          itemBuilder: (context, index) {
                            final taller = _viewModel.talleres[index];
                            return GenericListTile(
                              onTap: () => _navigateToDetalle(taller),
                              leadingIcon: Icon(
                                Icons.build,
                                color: colorScheme.primary,
                                size: 32,
                              ),
                              leadingBackgroundColor: colorScheme.primary,
                              title: taller.nombre,
                              subtitle:
                                  '${taller.direccion}\nTel: ${taller.telefono}',
                              trailing: const Icon(
                                Icons.chevron_right,
                                color: AppColors.grey,
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
