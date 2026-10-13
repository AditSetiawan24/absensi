<script lang="ts">
  import Button from '../../components/ui/Button.svelte';
  import TextField from '../../components/ui/TextField.svelte';
  import Dropdown from '../../components/ui/Dropdown.svelte';
  import PageLayout from '../../components/layout/PageLayout.svelte';
  import { push } from 'svelte-spa-router';
  import { authApi } from '../../lib/api/auth';
  import { toast } from '../../lib/stores/toast';
  import { GENDER_OPTIONS } from '../../lib/utils/constants';

  let role = $state('guru');
  let isLoading = $state(false);
  let currentStep = $state(0);

  // Form states
  let nama = $state('');
  let email = $state('');
  let username = $state('');
  let password = $state('');
  let password_confirmation = $state('');
  let no_hp = $state('');
  
  // Guru/Kepsek specifics
  let nip = $state('');
  let gender = $state('');
  
  // Guru specifics
  let kode_sekolah = $state('');
  let kode_kelas = $state('');
  
  // Ortu specifics
  let alamat = $state('');
  let nis_anak = $state('');
  let nama_anak = $state('');

  const roles = [
    { id: 'guru', label: 'Guru' },
    { id: 'orang_tua', label: 'Orang Tua' },
    { id: 'kepala_sekolah', label: 'Kepala Sekolah' }
  ];

  function nextStep() {
    if (currentStep === 0) {
      if (!nama.trim()) {
        toast.error('Nama tidak boleh kosong');
        return;
      }
      if (!email.trim()) {
        toast.error('Email tidak boleh kosong');
        return;
      }
      if (!email.includes('@')) {
        toast.error('Email tidak valid');
        return;
      }
      if (!username.trim()) {
        toast.error('Username tidak boleh kosong');
        return;
      }
      if (!password) {
        toast.error('Password tidak boleh kosong');
        return;
      }
      if (password.length < 6) {
        toast.error('Password minimal 6 karakter');
        return;
      }
      if (!password_confirmation) {
        toast.error('Konfirmasi password tidak boleh kosong');
        return;
      }
      if (password !== password_confirmation) {
        toast.error('Password tidak cocok');
        return;
      }
      currentStep++;
    } else {
      handleRegister();
    }
  }

  function prevStep() {
    if (currentStep > 0) currentStep--;
  }

  async function handleRegister() {
    if (role === 'guru') {
      if (!kode_sekolah.trim()) {
        toast.error('Kode sekolah tidak boleh kosong');
        return;
      }
      if (!kode_kelas.trim()) {
        toast.error('Kode kelas tidak boleh kosong');
        return;
      }
      if (!nip.trim()) {
        toast.error('NIP tidak boleh kosong');
        return;
      }
      if (!no_hp.trim()) {
        toast.error('Nomor HP tidak boleh kosong');
        return;
      }
      if (!gender) {
        toast.error('Pilih jenis kelamin');
        return;
      }
    } else if (role === 'kepala_sekolah') {
      if (!nip.trim()) {
        toast.error('NIP tidak boleh kosong');
        return;
      }
      if (!no_hp.trim()) {
        toast.error('Nomor HP tidak boleh kosong');
        return;
      }
    } else if (role === 'orang_tua') {
      if (!nis_anak.trim()) {
        toast.error('NIS anak tidak boleh kosong');
        return;
      }
      if (!nama_anak.trim()) {
        toast.error('Nama anak tidak boleh kosong');
        return;
      }
      if (!no_hp.trim()) {
        toast.error('Nomor HP tidak boleh kosong');
        return;
      }
      if (!alamat.trim()) {
        toast.error('Alamat tidak boleh kosong');
        return;
      }
    }
    
    isLoading = true;
    
    let registerData: any = { 
      nama: nama.trim(), 
      email: email.trim(), 
      username: username.trim(), 
      password, 
      password_confirmation, 
      no_hp: no_hp.trim(), 
      role 
    };
    
    if (role === 'guru') {
      Object.assign(registerData, { 
        nip: nip.trim(), 
        gender, 
        kode_sekolah: kode_sekolah.trim(), 
        kode_kelas: kode_kelas.trim() 
      });
    } else if (role === 'kepala_sekolah') {
      Object.assign(registerData, { nip: nip.trim() });
    } else if (role === 'orang_tua') {
      Object.assign(registerData, { 
        alamat: alamat.trim(), 
        nis_anak: nis_anak.trim(), 
        nama_anak: nama_anak.trim() 
      });
    }

    const res = await authApi.register(registerData);
    isLoading = false;

    if (res.success) {
      toast.success('Registrasi berhasil! Silakan login');
      push('/login');
    } else {
      toast.error(res.message || 'Registrasi gagal');
    }
  }
</script>

<PageLayout title="Daftar Akun" showBack={true} transparent={true}>
  <div class="register-content">
    
    <div class="stepper-header">
      <div class="step {currentStep >= 0 ? 'active' : ''}">
        <div class="step-circle">1</div>
        <span>Informasi Dasar</span>
      </div>
      <div class="step-divider"></div>
      <div class="step {currentStep >= 1 ? 'active' : ''}">
        <div class="step-circle">2</div>
        <span>Detail Tambahan</span>
      </div>
    </div>

    <form class="register-form" onsubmit={(e) => { e.preventDefault(); }}>
      
      {#if currentStep === 0}
        <div class="step-content">
          <label class="section-label">Daftar Sebagai</label>
          <div class="role-selector">
            {#each roles as r}
              <!-- svelte-ignore a11y_click_events_have_key_events -->
              <!-- svelte-ignore a11y_no_static_element_interactions -->
              <div 
                class="role-chip {role === r.id ? 'active' : ''}" 
                onclick={() => role = r.id}
                style={r.id === 'kepala_sekolah' ? 'width: 100%; margin-top: 8px;' : 'width: calc(50% - 4px);'}
              >
                {r.label}
              </div>
            {/each}
          </div>

          <div class="input-group">
            <TextField bind:value={nama} label="Nama Lengkap" placeholder="Masukkan nama lengkap" prefixIcon="person_outline" />
          </div>
          <div class="input-group">
            <TextField bind:value={email} label="Email" type="email" placeholder="Masukkan email" prefixIcon="email_outlined" />
          </div>
          <div class="input-group">
            <TextField bind:value={username} label="Username" placeholder="Masukkan username" prefixIcon="alternate_email" />
          </div>
          <div class="input-group">
            <TextField bind:value={password} label="Password" type="password" placeholder="Masukkan password" prefixIcon="lock_outline" isPassword={true} />
          </div>
          <div class="input-group">
            <TextField bind:value={password_confirmation} label="Konfirmasi Password" type="password" placeholder="Masukkan ulang password" prefixIcon="lock_outline" isPassword={true} />
          </div>
        </div>
      {/if}

      {#if currentStep === 1}
        <div class="step-content">
          {#if role === 'guru'}
            <div class="info-box blue">
              <span class="info-icon">ℹ</span>
              <span>Masukkan kode sekolah dan kode kelas</span>
            </div>
            <div class="input-group">
              <TextField bind:value={kode_sekolah} label="Kode Sekolah" placeholder="Masukkan kode sekolah" prefixIcon="key" />
            </div>
            <div class="input-group">
              <TextField bind:value={kode_kelas} label="Kode Kelas" placeholder="Contoh: KLS1, KLS2, ... KLS6" prefixIcon="class_outlined" />
            </div>
            <div class="input-group">
              <TextField bind:value={nip} label="NIP" placeholder="Masukkan NIP" prefixIcon="badge_outlined" />
            </div>
            <div class="input-group">
              <TextField bind:value={no_hp} label="Nomor HP" type="tel" placeholder="Masukkan nomor HP" prefixIcon="phone_outlined" />
            </div>
            <div class="input-group">
              <Dropdown bind:value={gender} label="Jenis Kelamin" options={GENDER_OPTIONS} />
            </div>
            
          {:else if role === 'kepala_sekolah'}
            <div class="input-group">
              <TextField bind:value={nip} label="NIP" placeholder="Masukkan NIP" prefixIcon="badge_outlined" />
            </div>
            <div class="input-group">
              <TextField bind:value={no_hp} label="Nomor HP" type="tel" placeholder="Masukkan nomor HP" prefixIcon="phone_outlined" />
            </div>
            
          {:else if role === 'orang_tua'}
            <div class="info-box orange">
              <span class="info-icon">ℹ</span>
              <span>NIS dan nama anak harus sesuai dengan data di sekolah</span>
            </div>
            <div class="input-group">
              <TextField bind:value={nis_anak} label="NIS Anak" placeholder="Masukkan NIS anak" prefixIcon="numbers" />
            </div>
            <div class="input-group">
              <TextField bind:value={nama_anak} label="Nama Lengkap Anak" placeholder="Masukkan nama lengkap anak sesuai data sekolah" prefixIcon="child_care" />
            </div>
            <div class="input-group">
              <TextField bind:value={no_hp} label="Nomor HP" type="tel" placeholder="Masukkan nomor HP" prefixIcon="phone_outlined" />
            </div>
            <div class="input-group">
              <TextField bind:value={alamat} label="Alamat" placeholder="Masukkan alamat lengkap" prefixIcon="location_on_outlined" multiline={true} rows={3} />
            </div>
          {/if}
        </div>
      {/if}

      <div class="step-actions">
        <div class="flex-1">
          <Button 
            text={currentStep === 1 ? 'Daftar' : 'Lanjut'} 
            onClick={nextStep} 
            {isLoading} 
          />
        </div>
        {#if currentStep > 0}
          <div class="flex-1">
            <Button 
              text="Kembali" 
              isOutlined={true} 
              onClick={prevStep} 
            />
          </div>
        {/if}
      </div>
      
    </form>
  </div>
</PageLayout>

<style>
  .register-content {
    padding: 24px;
    display: flex;
    flex-direction: column;
    min-height: calc(100vh - 64px);
  }
  
  .stepper-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    margin-bottom: 32px;
  }
  
  .step {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 8px;
    opacity: 0.5;
  }
  
  .step.active {
    opacity: 1;
  }
  
  .step-circle {
    width: 32px;
    height: 32px;
    border-radius: 50%;
    background-color: var(--primary);
    color: white;
    display: flex;
    align-items: center;
    justify-content: center;
    font-weight: bold;
    font-size: 14px;
  }
  
  .step span {
    font-size: 12px;
    font-weight: 600;
    color: var(--text-primary);
  }
  
  .step-divider {
    flex: 1;
    height: 2px;
    background-color: #e0e0e0;
    margin: 0 16px;
    position: relative;
    top: -10px;
  }
  
  .section-label {
    font-size: 14px;
    font-weight: 500;
    color: var(--text-primary);
    margin-bottom: 12px;
    display: block;
  }
  
  .role-selector {
    display: flex;
    flex-wrap: wrap;
    justify-content: space-between;
    margin-bottom: 16px;
  }
  
  .role-chip {
    padding: 12px 0;
    border-radius: 12px;
    border: 1px solid #e0e0e0;
    background-color: #f5f5f5;
    color: var(--text-primary);
    font-size: 14px;
    font-weight: 600;
    text-align: center;
    cursor: pointer;
    transition: all 0.2s;
  }
  
  .role-chip.active {
    background-color: var(--primary);
    color: white;
    border-color: var(--primary);
  }
  
  .register-form {
    display: flex;
    flex-direction: column;
    flex: 1;
  }
  
  .step-content {
    flex: 1;
  }

  .input-group {
    margin-bottom: 16px;
  }
  
  .step-actions {
    display: flex;
    gap: 12px;
    margin-top: 16px;
    margin-bottom: 24px;
  }
  
  .flex-1 {
    flex: 1;
  }
  
  .info-box {
    display: flex;
    align-items: flex-start;
    padding: 12px;
    border-radius: 12px;
    margin-bottom: 16px;
    gap: 8px;
    font-size: 12px;
  }
  
  .info-box.blue {
    background-color: rgba(33, 150, 243, 0.1);
    border: 1px solid rgba(33, 150, 243, 0.3);
    color: #2196f3;
  }
  
  .info-box.orange {
    background-color: rgba(255, 152, 0, 0.1);
    border: 1px solid rgba(255, 152, 0, 0.3);
    color: #ff9800;
  }
  
  .info-icon {
    font-size: 16px;
    font-weight: bold;
  }
</style>
