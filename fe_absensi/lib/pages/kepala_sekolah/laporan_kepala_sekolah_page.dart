import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart' as xl;
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../models/laporan_model.dart';
import '../../models/siswa_model.dart';
import '../../services/laporan_service.dart';
import '../../services/data_service.dart';
import '../../widgets/common_widgets.dart';

class LaporanKepalaSekolahPage extends StatefulWidget {
  const LaporanKepalaSekolahPage({super.key});

  @override
  State<LaporanKepalaSekolahPage> createState() => _LaporanKepalaSekolahPageState();
}

class _LaporanKepalaSekolahPageState extends State<LaporanKepalaSekolahPage> {
  List<Laporan> _laporanList = [];
  List<Kelas> _kelasList = [];
  
  Kelas? _selectedKelas;
  String? _selectedTahunAjar;
  String? _selectedSemester;
  
  bool _isLoading = true;
  bool _isDownloading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadKelas();
    _loadLaporan();
  }

  Future<void> _loadKelas() async {
    final response = await KelasService.getAll();
    if (response.success && response.data != null) {
      setState(() {
        _kelasList = response.data!;
      });
    }
  }

  Future<void> _loadLaporan() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final response = await LaporanService.getAll();

    setState(() {
      _isLoading = false;
      if (response.success && response.data != null) {
        _laporanList = response.data!;
      } else {
        _error = response.message;
      }
    });
  }

  List<Laporan> get _filteredLaporan {
    return _laporanList.where((l) {
      if (_selectedKelas != null && l.idKelas != _selectedKelas!.idKelas) {
        return false;
      }
      if (_selectedTahunAjar != null && l.tahunAjar != _selectedTahunAjar) {
        return false;
      }
      if (_selectedSemester != null && l.semester != _selectedSemester) {
        return false;
      }
      return true;
    }).toList();
  }

  List<String> get _tahunAjarOptions {
    return _laporanList
        .map((l) => l.tahunAjar)
        .where((t) => t != null)
        .cast<String>()
        .toSet()
        .toList();
  }

  Future<void> _downloadPdf(Laporan laporan) async {
    setState(() {
      _isDownloading = true;
    });

    try {
      final pdf = pw.Document();
      
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(
                  child: pw.Text(
                    'LAPORAN KEHADIRAN SISWA',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.Center(
                  child: pw.Text(AppConstants.schoolName),
                ),
                pw.SizedBox(height: 20),
                pw.Divider(),
                pw.SizedBox(height: 20),
                _buildPdfInfo('Tahun Ajaran', laporan.tahunAjar ?? '-'),
                _buildPdfInfo('Semester', laporan.semester),
                _buildPdfInfo('Kelas', laporan.kelas?.kelas ?? '-'),
                pw.SizedBox(height: 20),
                pw.Text(
                  'Rekap Kehadiran:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 10),
                pw.Table.fromTextArray(
                  headers: ['Status', 'Jumlah'],
                  data: [
                    ['Hadir', '${laporan.hadir ?? 0}'],
                    ['Izin', '${laporan.izin ?? 0}'],
                    ['Sakit', '${laporan.sakit ?? 0}'],
                    ['Alfa', '${laporan.alfa ?? 0}'],
                  ],
                ),
                pw.SizedBox(height: 30),
                pw.Text(
                  'Tanggal Cetak: ${DateFormat('d MMMM yyyy', 'id').format(DateTime.now())}',
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ],
            );
          },
        ),
      );

      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/laporan_${laporan.idLaporan}.pdf');
      await file.writeAsBytes(await pdf.save());

      setState(() {
        _isDownloading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF disimpan: ${file.path}'),
            backgroundColor: AppColors.success,
            action: SnackBarAction(
              label: 'Buka',
              textColor: Colors.white,
              onPressed: () => OpenFilex.open(file.path),
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isDownloading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuat PDF: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  pw.Widget _buildPdfInfo(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 100,
            child: pw.Text(label),
          ),
          pw.Text(': $value'),
        ],
      ),
    );
  }

  Future<void> _downloadExcel(Laporan laporan) async {
    setState(() {
      _isDownloading = true;
    });

    try {
      final excel = xl.Excel.createExcel();
      final sheet = excel['Laporan'];

      // Header
      sheet.appendRow([
        xl.TextCellValue('LAPORAN KEHADIRAN SISWA'),
      ]);
      sheet.appendRow([
        xl.TextCellValue(AppConstants.schoolName),
      ]);
      sheet.appendRow([xl.TextCellValue('')]);
      sheet.appendRow([
        xl.TextCellValue('Tahun Ajaran'),
        xl.TextCellValue(laporan.tahunAjar ?? '-'),
      ]);
      sheet.appendRow([
        xl.TextCellValue('Semester'),
        xl.TextCellValue(laporan.semester),
      ]);
      sheet.appendRow([
        xl.TextCellValue('Kelas'),
        xl.TextCellValue(laporan.kelas?.kelas ?? '-'),
      ]);
      sheet.appendRow([xl.TextCellValue('')]);

      // Stats
      sheet.appendRow([
        xl.TextCellValue('Status'),
        xl.TextCellValue('Jumlah'),
      ]);
      sheet.appendRow([
        xl.TextCellValue('Hadir'),
        xl.IntCellValue(laporan.hadir),
      ]);
      sheet.appendRow([
        xl.TextCellValue('Izin'),
        xl.IntCellValue(laporan.izin),
      ]);
      sheet.appendRow([
        xl.TextCellValue('Sakit'),
        xl.IntCellValue(laporan.sakit),
      ]);
      sheet.appendRow([
        xl.TextCellValue('Alfa'),
        xl.IntCellValue(laporan.alfa),
      ]);

      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/laporan_${laporan.idLaporan}.xlsx');
      await file.writeAsBytes(excel.encode()!);

      setState(() {
        _isDownloading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Excel disimpan: ${file.path}'),
            backgroundColor: AppColors.success,
            action: SnackBarAction(
              label: 'Buka',
              textColor: Colors.white,
              onPressed: () => OpenFilex.open(file.path),
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isDownloading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuat Excel: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showDownloadOptions(Laporan laporan) {
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
            children: [
              const Text(
                'Download Laporan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildDownloadOption(
                      'PDF',
                      Icons.picture_as_pdf,
                      Colors.red,
                      () {
                        Navigator.pop(context);
                        _downloadPdf(laporan);
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDownloadOption(
                      'Excel',
                      Icons.table_chart,
                      Colors.green,
                      () {
                        Navigator.pop(context);
                        _downloadExcel(laporan);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDownloadOption(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 40),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Kehadiran'),
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
                            hint: const Text('Semua Kelas'),
                            items: [
                              const DropdownMenuItem<Kelas>(
                                value: null,
                                child: Text('Semua Kelas'),
                              ),
                              ..._kelasList.map((k) => DropdownMenuItem(
                                    value: k,
                                    child: Text('Kelas ${k.kelas}'),
                                  )),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedKelas = value;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedSemester,
                            isExpanded: true,
                            hint: const Text('Semester'),
                            items: [
                              const DropdownMenuItem<String>(
                                value: null,
                                child: Text('Semua'),
                              ),
                              ...AppConstants.semesterNames.map((s) => DropdownMenuItem(
                                    value: 'Semester $s',
                                    child: Text('Semester $s'),
                                  )),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedSemester = value;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (_tahunAjarOptions.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedTahunAjar,
                        isExpanded: true,
                        hint: const Text('Semua Tahun Ajaran'),
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('Semua Tahun Ajaran'),
                          ),
                          ..._tahunAjarOptions.map((t) => DropdownMenuItem(
                                value: t,
                                child: Text('TA $t'),
                              )),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedTahunAjar = value;
                          });
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Laporan List
          Expanded(
            child: _isLoading
                ? const LoadingWidget()
                : _error != null
                    ? CustomErrorWidget(
                        message: _error!,
                        onRetry: _loadLaporan,
                      )
                    : _filteredLaporan.isEmpty
                        ? const EmptyWidget(
                            message: 'Tidak ada laporan yang ditemukan',
                          )
                        : Stack(
                            children: [
                              RefreshIndicator(
                                onRefresh: _loadLaporan,
                                child: ListView.builder(
                                  padding: const EdgeInsets.all(16),
                                  itemCount: _filteredLaporan.length,
                                  itemBuilder: (context, index) {
                                    final laporan = _filteredLaporan[index];
                                    return _buildLaporanCard(laporan);
                                  },
                                ),
                              ),
                              if (_isDownloading)
                                Container(
                                  color: Colors.black.withOpacity(0.3),
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                            ],
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildLaporanCard(Laporan laporan) {
    final totalKehadiran = (laporan.hadir ?? 0) + (laporan.izin ?? 0) +
        (laporan.sakit ?? 0) + (laporan.alfa ?? 0);
    final persentaseHadir = totalKehadiran > 0
        ? ((laporan.hadir ?? 0) / totalKehadiran * 100)
        : 0.0;
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.description, color: isDark ? AppColors.primaryLight : AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kelas ${laporan.kelas?.kelas ?? '-'}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.getTextPrimary(context),
                      ),
                    ),
                    Text(
                      '${laporan.semester} - TA ${laporan.tahunAjar ?? '-'}',
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
          const SizedBox(height: 12),
          Row(
            children: [
              _buildMiniStat('Hadir', laporan.hadir ?? 0, AppColors.statusHadir),
              _buildMiniStat('Izin', laporan.izin ?? 0, AppColors.statusIzin),
              _buildMiniStat('Sakit', laporan.sakit ?? 0, AppColors.statusSakit),
              _buildMiniStat('Alfa', laporan.alfa ?? 0, AppColors.statusAlfa),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => _showDownloadOptions(laporan),
                icon: const Icon(Icons.download, size: 18),
                label: const Text('Download'),
              ),
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

  Color _getPercentageColor(double percentage) {
    if (percentage >= 90) return AppColors.success;
    if (percentage >= 75) return AppColors.warning;
    return AppColors.error;
  }
}
