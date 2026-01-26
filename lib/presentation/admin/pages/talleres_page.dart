import 'package:autovitae/core/theme/app_colors.dart';
import 'package:autovitae/core/theme/app_fonts.dart';
import 'package:autovitae/data/models/taller.dart';
import 'package:autovitae/presentation/shared/widgets/cards/generic_list_tile.dart';
import 'package:autovitae/viewmodels/taller_viewmodel.dart';
import 'package:flutter/material.dart';

class TalleresPage extends StatefulWidget {
  const TalleresPage({super.key});

  @override
  State<TalleresPage> createState() => _TalleresPageState();
}

class _TalleresPageState extends State<TalleresPage> {
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

  Future<void> _navigateToCreateTaller() async {
    final result = await Navigator.of(context).pushNamed('/create_taller');
    
    if (result == true) {
      _loadTalleres();
    }
  }

  Future<void> _navigateToEditTaller(Taller taller) async {
    final result = await Navigator.of(context).pushNamed(
      '/edit_taller',
      arguments: taller,
    );

    if (result == true) {
      _loadTalleres();
    }
  }

  Future<void> _toggleTallerStatus(Taller taller) async {
    final action = taller.estado == 1 ? 'desactivar' : 'activar';
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('¿$action taller?'),
        content: Text(
          '¿Estás seguro de que deseas $action "${taller.nombre}"?',
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
      final success = taller.estado == 1
          ? await _viewModel.eliminarTaller(taller.uidTaller!)
          : await _viewModel.activarTaller(taller.uidTaller!);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Taller ${action}do exitosamente')),
          );
          _loadTalleres();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_viewModel.error ?? 'Error al $action taller'),
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
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar taller...',
                    hintStyle: AppTextStyles.caption,
                    prefixIcon: Icon(
                      Icons.search,
                      color: AppColors.primaryColor,
                    ),
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
              const SizedBox(width: 8),
              FloatingActionButton(
                onPressed: _navigateToCreateTaller,
                backgroundColor: AppColors.primaryColor,
                foregroundColor: AppColors.black,
                child: const Icon(Icons.add),
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
              : _viewModel.talleres.isEmpty
              ? Center(
                  child: Text(
                    'No hay talleres registrados',
                    style: AppTextStyles.bodyText,
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _viewModel.talleres.length,
                  itemBuilder: (context, index) {
                    final taller = _viewModel.talleres[index];
                    final isActive = taller.estado == 1;
                    return GenericListTile(
                      leadingIcon: Icon(
                        Icons.build,
                        color: isActive ? AppColors.success : AppColors.grey,
                        size: 28,
                      ),
                      leadingBackgroundColor: isActive
                          ? AppColors.success.withOpacity(0.2)
                          : AppColors.grey.withOpacity(0.2),
                      title: taller.nombre,
                      subtitle: '${taller.direccion}\nTel: ${taller.telefono}',
                      isThreeLine: true,
                      trailing: PopupMenuButton(
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, color: AppColors.primaryColor),
                                const SizedBox(width: 8),
                                const Text('Editar'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'toggle',
                            child: Row(
                              children: [
                                Icon(
                                  isActive ? Icons.delete : Icons.check,
                                  color: isActive ? AppColors.error : AppColors.success,
                                ),
                                const SizedBox(width: 8),
                                Text(isActive ? 'Desactivar' : 'Activar'),
                              ],
                            ),
                          ),
                        ],
                        onSelected: (value) {
                          if (value == 'edit') {
                            _navigateToEditTaller(taller);
                          } else if (value == 'toggle') {
                            _toggleTallerStatus(taller);
                          }
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}