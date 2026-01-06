import 'package:autovitae/view/auth_view/login_view/login_view.dart';
import 'package:autovitae/view/auth_view/register_view/register_view.dart';
import 'package:flutter/material.dart';

final Map<String, WidgetBuilder> routes = {
  '/': (context) => const LoginView(),
  '/registerCliente': (context) => const RegistrarCliente(),
};
