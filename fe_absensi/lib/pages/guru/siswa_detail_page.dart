import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/siswa_model.dart';
import '../../models/absensi_model.dart';
import '../../services/absensi_service.dart';
import '../../widgets/common_widgets.dart';

class SiswaDetailPage extends StatefulWidget {
  final Siswa siswa;

  const SiswaDetailPage({super.key, required this.siswa});

  @override
  State<SiswaDetailPage> createState() => _SiswaDetailPageState();
}

class _SiswaDetailPageState extends State<SiswaDetailPage> {
  List<Absensi> _absensiList = [];
  Map<String, dynamic>? _statistics;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final absensiResponse = await AbsensiService.getBySiswa(widget.siswa.nis);
    final statsResponse = await AbsensiService.getStatistics(nis: widget.siswa.nis);

    setState(() {
      _isLoading = false;
      if (absensiResponse.success && absensiResponse.data != null) {
        final data = absensiResponse.data!;
        if (data['absensi'] != null) {
          final absensiData = data['absensi'];
          if (absensiData is List) {
            _absensiList = absensiData.map((e) => Absensi.fromJson(e as Map<String, dynamic>)).toList();
          }
        }
      }
      if (statsResponse.success && statsResponse.data != null) {
        _statistics = statsResponse.data;
      }
      if (!absensiResponse.success) {
        _error = absensiResponse.message;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Siswa'),
      ),
      body: _isLoading
          ? const LoadingWidget()
          : _error != null
              ? CustomErrorWidget(message: _error!, onRetry: _loadData)
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Student Info Card
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
                              CircleAvatar(
                                radius: 40,
                                backgroundColor: Colors.white.withOpacity(0.2),
                                child: Text(
                                  widget.siswa.nama[0].toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                widget.siswa.nama,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'NIS: ${widget.siswa.nis}',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Kelas ${widget.siswa.kelas?.kelas ?? '-'}',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Statistics
                        if (_statistics != null) ...[
                          const Text(
                            'Statistik Kehadiran',
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
                                  title: 'Hadir',
                                  value: '${_statistics!['hadir'] ?? 0}',
                                  subtitle: '${((_statistics!['persentase_hadir'] ?? 0) as num).toStringAsFixed(1)}%',
                                  icon: Icons.check_circle,
                                  color: AppColors.statusHadir,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: StatCard(
                                  title: 'Izin',
                                  value: '${_statistics!['izin'] ?? 0}',
                                  subtitle: 'hari',
                                  icon: Icons.assignment,
                                  color: AppColors.statusIzin,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: StatCard(
                                  title: 'Sakit',
                                  value: '${_statistics!['sakit'] ?? 0}',
                                  subtitle: 'hari',
                                  icon: Icons.local_hospital,
                                  color: AppColors.statusSakit,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: StatCard(
                                  title: 'Alfa',
                                  value: '${_statistics!['alfa'] ?? 0}',
                                  subtitle: 'hari',
                                  icon: Icons.cancel,
                                  color: AppColors.statusAlfa,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Recent Attendance
                        const Text(
                          'Riwayat Absensi',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (_absensiList.isEmpty)
                          const EmptyWidget(message: 'Belum ada riwayat absensi')
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _absensiList.length,
                            itemBuilder: (context, index) {
                              final absensi = _absensiList[index];
                              return _buildAbsensiItem(absensi);
                            },
                          ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildAbsensiItem(Absensi absensi) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.calendar_today,
              size: 20,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  absensi.tanggal,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (absensi.keterangan != null && absensi.keterangan!.isNotEmpty)
                  Text(
                    absensi.keterangan!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          StatusBadge(status: absensi.status),
        ],
      ),
    );
  }
}
