import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/siswa_model.dart';
import '../../services/data_service.dart';
import '../../widgets/common_widgets.dart';

class ListGuruPage extends StatefulWidget {
  const ListGuruPage({super.key});

  @override
  State<ListGuruPage> createState() => _ListGuruPageState();
}

class _ListGuruPageState extends State<ListGuruPage> {
  List<Guru> _guruList = [];
  String _searchQuery = '';
  bool _isLoading = true;
  String? _error;

  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadGuru();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadGuru() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final response = await GuruService.getAll();

    setState(() {
      _isLoading = false;
      if (response.success && response.data != null) {
        _guruList = response.data!;
      } else {
        _error = response.message;
      }
    });
  }

  List<Guru> get _filteredGuru {
    if (_searchQuery.isEmpty) return _guruList;
    return _guruList.where((guru) {
      return guru.nama.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          guru.nip.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Guru'),
      ),
      body: Column(
        children: [
          // Search
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[50],
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari guru...',
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
          ),

          // Guru List
          Expanded(
            child: _isLoading
                ? const LoadingWidget()
                : _error != null
                    ? CustomErrorWidget(
                        message: _error!,
                        onRetry: _loadGuru,
                      )
                    : _filteredGuru.isEmpty
                        ? const EmptyWidget(
                            message: 'Tidak ada guru ditemukan',
                          )
                        : RefreshIndicator(
                            onRefresh: _loadGuru,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _filteredGuru.length,
                              itemBuilder: (context, index) {
                                final guru = _filteredGuru[index];
                                return _buildGuruCard(guru);
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuruCard(Guru guru) {
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
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: AppColors.primary,
          child: Text(
            guru.nama[0].toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        title: Text(
          guru.nama,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.badge, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  'NIP: ${guru.nip}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(
                  guru.gender == 'Laki-laki' ? Icons.male : Icons.female,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  guru.gender,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            if (guru.noHp.isNotEmpty) ...[
              const SizedBox(height: 2),
              Row(
                children: [
                  const Icon(Icons.phone, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    guru.noHp,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () {
            _showGuruOptions(guru);
          },
        ),
      ),
    );
  }

  void _showGuruOptions(Guru guru) {
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
              CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.primary,
                child: Text(
                  guru.nama[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 32,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                guru.nama,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'NIP: ${guru.nip}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.phone,
                      label: 'Telepon',
                      color: AppColors.success,
                      onTap: () {
                        // TODO: Open phone
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.email,
                      label: 'Email',
                      color: AppColors.primary,
                      onTap: () {
                        // TODO: Open email
                        Navigator.pop(context);
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

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
