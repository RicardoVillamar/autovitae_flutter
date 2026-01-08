import 'package:flutter/material.dart';
import 'package:autovitae/data/models/taller.dart';
import 'package:autovitae/viewmodels/taller_viewmodel.dart';
import 'package:autovitae/core/theme/app_colors.dart';
import 'package:autovitae/core/theme/app_fonts.dart';
import 'package:autovitae/presentation/client/screens/detalle_taller_screen.dart';
import 'package:autovitae/presentation/shared/widgets/cards/generic_list_tile.dart';

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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Talleres Disponibles'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.black,
        elevation: 0,
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
                hintStyle: AppTextStyles.caption,
                prefixIcon: Icon(Icons.search, color: AppColors.primaryColor),
                filled: true,
                fillColor: AppColors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.primaryColor,
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
                      color: AppColors.primaryColor,
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
                          color: AppColors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No hay talleres disponibles',
                          style: AppTextStyles.bodyText.copyWith(
                            color: AppColors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadTalleres,
                    color: AppColors.primaryColor,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _viewModel.talleres.length,
                      itemBuilder: (context, index) {
                        final taller = _viewModel.talleres[index];
                        return GenericListTile(
                          onTap: () => _navigateToDetalle(taller),
                          leadingIcon: Icon(
                            Icons.build,
                            color: AppColors.primaryColor,
                            size: 32,
                          ),
                          leadingBackgroundColor: AppColors.primaryColor,
                          title: taller.nombre,
                          subtitle:
                              '${taller.direccion}\nTel: ${taller.telefono}',
                          trailing: Icon(
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