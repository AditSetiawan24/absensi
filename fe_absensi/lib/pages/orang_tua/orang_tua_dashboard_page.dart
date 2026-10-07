import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../models/dashboard_model.dart';
import '../../services/dashboard_service.dart';
import '../../widgets/common_widgets.dart';

class OrangTuaDashboardPage extends StatefulWidget {
  const OrangTuaDashboardPage({super.key});

  @override
  State<OrangTuaDashboardPage> createState() => _OrangTuaDashboardPageState();
}

class _OrangTuaDashboardPageState extends State<OrangTuaDashboardPage> {
  OrangTuaDashboard? _dashboard;
  bool _isLoading = true;
  String? _error;
  
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  
  // Map for attendance markers
  Map<DateTime, String?> _attendanceMap = {};

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final idOrtu = int.parse(auth.user?.id ?? '0');
    
    final response = await DashboardService.getOrangTuaDashboard(idOrtu);

    setState(() {
      _isLoading = false;
      if (response.success && response.data != null) {
        _dashboard = response.data;
        _buildAttendanceMap();
      } else {
        _error = response.message;
      }
    });
  }

  void _buildAttendanceMap() {
    _attendanceMap = {};
    if (_dashboard?.siswaList != null) {
      for (var siswa in _dashboard!.siswaList) {
        for (var calendar in siswa.calendar) {
          final date = DateTime.parse(calendar.date);
          final normalizedDate = DateTime(date.year, date.month, date.day);
          _attendanceMap[normalizedDate] = calendar.status;
        }
      }
    }
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case AppConstants.statusHadir:
        return AppColors.statusHadir;
      case AppConstants.statusIzin:
        return AppColors.statusIzin;
      case AppConstants.statusSakit:
        return AppColors.statusSakit;
      case AppConstants.statusAlfa:
        return AppColors.statusAlfa;
      default:
        return Colors.grey;
    }
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
                        (auth.user?.nama ?? 'O')[0].toUpperCase(),
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
                            auth.user?.nama ?? 'Orang Tua',
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Children Cards
        if (_dashboard!.siswaList.isNotEmpty) ...[
          const Text(
            'Data Anak',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ..._dashboard!.siswaList.map((siswa) => _buildChildCard(siswa)),
          const SizedBox(height: 24),
        ],

        // Calendar
        const Text(
          'Kalender Kehadiran',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
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
          child: TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              _showDayDetail(selectedDay);
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            calendarStyle: const CalendarStyle(
              outsideDaysVisible: false,
              weekendTextStyle: TextStyle(color: Colors.red),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: true,
              titleCentered: true,
            ),
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                final normalizedDate = DateTime(date.year, date.month, date.day);
                final status = _attendanceMap[normalizedDate];
                if (status != null) {
                  return Positioned(
                    bottom: 1,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _getStatusColor(status),
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                }
                return null;
              },
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildLegend('Hadir', AppColors.statusHadir),
            _buildLegend('Izin', AppColors.statusIzin),
            _buildLegend('Sakit', AppColors.statusSakit),
            _buildLegend('Alfa', AppColors.statusAlfa),
          ],
        ),
        const SizedBox(height: 24),

        // Statistics
        if (_dashboard!.siswaList.isNotEmpty) ...[
          const Text(
            'Statistik Bulan Ini',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildMonthlyStats(),
        ],
      ],
    );
  }

  Widget _buildChildCard(SiswaAbsensiData siswa) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
            radius: 30,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: Text(
              siswa.nama[0].toUpperCase(),
              style: const TextStyle(
                fontSize: 24,
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
                  siswa.nama,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'NIS: ${siswa.nis}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                  ),
                ),
                Text(
                  'Kelas: ${siswa.kelas}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${siswa.persentaseHadir.toStringAsFixed(0)}%',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlyStats() {
    // Calculate monthly stats from calendar data
    int hadir = 0;
    int izin = 0;
    int sakit = 0;
    int alfa = 0;

    final now = DateTime.now();
    
    _attendanceMap.forEach((date, status) {
      if (date.year == now.year && date.month == now.month) {
        switch (status) {
          case AppConstants.statusHadir:
            hadir++;
            break;
          case AppConstants.statusIzin:
            izin++;
            break;
          case AppConstants.statusSakit:
            sakit++;
            break;
          case AppConstants.statusAlfa:
            alfa++;
            break;
        }
      }
    });

    return Row(
      children: [
        Expanded(
          child: StatCard(
            title: 'Hadir',
            value: '$hadir',
            subtitle: 'hari',
            icon: Icons.check_circle,
            color: AppColors.statusHadir,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: StatCard(
            title: 'Izin',
            value: '$izin',
            subtitle: 'hari',
            icon: Icons.assignment,
            color: AppColors.statusIzin,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: StatCard(
            title: 'Sakit',
            value: '$sakit',
            subtitle: 'hari',
            icon: Icons.local_hospital,
            color: AppColors.statusSakit,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: StatCard(
            title: 'Alfa',
            value: '$alfa',
            subtitle: 'hari',
            icon: Icons.cancel,
            color: AppColors.statusAlfa,
          ),
        ),
      ],
    );
  }

  void _showDayDetail(DateTime day) {
    final normalizedDate = DateTime(day.year, day.month, day.day);
    final status = _attendanceMap[normalizedDate];

    if (status == null) return;

    // Find the attendance detail for this day
    String? keterangan;
    String? namaSiswa;
    
    for (var siswa in _dashboard!.siswaList) {
      for (var calendar in siswa.calendar) {
        final date = DateTime.parse(calendar.date);
        if (date.year == day.year && date.month == day.month && date.day == day.day) {
          keterangan = calendar.keterangan;
          namaSiswa = siswa.nama;
          break;
        }
      }
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    DateFormat('EEEE, d MMMM yyyy', 'id').format(day),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              if (namaSiswa != null) ...[
                Text(
                  namaSiswa,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
              ],
              Row(
                children: [
                  const Text('Status: '),
                  StatusBadge(status: status),
                ],
              ),
              if (keterangan != null && keterangan.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  'Keterangan: $keterangan',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}
