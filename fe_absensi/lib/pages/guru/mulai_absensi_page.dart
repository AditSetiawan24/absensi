import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../models/siswa_model.dart';
import '../../services/data_service.dart';
import '../../services/absensi_service.dart';
import '../../widgets/common_widgets.dart';
import 'package:intl/intl.dart';

class MulaiAbsensiPage extends StatefulWidget {
  const MulaiAbsensiPage({super.key});

  @override
  State<MulaiAbsensiPage> createState() => _MulaiAbsensiPageState();
}

class _MulaiAbsensiPageState extends State<MulaiAbsensiPage> {
  List<Kelas> _kelasList = [];
  List<Siswa> _siswaList = [];
  Map<String, String> _absensiStatus = {}; // nis -> status
  Map<String, String> _keterangan = {}; // nis -> keterangan
  
  Kelas? _selectedKelas;
  bool _isLoadingKelas = true;
  bool _isLoadingSiswa = false;
  bool _isSubmitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadKelas();
  }

  Future<void> _loadKelas() async {
    setState(() {
      _isLoadingKelas = true;
      _error = null;
    });

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final nip = auth.user?.nip ?? '';
    
    final response = await KelasService.getByGuru(nip);

    setState(() {
      _isLoadingKelas = false;
      if (response.success && response.data != null) {
        _kelasList = response.data!;
        if (_kelasList.isNotEmpty) {
          _selectedKelas = _kelasList.first;
          _loadSiswa();
        }
      } else {
        _error = response.message;
      }
    });
  }

  Future<void> _loadSiswa() async {
    if (_selectedKelas == null) return;

    setState(() {
      _isLoadingSiswa = true;
      _error = null;
    });

    final response = await SiswaService.getByKelas(_selectedKelas!.idKelas);

    setState(() {
      _isLoadingSiswa = false;
      if (response.success && response.data != null) {
        _siswaList = response.data!;
        // Initialize all students as "hadir" by default
        for (var siswa in _siswaList) {
          _absensiStatus[siswa.nis] = AppConstants.statusHadir;
        }
      } else {
        _error = response.message;
      }
    });
  }

  void _updateStatus(String nis, String status) {
    setState(() {
      _absensiStatus[nis] = status;
    });
  }

  void _updateKeterangan(String nis, String keterangan) {
    _keterangan[nis] = keterangan;
  }

  Future<void> _submitAbsensi() async {
    if (_siswaList.isEmpty || _selectedKelas == null) return;

    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    
    // Check if attendance already exists for today
    final existingResponse = await AbsensiService.getByKelas(
      _selectedKelas!.idKelas,
      date: today,
    );
    
    if (existingResponse.success && existingResponse.data != null && existingResponse.data!.isNotEmpty) {
      // Show confirmation dialog
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Absensi Sudah Ada'),
          content: Text(
            'Sudah ada ${existingResponse.data!.length} data absensi untuk hari ini. Apakah Anda ingin mengganti data yang sudah ada?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: const Text('Ganti'),
            ),
          ],
        ),
      );
      
      if (confirm != true) return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final auth = Provider.of<AuthProvider>(context, listen: false);

    final absensiList = _siswaList.map((siswa) {
      return {
        'nis': siswa.nis,
        'nip': auth.user?.nip ?? '',
        'tanggal': today,
        'status_kehadiran': _absensiStatus[siswa.nis] ?? AppConstants.statusHadir,
        'keterangan': _keterangan[siswa.nis] ?? '',
      };
    }).toList();

    final response = await AbsensiService.createBulk(absensiList);

    setState(() {
      _isSubmitting = false;
    });

    if (response.success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Absensi berhasil disimpan'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mulai Absensi'),
        actions: [
          TextButton.icon(
            onPressed: _isSubmitting ? null : _submitAbsensi,
            icon: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.check, color: Colors.white),
            label: Text(
              'Simpan',
              style: TextStyle(
                color: _isSubmitting ? Colors.grey : Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Date and Class Selection
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[50],
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('EEEE, d MMMM yyyy', 'id').format(DateTime.now()),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (_isLoadingKelas)
                  const CircularProgressIndicator()
                else if (_kelasList.isNotEmpty)
                  CustomDropdown<Kelas>(
                    label: 'Pilih Kelas',
                    value: _selectedKelas,
                    items: _kelasList
                        .map((k) => DropdownMenuItem(
                              value: k,
                              child: Text('Kelas ${k.kelas}'),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedKelas = value;
                        _siswaList = [];
                        _absensiStatus = {};
                        _keterangan = {};
                      });
                      _loadSiswa();
                    },
                  ),
              ],
            ),
          ),

          // Student List
          Expanded(
            child: _isLoadingSiswa
                ? const LoadingWidget()
                : _error != null
                    ? CustomErrorWidget(
                        message: _error!,
                        onRetry: _loadSiswa,
                      )
                    : _siswaList.isEmpty
                        ? const EmptyWidget(
                            message: 'Tidak ada siswa di kelas ini',
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _siswaList.length,
                            itemBuilder: (context, index) {
                              final siswa = _siswaList[index];
                              return _buildSiswaCard(siswa, index + 1);
                            },
                          ),
          ),

          // Summary Footer
          if (_siswaList.isNotEmpty)
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
                  _buildSummaryItem(
                    'Hadir',
                    _absensiStatus.values.where((s) => s == AppConstants.statusHadir).length,
                    AppColors.statusHadir,
                  ),
                  _buildSummaryItem(
                    'Izin',
                    _absensiStatus.values.where((s) => s == AppConstants.statusIzin).length,
                    AppColors.statusIzin,
                  ),
                  _buildSummaryItem(
                    'Sakit',
                    _absensiStatus.values.where((s) => s == AppConstants.statusSakit).length,
                    AppColors.statusSakit,
                  ),
                  _buildSummaryItem(
                    'Alfa',
                    _absensiStatus.values.where((s) => s == AppConstants.statusAlfa).length,
                    AppColors.statusAlfa,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSiswaCard(Siswa siswa, int number) {
    final currentStatus = _absensiStatus[siswa.nis] ?? AppConstants.statusHadir;
    
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
      child: Column(
        children: [
          Row(
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
                      siswa.nama,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'NIS: ${siswa.nis}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStatusButton(siswa.nis, AppConstants.statusHadir, 'Hadir', currentStatus),
              const SizedBox(width: 8),
              _buildStatusButton(siswa.nis, AppConstants.statusIzin, 'Izin', currentStatus),
              const SizedBox(width: 8),
              _buildStatusButton(siswa.nis, AppConstants.statusSakit, 'Sakit', currentStatus),
              const SizedBox(width: 8),
              _buildStatusButton(siswa.nis, AppConstants.statusAlfa, 'Alfa', currentStatus),
            ],
          ),
          if (currentStatus != AppConstants.statusHadir) ...[
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                hintText: 'Keterangan (opsional)',
                isDense: true,
                contentPadding: const EdgeInsets.all(12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) => _updateKeterangan(siswa.nis, value),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusButton(String nis, String status, String label, String currentStatus) {
    final isSelected = currentStatus == status;
    Color color;
    
    switch (status) {
      case AppConstants.statusHadir:
        color = AppColors.statusHadir;
        break;
      case AppConstants.statusIzin:
        color = AppColors.statusIzin;
        break;
      case AppConstants.statusSakit:
        color = AppColors.statusSakit;
        break;
      case AppConstants.statusAlfa:
        color = AppColors.statusAlfa;
        break;
      default:
        color = Colors.grey;
    }

    return Expanded(
      child: GestureDetector(
        onTap: () => _updateStatus(nis, status),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? color : color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? color : color.withOpacity(0.3),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, int count, Color color) {
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
