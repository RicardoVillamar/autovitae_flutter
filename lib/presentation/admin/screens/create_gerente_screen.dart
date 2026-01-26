import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Necesario para obtener el File
import 'package:autovitae/data/services/cloudinary_service.dart';
import 'package:autovitae/presentation/shared/widgets/inputs/text_field_custom.dart';
import 'package:autovitae/viewmodels/gerente_viewmodel.dart';
import 'package:autovitae/core/utils/validators.dart';
import 'package:autovitae/core/theme/app_colors.dart';

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error en el proceso: $e')),
        );
      } finally {
        if (mounted) setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Nuevo Gerente'), 
        centerTitle: true, 
        backgroundColor: AppColors.primaryColor, 
        foregroundColor: Colors.black, 
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
                _buildAvatarSelector(),
                const SizedBox(height: 25),
                _buildFormFields(screenWidth),
                const SizedBox(height: 32),
                _buildActionButtons(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSelector() {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 55,
            backgroundColor: AppColors.primaryColor.withOpacity(0.1),
            backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
            child: _imageFile == null 
                ? const Icon(Icons.person, size: 55, color: AppColors.grey) 
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: _pickImage,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppColors.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.camera_alt, size: 20, color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormFields(double screenWidth) {
    return Column(
      children: [
        _buildSectionHeader(Icons.badge_outlined, 'Datos de Identidad'),
        _buildFormCard([
          TxtffCustom(label: 'Número de Cédula', screenWidth: screenWidth, controller: _cedulaController, keyboardType: TextInputType.number),
          TxtffCustom(label: 'Nombres', screenWidth: screenWidth, controller: _nombreController, validator: Validators.nameValidator),
          TxtffCustom(label: 'Apellidos', screenWidth: screenWidth, controller: _apellidoController, validator: Validators.nameValidator),
        ]),
        const SizedBox(height: 15),
        _buildSectionHeader(Icons.lock_outline, 'Contacto y Seguridad'),
        _buildFormCard([
          TxtffCustom(label: 'Correo electrónico', screenWidth: screenWidth, controller: _correoController, keyboardType: TextInputType.emailAddress, validator: Validators.emailValidator),
          TxtffCustom(label: 'Teléfono', screenWidth: screenWidth, controller: _telefonoController, keyboardType: TextInputType.phone, validator: Validators.phoneValidator),
          TxtffCustom(label: 'Contraseña', screenWidth: screenWidth, controller: _passwordController, obscureText: true),
        ]),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryColor,
              shape: const StadiumBorder(),
              fixedSize: const Size.fromHeight(45),
            ),
            child: const Text('Cancelar'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: (_viewModel.isLoading || _isUploading) ? null : _createGerente,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: AppColors.black,
              shape: const StadiumBorder(),
              fixedSize: const Size.fromHeight(45),
            ),
            child: (_viewModel.isLoading || _isUploading)
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.black))
                : const Text('Guardar', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryColor, size: 20),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        ],
      ),
    );
  }

  Widget _buildFormCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(children: children),
    );
  }
}