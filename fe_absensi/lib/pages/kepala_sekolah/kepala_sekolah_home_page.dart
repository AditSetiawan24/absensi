import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'kepala_sekolah_dashboard_page.dart';
import 'laporan_kepala_sekolah_page.dart';
import '../shared/settings_page.dart';

class KepalaSekolahHomePage extends StatefulWidget {
  const KepalaSekolahHomePage({super.key});

  @override
  State<KepalaSekolahHomePage> createState() => _KepalaSekolahHomePageState();
}

class _KepalaSekolahHomePageState extends State<KepalaSekolahHomePage> {
  int _currentIndex = 0;
  
  final List<Widget> _pages = [
    const KepalaSekolahDashboardPage(),
    const LaporanKepalaSekolahPage(),
    const SettingsPage(key: ValueKey('kepala_sekolah_settings')),
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
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Rekapitulasi',
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
