import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:excel/excel.dart' as xl;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../models/laporan_model.dart';
import '../../models/siswa_model.dart';
import '../../services/laporan_service.dart';
import '../../services/data_service.dart';
import '../../widgets/common_widgets.dart';
import 'rekap_bulanan_page.dart';

class LaporanGuruPage extends StatefulWidget {
  const LaporanGuruPage({super.key});

  @override
  State<LaporanGuruPage> createState() => _LaporanGuruPageState();
}

class _LaporanGuruPageState extends State<LaporanGuruPage> {
  List<Laporan> _laporanList = [];
  List<Kelas> _kelasList = [];
  Kelas? _selectedKelas;
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _error;

  // Form fields for create/edit
  final _tahunAjarController = TextEditingController();
  final _periodeAwalController = TextEditingController();
  final _periodeAkhirController = TextEditingController();
  String _selectedSemester = 'Ganjil';

  @override
  void initState() {
    super.initState();
    _loadKelas();
  }

  @override
  void dispose() {
    _tahunAjarController.dispose();
    _periodeAwalController.dispose();
    _periodeAkhirController.dispose();
    super.dispose();
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
      _loadLaporan();
    } else {
      setState(() {
        _isLoading = false;
        _error = 'Gagal memuat data kelas';
      });
    }
  }

  Future<void> _loadLaporan() async {
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

    final response = await LaporanService.getByKelas(_selectedKelas!.idKelas);

    setState(() {
      _isLoading = false;
      if (response.success && response.data != null) {
        _laporanList = response.data!;
      } else {
        _error = response.message;
      }
    });
  }

  Future<void> _submitLaporan() async {
    if (_selectedKelas == null || _tahunAjarController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lengkapi semua field'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final nip = auth.user?.nip ?? '';

    if (nip.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('NIP guru tidak ditemukan'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final response = await LaporanService.createFromAbsensi(
      tahunAjar: _tahunAjarController.text.trim(),
      semester: _selectedSemester == 'Ganjil' ? 1 : 2,
      kelas: _selectedKelas!.kelas,
      nip: nip,
    );

    setState(() {
      _isSubmitting = false;
    });

    if (response.success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Laporan berhasil dibuat'),
          backgroundColor: AppColors.success,
        ),
      );
      _loadLaporan();
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

  Future<void> _deleteLaporan(Laporan laporan) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Laporan'),
        content: Text('Yakin ingin menghapus laporan ${laporan.semester}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true || laporan.idLaporan == null) return;

    setState(() => _isSubmitting = true);

    final response = await LaporanService.delete(laporan.idLaporan!);

    setState(() => _isSubmitting = false);

    if (response.success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Laporan berhasil dihapus'),
          backgroundColor: AppColors.success,
        ),
      );
      _loadLaporan();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _submitLaporanToServer(Laporan laporan) async {
    if (laporan.idLaporan == null) return;

    setState(() => _isSubmitting = true);

    final response = await LaporanService.submit(laporan.idLaporan!);

    setState(() => _isSubmitting = false);

    if (response.success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Laporan berhasil disubmit'),
          backgroundColor: AppColors.success,
        ),
      );
      _loadLaporan();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _unsubmitLaporan(Laporan laporan) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Batal Submit'),
        content: const Text('Yakin ingin membatalkan submit laporan ini? Laporan akan kembali ke status draft.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Tidak'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.warning),
            child: const Text('Ya, Batalkan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true || laporan.idLaporan == null) return;

    setState(() => _isSubmitting = true);

    final response = await LaporanService.unsubmit(laporan.idLaporan!);

    setState(() => _isSubmitting = false);

    if (response.success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Submit laporan berhasil dibatalkan'),
          backgroundColor: AppColors.success,
        ),
      );
      _loadLaporan();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _refreshLaporanData(Laporan laporan) async {
    if (laporan.idLaporan == null) return;

    setState(() => _isSubmitting = true);

    final response = await LaporanService.refresh(laporan.idLaporan!);

    setState(() => _isSubmitting = false);

    if (response.success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message),
          backgroundColor: AppColors.success,
        ),
      );
      _loadLaporan();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showDownloadOptions(Laporan laporan) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
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
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.picture_as_pdf, color: Colors.red),
              ),
              title: const Text('Download PDF'),
              subtitle: const Text('Format dokumen PDF'),
              onTap: () {
                Navigator.pop(context);
                _downloadLaporan(laporan, 'pdf');
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.table_chart, color: Colors.green),
              ),
              title: const Text('Download Excel'),
              subtitle: const Text('Format spreadsheet Excel'),
              onTap: () {
                Navigator.pop(context);
                _downloadLaporan(laporan, 'excel');
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadLaporan(Laporan laporan, String format) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Membuat file ${format.toUpperCase()}...'),
        backgroundColor: AppColors.primary,
      ),
    );

    try {
      if (format == 'pdf') {
        await _generateAndPrintPdf(laporan);
      } else {
        await _generateAndSaveExcel(laporan);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuat file: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _generateAndPrintPdf(Laporan laporan) async {
    final pdf = pw.Document();
    
    final total = laporan.hadir + laporan.izin + laporan.sakit + laporan.alfa;
    final persentaseHadir = total > 0 ? (laporan.hadir / total * 100) : 0.0;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      'LAPORAN KEHADIRAN SISWA',
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      'SD Negeri Kemutung Kidul',
                      style: const pw.TextStyle(fontSize: 14),
                    ),
                    pw.SizedBox(height: 20),
                  ],
                ),
              ),
              
              // Info Laporan
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Kelas: ${_selectedKelas?.kelas ?? '-'}'),
                        pw.Text('Tahun Ajaran: ${laporan.tahunAjar ?? '-'}'),
                      ],
                    ),
                    pw.SizedBox(height: 5),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Periode: ${laporan.periodeAwal} s/d ${laporan.periodeAkhir}'),
                        pw.Text(laporan.semester),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
              
              // Statistik
              pw.Text(
                'Rekap Kehadiran:',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 10),
              
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Status', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Jumlah', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Persentase', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                    ],
                  ),
                  _buildPdfTableRow('Hadir', laporan.hadir, total),
                  _buildPdfTableRow('Izin', laporan.izin, total),
                  _buildPdfTableRow('Sakit', laporan.sakit, total),
                  _buildPdfTableRow('Alfa', laporan.alfa, total),
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('TOTAL', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('$total', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('100%', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
              
              pw.SizedBox(height: 20),
              pw.Text('Tingkat Kehadiran: ${persentaseHadir.toStringAsFixed(1)}%'),
              
              pw.SizedBox(height: 40),
              
              // Footer
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Column(
                    children: [
                      pw.Text('Kemutung Kidul, ${DateFormat('dd MMMM yyyy', 'id').format(DateTime.now())}'),
                      pw.SizedBox(height: 5),
                      pw.Text('Wali Kelas'),
                      pw.SizedBox(height: 50),
                      pw.Text('_______________________'),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    // Print atau simpan PDF
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Laporan_Kehadiran_${laporan.tahunAjar?.replaceAll('/', '-')}_${laporan.semester.replaceAll(' ', '_')}.pdf',
    );
  }

  pw.TableRow _buildPdfTableRow(String status, int value, int total) {
    final percentage = total > 0 ? (value / total * 100) : 0.0;
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(status),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text('$value'),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text('${percentage.toStringAsFixed(1)}%'),
        ),
      ],
    );
  }

  Future<void> _generateAndSaveExcel(Laporan laporan) async {
    final excel = xl.Excel.createExcel();
    final sheet = excel['Laporan Kehadiran'];
    
    // Header
    sheet.cell(xl.CellIndex.indexByString('A1')).value = xl.TextCellValue('LAPORAN KEHADIRAN SISWA');
    sheet.cell(xl.CellIndex.indexByString('A2')).value = xl.TextCellValue('SD Negeri Kemutung Kidul');
    
    // Info
    sheet.cell(xl.CellIndex.indexByString('A4')).value = xl.TextCellValue('Kelas');
    sheet.cell(xl.CellIndex.indexByString('B4')).value = xl.TextCellValue(_selectedKelas?.kelas ?? '-');
    
    sheet.cell(xl.CellIndex.indexByString('A5')).value = xl.TextCellValue('Tahun Ajaran');
    sheet.cell(xl.CellIndex.indexByString('B5')).value = xl.TextCellValue(laporan.tahunAjar ?? '-');
    
    sheet.cell(xl.CellIndex.indexByString('A6')).value = xl.TextCellValue('Semester');
    sheet.cell(xl.CellIndex.indexByString('B6')).value = xl.TextCellValue(laporan.semester);
    
    sheet.cell(xl.CellIndex.indexByString('A7')).value = xl.TextCellValue('Periode');
    sheet.cell(xl.CellIndex.indexByString('B7')).value = xl.TextCellValue('${laporan.periodeAwal} s/d ${laporan.periodeAkhir}');
    
    // Table Header
    sheet.cell(xl.CellIndex.indexByString('A9')).value = xl.TextCellValue('Status');
    sheet.cell(xl.CellIndex.indexByString('B9')).value = xl.TextCellValue('Jumlah');
    sheet.cell(xl.CellIndex.indexByString('C9')).value = xl.TextCellValue('Persentase');
    
    final total = laporan.hadir + laporan.izin + laporan.sakit + laporan.alfa;
    
    // Data rows
    sheet.cell(xl.CellIndex.indexByString('A10')).value = xl.TextCellValue('Hadir');
    sheet.cell(xl.CellIndex.indexByString('B10')).value = xl.IntCellValue(laporan.hadir);
    sheet.cell(xl.CellIndex.indexByString('C10')).value = xl.TextCellValue('${total > 0 ? (laporan.hadir / total * 100).toStringAsFixed(1) : 0}%');
    
    sheet.cell(xl.CellIndex.indexByString('A11')).value = xl.TextCellValue('Izin');
    sheet.cell(xl.CellIndex.indexByString('B11')).value = xl.IntCellValue(laporan.izin);
    sheet.cell(xl.CellIndex.indexByString('C11')).value = xl.TextCellValue('${total > 0 ? (laporan.izin / total * 100).toStringAsFixed(1) : 0}%');
    
    sheet.cell(xl.CellIndex.indexByString('A12')).value = xl.TextCellValue('Sakit');
    sheet.cell(xl.CellIndex.indexByString('B12')).value = xl.IntCellValue(laporan.sakit);
    sheet.cell(xl.CellIndex.indexByString('C12')).value = xl.TextCellValue('${total > 0 ? (laporan.sakit / total * 100).toStringAsFixed(1) : 0}%');
    
    sheet.cell(xl.CellIndex.indexByString('A13')).value = xl.TextCellValue('Alfa');
    sheet.cell(xl.CellIndex.indexByString('B13')).value = xl.IntCellValue(laporan.alfa);
    sheet.cell(xl.CellIndex.indexByString('C13')).value = xl.TextCellValue('${total > 0 ? (laporan.alfa / total * 100).toStringAsFixed(1) : 0}%');
    
    sheet.cell(xl.CellIndex.indexByString('A14')).value = xl.TextCellValue('TOTAL');
    sheet.cell(xl.CellIndex.indexByString('B14')).value = xl.IntCellValue(total);
    sheet.cell(xl.CellIndex.indexByString('C14')).value = xl.TextCellValue('100%');
    
    // Remove default sheet
    excel.delete('Sheet1');
    
    // Save file to cache directory (accessible for sharing)
    final directory = await getTemporaryDirectory();
    final fileName = 'Laporan_Kehadiran_${laporan.tahunAjar?.replaceAll('/', '-')}_${laporan.semester.replaceAll(' ', '_')}.xlsx';
    final filePath = '${directory.path}/$fileName';
    
    final fileBytes = excel.save();
    if (fileBytes != null) {
      final file = File(filePath);
      await file.writeAsBytes(fileBytes);
      
      // Use share to open the file with external apps
      await Share.shareXFiles(
        [XFile(filePath)],
        subject: 'Laporan Kehadiran ${laporan.tahunAjar}',
      );
    }
  }

  void _showCreateDialog() {
    _tahunAjarController.text = '${DateTime.now().year}/${DateTime.now().year + 1}';
    
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
                        'Buat Laporan Baru',
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
                    controller: _tahunAjarController,
                    label: 'Tahun Ajaran',
                    hint: 'Contoh: 2024/2025',
                    prefixIcon: Icons.calendar_today,
                  ),
                  const SizedBox(height: 16),
                  
                  CustomDropdown<String>(
                    label: 'Semester',
                    value: _selectedSemester,
                    items: AppConstants.semesterNames
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (value) {
                      setModalState(() {
                        _selectedSemester = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  if (_selectedKelas != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.class_, color: AppColors.primary),
                          const SizedBox(width: 12),
                          Text(
                            'Kelas ${_selectedKelas!.kelas}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),
                  
                  const Text(
                    'Catatan: Laporan akan dibuat sebagai draft. Anda dapat submit setelah memverifikasi data.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  CustomButton(
                    text: 'Buat Laporan',
                    onPressed: _submitLaporan,
                    isLoading: _isSubmitting,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Kehadiran'),
        automaticallyImplyLeading: false,
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RekapBulananPage()),
              );
            },
            icon: const Icon(Icons.calendar_month, color: Colors.white),
            label: const Text('Rekap Bulanan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[50],
            child: Row(
              children: [
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
                            _loadLaporan();
                          },
                        ),
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
                    : _laporanList.isEmpty
                        ? const EmptyWidget(
                            message: 'Belum ada laporan untuk kelas ini',
                          )
                        : RefreshIndicator(
                            onRefresh: _loadLaporan,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _laporanList.length,
                              itemBuilder: (context, index) {
                                final laporan = _laporanList[index];
                                return _buildLaporanCard(laporan);
                              },
                            ),
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateDialog,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Buat Laporan', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildLaporanCard(Laporan laporan) {
    final isSubmitted = laporan.isSubmitted;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isSubmitted 
            ? Border.all(color: AppColors.success.withOpacity(0.5), width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with status badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSubmitted 
                      ? AppColors.success.withOpacity(0.1)
                      : AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isSubmitted ? Icons.check_circle : Icons.description,
                  color: isSubmitted ? AppColors.success : AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Laporan ${laporan.semester}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        // Status Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isSubmitted 
                                ? AppColors.success.withOpacity(0.1)
                                : AppColors.warning.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isSubmitted ? 'Submitted' : 'Draft',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isSubmitted ? AppColors.success : AppColors.warning,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Tahun Ajaran ${laporan.tahunAjar ?? '-'}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    if (isSubmitted && laporan.submittedAt != null)
                      Text(
                        'Disubmit: ${_formatDate(laporan.submittedAt!)}',
                        style: const TextStyle(
                          color: AppColors.success,
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          
          // Stats
          Row(
            children: [
              Expanded(
                child: _buildLaporanStat(
                  'Hadir',
                  '${laporan.hadir}',
                  AppColors.statusHadir,
                ),
              ),
              Expanded(
                child: _buildLaporanStat(
                  'Izin',
                  '${laporan.izin}',
                  AppColors.statusIzin,
                ),
              ),
              Expanded(
                child: _buildLaporanStat(
                  'Sakit',
                  '${laporan.sakit}',
                  AppColors.statusSakit,
                ),
              ),
              Expanded(
                child: _buildLaporanStat(
                  'Alfa',
                  '${laporan.alfa}',
                  AppColors.statusAlfa,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          
          // Action Buttons Row 1
          Row(
            children: [
              // View Button
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showLaporanDetail(laporan),
                  icon: const Icon(Icons.visibility_outlined, size: 18),
                  label: const Text('Lihat'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              
              // Download Button
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showDownloadOptions(laporan),
                  icon: const Icon(Icons.download, size: 18),
                  label: const Text('Download'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              
              // Refresh Button (only for drafts)
              if (!isSubmitted)
                IconButton(
                  onPressed: _isSubmitting ? null : () => _refreshLaporanData(laporan),
                  icon: const Icon(Icons.refresh, color: AppColors.primary),
                  tooltip: 'Refresh Data',
                ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Action Buttons Row 2
          Row(
            children: [
              // Submit/Unsubmit Button
              Expanded(
                child: isSubmitted
                    ? OutlinedButton.icon(
                        onPressed: _isSubmitting ? null : () => _unsubmitLaporan(laporan),
                        icon: const Icon(Icons.undo, size: 18),
                        label: const Text('Batal Submit'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.warning,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      )
                    : ElevatedButton.icon(
                        onPressed: _isSubmitting ? null : () => _submitLaporanToServer(laporan),
                        icon: const Icon(Icons.send, size: 18, color: Colors.white),
                        label: const Text('Submit', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
              ),
              
              // Delete Button (only for drafts)
              if (!isSubmitted) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isSubmitting ? null : () => _deleteLaporan(laporan),
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Hapus'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy, HH:mm', 'id').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  Widget _buildLaporanStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: color,
          ),
        ),
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

  void _showLaporanDetail(Laporan laporan) {
    final total = (laporan.hadir ?? 0) + (laporan.izin ?? 0) + (laporan.sakit ?? 0) + (laporan.alfa ?? 0);
    final persentaseHadir = total > 0 ? ((laporan.hadir ?? 0) / total * 100) : 0.0;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.description, color: AppColors.primary, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Laporan Semester ${laporan.semester}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Tahun Ajaran ${laporan.tahunAjar}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Summary Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${persentaseHadir.toStringAsFixed(1)}%',
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const Text(
                      'Tingkat Kehadiran',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Stats Grid
              const Text(
                'Statistik Kehadiran',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildDetailStat('Hadir', '${laporan.hadir ?? 0}', AppColors.statusHadir),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDetailStat('Izin', '${laporan.izin ?? 0}', AppColors.statusIzin),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildDetailStat('Sakit', '${laporan.sakit ?? 0}', AppColors.statusSakit),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDetailStat('Alfa', '${laporan.alfa ?? 0}', AppColors.statusAlfa),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Info
              const Text(
                'Informasi',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildInfoRow('Total Kehadiran', '$total siswa'),
              _buildInfoRow('Kelas', _selectedKelas?.kelas ?? '-'),
              // if (laporan.periodeAwal != null)
              //   _buildInfoRow('Periode', '${laporan.periodeAwal} - ${laporan.periodeAkhir}'),
              
              const SizedBox(height: 24),
              
              // Close Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Tutup', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailStat(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
