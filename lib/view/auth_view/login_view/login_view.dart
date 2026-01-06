import 'package:autovitae/utils/colors.dart';
import 'package:autovitae/utils/font.dart';
import 'package:autovitae/view/components/inputs/text_field_custom.dart';
import 'package:flutter/material.dart';
//import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        margin: EdgeInsets.all(20),
        decoration: BoxDecoration(color: AppColors.background),
        child: ListView(
          children: [
            Center(child: Text('AutoVitae', style: AppTextStyles.headline1)),
            const SizedBox(height: 16),
            Center(child: Text('Grupo #1', style: AppTextStyles.bodyText)),
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
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {},
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(
                  AppColors.primaryColor,
                ),
                foregroundColor: WidgetStateProperty.all(AppColors.black),
              ),
              child: Text('Iniciar Sesión'),
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
              child: Text('Registrarse'),
            ),
          ],
        ),
      ),
    );
  }
}
