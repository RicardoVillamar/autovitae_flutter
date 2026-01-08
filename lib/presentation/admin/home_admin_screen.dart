import 'package:flutter/material.dart';
import 'package:autovitae/presentation/admin/pages/dashboard_page.dart';
import 'package:autovitae/presentation/admin/pages/talleres_page.dart';
import 'package:autovitae/presentation/admin/pages/gerentes_page.dart';
import 'package:autovitae/viewmodels/login_viewmodel.dart';
import 'package:autovitae/core/theme/app_colors.dart';
import 'package:autovitae/presentation/shared/widgets/navigation/custom_bottom_nav_bar.dart';

class HomeAdminScreen extends StatefulWidget {
  const HomeAdminScreen({super.key});

  @override
  State<HomeAdminScreen> createState() => _HomeAdminScreenState();
}

class _HomeAdminScreenState extends State<HomeAdminScreen> {
  int _selectedIndex = 0;
  final LoginPageModel _loginViewModel = LoginPageModel();

  final List<Widget> _screens = [
    const DashboardPage(),
    const TalleresPage(),
    const GerentesPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await _loginViewModel.signOut();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: const Text('AutoVitae - Administrador'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.black,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(bottom: kBottomNavigationBarHeight + 32),
        child: _screens[_selectedIndex],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.build),
            label: 'Talleres',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Gerentes',
          ),
        ],
      ),
    );
  }
}
