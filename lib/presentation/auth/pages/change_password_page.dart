import 'package:flutter/material.dart';
import 'package:autovitae/viewmodels/login_viewmodel.dart';
import 'package:autovitae/core/utils/validators.dart';
import 'package:autovitae/core/theme/app_colors.dart';
import 'package:autovitae/core/theme/app_fonts.dart';
import 'package:form_field_validator/form_field_validator.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final LoginPageModel _viewModel = LoginPageModel();
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

Future<void> _changePassword() async {
  if (!_formKey.currentState!.validate()) return;
  setState(() => _isLoading = true);

  try {
    // 1. Cambiar clave
    await _viewModel.changePassword(
      _currentPasswordController.text,
      _newPasswordController.text,
    );

    // 2. ACTUALIZAR BASE DE DATOS (Este es el paso que te está fallando)
    // Aquí el ViewModel llama al Repository -> GerenteRepository -> Firestore
    final success = await _viewModel.updatePrimerLoginGerente();
    
    if (!success) {
      throw Exception("No se pudo actualizar el estado en la base de datos");
    }

    if (!mounted) return;

    // 3. Navegar
    Navigator.of(context).pushNamedAndRemoveUntil('/home_gerent', (r) => false);
  } catch (e) {
    setState(() => _isLoading = false);
    // Mostrar error...
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Cambiar Contraseña'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              _buildHeaderIcon(),
              const SizedBox(height: 32),
              Text(
                'Cambiar tu contraseña',
                style: AppTextStyles.headline1,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Por seguridad, debes cambiar la contraseña temporal asignada.',
                style: AppTextStyles.caption,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              
              // Campo: Contraseña Actual
              TextFormField(
                controller: _currentPasswordController,
                obscureText: _obscureCurrentPassword,
                decoration: _inputDecoration(
                  'Contraseña Actual', 
                  Icons.lock_outline,
                  _obscureCurrentPassword,
                  () => setState(() => _obscureCurrentPassword = !_obscureCurrentPassword),
                ),
                validator: RequiredValidator(errorText: 'La contraseña actual es requerida').call,
              ),
              const SizedBox(height: 16),

              // Campo: Nueva Contraseña
              TextFormField(
                controller: _newPasswordController,
                obscureText: _obscureNewPassword,
                decoration: _inputDecoration(
                  'Nueva Contraseña', 
                  Icons.lock,
                  _obscureNewPassword,
                  () => setState(() => _obscureNewPassword = !_obscureNewPassword),
                ),
                validator: Validators.passwordValidator.call,
              ),
              const SizedBox(height: 16),

              // Campo: Confirmar Contraseña
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                decoration: _inputDecoration(
                  'Confirmar Nueva Contraseña', 
                  Icons.lock,
                  _obscureConfirmPassword,
                  () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                ),
                validator: (val) {
                  if (val != _newPasswordController.text) {
                    return 'Las contraseñas no coinciden';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Botón de Acción
              ElevatedButton(
                onPressed: _isLoading ? null : _changePassword,
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: AppColors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                child: _isLoading
                    ? const SizedBox(
                        height: 20, width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                      )
                    : const Text('Actualizar y Entrar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderIcon() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.primaryColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.lock_reset, size: 80, color: AppColors.primaryColor),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon, bool obscure, VoidCallback toggle) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      suffixIcon: IconButton(
        icon: Icon(obscure ? Icons.visibility : Icons.visibility_off),
        onPressed: toggle,
      ),
      border: const OutlineInputBorder(),
    );
  }
}