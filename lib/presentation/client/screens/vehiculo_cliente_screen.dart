import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:autovitae/data/models/vehiculo.dart';
import 'package:autovitae/viewmodels/vehiculo_viewmodel.dart';
import 'package:autovitae/core/utils/session_manager.dart';
import 'package:autovitae/core/theme/app_colors.dart';
import 'package:autovitae/presentation/shared/widgets/inputs/text_field_custom.dart';
import 'package:autovitae/core/utils/validators.dart';

class VehiculoClienteScreen extends StatefulWidget {
  final Vehiculo? vehiculo;

  const VehiculoClienteScreen({super.key, this.vehiculo});

  @override
  State<VehiculoClienteScreen> createState() => _VehiculoClienteScreenState();
}

class _VehiculoClienteScreenState extends State<VehiculoClienteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _viewModel = VehiculoViewModel();
  final ImagePicker _picker = ImagePicker();

  File? _imageFile;
  String? _currentImageUrl;
  bool _isLoading = false;

  final _marcaController = TextEditingController();
  final _modeloController = TextEditingController();
  final _anioController = TextEditingController();
  final _placaController = TextEditingController();
  final _kilometrajeController = TextEditingController();

  bool get isEditing => widget.vehiculo != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _loadVehiculoData();
    }
  }

  void _loadVehiculoData() {
    final vehiculo = widget.vehiculo!;
    _marcaController.text = vehiculo.marca ?? '';
    _modeloController.text = vehiculo.modelo ?? '';
    _anioController.text = vehiculo.anio?.toString() ?? '';
    _placaController.text = vehiculo.placa ?? '';
    _kilometrajeController.text = vehiculo.kilometraje.toString();
    _currentImageUrl = vehiculo.imageUrl;
  }

  @override
  void dispose() {
    _marcaController.dispose();
    _modeloController.dispose();
    _anioController.dispose();
    _placaController.dispose();
    _kilometrajeController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (pickedFile != null) {
        setState(() => _imageFile = File(pickedFile.path));
      }
    } catch (e) {
      debugPrint("Error al seleccionar imagen: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al seleccionar imagen')),
        );
      }
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
              if (_imageFile != null || _currentImageUrl != null)
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: colorScheme.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.delete, color: colorScheme.error),
                  ),
                  title: const Text('Eliminar Imagen'),
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

  Future<void> _saveVehiculo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final cliente = await SessionManager().getCliente();
      if (cliente == null) {
        throw Exception('No se encontró el cliente');
      }

      final vehiculo = Vehiculo(
        uidVehiculo: widget.vehiculo?.uidVehiculo,
        uidCliente: widget.vehiculo?.uidCliente ?? cliente.uidCliente!,
        marca: _marcaController.text.trim(),
        modelo: _modeloController.text.trim(),
        anio: int.tryParse(_anioController.text.trim()),
        placa: _placaController.text.trim().toUpperCase(),
        kilometraje: int.tryParse(_kilometrajeController.text.trim()) ?? 0,
        imageUrl: _currentImageUrl,
      );

      bool success;
      if (isEditing) {
        success = await _viewModel.actualizarVehiculoConImagen(
          widget.vehiculo!.uidVehiculo!,
          vehiculo,
          imageFile: _imageFile,
          currentImageUrl: _currentImageUrl,
        );
      } else {
        success = await _viewModel.registrarVehiculo(
          vehiculo,
          imageFile: _imageFile,
        );
      }

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isEditing
                  ? 'Vehículo actualizado exitosamente'
                  : 'Vehículo registrado exitosamente'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.of(context).pop(true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_viewModel.error ?? 'Error al guardar vehículo'),
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

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Vehículo' : 'Nuevo Vehículo'),
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                _buildFormFields(screenWidth, colorScheme),
                const SizedBox(height: 32),
                _buildImageSelector(colorScheme, textTheme),
                const SizedBox(height: 24),
                _buildActionButtons(colorScheme),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageSelector(ColorScheme colorScheme, TextTheme textTheme) {
    return Column(children: [
      _buildSectionHeader(
          Icons.directions_car, 'Foto del Vehículo', colorScheme),
      GestureDetector(
        onTap: _showImageSourceDialog,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Container(
            width: double.infinity,
            height: 160,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.3),
                width: 2,
              ),
              image: _imageFile != null
                  ? DecorationImage(
                      image: FileImage(_imageFile!),
                      fit: BoxFit.cover,
                    )
                  : (_currentImageUrl != null && _currentImageUrl!.isNotEmpty)
                      ? DecorationImage(
                          image: NetworkImage(_currentImageUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
            ),
            child: (_imageFile == null &&
                    (_currentImageUrl == null || _currentImageUrl!.isEmpty))
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.directions_car,
                        size: 48,
                        color: colorScheme.primary.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Agregar foto',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  )
                : Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        size: 20,
                        color: colorScheme.onPrimary,
                      ),
                    ),
                  ),
          ),
        ),
      )
    ]);
  }

  Widget _buildFormFields(double screenWidth, ColorScheme colorScheme) {
    return Column(
      children: [
        _buildSectionHeader(
          Icons.directions_car_outlined,
          'Información del Vehículo',
          colorScheme,
        ),
        _buildFormCard([
          TxtffCustom(
            label: 'Marca',
            screenWidth: screenWidth,
            controller: _marcaController,
            validator: Validators.requiredValidator.call,
          ),
          TxtffCustom(
            label: 'Modelo',
            screenWidth: screenWidth,
            controller: _modeloController,
            validator: Validators.requiredValidator.call,
          ),
          TxtffCustom(
            label: 'Año',
            screenWidth: screenWidth,
            controller: _anioController,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'El año es requerido';
              }
              final year = int.tryParse(value);
              if (year == null ||
                  year < 1900 ||
                  year > DateTime.now().year + 1) {
                return 'Ingrese un año válido';
              }
              return null;
            },
          ),
        ]),
        const SizedBox(height: 16),
        _buildSectionHeader(
          Icons.confirmation_number_outlined,
          'Identificación',
          colorScheme,
        ),
        _buildFormCard([
          TxtffCustom(
            label: 'Placa',
            screenWidth: screenWidth,
            controller: _placaController,
            validator: Validators.placaValidator.call,
          ),
          TxtffCustom(
            label: 'Kilometraje',
            screenWidth: screenWidth,
            controller: _kilometrajeController,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                final km = int.tryParse(value);
                if (km == null || km < 0) {
                  return 'Ingrese un kilometraje válido';
                }
              }
              return null;
            },
          ),
        ]),
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
            onPressed: _isLoading ? null : _saveVehiculo,
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
                : Text(isEditing ? 'Actualizar' : 'Guardar'),
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
