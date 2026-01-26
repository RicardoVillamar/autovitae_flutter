import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:autovitae/data/models/gerente.dart';
import 'package:autovitae/data/services/cloudinary_service.dart';
import 'package:autovitae/data/repositories/usuario_repository.dart';
import 'package:autovitae/presentation/shared/widgets/inputs/text_field_custom.dart';
import 'package:autovitae/viewmodels/gerente_viewmodel.dart';
import 'package:autovitae/core/utils/validators.dart';
import 'package:autovitae/core/theme/app_colors.dart';

class EditGerenteScreen extends StatefulWidget {
  // Ahora es constante y no requiere el objeto en el constructor
  const EditGerenteScreen({super.key});

  @override
  State<EditGerenteScreen> createState() => _EditGerenteScreenState();
}

class _EditGerenteScreenState extends State<EditGerenteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _viewModel = GerenteViewModel();
  final _usuarioRepository = UsuarioRepository();
  final _cloudinaryService = CloudinaryService();
  final ImagePicker _picker = ImagePicker();

  // Variables de estado
  late Gerente _gerente; 
  bool _isInitialized = false;
  File? _imageFile;
  String? _currentImageUrl;
  bool _isUploading = false;
  bool _isLoadingData = true;

  // Controladores
  final _cedulaController = TextEditingController();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _correoController = TextEditingController();
  final _telefonoController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Capturamos el argumento de la ruta una sola vez
    if (!_isInitialized) {
      final args = ModalRoute.of(context)!.settings.arguments;
      if (args is Gerente) {
        _gerente = args;
        _loadGerenteData();
      } else {
        // Si no hay argumentos válidos, cerramos la pantalla
        Navigator.of(context).pop();
      }
      _isInitialized = true;
    }
  }

  Future<void> _loadGerenteData() async {
    try {
      final usuario = await _usuarioRepository.getById(_gerente.uidUsuario!);
      if (usuario != null) {
        setState(() {
          _cedulaController.text = usuario.cedula ?? '';
          _nombreController.text = usuario.nombre ?? '';
          _apellidoController.text = usuario.apellido ?? '';
          _correoController.text = usuario.correo ?? '';
          _telefonoController.text = usuario.telefono ?? '';
          _currentImageUrl = usuario.fotoUrl;
          _isLoadingData = false;
        });
      }
    } catch (e) {
      debugPrint("Error cargando datos del usuario: $e");
      if (mounted) setState(() => _isLoadingData = false);
    }
  }

  @override
  void dispose() {
    _cedulaController.dispose();
    _nombreController.dispose();
    _apellidoController.dispose();
    _correoController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  Future<void> _updateGerente() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isUploading = true);
      String? imageUrl = _currentImageUrl;

      try {
        // 1. Si hay nueva imagen, subirla a Cloudinary
        if (_imageFile != null) {
          imageUrl = await _cloudinaryService.uploadImage(_imageFile!);
        }

        // 2. Actualizar el perfil completo mediante el ViewModel
        final success = await _viewModel.actualizarPerfilCompleto(
          uidUsuario: _gerente.uidUsuario!,
          nombres: _nombreController.text,
          apellidos: _apellidoController.text,
          email: _correoController.text,
          telefono: _telefonoController.text,
          fotoUrl: imageUrl,
        );

        if (mounted && success) {
          Navigator.of(context).pop(true); // Retornamos true para refrescar la lista
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
        title: const Text('Editar Gerente'),
        centerTitle: true,
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoadingData 
        ? const Center(child: CircularProgressIndicator(color: AppColors.primaryColor))
        : SafeArea(
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
    ImageProvider? imageProvider;
    if (_imageFile != null) {
      imageProvider = FileImage(_imageFile!);
    } else if (_currentImageUrl != null && _currentImageUrl!.isNotEmpty) {
      imageProvider = NetworkImage(_currentImageUrl!);
    }

    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 55,
            backgroundColor: AppColors.primaryColor.withOpacity(0.1),
            backgroundImage: imageProvider,
            child: imageProvider == null 
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
                child: const Icon(Icons.edit, size: 20, color: Colors.black),
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
          // Campo de cédula bloqueado (no se debe cambiar el ID único)
          Opacity(
            opacity: 0.6,
            child: AbsorbPointer(
              child: TxtffCustom(
                label: 'Cédula', 
                screenWidth: screenWidth, 
                controller: _cedulaController,
              ),
            ),
          ),
          TxtffCustom(label: 'Nombres', screenWidth: screenWidth, controller: _nombreController, validator: Validators.nameValidator),
          TxtffCustom(label: 'Apellidos', screenWidth: screenWidth, controller: _apellidoController, validator: Validators.nameValidator),
        ]),
        const SizedBox(height: 5),
        _buildSectionHeader(Icons.contact_mail_outlined, 'Información de Contacto'),
        _buildFormCard([
          TxtffCustom(label: 'Correo electrónico', screenWidth: screenWidth, controller: _correoController, keyboardType: TextInputType.emailAddress, validator: Validators.emailValidator),
          TxtffCustom(label: 'Teléfono', screenWidth: screenWidth, controller: _telefonoController, keyboardType: TextInputType.phone, validator: Validators.phoneValidator),
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
            onPressed: (_viewModel.isLoading || _isUploading) ? null : _updateGerente,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: AppColors.black,
              shape: const StadiumBorder(),
              fixedSize: const Size.fromHeight(45),
            ),
            child: (_viewModel.isLoading || _isUploading)
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.black))
                : const Text('Actualizar', style: TextStyle(fontWeight: FontWeight.bold)),
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