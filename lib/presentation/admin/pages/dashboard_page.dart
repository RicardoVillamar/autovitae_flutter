import 'package:flutter/material.dart';
import 'package:autovitae/core/utils/session_manager.dart';
import 'package:autovitae/core/theme/app_colors.dart';
import 'package:autovitae/core/theme/app_fonts.dart';
import 'package:autovitae/presentation/shared/widgets/cards/dashboard_card.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String _adminName = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final usuario = await SessionManager().getUsuario();
    if (usuario != null && mounted) {
      setState(() {
        _adminName = '${usuario.nombre} ${usuario.apellido}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Bienvenido, $_adminName', style: AppTextStyles.headline1),
          const SizedBox(height: 8),
          Text(
            'Panel de Administración',
            style: AppTextStyles.caption.copyWith(color: AppColors.grey),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: GridView.count(
              padding: EdgeInsets.only(bottom: kBottomNavigationBarHeight + 24),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.85,
              children: [
                DashboardCard(
                  icon: Icons.store,
                  title: 'Gestionar Talleres',
                  subtitle: 'Administrar talleres',
                  color: AppColors.primaryColor,
                  onTap: () {
                    DefaultTabController.of(context).animateTo(1);
                  },
                ),
                DashboardCard(
                  icon: Icons.people,
                  title: 'Gestionar Gerentes',
                  subtitle: 'Administrar gerentes',
                  color: AppColors.success,
                  onTap: () {
                    DefaultTabController.of(context).animateTo(2);
                  },
                ),
                DashboardCard(
                  icon: Icons.group,
                  title: 'Gestionar Clientes',
                  subtitle: 'Ver clientes registrados',
                  color: AppColors.secondaryColor,
                  onTap: () {
                    Navigator.of(context).pushNamed('/clientes_admin');
                  },
                ),
                DashboardCard(
                  icon: Icons.assessment,
                  title: 'Reportes',
                  subtitle: 'Ver estadísticas',
                  color: AppColors.warning,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Próximamente'),
                        backgroundColor: AppColors.primaryColor,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
