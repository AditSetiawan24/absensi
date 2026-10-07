import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../models/absensi_model.dart';
import '../../services/absensi_service.dart';
import '../../widgets/common_widgets.dart';

class EditAbsensiPage extends StatefulWidget {
  final Absensi absensi;

  const EditAbsensiPage({super.key, required this.absensi});

  @override
  State<EditAbsensiPage> createState() => _EditAbsensiPageState();
}

class _EditAbsensiPageState extends State<EditAbsensiPage> {
  final _formKey = GlobalKey<FormState>();
  final _keteranganController = TextEditingController();
  
  late String _selectedStatus;
  String? _filePath;
  String? _fileName;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.absensi.status;
    _keteranganController.text = widget.absensi.keterangan ?? '';
    _fileName = widget.absensi.fileSurat;
  }

  @override
  void dispose() {
    _keteranganController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );

    if (result != null) {
      setState(() {
        _filePath = result.files.single.path;
        _fileName = result.files.single.name;
      });
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final response = await AbsensiService.update(
      idAbsensi: widget.absensi.idAbsensi!,
      statusKehadiran: _selectedStatus,
      keterangan: _keteranganController.text.trim(),
    );

    setState(() {
      _isLoading = false;
    });

    if (response.success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Absensi berhasil diupdate'),
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
        title: const Text('Edit Absensi'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Student Info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.primary,
                      child: Text(
                        (widget.absensi.namaSiswa ?? 'S')[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.absensi.namaSiswa ?? '-',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'NIS: ${widget.absensi.nis}',
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
              ),
              const SizedBox(height: 24),

              // Status Selection
              const Text(
                'Status Kehadiran',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildStatusButton(AppConstants.statusHadir, 'Hadir', AppColors.statusHadir),
                  const SizedBox(width: 8),
                  _buildStatusButton(AppConstants.statusIzin, 'Izin', AppColors.statusIzin),
                  const SizedBox(width: 8),
                  _buildStatusButton(AppConstants.statusSakit, 'Sakit', AppColors.statusSakit),
                  const SizedBox(width: 8),
                  _buildStatusButton(AppConstants.statusAlfa, 'Alfa', AppColors.statusAlfa),
                ],
              ),
              const SizedBox(height: 24),

              // Keterangan
              CustomTextField(
                controller: _keteranganController,
                label: 'Keterangan',
                hint: 'Masukkan keterangan (opsional)',
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // File Upload
              if (_selectedStatus == AppConstants.statusIzin ||
                  _selectedStatus == AppConstants.statusSakit) ...[
                const Text(
                  'Surat Keterangan (Opsional)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: _pickFile,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.border,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          _fileName != null ? Icons.file_present : Icons.cloud_upload_outlined,
                          size: 48,
                          color: _fileName != null ? AppColors.primary : AppColors.textSecondary,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _fileName ?? 'Tap untuk upload file',
                          style: TextStyle(
                            color: _fileName != null ? AppColors.textPrimary : AppColors.textSecondary,
                          ),
                        ),
                        if (_fileName == null)
                          const Text(
                            'JPG, PNG, atau PDF (Max 2MB)',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Save Button
              CustomButton(
                text: 'Simpan Perubahan',
                onPressed: _saveChanges,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusButton(String status, String label, Color color) {
    final isSelected = _selectedStatus == status;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedStatus = status;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
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
}
