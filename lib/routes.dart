import 'package:autovitae/presentation/auth/pages/login_page.dart';
import 'package:autovitae/presentation/auth/pages/register_page.dart';
import 'package:autovitae/presentation/auth/pages/change_password_page.dart';
import 'package:autovitae/presentation/admin/home_admin_screen.dart';
import 'package:autovitae/presentation/client/home_client_screen.dart';
import 'package:autovitae/presentation/manager/home_manager_screen.dart';
import 'package:autovitae/presentation/client/screens/talleres_disponibles_screen.dart';
import 'package:flutter/material.dart';

final Map<String, WidgetBuilder> routes = {
  '/': (context) => const LoginPage(),
  '/login': (context) => const LoginPage(),
  '/registerCliente': (context) => const RegisterPage(),
  '/cambiar_password': (context) => const ChangePasswordPage(),
  '/home_admin': (context) => const HomeAdminScreen(),
  '/home_client': (context) => const HomeClientScreen(),
  '/home_gerent': (context) => const HomeManagerScreen(),
  '/talleres_cliente': (context) => const TalleresDisponiblesScreen(),
};
