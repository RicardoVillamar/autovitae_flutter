import 'package:flutter/material.dart';
import 'package:autovitae/data/models/gerente.dart';
import 'package:autovitae/viewmodels/gerente_viewmodel.dart';
import 'package:autovitae/data/repositories/usuario_repository.dart';
import 'package:autovitae/data/repositories/taller_repository.dart';
import 'package:autovitae/core/theme/app_colors.dart';
import 'package:autovitae/core/theme/app_fonts.dart';
import 'package:autovitae/presentation/shared/widgets/cards/generic_list_tile.dart';

class GerentesPage extends StatefulWidget {
  const GerentesPage({super.key});

  @override
  State<GerentesPage> createState() => _GerentesPageState();
}

class _GerentesPageState extends State<GerentesPage> {
  final GerenteViewModel _viewModel = GerenteViewModel();
  final UsuarioRepository _usuarioRepository = UsuarioRepository();
  final TallerRepository _tallerRepository = TallerRepository();
  bool _isLoading = false;
  bool _showOnlySinTaller = false;

  @override
  void initState() {
    super.initState();
    _loadGerentes();
  }

  Future<void> _loadGerentes() async {
    setState(() => _isLoading = true);
    if (_showOnlySinTaller) {
      await _viewModel.cargarGerentesSinTaller();
    } else {
      await _viewModel.cargarGerentesActivos();
    }
    setState(() => _isLoading = false);
  }

  Future<void> _navigateToCreateGerente() async {
    final result = await Navigator.of(context).pushNamed('/create_gerente');
    if (result == true) {
      _loadGerentes();
    }
  }

  Future<void> _navigateToEditGerente(Gerente gerente) async {
    final result = await Navigator.of(
      context,
    ).pushNamed('/edit_gerente', arguments: gerente);
    if (result == true) {
      _loadGerentes();
    }
  }

  Future<void> _showAssignTallerDialog(Gerente gerente) async {
    final talleres = await _tallerRepository.getActive();

    if (!mounted) return;

    if (talleres.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay talleres disponibles')),
      );
      return;
    }

    final selectedTaller = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Asignar Taller'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: talleres.length,
            itemBuilder: (context, index) {
              final taller = talleres[index];
              return ListTile(
                title: Text(taller.nombre),
                subtitle: Text(taller.direccion),
                onTap: () => Navigator.of(context).pop(taller.uidTaller),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );

    if (selectedTaller != null && mounted) {
      final success = await _viewModel.asignarTaller(
        gerente.uidGerente!,
        selectedTaller,
      );
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Taller asignado exitosamente')),
          );
          _loadGerentes();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_viewModel.error ?? 'Error al asignar taller'),
            ),
          );
        }
      }
    }
  }

  Future<void> _removeGerenteTaller(Gerente gerente) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover Taller'),
        content: const Text(
          '¿Estás seguro de que deseas remover el taller asignado?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Remover'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final success = await _viewModel.removerTaller(gerente.uidGerente!);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Taller removido exitosamente')),
          );
          _loadGerentes();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_viewModel.error ?? 'Error al remover taller'),
            ),
          );
        }
      }
    }
  }

  Future<void> _toggleGerenteStatus(Gerente gerente) async {
    final action = gerente.estado == 1 ? 'desactivar' : 'activar';
    final usuario = await _usuarioRepository.getById(gerente.uidUsuario!);

    if (!mounted) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('¿$action gerente?'),
        content: Text(
          '¿Estás seguro de que deseas $action a ${usuario?.nombre ?? 'este gerente'}?',
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
      final success = gerente.estado == 1
          ? await _viewModel.eliminarGerente(gerente.uidGerente!)
          : await _viewModel.activarGerente(gerente.uidGerente!);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gerente ${action}do exitosamente')),
          );
          _loadGerentes();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_viewModel.error ?? 'Error al $action gerente'),
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
                child: SwitchListTile(
                  title: Text('Solo sin taller', style: AppTextStyles.bodyText),
                  value: _showOnlySinTaller,
                  onChanged: (value) {
                    setState(() => _showOnlySinTaller = value);
                    _loadGerentes();
                  },
                ),
              ),
              FloatingActionButton(
                onPressed: _navigateToCreateGerente,
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
              : _viewModel.gerentes.isEmpty
              ? Center(
                  child: Text(
                    _showOnlySinTaller
                        ? 'No hay gerentes sin taller'
                        : 'No hay gerentes registrados',
                    style: AppTextStyles.bodyText,
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: kBottomNavigationBarHeight + 16,
                  ),
                  itemCount: _viewModel.gerentes.length,
                  itemBuilder: (context, index) {
                    final gerente = _viewModel.gerentes[index];
                    return FutureBuilder(
                      future: Future.wait([
                        _usuarioRepository.getById(gerente.uidUsuario!),
                        gerente.uidTaller != null
                            ? _tallerRepository.getById(gerente.uidTaller!)
                            : Future.value(null),
                      ]),
                      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
                        if (!snapshot.hasData) {
                          return const SizedBox.shrink();
                        }

                        final usuario = snapshot.data![0];
                        final taller = snapshot.data![1];
                        final isActive = gerente.estado == 1;

                        return GenericListTile(
                          leadingIcon: Icon(
                            Icons.person,
                            color: isActive
                                ? AppColors.secondaryColor
                                : AppColors.grey,
                            size: 28,
                          ),
                          leadingBackgroundColor: isActive
                              ? AppColors.secondaryColor
                              : AppColors.grey,
                          title:
                              '${usuario?.nombre ?? ''} ${usuario?.apellido ?? ''}',
                          subtitle:
                              '${usuario?.correo ?? ''}\n${taller != null ? 'Taller: ${taller.nombre}' : 'Sin taller asignado'}',
                          isThreeLine: true,
                          trailing: PopupMenuButton(
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.edit,
                                      color: AppColors.primaryColor,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text('Editar'),
                                  ],
                                ),
                              ),
                              if (gerente.uidTaller == null)
                                PopupMenuItem(
                                  value: 'assign',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.assignment,
                                        color: AppColors.secondaryColor,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text('Asignar Taller'),
                                    ],
                                  ),
                                ),
                              if (gerente.uidTaller != null)
                                PopupMenuItem(
                                  value: 'remove',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.remove_circle,
                                        color: AppColors.warning,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text('Remover Taller'),
                                    ],
                                  ),
                                ),
                              PopupMenuItem(
                                value: 'toggle',
                                child: Row(
                                  children: [
                                    Icon(
                                      isActive ? Icons.delete : Icons.check,
                                      color: isActive
                                          ? AppColors.error
                                          : AppColors.success,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(isActive ? 'Desactivar' : 'Activar'),
                                  ],
                                ),
                              ),
                            ],
                            onSelected: (value) {
                              if (value == 'edit') {
                                _navigateToEditGerente(gerente);
                              } else if (value == 'assign') {
                                _showAssignTallerDialog(gerente);
                              } else if (value == 'remove') {
                                _removeGerenteTaller(gerente);
                              } else if (value == 'toggle') {
                                _toggleGerenteStatus(gerente);
                              }
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}
