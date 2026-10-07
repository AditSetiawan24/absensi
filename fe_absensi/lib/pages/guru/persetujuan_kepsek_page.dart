import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../services/data_service.dart';
import '../../widgets/common_widgets.dart';

class PersetujuanKepsekPage extends StatefulWidget {
  const PersetujuanKepsekPage({super.key});

  @override
  State<PersetujuanKepsekPage> createState() => _PersetujuanKepsekPageState();
}

class _PersetujuanKepsekPageState extends State<PersetujuanKepsekPage> {
  List<dynamic> _pendingList = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPendingKepsek();
  }

  Future<void> _loadPendingKepsek() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final response = await KepsekService.getPending();

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (response.success && response.data != null) {
          _pendingList = response.data!;
        } else {
          _error = response.message;
        }
      });
    }
  }

  Future<void> _approveKepsek(String nip) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final response = await KepsekService.approve(nip);
    
    if (mounted) {
      Navigator.pop(context); // close loading
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message),
          backgroundColor: response.success ? Colors.green : AppColors.error,
        ),
      );

      if (response.success) {
        _loadPendingKepsek();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Persetujuan Kepala Sekolah'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? const LoadingWidget()
          : _error != null
              ? CustomErrorWidget(message: _error!, onRetry: _loadPendingKepsek)
              : _pendingList.isEmpty
                  ? const Center(
                      child: Text(
                        'Tidak ada pendaftaran Kepala Sekolah yang perlu disetujui.',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadPendingKepsek,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _pendingList.length,
                        itemBuilder: (context, index) {
                          final item = _pendingList[index];
                          final hasApproved = item['has_approved'] == true;
                          final count = item['approvals_count'] ?? 0;
                          
                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.person, color: AppColors.primary),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          item['nama'] ?? 'Unknown',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text('NIP: ${item['nip']}'),
                                  Text('Email: ${item['email']}'),
                                  Text('No HP: ${item['no_hp']}'),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Status: $count/4 Persetujuan',
                                    style: const TextStyle(
                                      color: Colors.orange,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: hasApproved 
                                          ? null 
                                          : () => _approveKepsek(item['nip']),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: hasApproved ? Colors.grey : AppColors.primary,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: Text(hasApproved ? 'Sudah Disetujui Anda' : 'Setujui'),
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
