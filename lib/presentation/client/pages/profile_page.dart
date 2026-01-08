import 'package:flutter/material.dart';
import 'package:autovitae/data/models/usuario.dart';
import 'package:autovitae/data/models/cliente.dart';
import 'package:autovitae/core/utils/session_manager.dart';
import 'package:autovitae/core/theme/app_colors.dart';
import 'package:autovitae/core/theme/app_fonts.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Usuario? _usuario;
  Cliente? _cliente;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    _usuario = await SessionManager().getUsuario();
    _cliente = await SessionManager().getCliente();
    setState(() => _isLoading = false);
  }

  Future<void> _navigateToEditProfile() async {
    final result = await Navigator.of(
      context,
    ).pushNamed('/edit_profile_cliente');
    if (result == true) {
      _loadUserData();
    }
  }

  Future<void> _navigateToChangePassword() async {
    Navigator.of(context).pushNamed('/cambiar_password');
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: AppColors.primaryColor),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person, size: 60, color: AppColors.primaryColor),
          ),
          const SizedBox(height: 24),
          Text(
            '${_usuario?.nombre ?? ''} ${_usuario?.apellido ?? ''}',
            style: AppTextStyles.headline1,
          ),
          const SizedBox(height: 8),
          Text(
            _usuario?.correo ?? '',
            style: AppTextStyles.bodyText.copyWith(color: AppColors.grey),
          ),
          const SizedBox(height: 32),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.badge, color: AppColors.primaryColor),
                  ),
                  title: Text('Cédula', style: AppTextStyles.caption),
                  subtitle: Text(
                    _usuario?.cedula ?? '',
                    style: AppTextStyles.bodyText,
                  ),
                ),
                Divider(
                  height: 1,
                  color: AppColors.grey.withValues(alpha: 0.3),
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.phone, color: AppColors.primaryColor),
                  ),
                  title: Text('Teléfono', style: AppTextStyles.caption),
                  subtitle: Text(
                    _usuario?.telefono ?? '',
                    style: AppTextStyles.bodyText,
                  ),
                ),
                Divider(
                  height: 1,
                  color: AppColors.grey.withValues(alpha: 0.3),
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.location_on,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  title: Text('Dirección', style: AppTextStyles.caption),
                  subtitle: Text(
                    _cliente?.direccion ?? 'No especificada',
                    style: AppTextStyles.bodyText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.edit, color: AppColors.primaryColor),
                  ),
                  title: Text('Editar Perfil', style: AppTextStyles.bodyText),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppColors.grey,
                  ),
                  onTap: _navigateToEditProfile,
                ),
                Divider(
                  height: 1,
                  color: AppColors.grey.withValues(alpha: 0.3),
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.lock, color: AppColors.primaryColor),
                  ),
                  title: Text(
                    'Cambiar Contraseña',
                    style: AppTextStyles.bodyText,
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppColors.grey,
                  ),
                  onTap: _navigateToChangePassword,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.info_outline, color: AppColors.primaryColor),
              ),
              title: Text('Acerca de', style: AppTextStyles.bodyText),
              subtitle: Text('AutoVitae v1.0.0', style: AppTextStyles.caption),
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'AutoVitae',
                  applicationVersion: '1.0.0',
                  applicationIcon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.directions_car,
                      size: 48,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  children: [
                    Text(
                      'Sistema de gestión de mantenimiento vehicular',
                      style: AppTextStyles.bodyText,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
