import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'orang_tua_dashboard_page.dart';
import 'laporan_orang_tua_page.dart';
import '../shared/settings_page.dart';

class OrangTuaHomePage extends StatefulWidget {
  const OrangTuaHomePage({super.key});

  @override
  State<OrangTuaHomePage> createState() => _OrangTuaHomePageState();
}

class _OrangTuaHomePageState extends State<OrangTuaHomePage> {
  int _currentIndex = 0;
  
  final List<Widget> _pages = [
    const OrangTuaDashboardPage(),
    const LaporanOrangTuaPage(),
    const SettingsPage(key: ValueKey('orang_tua_settings')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined),
              activeIcon: Icon(Icons.calendar_today),
              label: 'Kehadiran',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.description_outlined),
              activeIcon: Icon(Icons.description),
              label: 'Laporan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'Pengaturan',
            ),
          ],
        ),
      ),
    );
  }
}
