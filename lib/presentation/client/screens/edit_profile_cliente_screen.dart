import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:autovitae/data/models/usuario.dart';
import 'package:autovitae/data/models/cliente.dart';
import 'package:autovitae/viewmodels/cliente_viewmodel.dart';
import 'package:autovitae/core/utils/session_manager.dart';
import 'package:autovitae/core/theme/app_colors.dart';
import 'package:autovitae/presentation/shared/widgets/inputs/text_field_custom.dart';
import 'package:autovitae/core/utils/validators.dart';
import 'package:autovitae/presentation/client/widgets/password_confirm_dialog.dart';
import 'package:autovitae/presentation/shared/widgets/appbar/custom_app_bar.dart';

class EditProfileClienteScreen extends StatefulWidget {
  const EditProfileClienteScreen({super.key});

  @override
  State<EditProfileClienteScreen> createState() =>
      _EditProfileClienteScreenState();
}

class _EditProfileClienteScreenState extends State<EditProfileClienteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _viewModel = ClienteViewModel();
  final ImagePicker _picker = ImagePicker();

  Usuario? _usuario;
  Cliente? _cliente;
  File? _imageFile;
  String? _currentImageUrl;
  bool _isLoading = false;
  bool _isLoadingData = true;

  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _direccionController = TextEditingController();
  final _ciudadController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoadingData = true);
    _usuario = await SessionManager().getUsuario();
    _cliente = await SessionManager().getCliente();

    if (_usuario != null) {
      _nombreController.text = _usuario!.nombre;
      _apellidoController.text = _usuario!.apellido;
      _telefonoController.text = _usuario!.telefono;
      _currentImageUrl = _usuario!.fotoUrl;
    }

    if (_cliente != null) {
      _direccionController.text = _cliente!.direccion;
      _ciudadController.text = _cliente!.ciudad;
    }

    setState(() => _isLoadingData = false);
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _telefonoController.dispose();
    _direccionController.dispose();
    _ciudadController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 512,
        maxHeight: 512,
      );
      if (pickedFile != null) {
        setState(() => _imageFile = File(pickedFile.path));
      }
    } catch (e) {
      debugPrint("Error al seleccionar imagen: $e");
    }
  }

  void _showImageSourceDialog() {
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.photo_library, color: colorScheme.primary),
                ),
                title: const Text('Seleccionar de Galería'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.camera_alt, color: colorScheme.primary),
                ),
                title: const Text('Tomar Foto'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              if (_imageFile != null ||
                  (_currentImageUrl != null && _currentImageUrl!.isNotEmpty))
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: colorScheme.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.delete, color: colorScheme.error),
                  ),
                  title: const Text('Eliminar Foto'),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _imageFile = null;
                      _currentImageUrl = null;
                    });
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showPasswordConfirmationDialog() async {
    if (!_formKey.currentState!.validate()) return;

    final confirmed = await PasswordConfirmDialog.show(
      context: context,
      viewModel: _viewModel,
    );

    if (confirmed && mounted) {
      await _saveProfile();
    }
  }

  Future<void> _saveProfile() async {
    if (_usuario == null || _cliente == null) return;

    setState(() => _isLoading = true);

    try {
      final success = await _viewModel.actualizarPerfil(
        uidUsuario: _usuario!.uidUsuario!,
        uidCliente: _cliente!.uidCliente!,
        nombre: _nombreController.text.trim(),
        apellido: _apellidoController.text.trim(),
        telefono: _telefonoController.text.trim(),
        direccion: _direccionController.text.trim(),
        ciudad: _ciudadController.text.trim(),
        nuevaFoto: _imageFile,
        fotoUrlActual: _currentImageUrl,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Perfil actualizado exitosamente'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.of(context).pop(true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_viewModel.error ?? 'Error al actualizar perfil'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final screenWidth = MediaQuery.of(context).size.width;

    if (_isLoadingData) {
      return Scaffold(
        appBar: const CustomAppBar(
          title: 'Editar Perfil',
          showBackButton: true,
          showMenu: false,
        ),
        body: Center(
          child: CircularProgressIndicator(color: colorScheme.primary),
        ),
      );
    }

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Editar Perfil',
        showBackButton: true,
        showMenu: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                _buildAvatarSelector(colorScheme, textTheme),
                const SizedBox(height: 32),
                _buildFormFields(screenWidth, colorScheme),
                const SizedBox(height: 32),
                _buildActionButtons(colorScheme),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSelector(ColorScheme colorScheme, TextTheme textTheme) {
    final hasImage = _imageFile != null ||
        (_currentImageUrl != null && _currentImageUrl!.isNotEmpty);

    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: _showImageSourceDialog,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                  backgroundImage: _imageFile != null
                      ? FileImage(_imageFile!)
                      : (_currentImageUrl != null &&
                              _currentImageUrl!.isNotEmpty)
                          ? NetworkImage(_currentImageUrl!) as ImageProvider
                          : null,
                  child: !hasImage
                      ? Icon(
                          Icons.person,
                          size: 60,
                          color: colorScheme.primary,
                        )
                      : null,
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colorScheme.surface,
                        width: 3,
                      ),
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      size: 20,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Toca para cambiar foto',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
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
          Icons.person_outline,
          'Información Personal',
          colorScheme,
        ),
        _buildFormCard([
          TxtffCustom(
            label: 'Nombre',
            screenWidth: screenWidth,
            controller: _nombreController,
            validator: Validators.nameValidator.call,
          ),
          TxtffCustom(
            label: 'Apellido',
            screenWidth: screenWidth,
            controller: _apellidoController,
            validator: Validators.nameValidator.call,
          ),
          TxtffCustom(
            label: 'Teléfono',
            screenWidth: screenWidth,
            controller: _telefonoController,
            keyboardType: TextInputType.phone,
            validator: Validators.phoneValidator.call,
          ),
        ]),
        const SizedBox(height: 16),
        _buildSectionHeader(
          Icons.location_on_outlined,
          'Ubicación',
          colorScheme,
        ),
        _buildFormCard([
          TxtffCustom(
            label: 'Dirección',
            screenWidth: screenWidth,
            controller: _direccionController,
            validator: Validators.addressValidator.call,
          ),
          TxtffCustom(
            label: 'Ciudad',
            screenWidth: screenWidth,
            controller: _ciudadController,
            validator: Validators.requiredValidator.call,
          ),
        ]),
        const SizedBox(height: 16),
        // Información no editable
        _buildSectionHeader(
          Icons.info_outline,
          'Información de Cuenta',
          colorScheme,
        ),
        _buildInfoCard(colorScheme),
      ],
    );
  }

  Widget _buildInfoCard(ColorScheme colorScheme) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            Icons.email_outlined,
            'Correo',
            _usuario?.correo ?? '',
            colorScheme,
            textTheme,
          ),
          Divider(
            height: 24,
            color: colorScheme.outline.withValues(alpha: 0.2),
          ),
          _buildInfoRow(
            Icons.badge_outlined,
            'Cédula',
            _usuario?.cedula ?? '',
            colorScheme,
            textTheme,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Row(
      children: [
        Icon(icon, color: colorScheme.onSurfaceVariant, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                value,
                style: textTheme.bodyLarge,
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            'No editable',
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: colorScheme.outline),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Cancelar'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: _isLoading ? null : _showPasswordConfirmationDialog,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.onPrimary,
                    ),
                  )
                : const Text('Guardar Cambios'),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(
    IconData icon,
    String title,
    ColorScheme colorScheme,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: colorScheme.primary, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
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
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}
