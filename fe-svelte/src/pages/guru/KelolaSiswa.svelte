<script lang="ts">
  import { onMount } from 'svelte';
  import { push } from 'svelte-spa-router';
  import { siswaApi } from '../../lib/api/siswa';
  import { kelasApi } from '../../lib/api/kelas';
  import { dashboardApi } from '../../lib/api/dashboard';
  import { authStore } from '../../lib/stores/auth';
  import { toast } from '../../lib/stores/toast';
  
  import PageLayout from '../../components/layout/PageLayout.svelte';
  import Loading from '../../components/ui/Loading.svelte';
  import TextField from '../../components/ui/TextField.svelte';
  import Dropdown from '../../components/ui/Dropdown.svelte';

  let listSiswa = $state<any[]>([]);
  let loading = $state(true);
  let error = $state<string | null>(null);
  let idKelas = $state<number | null>(null);
  
  // Menu state
  let activeMenuId = $state<string | null>(null);
  
  // Dialog state
  let showDialog = $state(false);
  let isEdit = $state(false);
  let isSubmitting = $state(false);
  
  // Form state
  let formNis = $state('');
  let formNama = $state('');
  let formGender = $state('Laki - Laki');
  let formTglLahir = $state('');
  let formAlamat = $state('');

  async function loadData() {
    loading = true;
    error = null;
    const nip = $authStore.user?.nip;
    
    if (nip) {
      const kelasRes = await kelasApi.getByGuru(nip);
      
      if (kelasRes.success && kelasRes.data && kelasRes.data.length > 0) {
        idKelas = kelasRes.data[0].id_kelas || kelasRes.data[0].idKelas || null;
        
        const res = await siswaApi.getByKelas(idKelas!);
        if (res.success && res.data) {
          listSiswa = res.data;
        } else {
          error = res.message;
        }
      } else {
        error = "Anda belum diassign ke kelas manapun.";
      }
    }
    
    loading = false;
  }

  onMount(() => {
    loadData();
    
    const handleOutsideClick = () => {
      activeMenuId = null;
    };
    document.addEventListener('click', handleOutsideClick);
    return () => document.removeEventListener('click', handleOutsideClick);
  });

  async function handleDelete(siswa: any) {
    if (confirm(`Yakin ingin menghapus data siswa ${siswa.nama}?`)) {
      const res = await siswaApi.delete(siswa.nis);
      if (res.success) {
        toast.success(res.message || 'Siswa berhasil dihapus');
        loadData();
      } else {
        toast.error(res.message);
      }
    }
    activeMenuId = null;
  }
  
  function openDialog(siswa?: any) {
    activeMenuId = null;
    isEdit = !!siswa;
    if (siswa) {
      formNis = siswa.nis;
      formNama = siswa.nama;
      formGender = siswa.gender || 'Laki - Laki';
      formTglLahir = siswa.tanggal_lahir || siswa.tanggalLahir || '';
      formAlamat = siswa.alamat || '';
    } else {
      formNis = '';
      formNama = '';
      formGender = 'Laki - Laki';
      formTglLahir = '';
      formAlamat = '';
    }
    showDialog = true;
  }
  
  async function submitDialog() {
    if (!formNis || !formNama || !formTglLahir || !formAlamat) {
      toast.error('Semua field wajib diisi');
      return;
    }
    
    isSubmitting = true;
    
    const data = {
      nis: formNis,
      nama: formNama,
      gender: formGender,
      tanggal_lahir: formTglLahir,
      alamat: formAlamat,
      id_kelas: idKelas
    };
    
    let res;
    if (isEdit) {
      res = await siswaApi.update(formNis, data);
    } else {
      res = await siswaApi.create(data);
    }
    
    isSubmitting = false;
    
    if (res.success) {
      toast.success(res.message || (isEdit ? 'Siswa berhasil diupdate' : 'Siswa berhasil ditambahkan'));
      showDialog = false;
      loadData();
    } else {
      toast.error(res.message);
    }
  }
  
  async function handleImport() {
    if (!idKelas) {
      toast.error('Anda belum memiliki kelas aktif.');
      return;
    }
    
    // Create hidden file input
    const input = document.createElement('input');
    input.type = 'file';
    input.accept = '.xlsx,.xls,.csv';
    input.onchange = async (e: Event) => {
      const target = e.target as HTMLInputElement;
      if (target.files && target.files.length > 0) {
        const file = target.files[0];
        loading = true; // show loading spinner
        try {
          const res = await siswaApi.import(file, idKelas!);
          if (res.success) {
            toast.success(res.message || 'Siswa berhasil diimport');
            loadData();
          } else {
            toast.error(res.message);
            loading = false;
          }
        } catch (err: any) {
          toast.error('Terjadi kesalahan saat import');
          loading = false;
        }
      }
    };
    input.click();
  }
</script>

<PageLayout title="Kelola Data Siswa" showBack={true} hasBottomNav={true}>
  <!-- Top refresh action matching flutter -->
  <div class="top-actions">
    <button class="refresh-btn" onclick={loadData} aria-label="Refresh Data" title="Refresh Data">
      <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 2v6h-6"></path><path d="M3 12a9 9 0 0 1 15-6.7L21 8"></path><path d="M3 22v-6h6"></path><path d="M21 12a9 9 0 0 1-15 6.7L3 16"></path></svg>
    </button>
  </div>

  <div class="kelola-content">
    {#if loading}
      <Loading />
    {:else if error}
      <div class="empty-state">
        <div class="error-text">{error}</div>
        <button class="retry-btn" onclick={loadData}>Coba Lagi</button>
      </div>
    {:else if listSiswa.length === 0}
      <div class="empty-state">
        <svg class="empty-icon" xmlns="http://www.w3.org/2000/svg" width="64" height="64" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle><path d="M23 21v-2a4 4 0 0 0-3-3.87"></path><path d="M16 3.13a4 4 0 0 1 0 7.75"></path><line x1="2" y1="2" x2="22" y2="22"></line></svg>
        <div class="empty-text">Belum ada siswa di kelas Anda</div>
        <button class="empty-btn" onclick={handleImport}>
          <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path><polyline points="17 8 12 3 7 8"></polyline><line x1="12" y1="3" x2="12" y2="15"></line></svg>
          <span>Import dari Excel</span>
        </button>
      </div>
    {:else}
      <div class="siswa-list">
        {#each listSiswa as siswa}
          <!-- svelte-ignore a11y_click_events_have_key_events -->
          <!-- svelte-ignore a11y_no_static_element_interactions -->
          <div class="siswa-card">
            <div class="card-content" onclick={() => push(`/guru/siswa/${siswa.nis}`)}>
              <div class="avatar">
                {(siswa.nama && siswa.nama.length > 0) ? siswa.nama[0].toUpperCase() : '?'}
              </div>
              <div class="siswa-info">
                <span class="nama">{siswa.nama}</span>
                <span class="nis">NIS: {siswa.nis}</span>
              </div>
            </div>
            
            <div class="menu-container">
              <!-- svelte-ignore a11y_consider_explicit_label -->
              <button class="more-btn" onclick={(e) => { e.stopPropagation(); activeMenuId = activeMenuId === siswa.nis ? null : siswa.nis; }}>
                <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="1"></circle><circle cx="12" cy="5" r="1"></circle><circle cx="12" cy="19" r="1"></circle></svg>
              </button>
              
              {#if activeMenuId === siswa.nis}
                <div class="popup-menu" onclick={(e) => e.stopPropagation()}>
                  <button class="menu-item" onclick={() => openDialog(siswa)}>
                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="var(--info)" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path></svg>
                    <span>Edit Siswa</span>
                  </button>
                  <button class="menu-item danger" onclick={() => handleDelete(siswa)}>
                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path></svg>
                    <span>Hapus Siswa</span>
                  </button>
                </div>
              {/if}
            </div>
          </div>
        {/each}
      </div>
    {/if}
  </div>

  <!-- Floating Action Buttons -->
  <div class="fab-container">
    <button class="fab-mini" onclick={() => openDialog()}>
      <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"></line><line x1="5" y1="12" x2="19" y2="12"></line></svg>
    </button>
    <button class="fab-extended" onclick={handleImport}>
      <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path><polyline points="17 8 12 3 7 8"></polyline><line x1="12" y1="3" x2="12" y2="15"></line></svg>
      <span>Import Excel</span>
    </button>
  </div>
  
  <!-- Add/Edit Dialog -->
  {#if showDialog}
    <!-- svelte-ignore a11y_click_events_have_key_events -->
    <!-- svelte-ignore a11y_no_static_element_interactions -->
    <div class="dialog-backdrop" onclick={() => !isSubmitting && (showDialog = false)}>
      <div class="dialog-card" onclick={e => e.stopPropagation()}>
        <div class="dialog-title">{isEdit ? 'Edit Siswa' : 'Tambah Siswa'}</div>
        
        <div class="dialog-body">
          <TextField 
            bind:value={formNis} 
            label="NIS" 
            placeholder="Masukkan NIS" 
            disabled={isEdit}
          />
          
          <div class="mt-3">
            <TextField 
              bind:value={formNama} 
              label="Nama Lengkap" 
              placeholder="Masukkan nama siswa" 
            />
          </div>
          
          <div class="mt-3">
            <Dropdown 
              label="Jenis Kelamin" 
              bind:value={formGender} 
              options={[
                {value: 'Laki - Laki', label: 'Laki - Laki'}, 
                {value: 'Perempuan', label: 'Perempuan'}
              ]} 
            />
          </div>
          
          <div class="mt-3">
            <label class="input-label" for="tgl_lahir">Tanggal Lahir</label>
            <div class="date-input-wrapper">
              <input 
                id="tgl_lahir"
                type="date" 
                bind:value={formTglLahir} 
                class="date-input" 
              />
            </div>
          </div>
          
          <div class="mt-3">
            <TextField 
              bind:value={formAlamat} 
              label="Alamat" 
              placeholder="Masukkan alamat" 
              multiline={true}
              rows={2}
            />
          </div>
        </div>
        
        <div class="dialog-actions">
          <button class="btn-cancel" onclick={() => !isSubmitting && (showDialog = false)} disabled={isSubmitting}>Batal</button>
          <button class="btn-submit" onclick={submitDialog} disabled={isSubmitting}>
            {#if isSubmitting}
              <div class="spinner"></div>
            {:else}
              Simpan
            {/if}
          </button>
        </div>
      </div>
    </div>
  {/if}
</PageLayout>

<style>
  .top-actions {
    position: absolute;
    top: 16px;
    right: 16px;
    z-index: 100;
  }
  
  .refresh-btn {
    background: transparent;
    border: none;
    color: var(--text-primary);
    cursor: pointer;
    padding: 4px;
  }
  
  .kelola-content {
    padding: 16px;
    padding-bottom: 150px;
  }
  
  .empty-state {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    min-height: 400px;
  }
  
  .empty-icon {
    color: var(--text-secondary);
    margin-bottom: 16px;
  }
  
  .empty-text {
    color: var(--text-secondary);
    margin-bottom: 16px;
  }
  
  .empty-btn {
    display: flex;
    align-items: center;
    gap: 8px;
    background-color: var(--primary);
    color: white;
    border: none;
    padding: 8px 16px;
    border-radius: 4px;
    font-weight: 500;
    cursor: pointer;
    box-shadow: 0 2px 4px rgba(0,0,0,0.2);
  }
  
  .error-text {
    color: var(--error);
    margin-bottom: 16px;
    text-align: center;
  }
  
  .retry-btn {
    background-color: var(--primary);
    color: white;
    border: none;
    padding: 8px 16px;
    border-radius: 4px;
    cursor: pointer;
  }
  
  .siswa-list {
    display: flex;
    flex-direction: column;
  }
  
  .siswa-card {
    background: white;
    padding: 8px 16px;
    border-radius: 12px;
    margin-bottom: 12px;
    box-shadow: 0 1px 3px rgba(0,0,0,0.1);
    display: flex;
    justify-content: space-between;
    align-items: center;
  }
  
  .card-content {
    display: flex;
    align-items: center;
    flex: 1;
  }
  
  .avatar {
    width: 40px;
    height: 40px;
    border-radius: 20px;
    background-color: rgba(13, 71, 161, 0.1);
    color: var(--primary);
    display: flex;
    align-items: center;
    justify-content: center;
    font-weight: bold;
    font-size: 16px;
    margin-right: 16px;
  }
  
  .siswa-info {
    display: flex;
    flex-direction: column;
  }
  
  .nama {
    font-weight: bold;
    font-size: 16px;
    color: var(--text-primary);
  }
  
  .nis {
    font-size: 14px;
    color: var(--text-secondary);
  }
  
  .menu-container {
    position: relative;
  }
  
  .more-btn {
    background: none;
    border: none;
    color: var(--text-secondary);
    padding: 8px;
    cursor: pointer;
  }
  
  .popup-menu {
    position: absolute;
    top: 100%;
    right: 0;
    background: white;
    border-radius: 8px;
    box-shadow: 0 4px 12px rgba(0,0,0,0.15);
    z-index: 100;
    min-width: 150px;
    overflow: hidden;
  }
  
  .menu-item {
    display: flex;
    align-items: center;
    gap: 12px;
    padding: 12px 16px;
    background: none;
    border: none;
    width: 100%;
    text-align: left;
    cursor: pointer;
    font-size: 14px;
    color: var(--text-primary);
  }
  
  .menu-item:hover {
    background-color: #f5f5f5;
  }
  
  .menu-item.danger { color: var(--error); }
  
  /* FABs */
  .fab-container {
    position: fixed;
    bottom: 90px;
    right: 16px;
    display: flex;
    flex-direction: column;
    align-items: flex-end;
    gap: 16px;
    z-index: 50;
  }
  
  .fab-mini {
    width: 56px;
    height: 56px;
    border-radius: 28px;
    background-color: var(--primary);
    color: white;
    border: none;
    display: flex;
    align-items: center;
    justify-content: center;
    box-shadow: 0 4px 10px rgba(13, 71, 161, 0.3);
    cursor: pointer;
  }
  
  .fab-extended {
    height: 56px;
    border-radius: 28px;
    background-color: var(--primary);
    color: white;
    border: none;
    padding: 0 20px;
    display: flex;
    align-items: center;
    gap: 8px;
    font-weight: 500;
    font-size: 14px;
    box-shadow: 0 4px 10px rgba(13, 71, 161, 0.3);
    cursor: pointer;
  }
  
  /* Dialog */
  .dialog-backdrop {
    position: fixed;
    inset: 0;
    background: rgba(0,0,0,0.5);
    z-index: 2000;
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 16px;
  }
  
  .dialog-card {
    background: white;
    width: 100%;
    max-width: 400px;
    border-radius: 16px;
    padding: 24px;
    box-shadow: 0 10px 25px rgba(0,0,0,0.2);
    animation: zoomIn 0.2s ease-out;
    max-height: 90vh;
    overflow-y: auto;
  }
  
  .dialog-title {
    font-size: 20px;
    font-weight: 600;
    color: var(--text-primary);
    margin-bottom: 16px;
  }
  
  .mt-3 { margin-top: 12px; }
  
  .input-label {
    display: block;
    font-size: 14px;
    font-weight: 500;
    color: var(--text-primary);
    margin-bottom: 8px;
  }
  
  .date-input-wrapper {
    position: relative;
  }
  
  .date-input {
    width: 100%;
    padding: 12px;
    border-radius: 8px;
    border: 1px solid var(--border);
    background: var(--bg);
    color: var(--text-primary);
    font-family: inherit;
    font-size: 14px;
  }
  
  .dialog-actions {
    display: flex;
    justify-content: flex-end;
    gap: 12px;
    margin-top: 24px;
  }
  
  .btn-cancel {
    background: transparent;
    border: none;
    color: var(--primary);
    padding: 8px 16px;
    font-weight: 500;
    border-radius: 4px;
    cursor: pointer;
  }
  
  .btn-submit {
    background: var(--primary);
    border: none;
    color: white;
    padding: 8px 16px;
    font-weight: 500;
    border-radius: 4px;
    cursor: pointer;
    min-width: 80px;
    display: flex;
    justify-content: center;
  }
  
  .btn-submit:disabled, .btn-cancel:disabled {
    opacity: 0.7;
    cursor: not-allowed;
  }
  
  .spinner {
    width: 16px;
    height: 16px;
    border: 2px solid rgba(255,255,255,0.3);
    border-radius: 50%;
    border-top-color: white;
    animation: spin 1s ease-in-out infinite;
  }
  
  @keyframes spin {
    to { transform: rotate(360deg); }
  }
  
  @keyframes zoomIn {
    from { transform: scale(0.95); opacity: 0; }
    to { transform: scale(1); opacity: 1; }
  }
</style>
