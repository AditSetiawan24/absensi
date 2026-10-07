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
import '../../providers/auth_provider.dart';
import '../../models/laporan_model.dart';
import '../../models/siswa_model.dart';
import '../../services/rekap_bulanan_service.dart';
import '../../services/data_service.dart';
import '../../widgets/common_widgets.dart';

class RekapBulananPage extends StatefulWidget {
  const RekapBulananPage({super.key});

  @override
  State<RekapBulananPage> createState() => _RekapBulananPageState();
}

class _RekapBulananPageState extends State<RekapBulananPage> {
  List<Laporan> _rekapList = [];
  List<Kelas> _kelasList = [];
  Kelas? _selectedKelas;
  bool _isLoading = true;
  String? _error;

  // Form fields for create
  int _selectedBulan = DateTime.now().month;
  int _selectedTahun = DateTime.now().year;

  final List<String> _namaBulan = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];

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
      _loadRekap();
    } else {
      setState(() {
        _isLoading = false;
        _error = 'Gagal memuat data kelas';
      });
    }
  }

  Future<void> _loadRekap() async {
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

    final response = await RekapBulananService.getAll(
      idKelas: _selectedKelas!.idKelas,
    );

    setState(() {
      _isLoading = false;
      if (response.success && response.data != null) {
        _rekapList = response.data!;
      } else {
        _error = response.message;
      }
    });
  }

  Future<void> _deleteRekap(Laporan rekap) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Rekap'),
        content: Text('Yakin ingin menghapus rekap ${rekap.namaBulan} ${rekap.tahun}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true && rekap.idLaporan != null) {
      final response = await RekapBulananService.delete(rekap.idLaporan!);
      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rekap berhasil dihapus'), backgroundColor: AppColors.success),
        );
        _loadRekap();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.message ?? 'Gagal menghapus rekap'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _submitRekap(Laporan rekap) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Submit Rekap'),
        content: Text('Submit rekap ${rekap.namaBulan} ${rekap.tahun}?\nRekap yang sudah disubmit tidak dapat diedit.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Submit'),
          ),
        ],
      ),
    );

    if (confirm == true && rekap.idLaporan != null) {
      final response = await RekapBulananService.submit(rekap.idLaporan!);
      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rekap berhasil disubmit'), backgroundColor: AppColors.success),
        );
        _loadRekap();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.message ?? 'Gagal submit rekap'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _unsubmitRekap(Laporan rekap) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Batal Submit'),
        content: Text('Batalkan submit rekap ${rekap.namaBulan} ${rekap.tahun}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Tidak'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );

    if (confirm == true && rekap.idLaporan != null) {
      final response = await RekapBulananService.unsubmit(rekap.idLaporan!);
      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Submit rekap berhasil dibatalkan'), backgroundColor: AppColors.success),
        );
        _loadRekap();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.message ?? 'Gagal membatalkan submit'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _refreshRekapData(Laporan rekap) async {
    if (rekap.idLaporan == null) return;
    
    final response = await RekapBulananService.refresh(rekap.idLaporan!);
    if (response.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.message ?? 'Data rekap berhasil di-refresh'), backgroundColor: AppColors.success),
      );
      _loadRekap();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.message ?? 'Gagal refresh data'), backgroundColor: Colors.red),
      );
    }
  }

  void _showCreateDialog() {
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
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Buat Rekap Bulanan',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  
                  // Bulan Dropdown
                  DropdownButtonFormField<int>(
                    value: _selectedBulan,
                    decoration: const InputDecoration(
                      labelText: 'Bulan',
                      border: OutlineInputBorder(),
                    ),
                    items: List.generate(12, (index) {
                      return DropdownMenuItem(
                        value: index + 1,
                        child: Text(_namaBulan[index]),
                      );
                    }),
                    onChanged: (value) {
                      setModalState(() => _selectedBulan = value!);
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Tahun Dropdown
                  DropdownButtonFormField<int>(
                    value: _selectedTahun,
                    decoration: const InputDecoration(
                      labelText: 'Tahun',
                      border: OutlineInputBorder(),
                    ),
                    items: List.generate(10, (index) {
                      final year = DateTime.now().year - 2 + index;
                      return DropdownMenuItem(
                        value: year,
                        child: Text(year.toString()),
                      );
                    }),
                    onChanged: (value) {
                      setModalState(() => _selectedTahun = value!);
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _createRekap(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Buat Rekap', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _createRekap(BuildContext dialogContext) async {
    if (_selectedKelas == null) return;
    
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final nip = auth.user?.nip ?? '';

    Navigator.pop(dialogContext);

    setState(() => _isLoading = true);

    final response = await RekapBulananService.create(
      idKelas: _selectedKelas!.idKelas,
      nip: nip,
      bulan: _selectedBulan,
      tahun: _selectedTahun,
    );

    if (response.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.message ?? 'Rekap berhasil dibuat'), backgroundColor: AppColors.success),
      );
      _loadRekap();
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.message ?? 'Gagal membuat rekap'), backgroundColor: Colors.red),
      );
    }
  }

  void _showDownloadOptions(Laporan rekap) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Download Rekap',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Colors.red, size: 32),
              title: const Text('Download PDF'),
              subtitle: const Text('Untuk dicetak atau dikirim'),
              onTap: () {
                Navigator.pop(context);
                _generateAndPrintPdf(rekap);
              },
            ),
            ListTile(
              leading: const Icon(Icons.table_chart, color: Colors.green, size: 32),
              title: const Text('Download Excel'),
              subtitle: const Text('Untuk diolah lebih lanjut'),
              onTap: () {
                Navigator.pop(context);
                _generateAndSaveExcel(rekap);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _generateAndPrintPdf(Laporan rekap) async {
    final pdf = pw.Document();
    
    final total = rekap.hadir + rekap.izin + rekap.sakit + rekap.alfa;
    
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text('REKAP KEHADIRAN BULANAN', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 4),
                    pw.Text('SD Negeri Kemutung Kidul', style: const pw.TextStyle(fontSize: 14)),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Kelas')),
                    pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(_selectedKelas?.kelas ?? '-')),
                  ]),
                  pw.TableRow(children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Bulan')),
                    pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('${rekap.namaBulan} ${rekap.tahun}')),
                  ]),
                  pw.TableRow(children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Periode')),
                    pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('${rekap.periodeAwal} s/d ${rekap.periodeAkhir}')),
                  ]),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Text('Rekap Kehadiran:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Table(
                border: pw.TableBorder.all(),
                columnWidths: {
                  0: const pw.FlexColumnWidth(2),
                  1: const pw.FlexColumnWidth(1),
                  2: const pw.FlexColumnWidth(1),
                },
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Status', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Jumlah', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('%', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    ],
                  ),
                  _buildPdfTableRow('Hadir', rekap.hadir, total),
                  _buildPdfTableRow('Izin', rekap.izin, total),
                  _buildPdfTableRow('Sakit', rekap.sakit, total),
                  _buildPdfTableRow('Alfa', rekap.alfa, total),
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('TOTAL', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('$total', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('100%', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  pw.TableRow _buildPdfTableRow(String label, int value, int total) {
    final percentage = total > 0 ? (value / total * 100) : 0.0;
    return pw.TableRow(
      children: [
        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(label)),
        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('$value')),
        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('${percentage.toStringAsFixed(1)}%')),
      ],
    );
  }

  Future<void> _generateAndSaveExcel(Laporan rekap) async {
    final excel = xl.Excel.createExcel();
    final sheet = excel['Rekap Bulanan'];
    
    sheet.cell(xl.CellIndex.indexByString('A1')).value = xl.TextCellValue('REKAP KEHADIRAN BULANAN');
    sheet.cell(xl.CellIndex.indexByString('A2')).value = xl.TextCellValue('SD Negeri Kemutung Kidul');
    
    sheet.cell(xl.CellIndex.indexByString('A4')).value = xl.TextCellValue('Kelas');
    sheet.cell(xl.CellIndex.indexByString('B4')).value = xl.TextCellValue(_selectedKelas?.kelas ?? '-');
    
    sheet.cell(xl.CellIndex.indexByString('A5')).value = xl.TextCellValue('Bulan');
    sheet.cell(xl.CellIndex.indexByString('B5')).value = xl.TextCellValue('${rekap.namaBulan} ${rekap.tahun}');
    
    sheet.cell(xl.CellIndex.indexByString('A6')).value = xl.TextCellValue('Periode');
    sheet.cell(xl.CellIndex.indexByString('B6')).value = xl.TextCellValue('${rekap.periodeAwal} s/d ${rekap.periodeAkhir}');
    
    sheet.cell(xl.CellIndex.indexByString('A8')).value = xl.TextCellValue('Status');
    sheet.cell(xl.CellIndex.indexByString('B8')).value = xl.TextCellValue('Jumlah');
    sheet.cell(xl.CellIndex.indexByString('C8')).value = xl.TextCellValue('Persentase');
    
    final total = rekap.hadir + rekap.izin + rekap.sakit + rekap.alfa;
    
    sheet.cell(xl.CellIndex.indexByString('A9')).value = xl.TextCellValue('Hadir');
    sheet.cell(xl.CellIndex.indexByString('B9')).value = xl.IntCellValue(rekap.hadir);
    sheet.cell(xl.CellIndex.indexByString('C9')).value = xl.TextCellValue('${total > 0 ? (rekap.hadir / total * 100).toStringAsFixed(1) : 0}%');
    
    sheet.cell(xl.CellIndex.indexByString('A10')).value = xl.TextCellValue('Izin');
    sheet.cell(xl.CellIndex.indexByString('B10')).value = xl.IntCellValue(rekap.izin);
    sheet.cell(xl.CellIndex.indexByString('C10')).value = xl.TextCellValue('${total > 0 ? (rekap.izin / total * 100).toStringAsFixed(1) : 0}%');
    
    sheet.cell(xl.CellIndex.indexByString('A11')).value = xl.TextCellValue('Sakit');
    sheet.cell(xl.CellIndex.indexByString('B11')).value = xl.IntCellValue(rekap.sakit);
    sheet.cell(xl.CellIndex.indexByString('C11')).value = xl.TextCellValue('${total > 0 ? (rekap.sakit / total * 100).toStringAsFixed(1) : 0}%');
    
    sheet.cell(xl.CellIndex.indexByString('A12')).value = xl.TextCellValue('Alfa');
    sheet.cell(xl.CellIndex.indexByString('B12')).value = xl.IntCellValue(rekap.alfa);
    sheet.cell(xl.CellIndex.indexByString('C12')).value = xl.TextCellValue('${total > 0 ? (rekap.alfa / total * 100).toStringAsFixed(1) : 0}%');
    
    sheet.cell(xl.CellIndex.indexByString('A13')).value = xl.TextCellValue('TOTAL');
    sheet.cell(xl.CellIndex.indexByString('B13')).value = xl.IntCellValue(total);
    sheet.cell(xl.CellIndex.indexByString('C13')).value = xl.TextCellValue('100%');
    
    excel.delete('Sheet1');
    
    final directory = await getTemporaryDirectory();
    final fileName = 'Rekap_${rekap.namaBulan}_${rekap.tahun}.xlsx';
    final filePath = '${directory.path}/$fileName';
    
    final fileBytes = excel.save();
    if (fileBytes != null) {
      final file = File(filePath);
      await file.writeAsBytes(fileBytes);
      
      await Share.shareXFiles(
        [XFile(filePath)],
        subject: 'Rekap Bulanan ${rekap.namaBulan} ${rekap.tahun}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rekap Bulanan'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateDialog,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          // Kelas Selector
          if (_kelasList.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey[100],
              child: Row(
                children: [
                  const Text('Kelas: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<Kelas>(
                      value: _selectedKelas,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: _kelasList.map((kelas) {
                        return DropdownMenuItem(
                          value: kelas,
                          child: Text(kelas.kelas),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedKelas = value);
                        _loadRekap();
                      },
                    ),
                  ),
                ],
              ),
            ),
          
          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_error!, style: const TextStyle(color: Colors.red)),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadRekap,
                              child: const Text('Coba Lagi'),
                            ),
                          ],
                        ),
                      )
                    : _rekapList.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.calendar_month, size: 64, color: Colors.grey[400]),
                                const SizedBox(height: 16),
                                Text(
                                  'Belum ada rekap bulanan',
                                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                                ),
                                const SizedBox(height: 8),
                                const Text('Tap + untuk membuat rekap baru'),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadRekap,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _rekapList.length,
                              itemBuilder: (context, index) {
                                return _buildRekapCard(_rekapList[index]);
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildRekapCard(Laporan rekap) {
    final total = rekap.hadir + rekap.izin + rekap.sakit + rekap.alfa;
    final persentaseHadir = total > 0 ? (rekap.hadir / total * 100) : 0.0;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: rekap.isSubmitted ? AppColors.success : Colors.orange,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: rekap.isSubmitted ? AppColors.success.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_month,
                  color: rekap.isSubmitted ? AppColors.success : Colors.orange,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${rekap.namaBulan} ${rekap.tahun}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${rekap.periodeAwal} - ${rekap.periodeAkhir}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: rekap.isSubmitted ? AppColors.success : Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    rekap.isSubmitted ? 'Submitted' : 'Draft',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          
          // Stats
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('Hadir', rekap.hadir, Colors.green),
                    _buildStatItem('Izin', rekap.izin, Colors.blue),
                    _buildStatItem('Sakit', rekap.sakit, Colors.orange),
                    _buildStatItem('Alfa', rekap.alfa, Colors.red),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: persentaseHadir / 100,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    persentaseHadir >= 80 ? Colors.green : persentaseHadir >= 60 ? Colors.orange : Colors.red,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Kehadiran: ${persentaseHadir.toStringAsFixed(1)}%',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          
          // Actions
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(10)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!rekap.isSubmitted) ...[
                  IconButton(
                    icon: const Icon(Icons.refresh, size: 20),
                    tooltip: 'Refresh Data',
                    onPressed: () => _refreshRekapData(rekap),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                    tooltip: 'Hapus',
                    onPressed: () => _deleteRekap(rekap),
                  ),
                  IconButton(
                    icon: const Icon(Icons.check_circle, size: 20, color: Colors.green),
                    tooltip: 'Submit',
                    onPressed: () => _submitRekap(rekap),
                  ),
                ] else ...[
                  IconButton(
                    icon: const Icon(Icons.undo, size: 20, color: Colors.orange),
                    tooltip: 'Batal Submit',
                    onPressed: () => _unsubmitRekap(rekap),
                  ),
                ],
                IconButton(
                  icon: const Icon(Icons.download, size: 20, color: AppColors.primary),
                  tooltip: 'Download',
                  onPressed: () => _showDownloadOptions(rekap),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int value, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Text(
            '$value',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      ],
    );
  }
}
