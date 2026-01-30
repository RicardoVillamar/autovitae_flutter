import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:autovitae/data/services/cloudinary_service.dart';
import 'package:autovitae/presentation/shared/widgets/inputs/text_field_custom.dart';
import 'package:autovitae/viewmodels/gerente_viewmodel.dart';
import 'package:autovitae/core/utils/validators.dart';

class CreateGerenteScreen extends StatefulWidget {
  const CreateGerenteScreen({super.key});

  @override
  State<CreateGerenteScreen> createState() => _CreateGerenteScreenState();
}

class _CreateGerenteScreenState extends State<CreateGerenteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _viewModel = GerenteViewModel();

  final _cloudinaryService = CloudinaryService();

  final ImagePicker _picker = ImagePicker();

  File? _imageFile;
  bool _isUploading = false;

  final _cedulaController = TextEditingController();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _correoController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _cedulaController.dispose();
    _nombreController.dispose();
    _apellidoController.dispose();
    _correoController.dispose();
    _telefonoController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
      );
      if (pickedFile != null) {
        setState(() => _imageFile = File(pickedFile.path));
      }
    } catch (e) {
      debugPrint("Error al seleccionar imagen: $e");
    }
  }

  Future<void> _createGerente() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isUploading = true);
      String? imageUrl;

      try {
        if (_imageFile != null) {
          imageUrl = await _cloudinaryService.uploadImage(_imageFile!);
        }

        final success = await _viewModel.registrarGerente(
          cedula: _cedulaController.text,
          nombres: _nombreController.text,
          apellidos: _apellidoController.text,
          email: _correoController.text,
          telefono: _telefonoController.text,
          password: _passwordController.text,
          fotoUrl: imageUrl,
        );

        if (mounted && success) {
          Navigator.of(context).pop(true);
        } else if (mounted && _viewModel.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${_viewModel.error}')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error en el proceso: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Gerente'),
        backgroundColor: colorScheme.surfaceContainerLowest,
        foregroundColor: colorScheme.onSurface,
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 10),
                _buildAvatarSelector(colorScheme),
                const SizedBox(height: 25),
                _buildFormFields(screenWidth, colorScheme),
                const SizedBox(height: 32),
                _buildActionButtons(colorScheme),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSelector(ColorScheme colorScheme) {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 55,
            backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
            backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
            child: _imageFile == null
                ? Icon(Icons.person,
                    size: 55, color: colorScheme.onSurfaceVariant)
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: _pickImage,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.camera_alt,
                    size: 20, color: colorScheme.onPrimary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormFields(double screenWidth, ColorScheme colorScheme) {
    return Column(
      children: [
        _buildSectionHeader(
            Icons.badge_outlined, 'Datos de Identidad', colorScheme),
        _buildFormCard([
          TxtffCustom(
              label: 'Número de Cédula',
              screenWidth: screenWidth,
              controller: _cedulaController,
              keyboardType: TextInputType.number),
          TxtffCustom(
              label: 'Nombres',
              screenWidth: screenWidth,
              controller: _nombreController,
              validator: Validators.nameValidator.call),
          TxtffCustom(
              label: 'Apellidos',
              screenWidth: screenWidth,
              controller: _apellidoController,
              validator: Validators.nameValidator.call),
        ]),
        const SizedBox(height: 15),
        _buildSectionHeader(
            Icons.lock_outline, 'Contacto y Seguridad', colorScheme),
        _buildFormCard([
          TxtffCustom(
              label: 'Correo electrónico',
              screenWidth: screenWidth,
              controller: _correoController,
              keyboardType: TextInputType.emailAddress,
              validator: Validators.emailValidator.call),
          TxtffCustom(
              label: 'Teléfono',
              screenWidth: screenWidth,
              controller: _telefonoController,
              keyboardType: TextInputType.phone,
              validator: Validators.phoneValidator.call),
          TxtffCustom(
              label: 'Contraseña',
              screenWidth: screenWidth,
              controller: _passwordController,
              obscureText: true),
        ]),
      ],
    );
  }

  Widget _buildActionButtons(ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: colorScheme.primary,
              shape: const StadiumBorder(),
              fixedSize: const Size.fromHeight(45),
            ),
            child: const Text('Cancelar'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed:
                (_viewModel.isLoading || _isUploading) ? null : _createGerente,
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              shape: const StadiumBorder(),
              fixedSize: const Size.fromHeight(45),
            ),
            child: (_viewModel.isLoading || _isUploading)
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: colorScheme.onPrimary))
                : const Text('Guardar',
                    style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(
      IconData icon, String title, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: colorScheme.primary, size: 20),
          const SizedBox(width: 8),
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        ],
      ),
    );
  }

  Widget _buildFormCard(List<Widget> children) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(children: children),
    );
  }
}
