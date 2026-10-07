import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../models/dashboard_model.dart';
import '../../services/dashboard_service.dart';
import '../../widgets/common_widgets.dart';

class KepalaSekolahDashboardPage extends StatefulWidget {
  const KepalaSekolahDashboardPage({super.key});

  @override
  State<KepalaSekolahDashboardPage> createState() => _KepalaSekolahDashboardPageState();
}

class _KepalaSekolahDashboardPageState extends State<KepalaSekolahDashboardPage> {
  KepalaSekolahDashboard? _dashboard;
  bool _isLoading = true;
  String? _error;
  
  // Filter variables
  String? _selectedTahunAjar;
  String _selectedSemester = 'Ganjil';
  List<String> _tahunAjarOptions = [];

  @override
  void initState() {
    super.initState();
    _initializeTahunAjar();
    _loadDashboard();
  }
  
  void _initializeTahunAjar() {
    final now = DateTime.now();
    final currentYear = now.year;
    final currentMonth = now.month;
    
    // Determine current academic year
    String currentTahunAjar;
    if (currentMonth >= 7) {
      currentTahunAjar = '$currentYear/${currentYear + 1}';
      _selectedSemester = 'Ganjil';
    } else {
      currentTahunAjar = '${currentYear - 1}/$currentYear';
      _selectedSemester = 'Genap';
    }
    
    // Generate tahun ajar options (current year + 2 previous years)
    _tahunAjarOptions = [];
    for (int i = 0; i < 3; i++) {
      final year = currentYear - i;
      _tahunAjarOptions.add('$year/${year + 1}');
      if (i < 2) {
        _tahunAjarOptions.add('${year - 1}/$year');
      }
    }
    _tahunAjarOptions = _tahunAjarOptions.toSet().toList()..sort((a, b) => b.compareTo(a));
    _selectedTahunAjar = currentTahunAjar;
  }

  Future<void> _loadDashboard() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    // Convert tahun ajar to year format for API
    String? tahunAjar;
    if (_selectedTahunAjar != null && _selectedTahunAjar!.contains('/')) {
      tahunAjar = _selectedTahunAjar!.split('/')[0];
    }
    
    // Convert semester name to number
    final semester = _selectedSemester == 'Ganjil' ? 1 : 2;

    final response = await DashboardService.getKepalaSekolahDashboard(
      tahunAjar: tahunAjar,
      semester: semester,
    );

    setState(() {
      _isLoading = false;
      if (response.success && response.data != null) {
        _dashboard = response.data;
      } else {
        _error = response.message;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadDashboard,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.primary,
                      child: Text(
                        (auth.user?.nama ?? 'K')[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selamat Datang,',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            auth.user?.nama ?? 'Kepala Sekolah',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Filter Section
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedTahunAjar,
                              isExpanded: true,
                              hint: const Text('Tahun Ajar'),
                              items: _tahunAjarOptions.map((t) => DropdownMenuItem(
                                value: t,
                                child: Text('TA $t', style: const TextStyle(fontSize: 13)),
                              )).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedTahunAjar = value;
                                });
                                _loadDashboard();
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedSemester,
                              isExpanded: true,
                              items: AppConstants.semesterNames.map((s) => DropdownMenuItem(
                                value: s,
                                child: Text('Semester $s', style: const TextStyle(fontSize: 13)),
                              )).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedSemester = value;
                                  });
                                  _loadDashboard();
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                if (_isLoading)
                  const LoadingWidget()
                else if (_error != null)
                  CustomErrorWidget(
                    message: _error!,
                    onRetry: _loadDashboard,
                  )
                else if (_dashboard != null)
                  _buildDashboardContent(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardContent() {
    // Calculate totals from classStats
    int totalHadir = 0;
    int totalIzin = 0;
    int totalSakit = 0;
    int totalAlfa = 0;
    int totalAbsensi = 0;
    
    for (var kelas in _dashboard!.kelasStats) {
      totalHadir += kelas.hadir;
      totalIzin += kelas.izin;
      totalSakit += kelas.sakit;
      totalAlfa += kelas.alfa;
      totalAbsensi += kelas.totalAbsensi;
    }
    
    final totalTidakHadir = totalIzin + totalSakit + totalAlfa;
    final persentaseHadir = totalAbsensi > 0 ? (totalHadir / totalAbsensi) * 100 : 0.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Overall Stats
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
          child: Column(
            children: [
              const Text(
                'Rekapitulasi Kehadiran',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              Text(
                'Semester $_selectedSemester - TA $_selectedTahunAjar',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildOverallStat(
                    'Total Siswa',
                    '${_dashboard!.totalSiswa}',
                    Icons.people,
                  ),
                  _buildOverallStat(
                    'Hadir',
                    '$totalHadir',
                    Icons.check_circle,
                  ),
                  _buildOverallStat(
                    'Tidak Hadir',
                    '$totalTidakHadir',
                    Icons.cancel,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Tingkat Kehadiran: ${persentaseHadir.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Stats Details
        const Text(
          'Detail Kehadiran Semester Ini',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'Izin',
                value: '$totalIzin',
                subtitle: 'siswa',
                icon: Icons.assignment,
                color: AppColors.statusIzin,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                title: 'Sakit',
                value: '$totalSakit',
                subtitle: 'siswa',
                icon: Icons.local_hospital,
                color: AppColors.statusSakit,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                title: 'Alfa',
                value: '$totalAlfa',
                subtitle: 'siswa',
                icon: Icons.cancel,
                color: AppColors.statusAlfa,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Per Class Statistics
        const Text(
          'Statistik Per Kelas',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (_dashboard!.kelasStats.isNotEmpty)
          Container(
            height: 250,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.getCardColor(context),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.black.withOpacity(0.2)
                      : Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: _buildKelasChart(),
          ),
        const SizedBox(height: 24),

        // Class Details
        const Text(
          'Detail Per Kelas',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _dashboard!.kelasStats.length,
          itemBuilder: (context, index) {
            final kelas = _dashboard!.kelasStats[index];
            return _buildKelasCard(kelas);
          },
        ),
        const SizedBox(height: 24),

        // Comparison Cards
        if (_dashboard!.comparison != null) ...[
          const Text(
            'Perbandingan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildComparisonCard(
                  'Semester Ini',
                  _dashboard!.comparison!.currentSemester,
                  Icons.trending_up,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildComparisonCard(
                  'Peningkatan',
                  _dashboard!.comparison!.improvement,
                  Icons.calendar_today,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildOverallStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildKelasChart() {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 100,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final kelas = _dashboard!.kelasStats[groupIndex];
              return BarTooltipItem(
                'Kelas ${kelas.kelas}\n${rod.toY.toStringAsFixed(1)}%',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < _dashboard!.kelasStats.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _dashboard!.kelasStats[index].kelas,
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}%',
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 25,
        ),
        borderData: FlBorderData(show: false),
        barGroups: _dashboard!.kelasStats.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value.persentaseHadir,
                color: AppColors.primary,
                width: 16,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildKelasCard(KelasStats kelas) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.class_, color: isDark ? AppColors.primaryLight : AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kelas ${kelas.kelas}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.getTextPrimary(context),
                      ),
                    ),
                    Text(
                      'Total ${kelas.jumlahSiswa} siswa',
                      style: TextStyle(
                        color: AppColors.getTextSecondary(context),
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
                  color: _getPercentageColor(kelas.persentaseHadir),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${kelas.persentaseHadir.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildMiniStat('Hadir', kelas.hadir, AppColors.statusHadir),
              _buildMiniStat('Izin', kelas.izin, AppColors.statusIzin),
              _buildMiniStat('Sakit', kelas.sakit, AppColors.statusSakit),
              _buildMiniStat('Alfa', kelas.alfa, AppColors.statusAlfa),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, int value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            '$value',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 16,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.getTextSecondary(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonCard(String title, double percentage, IconData icon) {
    final isPositive = percentage >= 0;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        children: [
          Icon(icon, color: AppColors.getTextSecondary(context)),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.getTextSecondary(context),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isPositive ? Icons.trending_up : Icons.trending_down,
                color: isPositive ? AppColors.success : AppColors.error,
                size: 20,
              ),
              const SizedBox(width: 4),
              Text(
                '${isPositive ? '+' : ''}${percentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isPositive ? AppColors.success : AppColors.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getPercentageColor(double percentage) {
    if (percentage >= 90) return AppColors.success;
    if (percentage >= 75) return AppColors.warning;
    return AppColors.error;
  }
}
