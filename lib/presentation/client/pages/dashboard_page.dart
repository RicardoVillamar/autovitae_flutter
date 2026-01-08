import 'package:flutter/material.dart';
import 'package:autovitae/core/utils/session_manager.dart';
import 'package:autovitae/presentation/shared/widgets/cards/dashboard_card.dart';
import 'package:autovitae/core/theme/app_colors.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String _clientName = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final usuario = await SessionManager().getUsuario();
    if (usuario != null && mounted) {
      setState(() {
        _clientName = '${usuario.nombre} ${usuario.apellido}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bienvenido, $_clientName',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                DashboardCard(
                  icon: Icons.directions_car,
                  title: 'Mis Vehículos',
                  subtitle: 'Ver mis vehículos',
                  color: AppColors.primaryColor,
                  onTap: () {
                    // Navigate to vehicles tab
                    DefaultTabController.of(context).animateTo(1);
                  },
                ),
                DashboardCard(
                  icon: Icons.calendar_today,
                  title: 'Agendar Cita',
                  subtitle: 'Nueva cita',
                  color: AppColors.secondaryColor,
                  onTap: () {
                    Navigator.of(context).pushNamed('/create_cita');
                  },
                ),
                DashboardCard(
                  icon: Icons.build_circle,
                  title: 'Programar Mantenimiento',
                  subtitle: 'Seleccionar taller',
                  color: AppColors.warning,
                  onTap: () {
                     Navigator.of(context).pushNamed('/talleres_cliente');
                  },
                ),
                DashboardCard(
                  icon: Icons.history,
                  title: 'Historial',
                  subtitle: 'Ver historial',
                  color: AppColors.success,
                  onTap: () {
                    // Navigate to history tab
                    DefaultTabController.of(context).animateTo(2);
                  },
                ),
                DashboardCard(
                  icon: Icons.local_shipping,
                  title: 'Solicitar Remolque',
                  subtitle: 'Servicio de grúa',
                  color: AppColors.error,
                  onTap: () {
                    Navigator.of(context).pushNamed('/solicitar_remolque');
                  },
                ),
                DashboardCard(
                  icon: Icons.store,
                  title: 'Talleres',
                  subtitle: 'Ver talleres disponibles',
                  color: AppColors.grey,
                  onTap: () {
                    Navigator.of(context).pushNamed('/talleres_cliente');
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
