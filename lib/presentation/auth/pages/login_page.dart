import 'package:autovitae/core/theme/app_colors.dart';
import 'package:autovitae/core/theme/app_fonts.dart';
import 'package:autovitae/core/utils/session_manager.dart';
import 'package:autovitae/presentation/shared/widgets/inputs/text_field_custom.dart';
import 'package:autovitae/viewmodels/login_viewmodel.dart';
import 'package:autovitae/data/models/rol_usuario.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final LoginPageModel _viewModel = LoginPageModel();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _checkActiveSession();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _checkActiveSession() async {
    final authResult = await _viewModel.validateActiveSession();
    if (authResult != null && mounted) {
      _navigateByRole(authResult.rol, authResult.primerLoginGerente);
    }
  }

  Future<void> _login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingresa email y contraseña'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authResult = await _viewModel.login(
        emailController.text.trim(),
        passwordController.text,
        persistSession: _rememberMe,
      );

      if (!mounted) return;

      setState(() => _isLoading = false);

      if (authResult != null) {
        await SessionManager().saveSession(
          usuario: authResult.usuario,
          gerente: authResult.gerente,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Inicio de sesión exitoso'),
              backgroundColor: AppColors.success,
            ),
          );
          _navigateByRole(authResult.rol, authResult.primerLoginGerente);
        }
      }
           else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_viewModel.error ?? 'Error al iniciar sesión'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _navigateByRole(RolUsuario rol, bool? primerLoginGerente) {
    // If gerente and first login, go to change password
    if (rol == RolUsuario.gerente && primerLoginGerente == true) {
      Navigator.of(context).pushReplacementNamed('/cambiar_password');
      return;
    }

    // Navigate to appropriate home screen based on role
    if (rol == RolUsuario.admin) {
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil('/home_admin', (r) => false);
      return;
    }

    if (rol == RolUsuario.cliente) {
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil('/home_client', (r) => false);
      return;
    }

    if (rol == RolUsuario.gerente) {
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil('/home_gerent', (r) => false);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        margin: const EdgeInsets.all(20),
        decoration: const BoxDecoration(color: AppColors.background),
        child: ListView(
          children: [
            const SizedBox(height: 60),
            const Center(child: Text('AutoVitae', style: AppTextStyles.headline1)),
            const SizedBox(height: 16),
            TxtffCustom(
              label: 'Email',
              screenWidth: screenWidth,
              controller: emailController,
              showCounter: false,
            ),
            const SizedBox(height: 16),
            TxtffCustom(
              label: 'Contraseña',
              screenWidth: screenWidth,
              controller: passwordController,
              showCounter: false,
              obscureText: true,
            ),
            const SizedBox(height: 10),
            CheckboxListTile(
              title: const Text('Recordar sesión', style: AppTextStyles.bodyText),
              value: _rememberMe,
              activeColor: AppColors.primaryColor,
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: (value) {
                setState(() {
                  _rememberMe = value ?? false;
                });
              },
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _isLoading ? null : _login,
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(
                  _isLoading ? AppColors.grey : AppColors.primaryColor,
                ),
                foregroundColor: WidgetStateProperty.all(AppColors.black),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.black,
                        ),
                      ),
                    )
                  : const Text('Iniciar Sesión'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/registerCliente');
              },
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(
                  AppColors.secondaryColor,
                ),
                foregroundColor: WidgetStateProperty.all(AppColors.black),
              ),
              child: const Text('Registrarse'),
            ),
          ],
        ),
      ),
    );
  }
}
