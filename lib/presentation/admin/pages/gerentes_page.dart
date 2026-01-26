import 'package:flutter/material.dart';
import 'package:autovitae/data/models/gerente.dart';
import 'package:autovitae/viewmodels/gerente_viewmodel.dart';
import 'package:autovitae/data/repositories/usuario_repository.dart';
import 'package:autovitae/data/repositories/taller_repository.dart';
import 'package:autovitae/core/theme/app_colors.dart';
import 'package:autovitae/core/theme/app_fonts.dart';

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
    if (result == true) _loadGerentes();
  }

  Future<void> _navigateToEditGerente(Gerente gerente) async {
  final result = await Navigator.of(context).pushNamed(
    '/edit_gerente',
    arguments: gerente,
  );
  if (result == true) _loadGerentes();
  }


  Future<void> _showAssignTallerDialog(Gerente gerente) async {
    final talleres = await _tallerRepository.getActive();
    if (!mounted) return;

    if (talleres.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No hay talleres disponibles')));
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
      ),
    );

    if (selectedTaller != null && mounted) {
      final success = await _viewModel.asignarTaller(gerente.uidGerente!, selectedTaller);
      if (success) _loadGerentes();
    }
  }

  Future<void> _removeGerenteTaller(Gerente gerente) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover Taller'),
        content: const Text('¿Estás seguro de que deseas remover el taller asignado?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Remover')),
        ],
      ),
    );

    if (confirm == true) {
      final success = await _viewModel.removerTaller(gerente.uidGerente!);
      if (success) _loadGerentes();
    }
  }

  Future<void> _toggleGerenteStatus(Gerente gerente) async {
    final action = gerente.estado == 1 ? 'desactivar' : 'activar';
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('¿${action[0].toUpperCase()}${action.substring(1)} gerente?'),
        content: Text('¿Estás seguro de que deseas $action a este gerente?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(action.toUpperCase())),
        ],
      ),
    );

    if (confirm == true) {
      final success = gerente.estado == 1 
          ? await _viewModel.eliminarGerente(gerente.uidGerente!) 
          : await _viewModel.activarGerente(gerente.uidGerente!);
      if (success) _loadGerentes();
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
                  activeColor: AppColors.primaryColor,
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
              ? const Center(child: CircularProgressIndicator(color: AppColors.primaryColor))
              : _viewModel.gerentes.isEmpty
                  ? Center(child: Text(_showOnlySinTaller ? 'No hay gerentes sin taller' : 'No hay gerentes registrados'))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _viewModel.gerentes.length,
                      itemBuilder: (context, index) {
                        final gerente = _viewModel.gerentes[index];
                        return FutureBuilder(
                          future: Future.wait([
                            _usuarioRepository.getById(gerente.uidUsuario!),
                            gerente.uidTaller != null ? _tallerRepository.getById(gerente.uidTaller!) : Future.value(null),
                          ]),
                          builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
                            if (!snapshot.hasData) return const SizedBox(height: 100);

                            final usuario = snapshot.data![0];
                            final taller = snapshot.data![1];
                            final isActive = gerente.estado == 1;
                            final String? fotoUrl = usuario?.fotoUrl;

                            return Card(
                              elevation: 2,
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 28,
                                      backgroundColor: (fotoUrl != null && fotoUrl.isNotEmpty) 
                                          ? Colors.transparent 
                                          : (isActive ? AppColors.secondaryColor.withOpacity(0.1) : AppColors.grey.withOpacity(0.1)),
                                      backgroundImage: (fotoUrl != null && fotoUrl.isNotEmpty) 
                                          ? NetworkImage(fotoUrl) 
                                          : null,
                                      child: (fotoUrl == null || fotoUrl.isEmpty)
                                          ? Icon(Icons.person, color: isActive ? AppColors.secondaryColor : AppColors.grey, size: 30)
                                          : null,
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${usuario?.nombre ?? ''} ${usuario?.apellido ?? ''}',
                                            style: AppTextStyles.headline1.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            usuario?.correo ?? '', 
                                            style: AppTextStyles.bodyText.copyWith(
                                              color: Colors.black,
                                              fontWeight: FontWeight.normal,
                                            )
                                          ),
                                          Text(
                                            taller != null ? 'Taller: ${taller.nombre}' : 'Sin taller asignado',
                                            style: AppTextStyles.bodyText.copyWith(
                                              color: taller != null ? AppColors.secondaryColor : Colors.orange,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    PopupMenuButton(
                                      icon: const Icon(Icons.more_vert),
                                      onSelected: (value) {
                                        if (value == 'edit') _navigateToEditGerente(gerente);
                                        if (value == 'assign') _showAssignTallerDialog(gerente);
                                        if (value == 'remove') _removeGerenteTaller(gerente);
                                        if (value == 'toggle') _toggleGerenteStatus(gerente);
                                      },
                                      itemBuilder: (context) => [
                                        PopupMenuItem(
                                          value: 'edit',
                                          child: Row(
                                            children: const [
                                              Icon(Icons.edit, size: 20, color: Colors.blue),
                                              SizedBox(width: 12),
                                              Text('Editar'),
                                            ],
                                          ),
                                        ),
                                        if (gerente.uidTaller == null)
                                          PopupMenuItem(
                                            value: 'assign',
                                            child: Row(
                                              children: const [
                                                Icon(Icons.assignment_ind, size: 20, color: Colors.green),
                                                SizedBox(width: 12),
                                                Text('Asignar Taller'),
                                              ],
                                            ),
                                          ),
                                        if (gerente.uidTaller != null)
                                          PopupMenuItem(
                                            value: 'remove',
                                            child: Row(
                                              children: const [
                                                Icon(Icons.assignment_late, size: 20, color: Colors.orange),
                                                SizedBox(width: 12),
                                                Text('Remover Taller'),
                                              ],
                                            ),
                                          ),
                                        PopupMenuItem(
                                          value: 'toggle',
                                          child: Row(
                                            children: [
                                              Icon(
                                                isActive ? Icons.block : Icons.check_circle_outline,
                                                size: 20,
                                                color: isActive ? Colors.red : Colors.green,
                                              ),
                                              const SizedBox(width: 12),
                                              Text(isActive ? 'Desactivar' : 'Activar'),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
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