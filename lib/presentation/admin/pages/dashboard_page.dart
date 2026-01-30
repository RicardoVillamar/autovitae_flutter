import 'package:flutter/material.dart';
import 'package:autovitae/core/utils/session_manager.dart';
import 'package:autovitae/core/theme/app_colors.dart';
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Bienvenido, $_adminName', style: textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Panel de Administración',
            style: textTheme.bodySmall
                ?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: GridView.count(
              padding: const EdgeInsets.only(
                  bottom: kBottomNavigationBarHeight + 24),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.85,
              children: [
                DashboardCard(
                  icon: Icons.store,
                  title: 'Gestionar Talleres',
                  subtitle: 'Administrar talleres',
                  color: colorScheme.primary,
                  onTap: () {
                    DefaultTabController.of(context).animateTo(1);
                  },
                ),
                DashboardCard(
                  icon: Icons.people,
                  title: 'Gestionar Gerentes',
                  subtitle: 'Administrar gerentes',
                  color: colorScheme.primary,
                  onTap: () {
                    DefaultTabController.of(context).animateTo(2);
                  },
                ),
                DashboardCard(
                  icon: Icons.group,
                  title: 'Gestionar Clientes',
                  subtitle: 'Ver clientes registrados',
                  color: colorScheme.secondary,
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
                        content: const Text('Próximamente'),
                        backgroundColor: colorScheme.primary,
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
