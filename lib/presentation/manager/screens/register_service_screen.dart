import 'package:flutter/material.dart';
import 'package:autovitae/data/models/servicio_taller.dart';
import 'package:autovitae/data/models/categoria_serivicio_taller.dart';
import 'package:autovitae/viewmodels/servicio_taller_viewmodel.dart';
import 'package:autovitae/core/utils/session_manager.dart';
import 'package:autovitae/core/theme/app_colors.dart';
import 'package:autovitae/presentation/shared/widgets/buttons/primary_button.dart';
import 'package:autovitae/presentation/shared/widgets/buttons/secondary_button.dart';

class RegisterServiceScreen extends StatefulWidget {
  final ServicioTaller? servicio;

  const RegisterServiceScreen({super.key, this.servicio});

  @override
  State<RegisterServiceScreen> createState() => _RegisterServiceScreenState();
}

class _RegisterServiceScreenState extends State<RegisterServiceScreen> {
  final ServicioTallerViewModel _viewModel = ServicioTallerViewModel();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();

  CategoriaSerivicioTaller _selectedCategoria = CategoriaSerivicioTaller.otros;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.servicio != null) {
      _nombreController.text = widget.servicio!.nombre;
      _descripcionController.text = widget.servicio!.descripcion ?? '';
      _precioController.text = widget.servicio!.precio.toString();
      _selectedCategoria = widget.servicio!.categoria;
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _precioController.dispose();
    super.dispose();
  }

  Future<void> _guardarServicio() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final gerente = await SessionManager().getGerente();
    if (gerente?.uidTaller == null) {
      _showError('Error: No se encontró el taller del gerente');
      setState(() => _isLoading = false);
      return;
    }

    final servicio = ServicioTaller(
      uidServicio: widget.servicio?.uidServicio,
      uidTaller: gerente!.uidTaller!,
      nombre: _nombreController.text.trim(),
      descripcion: _descripcionController.text.trim(),
      precio: double.parse(_precioController.text.trim()),
      categoria: _selectedCategoria,
      estado: widget.servicio?.estado ?? 1,
    );

    bool success;
    if (widget.servicio == null) {
      success = await _viewModel.registrarServicio(servicio);
    } else {
      success = await _viewModel.actualizarServicio(
        widget.servicio!.uidServicio!,
        servicio,
      );
    }

    setState(() => _isLoading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.servicio == null
                ? 'Servicio creado exitosamente'
                : 'Servicio actualizado exitosamente',
          ),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.of(context).pop(true);
    } else {
      _showError(_viewModel.error ?? 'Error al guardar servicio');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.error),
    );
  }

  String _getCategoriaText(CategoriaSerivicioTaller categoria) {
    switch (categoria) {
      case CategoriaSerivicioTaller.mecanica:
        return 'Mecánica';
      case CategoriaSerivicioTaller.limpieza:
        return 'Limpieza';
      case CategoriaSerivicioTaller.pulido:
        return 'Pulido';
      case CategoriaSerivicioTaller.remolque:
        return 'Remolque';
      case CategoriaSerivicioTaller.cambioLlantas:
        return 'Cambio de Llantas';
      case CategoriaSerivicioTaller.otros:
        return 'Otros';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.servicio == null ? 'Nuevo Servicio' : 'Editar Servicio',
        ),
        backgroundColor: colorScheme.primary,
        foregroundColor: AppColors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Información del Servicio', style: textTheme.headlineSmall),
              const SizedBox(height: 24),
              // Nombre
              Text(
                'Nombre del Servicio *',
                style: textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nombreController,
                decoration: InputDecoration(
                  hintText: 'Ej: Cambio de aceite',
                  filled: true,
                  fillColor: AppColors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: AppColors.grey.withValues(alpha: 0.3),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: AppColors.grey.withValues(alpha: 0.3),
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El nombre es requerido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              // Categoría
              Text(
                'Categoría *',
                style: textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(8),
                  border:
                      Border.all(color: AppColors.grey.withValues(alpha: 0.3)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<CategoriaSerivicioTaller>(
                    value: _selectedCategoria,
                    isExpanded: true,
                    items: CategoriaSerivicioTaller.values.map((categoria) {
                      return DropdownMenuItem<CategoriaSerivicioTaller>(
                        value: categoria,
                        child: Text(_getCategoriaText(categoria)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedCategoria = value);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Precio
              Text(
                'Precio *',
                style: textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _precioController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  hintText: '0.00',
                  prefixText: '\$ ',
                  filled: true,
                  fillColor: AppColors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: AppColors.grey.withValues(alpha: 0.3),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: AppColors.grey.withValues(alpha: 0.3),
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El precio es requerido';
                  }
                  if (double.tryParse(value.trim()) == null) {
                    return 'Ingresa un precio válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              // Descripción
              Text(
                'Descripción',
                style: textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descripcionController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Describe el servicio...',
                  filled: true,
                  fillColor: AppColors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: AppColors.grey.withValues(alpha: 0.3),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: AppColors.grey.withValues(alpha: 0.3),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Botones
              PrimaryButton(
                text: widget.servicio == null
                    ? 'Crear Servicio'
                    : 'Actualizar Servicio',
                onPressed: _guardarServicio,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 12),
              SecondaryButton(
                text: 'Cancelar',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
