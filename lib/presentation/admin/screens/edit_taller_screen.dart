import 'package:autovitae/presentation/shared/widgets/inputs/text_field_custom.dart';
import 'package:flutter/material.dart';
import 'package:autovitae/data/models/taller.dart';
import 'package:autovitae/viewmodels/taller_viewmodel.dart';
import 'package:autovitae/core/utils/validators.dart';

class EditTallerScreen extends StatefulWidget {
  const EditTallerScreen({super.key});

  @override
  State<EditTallerScreen> createState() => _EditTallerScreenState();
}

class _EditTallerScreenState extends State<EditTallerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _viewModel = TallerViewModel();

  late TextEditingController _nombreController;
  late TextEditingController _direccionController;
  late TextEditingController _telefonoController;
  late TextEditingController _correoController;
  late TextEditingController _descripcionController;

  late Taller taller;
  bool _isInit = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      final args = ModalRoute.of(context)!.settings.arguments;
      if (args is Taller) {
        taller = args;
        _nombreController = TextEditingController(text: taller.nombre);
        _direccionController = TextEditingController(text: taller.direccion);
        _telefonoController = TextEditingController(text: taller.telefono);
        _correoController = TextEditingController(text: taller.correo);
        _descripcionController =
            TextEditingController(text: taller.descripcion);
      }
      _isInit = false;
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _direccionController.dispose();
    _telefonoController.dispose();
    _correoController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _editTaller() async {
    if (_formKey.currentState!.validate()) {
      final tallerEditado = Taller(
        uidTaller: taller.uidTaller,
        uidGerente: taller.uidGerente,
        nombre: _nombreController.text,
        direccion: _direccionController.text,
        telefono: _telefonoController.text,
        correo: _correoController.text,
        descripcion: _descripcionController.text,
        estado: taller.estado,
        fechaRegistro: taller.fechaRegistro,
      );

      final success = await _viewModel.actualizarTaller(
          tallerEditado.uidTaller!, tallerEditado);
      if (mounted && success) Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Taller'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(Icons.storefront_outlined,
                    'Detalles Generales', colorScheme),
                const SizedBox(height: 10),
                _buildFormCard([
                  TxtffCustom(
                      label: 'Nombre del taller',
                      screenWidth: screenWidth,
                      controller: _nombreController,
                      validator: Validators.nameValidator.call),
                  const SizedBox(height: 5),
                  TxtffCustom(
                      label: 'Dirección del taller',
                      screenWidth: screenWidth,
                      controller: _direccionController,
                      validator: Validators.addressValidator.call),
                  const SizedBox(height: 5),
                  TxtffCustom(
                      label: 'Descripción del taller',
                      screenWidth: screenWidth,
                      controller: _descripcionController,
                      maxLength: 200),
                ]),
                const SizedBox(height: 5),
                _buildSectionHeader(Icons.contact_mail_outlined,
                    'Información de contacto', colorScheme),
                const SizedBox(height: 5),
                _buildFormCard([
                  TxtffCustom(
                      label: 'Correo electrónico',
                      screenWidth: screenWidth,
                      controller: _correoController,
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.emailValidator.call),
                  const SizedBox(height: 5),
                  TxtffCustom(
                      label: 'Teléfono',
                      screenWidth: screenWidth,
                      controller: _telefonoController,
                      keyboardType: TextInputType.phone,
                      validator: Validators.phoneValidator.call),
                ]),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: colorScheme.primary,
                              side: BorderSide(
                                  color: colorScheme.primary, width: 1.5),
                              shape: const StadiumBorder(),
                              padding: EdgeInsets.zero,
                            ),
                            child: const Text('Cancelar',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: ElevatedButton(
                            onPressed:
                                _viewModel.isLoading ? null : _editTaller,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.onPrimary,
                              elevation: 0,
                              shape: const StadiumBorder(),
                              padding: EdgeInsets.zero,
                            ),
                            child: _viewModel.isLoading
                                ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: colorScheme.onPrimary))
                                : const Text('Guardar',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
      IconData icon, String title, ColorScheme colorScheme) {
    return Row(
      children: [
        Icon(icon, color: colorScheme.primary, size: 20),
        const SizedBox(width: 8),
        Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      ],
    );
  }

  Widget _buildFormCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Theme.of(context).colorScheme.shadow.withAlpha(25),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(children: children),
    );
  }
}
