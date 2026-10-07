import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/theme/app_colors.dart';
import '../../services/data_service.dart';
import '../../services/api_service.dart';
import '../../widgets/common_widgets.dart';
import '../../models/siswa_model.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
class KelolaSiswaPage extends StatefulWidget {
  const KelolaSiswaPage({super.key});

  @override
  State<KelolaSiswaPage> createState() => _KelolaSiswaPageState();
}

class _KelolaSiswaPageState extends State<KelolaSiswaPage> {
  List<Siswa> _siswaList = [];
  bool _isLoading = true;
  String? _error;
  int? _idKelas;

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

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final nip = auth.user?.nip ?? '';
    
    // Get class ID for this teacher first
    final kelasResponse = await KelasService.getByGuru(nip);
    
    if (kelasResponse.success && kelasResponse.data != null && kelasResponse.data!.isNotEmpty) {
      _idKelas = kelasResponse.data!.first.idKelas;
      
      // Get students
      final siswaResponse = await SiswaService.getByKelas(_idKelas!);
      
      if (mounted) {
        setState(() {
          _isLoading = false;
          if (siswaResponse.success && siswaResponse.data != null) {
            _siswaList = siswaResponse.data!;
          } else {
            _error = siswaResponse.message;
          }
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = "Anda belum diassign ke kelas manapun.";
        });
      }
    }
  }

  Future<void> _importExcel() async {
    if (_idKelas == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anda belum memiliki kelas aktif.')),
      );
      return;
    }

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls', 'csv'],
        withData: kIsWeb,
      );

      if (result != null) {
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Center(child: CircularProgressIndicator()),
          );
        }

        ApiResponse response;
        if (kIsWeb) {
          response = await SiswaService.importExcelWeb(
            result.files.single.bytes!,
            result.files.single.name,
            _idKelas!,
          );
        } else if (result.files.single.path != null) {
          response = await SiswaService.importExcel(
            result.files.single.path!, 
            _idKelas!
          );
        } else {
          if (mounted) Navigator.pop(context);
          return;
        }
        
        if (mounted) {
          Navigator.pop(context); // close loading
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message),
              backgroundColor: response.success ? Colors.green : AppColors.error,
              duration: const Duration(seconds: 4),
            ),
          );

          if (response.success) {
            _loadData();
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan saat import: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _showSiswaDialog({Siswa? siswa}) async {
    final isEdit = siswa != null;
    final nisController = TextEditingController(text: siswa?.nis);
    final namaController = TextEditingController(text: siswa?.nama);
    final alamatController = TextEditingController(text: siswa?.alamat);
    String selectedGender = siswa?.gender ?? 'Laki - Laki';
    final tglLahirController = TextEditingController(text: siswa?.tanggalLahir);
    bool isSubmitting = false;
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(isEdit ? 'Edit Siswa' : 'Tambah Siswa'),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomTextField(
                      controller: nisController,
                      label: 'NIS',
                      hint: 'Masukkan NIS',
                      enabled: !isEdit,
                      validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: namaController,
                      label: 'Nama Lengkap',
                      hint: 'Masukkan nama siswa',
                      validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedGender,
                      decoration: InputDecoration(
                        labelText: 'Jenis Kelamin',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: ['Laki - Laki', 'Perempuan'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                      onChanged: (v) => setDialogState(() => selectedGender = v!),
                    ),
                    const SizedBox(height: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tanggal Lahir',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: tglLahirController,
                          readOnly: true,
                          validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                          decoration: const InputDecoration(
                            hintText: 'YYYY-MM-DD',
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          onTap: () async {
                            DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1900),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) {
                              setDialogState(() {
                                tglLahirController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: alamatController,
                      label: 'Alamat',
                      hint: 'Masukkan alamat',
                      maxLines: 2,
                      validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: isSubmitting ? null : () async {
                  if (formKey.currentState!.validate() && _idKelas != null) {
                    setDialogState(() => isSubmitting = true);

                    final data = {
                      'nis': nisController.text,
                      'nama': namaController.text,
                      'gender': selectedGender,
                      'tanggal_lahir': tglLahirController.text,
                      'alamat': alamatController.text,
                      'id_kelas': _idKelas,
                    };

                    ApiResponse response;
                    if (isEdit) {
                      response = await SiswaService.update(siswa.nis, data);
                    } else {
                      response = await SiswaService.create(data);
                    }

                    if (mounted) {
                      setDialogState(() => isSubmitting = false);
                      
                      if (response.success) {
                        Navigator.pop(context); // close dialog only on success
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(response.message),
                            backgroundColor: AppColors.success,
                          ),
                        );
                        _loadData();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(response.message),
                            backgroundColor: AppColors.error,
                          ),
                        );
                      }
                    }
                  }
                },
                child: isSubmitting 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
                  : const Text('Simpan'),
              ),
            ],
          );
        }
      ),
    );
  }

  Future<void> _deleteSiswa(Siswa siswa) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Siswa?'),
        content: Text('Yakin ingin menghapus data siswa ${siswa.nama}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(child: CircularProgressIndicator()),
        );
      }

      final response = await SiswaService.delete(siswa.nis);

      if (mounted) {
        Navigator.pop(context); // close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: response.success ? AppColors.success : AppColors.error,
          ),
        );

        if (response.success) {
          _loadData();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Data Siswa'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'addBtn',
            onPressed: () => _showSiswaDialog(),
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 16),
          FloatingActionButton.extended(
            heroTag: 'importBtn',
            onPressed: _importExcel,
            icon: const Icon(Icons.upload_file),
            label: const Text('Import Excel'),
            backgroundColor: AppColors.primary,
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget()
          : _error != null
              ? CustomErrorWidget(message: _error!, onRetry: _loadData)
              : _siswaList.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.group_off, size: 64, color: AppColors.textSecondary),
                          const SizedBox(height: 16),
                          const Text(
                            'Belum ada siswa di kelas Anda',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _importExcel,
                            icon: const Icon(Icons.upload_file),
                            label: const Text('Import dari Excel'),
                          )
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadData,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16).copyWith(bottom: 80),
                        itemCount: _siswaList.length,
                        itemBuilder: (context, index) {
                          final siswa = _siswaList[index];
                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppColors.primary.withOpacity(0.1),
                                child: Text(
                                  siswa.nama.isNotEmpty ? siswa.nama[0].toUpperCase() : '?',
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                siswa.nama,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text('NIS: ${siswa.nis}'),
                              trailing: PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    _showSiswaDialog(siswa: siswa);
                                  } else if (value == 'delete') {
                                    _deleteSiswa(siswa);
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit, size: 20, color: Colors.blue),
                                        SizedBox(width: 8),
                                        Text('Edit Siswa'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete, size: 20, color: AppColors.error),
                                        SizedBox(width: 8),
                                        Text('Hapus Siswa', style: TextStyle(color: AppColors.error)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
