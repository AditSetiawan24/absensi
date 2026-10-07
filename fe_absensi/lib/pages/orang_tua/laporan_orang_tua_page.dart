import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../services/laporan_service.dart';
import '../../widgets/common_widgets.dart';

class LaporanOrangTuaPage extends StatefulWidget {
  const LaporanOrangTuaPage({super.key});

  @override
  State<LaporanOrangTuaPage> createState() => _LaporanOrangTuaPageState();
}

class _LaporanOrangTuaPageState extends State<LaporanOrangTuaPage> {
  List<Map<String, dynamic>> _laporanData = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadLaporan();
  }

  Future<void> _loadLaporan() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    // Get laporan for the parent's children
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final response = await LaporanService.getByOrangTua(auth.user?.id ?? '');

    setState(() {
      _isLoading = false;
      if (response.success && response.data != null) {
        _laporanData = response.data!;
      } else {
        _error = response.message;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Kehadiran'),
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const LoadingWidget()
          : _error != null
              ? CustomErrorWidget(
                  message: _error!,
                  onRetry: _loadLaporan,
                )
              : _laporanData.isEmpty
                  ? const EmptyWidget(
                      message: 'Belum ada laporan untuk anak Anda',
                    )
                  : RefreshIndicator(
                      onRefresh: _loadLaporan,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _laporanData.length,
                        itemBuilder: (context, index) {
                          final data = _laporanData[index];
                          return _buildChildReportCard(data);
                        },
                      ),
                    ),
    );
  }

  Widget _buildChildReportCard(Map<String, dynamic> data) {
    final siswa = data['siswa'] as Map<String, dynamic>?;
    final kelas = data['kelas'] as Map<String, dynamic>?;
    final statistik = data['statistik'] as Map<String, dynamic>?;

    final totalHadir = statistik?['total_hadir'] ?? 0;
    final totalSakit = statistik?['total_sakit'] ?? 0;
    final totalIzin = statistik?['total_izin'] ?? 0;
    final totalAlfa = statistik?['total_alfa'] ?? 0;
    final totalKehadiran = totalHadir + totalSakit + totalIzin + totalAlfa;
    final persentaseHadir = totalKehadiran > 0
        ? (totalHadir / totalKehadiran * 100)
        : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        siswa?['nama'] ?? 'Siswa',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Kelas ${kelas?['kelas'] ?? '-'}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getPercentageColor(persentaseHadir),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${persentaseHadir.toStringAsFixed(1)}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // NIS Info
                Row(
                  children: [
                    const Icon(
                      Icons.badge,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'NIS: ${siswa?['nis'] ?? '-'}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),

                // Stats
                Row(
                  children: [
                    _buildStatItem(
                      'Hadir',
                      totalHadir,
                      AppColors.statusHadir,
                    ),
                    _buildStatItem(
                      'Izin',
                      totalIzin,
                      AppColors.statusIzin,
                    ),
                    _buildStatItem(
                      'Sakit',
                      totalSakit,
                      AppColors.statusSakit,
                    ),
                    _buildStatItem(
                      'Alfa',
                      totalAlfa,
                      AppColors.statusAlfa,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Progress Bar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tingkat Kehadiran',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: persentaseHadir / 100,
                        minHeight: 10,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getPercentageColor(persentaseHadir),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              '$value',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getPercentageColor(double percentage) {
    if (percentage >= 90) return AppColors.success;
    if (percentage >= 75) return AppColors.warning;
    return AppColors.error;
  }
}
