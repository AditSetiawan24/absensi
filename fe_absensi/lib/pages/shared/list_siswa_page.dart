import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/siswa_model.dart';
import '../../services/data_service.dart';
import '../../widgets/common_widgets.dart';
import '../guru/siswa_detail_page.dart';

class ListSiswaPage extends StatefulWidget {
  final String? idKelas;
  
  const ListSiswaPage({super.key, this.idKelas});

  @override
  State<ListSiswaPage> createState() => _ListSiswaPageState();
}

class _ListSiswaPageState extends State<ListSiswaPage> {
  List<Siswa> _siswaList = [];
  List<Kelas> _kelasList = [];
  Kelas? _selectedKelas;
  String _searchQuery = '';
  bool _isLoading = true;
  String? _error;

  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    // Load kelas list
    final kelasResponse = await KelasService.getAll();
    if (kelasResponse.success && kelasResponse.data != null) {
      _kelasList = kelasResponse.data!;
      if (widget.idKelas != null) {
        _selectedKelas = _kelasList.firstWhere(
          (k) => k.idKelas.toString() == widget.idKelas,
          orElse: () => _kelasList.first,
        );
      }
    }

    await _loadSiswa();
  }

  Future<void> _loadSiswa() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final response = _selectedKelas != null
        ? await SiswaService.getByKelas(_selectedKelas!.idKelas)
        : await SiswaService.getAll();

    setState(() {
      _isLoading = false;
      if (response.success && response.data != null) {
        _siswaList = response.data!;
      } else {
        _error = response.message;
      }
    });
  }

  List<Siswa> get _filteredSiswa {
    if (_searchQuery.isEmpty) return _siswaList;
    return _siswaList.where((siswa) {
      return siswa.nama.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          siswa.nis.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Siswa'),
      ),
      body: Column(
        children: [
          // Search and Filter
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[50],
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari siswa...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 12),
                if (_kelasList.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<Kelas?>(
                        value: _selectedKelas,
                        isExpanded: true,
                        hint: const Text('Semua Kelas'),
                        items: [
                          const DropdownMenuItem<Kelas?>(
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
                          _loadSiswa();
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Siswa List
          Expanded(
            child: _isLoading
                ? const LoadingWidget()
                : _error != null
                    ? CustomErrorWidget(
                        message: _error!,
                        onRetry: _loadSiswa,
                      )
                    : _filteredSiswa.isEmpty
                        ? const EmptyWidget(
                            message: 'Tidak ada siswa ditemukan',
                          )
                        : RefreshIndicator(
                            onRefresh: _loadSiswa,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _filteredSiswa.length,
                              itemBuilder: (context, index) {
                                final siswa = _filteredSiswa[index];
                                return _buildSiswaCard(siswa, index + 1);
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildSiswaCard(Siswa siswa, int number) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              siswa.nama[0].toUpperCase(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
                fontSize: 18,
              ),
            ),
          ),
        ),
        title: Text(
          siswa.nama,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'NIS: ${siswa.nis}',
              style: const TextStyle(fontSize: 12),
            ),
            if (siswa.kelas != null)
              Text(
                'Kelas ${siswa.kelas!.kelas}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SiswaDetailPage(siswa: siswa),
            ),
          );
        },
      ),
    );
  }
}
