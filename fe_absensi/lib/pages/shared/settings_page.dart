import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/common_widgets.dart';
import '../../services/auth_service.dart';
import '../auth/landing_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _kodeKelasController = TextEditingController();
  bool _isChangingPassword = false;
  bool _isProcessingClass = false;
  Map<String, dynamic>? _kelasInfo;

  @override
  void initState() {
    super.initState();
    _loadKelasInfo();
  }

  Future<void> _loadKelasInfo() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.role == AppConstants.roleGuru && auth.user?.nip != null) {
      final response = await AuthService.getGuruClass(nip: auth.user!.nip!);
      if (response.success && response.data != null && mounted) {
        setState(() {
          _kelasInfo = response.data;
        });
      }
    }
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _kodeKelasController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password baru tidak cocok'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isChangingPassword = true;
    });

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final response = await AuthService.changePassword(
      username: auth.user?.username ?? '',
      role: auth.role ?? '',
      oldPassword: _currentPasswordController.text,
      password: _newPasswordController.text,
      passwordConfirmation: _confirmPasswordController.text,
    );

    setState(() {
      _isChangingPassword = false;
    });

    if (response.success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password berhasil diubah'),
          backgroundColor: AppColors.success,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showChangePasswordDialog() {
    _currentPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Ubah Password',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              CustomTextField(
                controller: _currentPasswordController,
                label: 'Password Saat Ini',
                hint: 'Masukkan password saat ini',
                obscureText: true,
                prefixIcon: Icons.lock_outline,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _newPasswordController,
                label: 'Password Baru',
                hint: 'Masukkan password baru',
                obscureText: true,
                prefixIcon: Icons.lock_outline,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _confirmPasswordController,
                label: 'Konfirmasi Password',
                hint: 'Masukkan ulang password baru',
                obscureText: true,
                prefixIcon: Icons.lock_outline,
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Simpan',
                onPressed: _changePassword,
                isLoading: _isChangingPassword,
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Keluar', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.logout();
      
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LandingPage()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final settings = Provider.of<SettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: Text(
                      (auth.user?.nama ?? 'U')[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          auth.user?.nama ?? 'User',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          auth.user?.email ?? '',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            _getRoleLabel(auth.user?.role ?? ''),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Settings Sections
            Text(
              'Preferensi',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.getTextSecondary(context),
              ),
            ),
            const SizedBox(height: 12),
            _buildSettingItem(
              icon: Icons.notifications_outlined,
              title: 'Notifikasi',
              subtitle: 'Terima notifikasi push',
              trailing: Switch(
                value: settings.notificationsEnabled,
                onChanged: (value) {
                  settings.setNotifications(value);
                },
              ),
            ),
            const SizedBox(height: 24),

            // Account Section
            Text(
              'Akun',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.getTextSecondary(context),
              ),
            ),
            const SizedBox(height: 12),
            _buildSettingItem(
              icon: Icons.lock_outline,
              title: 'Ubah Password',
              subtitle: 'Perbarui password akun Anda',
              onTap: _showChangePasswordDialog,
            ),
            
            // Guru Class Management Section
            if (auth.role == AppConstants.roleGuru) ...[
              const SizedBox(height: 24),
              Text(
                'Manajemen Kelas',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextSecondary(context),
                ),
              ),
              const SizedBox(height: 12),
              
              if (_kelasInfo != null && _kelasInfo!['has_class'] == true)
                _buildSettingItem(
                  icon: Icons.logout,
                  title: 'Lepas Kelas',
                  subtitle: 'Lepaskan kelas yang diampu saat ini',
                  onTap: _showReleaseClassDialog,
                ),
              _buildSettingItem(
                icon: Icons.swap_horiz,
                title: 'Pindah Kelas',
                subtitle: 'Pindah ke kelas lain',
                onTap: _showChangeClassDialog,
              ),
            ],
            const SizedBox(height: 24),

            // About Section
            Text(
              'Tentang',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.getTextSecondary(context),
              ),
            ),
            const SizedBox(height: 12),
            _buildSettingItem(
              icon: Icons.info_outline,
              title: 'Tentang Aplikasi',
              subtitle: AppConstants.appVersion,
              onTap: () {
                _showAboutDialog();
              },
            ),
            _buildSettingItem(
              icon: Icons.help_outline,
              title: 'Bantuan',
              subtitle: 'Pusat bantuan dan FAQ',
              onTap: () {
                // TODO: Show help
              },
            ),
            const SizedBox(height: 24),

            // Logout Button
            CustomButton(
              text: 'Keluar',
              onPressed: _logout,
              isOutlined: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.getCardColor(context),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark 
                ? Colors.black.withOpacity(0.2) 
                : Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(isDark ? 0.2 : 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: isDark ? AppColors.primaryLight : AppColors.primary),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.getTextPrimary(context),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.getTextSecondary(context),
          ),
        ),
        trailing: trailing ?? Icon(
          Icons.chevron_right,
          color: AppColors.getTextSecondary(context),
        ),
        onTap: onTap,
      ),
    );
  }

  String _getRoleLabel(String role) {
    switch (role) {
      case AppConstants.roleGuru:
        return 'Guru';
      case AppConstants.roleKepalaSekolah:
        return 'Kepala Sekolah';
      case AppConstants.roleOrangTua:
        return 'Orang Tua';
      default:
        return role;
    }
  }

  void _showReleaseClassDialog() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final namaKelas = _kelasInfo?['kelas']?['nama_kelas'] ?? 'kelas';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Lepas Kelas'),
        content: Text(
          'Apakah Anda yakin ingin melepaskan $namaKelas?\n\n'
          'Anda harus memilih kelas baru sebelum dapat melakukan absensi lagi.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _isProcessingClass = true);
              
              final response = await AuthService.releaseClass(
                nip: auth.user!.nip!,
              );
              
              setState(() => _isProcessingClass = false);
              
              if (response.success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(response.message),
                    backgroundColor: AppColors.success,
                  ),
                );
                _loadKelasInfo();
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(response.message),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            child: const Text('Lepas', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _showChangeClassDialog() {
    _kodeKelasController.clear();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Pindah Kelas',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Masukkan kode kelas baru.\nFormat: KLS1, KLS2, KLS3, KLS4, KLS5, KLS6',
                            style: TextStyle(fontSize: 12, color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _kodeKelasController,
                    label: 'Kode Kelas Baru',
                    hint: 'Contoh: KLS1',
                    prefixIcon: Icons.class_outlined,
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: 'Pindah',
                    isLoading: _isProcessingClass,
                    onPressed: () async {
                      if (_kodeKelasController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Masukkan kode kelas'),
                            backgroundColor: AppColors.error,
                          ),
                        );
                        return;
                      }
                      
                      setModalState(() => _isProcessingClass = true);
                      
                      final response = await AuthService.changeClass(
                        nip: auth.user!.nip!,
                        kodeKelas: _kodeKelasController.text.trim(),
                      );
                      
                      setModalState(() => _isProcessingClass = false);
                      
                      if (response.success && mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(response.message),
                            backgroundColor: AppColors.success,
                          ),
                        );
                        _loadKelasInfo();
                      } else if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(response.message),
                            backgroundColor: AppColors.error,
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.school, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            const Text(AppConstants.appName),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(AppConstants.schoolName),
            const SizedBox(height: 8),
            Text(
              'Versi ${AppConstants.appVersion}',
              style: TextStyle(color: AppColors.getTextSecondary(context)),
            ),
            const SizedBox(height: 16),
            const Text(
              'Aplikasi absensi siswa untuk memudahkan pencatatan dan pemantauan kehadiran siswa.',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }
}
