import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../models/absensi_model.dart';
import '../../models/siswa_model.dart';
import '../../services/absensi_service.dart';
import '../../services/data_service.dart';
import '../../widgets/common_widgets.dart';
import 'mulai_absensi_page.dart';
import 'edit_absensi_page.dart';

class AbsensiPage extends StatefulWidget {
  const AbsensiPage({super.key});

  @override
  State<AbsensiPage> createState() => _AbsensiPageState();
}

class _AbsensiPageState extends State<AbsensiPage> {
  List<Absensi> _absensiList = [];
  List<Kelas> _kelasList = [];
  Kelas? _selectedKelas;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadKelas();
  }

  Future<void> _loadKelas() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final nip = auth.user?.nip ?? '';
    
    final response = await KelasService.getByGuru(nip);

    if (response.success && response.data != null) {
      setState(() {
        _kelasList = response.data!;
        if (_kelasList.isNotEmpty) {
          _selectedKelas = _kelasList.first;
        }
      });
      _loadAbsensi();
    }
  }

  Future<void> _loadAbsensi() async {
    if (_selectedKelas == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final response = await AbsensiService.getByKelas(
      _selectedKelas!.idKelas,
      date: dateStr,
    );

    setState(() {
      _isLoading = false;
      if (response.success && response.data != null) {
        _absensiList = response.data!;
      } else {
        _error = response.message;
      }
    });
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadAbsensi();
    }
  }

  Future<void> _deleteAbsensi(Absensi absensi) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Absensi'),
        content: Text('Yakin ingin menghapus absensi ${absensi.namaSiswa ?? absensi.nis}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirm == true && absensi.idAbsensi != null) {
      final response = await AbsensiService.delete(absensi.idAbsensi!);
      if (response.success) {
        _loadAbsensi();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Absensi berhasil dihapus'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Absensi'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[50],
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: _selectDate,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                DateFormat('d MMM yyyy').format(_selectedDate),
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (_kelasList.isNotEmpty)
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<Kelas>(
                              value: _selectedKelas,
                              isExpanded: true,
                              items: _kelasList
                                  .map((k) => DropdownMenuItem(
                                        value: k,
                                        child: Text('Kelas ${k.kelas}'),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedKelas = value;
                                });
                                _loadAbsensi();
                              },
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Absensi List
          Expanded(
            child: _isLoading
                ? const LoadingWidget()
                : _error != null
                    ? CustomErrorWidget(
                        message: _error!,
                        onRetry: _loadAbsensi,
                      )
                    : _absensiList.isEmpty
                        ? EmptyWidget(
                            message: 'Belum ada data absensi untuk tanggal ini',
                            actionText: 'Mulai Absensi',
                            onAction: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MulaiAbsensiPage(),
                                ),
                              ).then((_) => _loadAbsensi());
                            },
                          )
                        : RefreshIndicator(
                            onRefresh: _loadAbsensi,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _absensiList.length,
                              itemBuilder: (context, index) {
                                final absensi = _absensiList[index];
                                return _buildAbsensiCard(absensi, index + 1);
                              },
                            ),
                          ),
          ),

          // Summary
          if (_absensiList.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSummary('Hadir', AppConstants.statusHadir, AppColors.statusHadir),
                  _buildSummary('Izin', AppConstants.statusIzin, AppColors.statusIzin),
                  _buildSummary('Sakit', AppConstants.statusSakit, AppColors.statusSakit),
                  _buildSummary('Alfa', AppConstants.statusAlfa, AppColors.statusAlfa),
                ],
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MulaiAbsensiPage()),
          ).then((_) => _loadAbsensi());
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Absensi', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildAbsensiCard(Absensi absensi, int number) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '$number',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  absensi.siswa?.nama ?? absensi.namaSiswa ?? 'Siswa ${absensi.nis}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'NIS: ${absensi.nis}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                if (absensi.keterangan != null && absensi.keterangan!.isNotEmpty)
                  Text(
                    absensi.keterangan!,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          StatusBadge(status: absensi.status),
          const SizedBox(width: 8),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 20),
                    SizedBox(width: 8),
                    Text('Edit'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 20, color: AppColors.error),
                    SizedBox(width: 8),
                    Text('Hapus', style: TextStyle(color: AppColors.error)),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'edit') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditAbsensiPage(absensi: absensi),
                  ),
                ).then((_) => _loadAbsensi());
              } else if (value == 'delete') {
                _deleteAbsensi(absensi);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(String label, String status, Color color) {
    final count = _absensiList.where((a) => a.status == status).length;
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              '$count',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 18,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
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
}
