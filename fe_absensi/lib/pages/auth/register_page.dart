import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common_widgets.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _noHpController = TextEditingController();
  final _nipController = TextEditingController();
  final _alamatController = TextEditingController();
  final _kodeSekolahController = TextEditingController();
  final _kodeKelasController = TextEditingController();
  final _nisAnakController = TextEditingController();
  final _namaAnakController = TextEditingController();
  
  String _selectedRole = AppConstants.roleGuru;
  String? _selectedGender;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  int _currentStep = 0;

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _noHpController.dispose();
    _nipController.dispose();
    _alamatController.dispose();
    _kodeSekolahController.dispose();
    _kodeKelasController.dispose();
    _nisAnakController.dispose();
    _namaAnakController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedRole == AppConstants.roleGuru && _selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih jenis kelamin'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    final success = await authProvider.register(
      nama: _namaController.text.trim(),
      email: _emailController.text.trim(),
      username: _usernameController.text.trim(),
      password: _passwordController.text,
      passwordConfirmation: _confirmPasswordController.text,
      role: _selectedRole,
      noHp: _noHpController.text.trim(),
      nip: _selectedRole != AppConstants.roleOrangTua ? _nipController.text.trim() : null,
      gender: _selectedRole == AppConstants.roleGuru ? _selectedGender : null,
      alamat: _selectedRole == AppConstants.roleOrangTua ? _alamatController.text.trim() : null,
      kodeSekolah: _selectedRole == AppConstants.roleGuru ? _kodeSekolahController.text.trim() : null,
      kodeKelas: _selectedRole == AppConstants.roleGuru ? _kodeKelasController.text.trim() : null,
      nisAnak: _selectedRole == AppConstants.roleOrangTua ? _nisAnakController.text.trim() : null,
      namaAnak: _selectedRole == AppConstants.roleOrangTua ? _namaAnakController.text.trim() : null,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registrasi berhasil! Silakan login'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'Registrasi gagal'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Daftar Akun',
          style: TextStyle(color: AppColors.textPrimary),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Stepper(
            currentStep: _currentStep,
            onStepContinue: () {
              if (_currentStep < 1) {
                setState(() {
                  _currentStep++;
                });
              } else {
                _register();
              }
            },
            onStepCancel: () {
              if (_currentStep > 0) {
                setState(() {
                  _currentStep--;
                });
              }
            },
            controlsBuilder: (context, details) {
              return Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Consumer<AuthProvider>(
                        builder: (context, auth, child) {
                          return CustomButton(
                            text: _currentStep == 1 ? 'Daftar' : 'Lanjut',
                            onPressed: details.onStepContinue,
                            isLoading: auth.isLoading,
                          );
                        },
                      ),
                    ),
                    if (_currentStep > 0) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomButton(
                          text: 'Kembali',
                          onPressed: details.onStepCancel,
                          isOutlined: true,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
            steps: [
              Step(
                title: const Text('Informasi Dasar'),
                content: _buildStep1(),
                isActive: _currentStep >= 0,
              ),
              Step(
                title: const Text('Detail Tambahan'),
                content: _buildStep2(),
                isActive: _currentStep >= 1,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return Column(
      children: [
        // Role Selection
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Daftar Sebagai',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            SizedBox(width: MediaQuery.of(context).size.width / 2.3, child: _buildRoleChip(AppConstants.roleGuru, 'Guru')),
            SizedBox(width: MediaQuery.of(context).size.width / 2.3, child: _buildRoleChip(AppConstants.roleOrangTua, 'Orang Tua')),
            SizedBox(width: double.infinity, child: _buildRoleChip(AppConstants.roleKepalaSekolah, 'Kepala Sekolah')),
          ],
        ),
        const SizedBox(height: 16),
        
        CustomTextField(
          controller: _namaController,
          label: 'Nama Lengkap',
          hint: 'Masukkan nama lengkap',
          prefixIcon: Icons.person_outline,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Nama tidak boleh kosong';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        
        CustomTextField(
          controller: _emailController,
          label: 'Email',
          hint: 'Masukkan email',
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Email tidak boleh kosong';
            }
            if (!value.contains('@')) {
              return 'Email tidak valid';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        
        CustomTextField(
          controller: _usernameController,
          label: 'Username',
          hint: 'Masukkan username',
          prefixIcon: Icons.alternate_email,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Username tidak boleh kosong';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        
        CustomTextField(
          controller: _passwordController,
          label: 'Password',
          hint: 'Masukkan password',
          prefixIcon: Icons.lock_outline,
          obscureText: _obscurePassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Password tidak boleh kosong';
            }
            if (value.length < 6) {
              return 'Password minimal 6 karakter';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        
        CustomTextField(
          controller: _confirmPasswordController,
          label: 'Konfirmasi Password',
          hint: 'Masukkan ulang password',
          prefixIcon: Icons.lock_outline,
          obscureText: _obscureConfirmPassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
            ),
            onPressed: () {
              setState(() {
                _obscureConfirmPassword = !_obscureConfirmPassword;
              });
            },
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Konfirmasi password tidak boleh kosong';
            }
            if (value != _passwordController.text) {
              return 'Password tidak cocok';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildStep2() {
    if (_selectedRole == AppConstants.roleGuru) {
      return _buildGuruForm();
    } else if (_selectedRole == AppConstants.roleOrangTua) {
      return _buildOrangTuaForm();
    } else {
      return _buildKepsekForm();
    }
  }

  Widget _buildKepsekForm() {
    return Column(
      children: [
        CustomTextField(
          controller: _nipController,
          label: 'NIP',
          hint: 'Masukkan NIP',
          prefixIcon: Icons.badge_outlined,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'NIP tidak boleh kosong';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _noHpController,
          label: 'Nomor HP',
          hint: 'Masukkan nomor HP',
          prefixIcon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Nomor HP tidak boleh kosong';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildGuruForm() {
    return Column(
      children: [
        // Kode Sekolah Field
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Masukkan kode sekolah dan kode kelas',
                  style: TextStyle(fontSize: 12, color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
        CustomTextField(
          controller: _kodeSekolahController,
          label: 'Kode Sekolah',
          hint: 'Masukkan kode sekolah',
          prefixIcon: Icons.key,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Kode sekolah tidak boleh kosong';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        
        CustomTextField(
          controller: _kodeKelasController,
          label: 'Kode Kelas',
          hint: 'Contoh: KLS1, KLS2, ... KLS6',
          prefixIcon: Icons.class_outlined,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Kode kelas tidak boleh kosong';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        
        CustomTextField(
          controller: _nipController,
          label: 'NIP',
          hint: 'Masukkan NIP',
          prefixIcon: Icons.badge_outlined,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'NIP tidak boleh kosong';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        
        CustomTextField(
          controller: _noHpController,
          label: 'Nomor HP',
          hint: 'Masukkan nomor HP',
          prefixIcon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Nomor HP tidak boleh kosong';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        
        CustomDropdown<String>(
          label: 'Jenis Kelamin',
          value: _selectedGender,
          hint: 'Pilih jenis kelamin',
          items: AppConstants.genderOptions
              .map((g) => DropdownMenuItem(value: g, child: Text(g)))
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedGender = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildOrangTuaForm() {
    return Column(
      children: [
        // Info Box
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'NIS dan nama anak harus sesuai dengan data di sekolah',
                  style: TextStyle(fontSize: 12, color: Colors.orange),
                ),
              ),
            ],
          ),
        ),
        
        // NIS Anak
        CustomTextField(
          controller: _nisAnakController,
          label: 'NIS Anak',
          hint: 'Masukkan NIS anak',
          prefixIcon: Icons.numbers,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'NIS anak tidak boleh kosong';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        
        // Nama Anak
        CustomTextField(
          controller: _namaAnakController,
          label: 'Nama Lengkap Anak',
          hint: 'Masukkan nama lengkap anak sesuai data sekolah',
          prefixIcon: Icons.child_care,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Nama anak tidak boleh kosong';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        
        CustomTextField(
          controller: _noHpController,
          label: 'Nomor HP',
          hint: 'Masukkan nomor HP',
          prefixIcon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Nomor HP tidak boleh kosong';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        
        CustomTextField(
          controller: _alamatController,
          label: 'Alamat',
          hint: 'Masukkan alamat lengkap',
          prefixIcon: Icons.location_on_outlined,
          maxLines: 3,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Alamat tidak boleh kosong';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildRoleChip(String role, String label) {
    final isSelected = _selectedRole == role;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRole = role;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
