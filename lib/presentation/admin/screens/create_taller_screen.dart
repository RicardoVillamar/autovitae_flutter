import 'package:autovitae/presentation/shared/widgets/inputs/text_field_custom.dart';
import 'package:flutter/material.dart';
import 'package:autovitae/data/models/taller.dart';
import 'package:autovitae/viewmodels/taller_viewmodel.dart';
import 'package:autovitae/core/utils/validators.dart';
import 'package:autovitae/core/theme/app_colors.dart';
import 'package:autovitae/core/theme/app_fonts.dart';

class CreateTallerScreen extends StatefulWidget {
  const CreateTallerScreen({super.key});

  @override
  State<CreateTallerScreen> createState() => _CreateTallerScreenState();
}

class _CreateTallerScreenState extends State<CreateTallerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _viewModel = TallerViewModel();
  final _nombreController = TextEditingController();
  final _direccionController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _correoController = TextEditingController();
  final _descripcionController = TextEditingController();

  @override
  void dispose() {
    _nombreController.dispose();
    _direccionController.dispose();
    _telefonoController.dispose();
    _correoController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _createTaller() async {
    if (_formKey.currentState!.validate()) {
      final taller = Taller(
        uidGerente: '', 
        nombre: _nombreController.text,
        direccion: _direccionController.text,
        telefono: _telefonoController.text,
        correo: _correoController.text,
        descripcion: _descripcionController.text,
        estado: 1,
      );

      final success = await _viewModel.registrarTaller(taller);

      if (mounted && success) {
        Navigator.of(context).pop(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Registrar Taller'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.primaryColor, 
        foregroundColor: Colors.black, 
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(Icons.add_business_outlined, 'Información del Negocio'),
                const SizedBox(height: 5),
                _buildFormCard([
                  TxtffCustom(label: 'Nombre del taller', screenWidth: screenWidth, controller: _nombreController, validator: Validators.nameValidator),
                  const SizedBox(height: 5),
                  TxtffCustom(label: 'Dirección del taller', screenWidth: screenWidth, controller: _direccionController, validator: Validators.addressValidator),
                  const SizedBox(height: 5),
                  TxtffCustom(label: 'Descripción del taller', screenWidth: screenWidth, controller: _descripcionController, maxLength: 200),
                ]),
                const SizedBox(height: 5),
                _buildSectionHeader(Icons.contact_phone_outlined, 'Contacto Directo'),
                const SizedBox(height: 5),
                _buildFormCard([
                  TxtffCustom(label: 'Correo electrónico', screenWidth: screenWidth, controller: _correoController, keyboardType: TextInputType.emailAddress, validator: Validators.emailValidator),
                  const SizedBox(height: 5),
                  TxtffCustom(label: 'Teléfono de contacto', screenWidth: screenWidth, controller: _telefonoController, keyboardType: TextInputType.phone, validator: Validators.phoneValidator),
                ]),
                const SizedBox(height: 5),

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
                              foregroundColor: AppColors.primaryColor,
                              side: const BorderSide(color: AppColors.primaryColor, width: 1.5),
                              shape: const StadiumBorder(),
                              padding: EdgeInsets.zero,
                            ),
                            child: const Text(
                              'Cancelar',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: ElevatedButton(
                            onPressed: _viewModel.isLoading ? null : _createTaller,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              foregroundColor: AppColors.black,
                              elevation: 0,
                              shape: const StadiumBorder(),
                              padding: EdgeInsets.zero,
                            ),
                            child: _viewModel.isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.black),
                                  )
                                : const Text(
                                    'Guardar',
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primaryColor, size: 22),
        const SizedBox(width: 8),
        Text(title, style: AppTextStyles.bodyText.copyWith(fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }

  Widget _buildFormCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 5))],
      ),
      child: Column(children: children),
    );
  }
}