<script lang="ts">
  import { onMount } from 'svelte';
  import { push } from 'svelte-spa-router';
  import { authStore } from '../../lib/stores/auth';
  import { authApi } from '../../lib/api/auth';
  import { toast } from '../../lib/stores/toast';
  import { AppConstants } from '../../lib/utils/constants';
  
  import PageLayout from '../../components/layout/PageLayout.svelte';
  import Button from '../../components/ui/Button.svelte';
  import TextField from '../../components/ui/TextField.svelte';
  import Modal from '../../components/ui/Modal.svelte';
  import Loading from '../../components/ui/Loading.svelte';

  let user = $derived($authStore.user);
  let currentRole = $derived($authStore.role || $authStore.user?.role || '');
  let currentNip = $derived($authStore.user?.nip || '');
  let currentUsername = $derived($authStore.user?.username || '');

  let loading = $state(false);
  let kelasInfo = $state<any>(null);
  let notificationsEnabled = $state(true);
  
  // Modals state
  let showLogoutDialog = $state(false);
  let showReleaseClassDialog = $state(false);
  let showChangeClassModal = $state(false);
  let showChangePasswordModal = $state(false);
  let showAboutModal = $state(false);
  let showHelpModal = $state(false);
  
  // Form states
  let oldPassword = $state('');
  let newPassword = $state('');
  let confirmPassword = $state('');
  let newKodeKelas = $state('');
  let isProcessing = $state(false);

  onMount(async () => {
    loadKelasInfo();
  });

  $effect(() => {
    if (currentRole === 'guru' && currentNip && !kelasInfo) {
      loadKelasInfo();
    }
  });

  async function loadKelasInfo() {
    const nip = currentNip;
    if (!nip) return;
    try {
      const res = await authApi.getGuruClass(nip);
      if (res.success && res.data) {
        kelasInfo = res.data;
      }
    } catch (e) {
      console.error('Failed to load kelas info', e);
    }
  }

  async function handleLogout() {
    showLogoutDialog = false;
    loading = true;
    try {
      await authApi.logout();
      authStore.set({ user: null, role: null, token: null, isLoading: false, error: null });
      push('/');
    } catch (err) {
      toast.error('Gagal keluar');
    } finally {
      loading = false;
    }
  }
  
  async function handleChangePassword() {
    if (!oldPassword) {
      toast.error('Password saat ini tidak boleh kosong');
      return;
    }
    if (!newPassword) {
      toast.error('Password baru tidak boleh kosong');
      return;
    }
    if (newPassword.length < 6) {
      toast.error('Password baru minimal 6 karakter');
      return;
    }
    if (newPassword !== confirmPassword) {
      toast.error('Password baru tidak cocok');
      return;
    }
    
    isProcessing = true;
    try {
      const res = await authApi.changePassword({
        username: currentUsername,
        role: currentRole,
        old_password: oldPassword,
        oldPassword: oldPassword,
        password: newPassword,
        password_confirmation: confirmPassword,
        passwordConfirmation: confirmPassword
      });
      
      if (res.success) {
        toast.success(res.message || 'Password berhasil diubah');
        showChangePasswordModal = false;
        oldPassword = '';
        newPassword = '';
        confirmPassword = '';
      } else {
        toast.error(res.message || 'Gagal mengubah password');
      }
    } catch (e: any) {
      toast.error(e.message || 'Gagal mengubah password');
    } finally {
      isProcessing = false;
    }
  }
  
  async function handleReleaseClass() {
    showReleaseClassDialog = false;
    isProcessing = true;
    try {
      const res = await authApi.releaseClass({ nip: currentNip });
      if (res.success) {
        toast.success(res.message || 'Kelas berhasil dilepaskan');
        loadKelasInfo();
      } else {
        toast.error(res.message || 'Gagal melepas kelas');
      }
    } catch (e: any) {
      toast.error(e.message || 'Gagal melepas kelas');
    } finally {
      isProcessing = false;
    }
  }
  
  async function handleChangeClass() {
    if (!newKodeKelas.trim()) {
      toast.error('Masukkan kode kelas');
      return;
    }
    
    isProcessing = true;
    try {
      const res = await authApi.changeClass({ 
        nip: currentNip, 
        kode_kelas: newKodeKelas.trim().toUpperCase(),
        kodeKelas: newKodeKelas.trim().toUpperCase()
      });
      if (res.success) {
        toast.success(res.message || 'Berhasil pindah kelas');
        showChangeClassModal = false;
        newKodeKelas = '';
        loadKelasInfo();
      } else {
        toast.error(res.message || 'Gagal pindah kelas');
      }
    } catch (e: any) {
      toast.error(e.message || 'Gagal pindah kelas');
    } finally {
      isProcessing = false;
    }
  }

  function getRoleLabel(role: string) {
    if (role === 'guru') return 'Guru';
    if (role === 'kepala_sekolah') return 'Kepala Sekolah';
    if (role === 'orang_tua') return 'Orang Tua';
    return role || 'User';
  }
</script>

<PageLayout title="Pengaturan" hasBottomNav={true}>
  <div class="settings-content">
    {#if !user}
      <Loading />
    {:else}
      <!-- Profile Card -->
      <div class="profile-card">
        <div class="avatar">{user.nama?.charAt(0).toUpperCase() || 'U'}</div>
        <div class="info">
          <h2>{user.nama || 'User'}</h2>
          <p class="email">{user.email || user.username || ''}</p>
          <div class="role-badge">{getRoleLabel(currentRole)}</div>
        </div>
      </div>

      <!-- Preferensi -->
      <div class="section-title">Preferensi</div>
      <div class="setting-item">
        <div class="item-icon"><svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"></path><path d="M13.73 21a2 2 0 0 1-3.46 0"></path></svg></div>
        <div class="item-text">
          <div class="item-title">Notifikasi</div>
          <div class="item-subtitle">Terima notifikasi push</div>
        </div>
        <div class="item-trailing">
          <label class="switch">
            <input type="checkbox" bind:checked={notificationsEnabled}>
            <span class="slider round"></span>
          </label>
        </div>
      </div>

      <!-- Akun -->
      <div class="section-title">Akun</div>
      <!-- svelte-ignore a11y_click_events_have_key_events -->
      <!-- svelte-ignore a11y_no_static_element_interactions -->
      <div class="setting-item clickable" onclick={() => showChangePasswordModal = true}>
        <div class="item-icon"><svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"></rect><path d="M7 11V7a5 5 0 0 1 10 0v4"></path></svg></div>
        <div class="item-text">
          <div class="item-title">Ubah Password</div>
          <div class="item-subtitle">Perbarui password akun Anda</div>
        </div>
        <div class="item-trailing">
          <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"></polyline></svg>
        </div>
      </div>
      
      <!-- Manajemen Kelas -->
      {#if currentRole === 'guru'}
        <div class="section-title">Manajemen Kelas</div>
        {#if kelasInfo && kelasInfo.has_class}
          <!-- svelte-ignore a11y_click_events_have_key_events -->
          <!-- svelte-ignore a11y_no_static_element_interactions -->
          <div class="setting-item clickable" onclick={() => showReleaseClassDialog = true}>
            <div class="item-icon"><svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"></path><polyline points="16 17 21 12 16 7"></polyline><line x1="21" y1="12" x2="9" y2="12"></line></svg></div>
            <div class="item-text">
              <div class="item-title">Lepas Kelas</div>
              <div class="item-subtitle">Lepaskan kelas yang diampu saat ini</div>
            </div>
            <div class="item-trailing">
              <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"></polyline></svg>
            </div>
          </div>
        {/if}
        <!-- svelte-ignore a11y_click_events_have_key_events -->
        <!-- svelte-ignore a11y_no_static_element_interactions -->
        <div class="setting-item clickable" onclick={() => showChangeClassModal = true}>
          <div class="item-icon"><svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="16 3 21 3 21 8"></polyline><line x1="4" y1="20" x2="21" y2="3"></line><polyline points="21 16 21 21 16 21"></polyline><line x1="15" y1="15" x2="21" y2="21"></line><line x1="4" y1="4" x2="9" y2="9"></line></svg></div>
          <div class="item-text">
            <div class="item-title">Pindah Kelas</div>
            <div class="item-subtitle">Pindah ke kelas lain</div>
          </div>
          <div class="item-trailing">
            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"></polyline></svg>
          </div>
        </div>
      {/if}

      <!-- Tentang -->
      <div class="section-title">Tentang</div>
      <!-- svelte-ignore a11y_click_events_have_key_events -->
      <!-- svelte-ignore a11y_no_static_element_interactions -->
      <div class="setting-item clickable" onclick={() => showAboutModal = true}>
        <div class="item-icon"><svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="16" x2="12" y2="12"></line><line x1="12" y1="8" x2="12.01" y2="8"></line></svg></div>
        <div class="item-text">
          <div class="item-title">Tentang Aplikasi</div>
          <div class="item-subtitle">{AppConstants.appVersion}</div>
        </div>
        <div class="item-trailing">
          <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"></polyline></svg>
        </div>
      </div>
      <!-- svelte-ignore a11y_click_events_have_key_events -->
      <!-- svelte-ignore a11y_no_static_element_interactions -->
      <div class="setting-item clickable" onclick={() => showHelpModal = true}>
        <div class="item-icon"><svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><path d="M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3"></path><line x1="12" y1="17" x2="12.01" y2="17"></line></svg></div>
        <div class="item-text">
          <div class="item-title">Bantuan</div>
          <div class="item-subtitle">Pusat bantuan dan FAQ</div>
        </div>
        <div class="item-trailing">
          <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"></polyline></svg>
        </div>
      </div>

      <div class="logout-wrapper">
        <Button 
          text="Keluar" 
          isOutlined={true}
          onClick={() => showLogoutDialog = true} 
          isLoading={loading}
        />
      </div>
    {/if}
  </div>

  <!-- Logout Dialog -->
  <Modal 
    isOpen={showLogoutDialog} 
    title="Keluar" 
    content="Yakin ingin keluar dari aplikasi?"
    confirmText="Keluar"
    cancelText="Batal"
    isDanger={true}
    onCancel={() => showLogoutDialog = false}
    onConfirm={handleLogout}
  />
  
  <!-- Release Class Dialog -->
  <Modal 
    isOpen={showReleaseClassDialog} 
    title="Lepas Kelas" 
    content={`Apakah Anda yakin ingin melepaskan ${kelasInfo?.kelas?.nama_kelas || 'kelas'}?\n\nAnda harus memilih kelas baru sebelum dapat melakukan absensi lagi.`}
    confirmText="Lepas"
    cancelText="Batal"
    isDanger={true}
    onCancel={() => showReleaseClassDialog = false}
    onConfirm={handleReleaseClass}
  />

  <!-- About Dialog -->
  <Modal 
    isOpen={showAboutModal} 
    title={AppConstants.appName} 
    confirmText="Tutup"
    cancelText=""
    onCancel={() => showAboutModal = false}
    onConfirm={() => showAboutModal = false}
  >
    <div style="text-align: left;">
      <p style="margin:0 0 8px 0; font-weight:600; color:var(--text-primary);">{AppConstants.schoolName}</p>
      <p style="margin:0 0 16px 0; color:var(--text-secondary); font-size:14px;">Versi {AppConstants.appVersion}</p>
      <p style="margin:0; font-size:14px; color:var(--text-primary);">Aplikasi absensi siswa untuk memudahkan pencatatan dan pemantauan kehadiran siswa.</p>
    </div>
  </Modal>

  <!-- Help Dialog -->
  <Modal 
    isOpen={showHelpModal} 
    title="Pusat Bantuan & FAQ" 
    confirmText="Tutup"
    cancelText=""
    onCancel={() => showHelpModal = false}
    onConfirm={() => showHelpModal = false}
  >
    <div style="text-align: left;">
      <p style="margin:0 0 12px 0; font-weight:600; font-size:15px;">Bantuan Penggunaan Sistem Absensi</p>
      <p style="margin:0 0 8px 0; font-size:14px; color:var(--text-secondary);">1. <strong>Guru</strong>: Gunakan menu Absensi untuk mencatat kehadiran siswa dan menu Laporan untuk mengajukan laporan semester.</p>
      <p style="margin:0 0 8px 0; font-size:14px; color:var(--text-secondary);">2. <strong>Kepala Sekolah</strong>: Pantau rekapitulasi kehadiran per kelas dan setujui laporan yang diajukan guru.</p>
      <p style="margin:0 0 8px 0; font-size:14px; color:var(--text-secondary);">3. <strong>Orang Tua</strong>: Pantau rekap kehadiran harian dan kalender kehadiran anak.</p>
      <p style="margin:16px 0 0 0; font-size:13px; color:var(--text-secondary);">Untuk kendala teknis atau reset akun, silakan hubungi administrator sekolah.</p>
    </div>
  </Modal>

  <!-- Bottom Sheet Modals -->
  {#if showChangePasswordModal || showChangeClassModal}
    <!-- svelte-ignore a11y_click_events_have_key_events -->
    <!-- svelte-ignore a11y_no_static_element_interactions -->
    <div class="bottom-sheet-backdrop" onclick={() => { showChangePasswordModal = false; showChangeClassModal = false; }}>
      <div class="bottom-sheet" onclick={e => e.stopPropagation()}>
        
        {#if showChangePasswordModal}
          <div class="sheet-header">
            <h3>Ubah Password</h3>
            <button class="icon-btn" onclick={() => showChangePasswordModal = false}>✕</button>
          </div>
          <div class="sheet-content">
            <div class="mb-4">
              <TextField bind:value={oldPassword} label="Password Saat Ini" placeholder="Masukkan password saat ini" type="password" prefixIcon="lock_outline" isPassword={true} />
            </div>
            <div class="mb-4">
              <TextField bind:value={newPassword} label="Password Baru" placeholder="Masukkan password baru" type="password" prefixIcon="lock_outline" isPassword={true} />
            </div>
            <div class="mb-6">
              <TextField bind:value={confirmPassword} label="Konfirmasi Password" placeholder="Masukkan ulang password baru" type="password" prefixIcon="lock_outline" isPassword={true} />
            </div>
            <Button text="Simpan" onClick={handleChangePassword} isLoading={isProcessing} />
          </div>
        {/if}
        
        {#if showChangeClassModal}
          <div class="sheet-header">
            <h3>Pindah Kelas</h3>
            <button class="icon-btn" onclick={() => showChangeClassModal = false}>✕</button>
          </div>
          <div class="sheet-content">
            <div class="info-box blue">
              <span class="info-icon">ℹ</span>
              <span>Masukkan kode kelas baru.<br/>Format: KLS1, KLS2, KLS3, KLS4, KLS5, KLS6</span>
            </div>
            <div class="mb-6 mt-4">
              <TextField bind:value={newKodeKelas} label="Kode Kelas Baru" placeholder="Contoh: KLS1" prefixIcon="class_outlined" />
            </div>
            <Button text="Pindah" onClick={handleChangeClass} isLoading={isProcessing} />
          </div>
        {/if}
        
      </div>
    </div>
  {/if}
</PageLayout>

<style>
  .settings-content {
    padding: 16px;
    padding-bottom: 96px;
  }
  
  .profile-card {
    display: flex;
    align-items: center;
    gap: 16px;
    background: linear-gradient(135deg, var(--primary), #1976d2); /* Approximating withOpacity(0.8) */
    padding: 20px;
    border-radius: 16px;
    margin-bottom: 24px;
    color: white;
  }
  
  .avatar {
    width: 70px;
    height: 70px;
    border-radius: 50%;
    background: rgba(255, 255, 255, 0.2);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 28px;
    font-weight: 700;
  }
  
  .info {
    flex: 1;
    display: flex;
    flex-direction: column;
    align-items: flex-start;
  }
  
  .info h2 {
    margin: 0 0 4px 0;
    font-size: 18px;
    font-weight: bold;
  }
  
  .email {
    margin: 0 0 8px 0;
    font-size: 14px;
    color: rgba(255, 255, 255, 0.9);
  }
  
  .role-badge {
    font-size: 12px;
    background: rgba(255, 255, 255, 0.2);
    padding: 2px 8px;
    border-radius: 10px;
  }
  
  .section-title {
    font-size: 16px;
    font-weight: bold;
    color: var(--text-secondary);
    margin-top: 24px;
    margin-bottom: 12px;
  }
  
  .setting-item {
    display: flex;
    align-items: center;
    background: var(--surface);
    margin-bottom: 8px;
    padding: 16px;
    border-radius: 12px;
    box-shadow: 0 2px 10px rgba(0,0,0,0.05);
  }
  
  .setting-item.clickable {
    cursor: pointer;
    transition: background 0.2s;
  }
  
  .setting-item.clickable:active {
    background: var(--bg);
  }
  
  .item-icon {
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 8px;
    background: rgba(13, 71, 161, 0.1);
    color: var(--primary);
    border-radius: 8px;
    margin-right: 16px;
  }
  
  .item-text {
    flex: 1;
  }
  
  .item-title {
    font-size: 16px;
    font-weight: 600;
    color: var(--text-primary);
  }
  
  .item-subtitle {
    font-size: 12px;
    color: var(--text-secondary);
    margin-top: 2px;
  }
  
  .item-trailing {
    color: var(--text-secondary);
    display: flex;
    align-items: center;
  }
  
  .logout-wrapper {
    margin-top: 24px;
    margin-bottom: 24px;
  }

  /* Toggle Switch */
  .switch {
    position: relative;
    display: inline-block;
    width: 40px;
    height: 24px;
  }

  .switch input { 
    opacity: 0;
    width: 0;
    height: 0;
  }

  .slider {
    position: absolute;
    cursor: pointer;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background-color: #ccc;
    -webkit-transition: .4s;
    transition: .4s;
  }

  .slider:before {
    position: absolute;
    content: "";
    height: 18px;
    width: 18px;
    left: 3px;
    bottom: 3px;
    background-color: white;
    -webkit-transition: .4s;
    transition: .4s;
  }

  input:checked + .slider {
    background-color: var(--primary);
  }

  input:focus + .slider {
    box-shadow: 0 0 1px var(--primary);
  }

  input:checked + .slider:before {
    -webkit-transform: translateX(16px);
    -ms-transform: translateX(16px);
    transform: translateX(16px);
  }

  .slider.round {
    border-radius: 24px;
  }

  .slider.round:before {
    border-radius: 50%;
  }

  /* Bottom Sheet */
  .bottom-sheet-backdrop {
    position: fixed;
    inset: 0;
    background: rgba(0,0,0,0.5);
    z-index: 2000;
    display: flex;
    align-items: flex-end;
  }
  
  .bottom-sheet {
    background: var(--surface);
    width: 100%;
    border-radius: 20px 20px 0 0;
    padding: 24px;
    padding-bottom: max(24px, env(safe-area-inset-bottom));
    animation: slideUp 0.3s ease-out;
  }
  
  @keyframes slideUp {
    from { transform: translateY(100%); }
    to { transform: translateY(0); }
  }
  
  .sheet-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 24px;
  }
  
  .sheet-header h3 {
    margin: 0;
    font-size: 20px;
    font-weight: bold;
    color: var(--text-primary);
  }
  
  .icon-btn {
    background: none;
    border: none;
    font-size: 20px;
    color: var(--text-secondary);
    cursor: pointer;
    padding: 4px;
  }
  
  .mb-4 { margin-bottom: 16px; }
  .mb-6 { margin-bottom: 24px; }
  .mt-4 { margin-top: 16px; }

  .info-box {
    display: flex;
    align-items: flex-start;
    padding: 12px;
    border-radius: 12px;
    gap: 8px;
    font-size: 12px;
  }
  
  .info-box.blue {
    background-color: rgba(33, 150, 243, 0.1);
    border: 1px solid rgba(33, 150, 243, 0.3);
    color: #2196f3;
  }
  
  .info-icon {
    font-size: 16px;
    font-weight: bold;
  }
</style>
