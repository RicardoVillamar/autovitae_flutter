import 'package:autovitae/core/theme/app_colors.dart';
import 'package:autovitae/core/utils/session_manager.dart';
import 'package:autovitae/presentation/shared/widgets/buttons/primary_button.dart';
import 'package:autovitae/presentation/shared/widgets/buttons/secondary_button.dart';
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
    final colorScheme = Theme.of(context).colorScheme;

    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Por favor ingresa email y contraseña'),
          backgroundColor: colorScheme.error,
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
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_viewModel.error ?? 'Error al iniciar sesión'),
            backgroundColor: colorScheme.error,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: colorScheme.error,
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Center(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 16),
            Center(
                child: Text('AutoVitae',
                    style: textTheme.headlineLarge
                        ?.copyWith(color: colorScheme.primary))),
            const SizedBox(height: 32),
            TxtffCustom(
              label: 'Email',
              screenWidth: screenWidth,
              controller: emailController,
              showCounter: false,
              keyboardType: TextInputType.emailAddress,
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
              title: Text('Recordar sesión', style: textTheme.bodyLarge),
              value: _rememberMe,
              activeColor: colorScheme.primary,
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: (value) {
                setState(() {
                  _rememberMe = value ?? false;
                });
              },
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              text: _isLoading ? 'Cargando...' : 'Iniciar Sesión',
              isLoading: _isLoading,
              onPressed: _isLoading ? null : _login,
            ),
            const SizedBox(height: 16),
            SecondaryButton(
                text: 'Registrarse',
                onPressed: () {
                  Navigator.of(context).pushNamed('/registerCliente');
                }),
          ],
        ),
      ),
    );
  }
}
