import 'package:flutter/material.dart';
import 'package:autovitae/presentation/client/pages/dashboard_page.dart';
import 'package:autovitae/presentation/client/pages/vehicles_page.dart';
import 'package:autovitae/presentation/client/pages/history_page.dart';
import 'package:autovitae/presentation/client/pages/profile_page.dart';
import 'package:autovitae/presentation/shared/widgets/navigation/custom_bottom_nav_bar.dart';
import 'package:autovitae/presentation/shared/widgets/appbar/custom_app_bar.dart';

class HomeClientScreen extends StatefulWidget {
  const HomeClientScreen({super.key});

  @override
  State<HomeClientScreen> createState() => _HomeClientScreenState();
}

class _HomeClientScreenState extends State<HomeClientScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardPage(),
    const VehiclesPage(),
    const HistoryPage(),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody:
          true, // Allows the body to go behind the transparent parts of the nav bar area
      appBar: const CustomAppBar(
        title: 'AutoVitae',
        showBackButton: false,
        showMenu: true,
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
            icon: Icon(Icons.directions_car),
            label: 'Vehículos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Historial',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
