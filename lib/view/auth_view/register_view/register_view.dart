import 'package:autovitae/utils/colors.dart';
import 'package:autovitae/utils/font.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class RegistrarCliente extends StatefulWidget {
  const RegistrarCliente({super.key});

  @override
  State<RegistrarCliente> createState() => _RegistrarClienteState();
}

class _RegistrarClienteState extends State<RegistrarCliente> {
  final TextEditingController _codigo = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registrar Cliente', style: AppTextStyles.headline1),
        surfaceTintColor: AppColors.background,
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: Icon(MdiIcons.chevronLeft),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Form(
        key: _formKey,
        child: Container(
          decoration: BoxDecoration(color: AppColors.background),
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Formulario de registro de cliente',
                  style: AppTextStyles.bodyText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
