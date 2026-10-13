<script lang="ts">
  import { onMount } from 'svelte';
  import { pop } from 'svelte-spa-router';
  import { absensiApi } from '../../lib/api/absensi';
  import { toast } from '../../lib/stores/toast';
  
  import PageLayout from '../../components/layout/PageLayout.svelte';
  import Button from '../../components/ui/Button.svelte';
  import Loading from '../../components/ui/Loading.svelte';
  import ErrorState from '../../components/ui/ErrorState.svelte';
  import TextField from '../../components/ui/TextField.svelte';

  let { params = {} } = $props<{ params?: any }>();
  
  let loading = $state(true);
  let submitting = $state(false);
  let error = $state('');
  
  let absensi = $state<any>(null);
  let selectedStatus = $state('hadir');
  let keterangan = $state('');
  let fileSurat = $state<File | null>(null);
  let fileName = $state<string | null>(null);

  async function loadData() {
    loading = true;
    error = '';
    
    const id = params.id;
    if (!id) {
      error = 'ID tidak valid';
      loading = false;
      return;
    }
    
    const res = await absensiApi.getById(id);
    
    loading = false;
    if (res.success && res.data) {
      absensi = res.data;
      selectedStatus = absensi.status_kehadiran || absensi.status || 'hadir';
      keterangan = absensi.keterangan || '';
      fileName = absensi.file_surat || null;
    } else {
      error = res.message || 'Gagal memuat data absensi';
    }
  }

  onMount(() => {
    loadData();
  });

  async function submitForm() {
    if (!absensi) return;
    
    submitting = true;
    const data = {
      status_kehadiran: selectedStatus,
      keterangan: selectedStatus === 'hadir' ? '' : keterangan
    };
    
    const res = await absensiApi.update(absensi.id_absensi || absensi.id, data);
    submitting = false;
    
    if (res.success) {
      toast.success('Absensi berhasil diupdate');
      pop();
    } else {
      toast.error(res.message);
    }
  }
  
  function handleFileSelect(e: Event) {
    const target = e.target as HTMLInputElement;
    if (target.files && target.files.length > 0) {
      fileSurat = target.files[0];
      fileName = fileSurat.name;
    }
  }
  
  function getAvatarLetter(name: string) {
    return (name || 'S')[0].toUpperCase();
  }
</script>

<PageLayout title="Edit Absensi" showBack={true} hasBottomNav={false}>
  {#if loading}
    <Loading />
  {:else if error}
    <ErrorState message={error} onRetry={loadData} />
  {:else if absensi}
    <div class="edit-form">
      <!-- Student Info -->
      <div class="student-info-card">
        <div class="avatar">
          {getAvatarLetter(absensi.nama_siswa || absensi.siswa?.nama)}
        </div>
        <div class="info-text">
          <div class="nama">{absensi.nama_siswa || absensi.siswa?.nama || '-'}</div>
          <div class="nis">NIS: {absensi.nis}</div>
        </div>
      </div>
      
      <!-- Status Selection -->
      <div class="section-title">Status Kehadiran</div>
      <div class="status-selector mt-3">
        <button 
          class="status-btn {selectedStatus === 'hadir' ? 'hadir-active' : 'hadir-inactive'}" 
          onclick={() => selectedStatus = 'hadir'}
        >Hadir</button>
        <button 
          class="status-btn {selectedStatus === 'izin' ? 'izin-active' : 'izin-inactive'}" 
          onclick={() => selectedStatus = 'izin'}
        >Izin</button>
        <button 
          class="status-btn {selectedStatus === 'sakit' ? 'sakit-active' : 'sakit-inactive'}" 
          onclick={() => selectedStatus = 'sakit'}
        >Sakit</button>
        <button 
          class="status-btn {selectedStatus === 'alfa' ? 'alfa-active' : 'alfa-inactive'}" 
          onclick={() => selectedStatus = 'alfa'}
        >Alfa</button>
      </div>
      
      <!-- Keterangan -->
      <div class="mt-6">
        <TextField
          bind:value={keterangan}
          label="Keterangan"
          placeholder="Masukkan keterangan (opsional)"
          multiline={true}
          rows={3}
        />
      </div>
      
      <!-- File Upload -->
      {#if selectedStatus === 'izin' || selectedStatus === 'sakit'}
        <div class="mt-6">
          <div class="section-title">Surat Keterangan (Opsional)</div>
          
          <div class="upload-area mt-3" onclick={() => document.getElementById('file-upload')?.click()}>
            {#if fileName}
              <svg class="upload-icon active" xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="16" y1="13" x2="8" y2="13"></line><line x1="16" y1="17" x2="8" y2="17"></line><polyline points="10 9 9 9 8 9"></polyline></svg>
              <div class="upload-text active">{fileName}</div>
            {:else}
              <svg class="upload-icon" xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path><polyline points="17 8 12 3 7 8"></polyline><line x1="12" y1="3" x2="12" y2="15"></line></svg>
              <div class="upload-text">Tap untuk upload file</div>
              <div class="upload-hint">JPG, PNG, atau PDF (Max 2MB)</div>
            {/if}
            
            <input 
              id="file-upload" 
              type="file" 
              class="hidden-input" 
              accept=".jpg,.jpeg,.png,.pdf"
              onchange={handleFileSelect}
            />
          </div>
        </div>
      {/if}

      <div class="submit-action">
        <Button 
          text="Simpan Perubahan" 
          onClick={submitForm} 
          isLoading={submitting} 
        />
      </div>
    </div>
  {/if}
</PageLayout>

<style>
  .edit-form {
    padding: 16px;
    padding-bottom: 40px;
  }
  
  .mt-3 { margin-top: 12px; }
  .mt-6 { margin-top: 24px; }
  
  .student-info-card {
    display: flex;
    align-items: center;
    padding: 16px;
    background-color: rgba(13, 71, 161, 0.1);
    border-radius: 12px;
    margin-bottom: 24px;
  }
  
  .avatar {
    width: 40px;
    height: 40px;
    border-radius: 20px;
    background-color: var(--primary);
    color: white;
    display: flex;
    align-items: center;
    justify-content: center;
    font-weight: bold;
    font-size: 16px;
    margin-right: 12px;
  }
  
  .info-text {
    display: flex;
    flex-direction: column;
  }
  
  .nama {
    font-weight: bold;
    font-size: 16px;
    color: var(--text-primary);
  }
  
  .nis {
    font-size: 12px;
    color: var(--text-secondary);
  }
  
  .section-title {
    font-size: 14px;
    font-weight: 500;
    color: var(--text-primary);
  }
  
  .status-selector {
    display: flex;
    gap: 8px;
  }
  
  .status-btn {
    flex: 1;
    padding: 12px 0;
    border-radius: 8px;
    font-weight: 600;
    font-size: 12px;
    cursor: pointer;
    border: 1px solid;
    transition: all 0.2s;
  }
  
  .hadir-active { background-color: var(--hadir); color: white; border-color: var(--hadir); }
  .hadir-inactive { background-color: rgba(39, 174, 96, 0.1); color: var(--hadir); border-color: rgba(39, 174, 96, 0.3); }
  
  .izin-active { background-color: var(--izin); color: white; border-color: var(--izin); }
  .izin-inactive { background-color: rgba(242, 201, 76, 0.1); color: var(--izin); border-color: rgba(242, 201, 76, 0.3); }
  
  .sakit-active { background-color: var(--sakit); color: white; border-color: var(--sakit); }
  .sakit-inactive { background-color: rgba(45, 156, 219, 0.1); color: var(--sakit); border-color: rgba(45, 156, 219, 0.3); }
  
  .alfa-active { background-color: var(--alfa); color: white; border-color: var(--alfa); }
  .alfa-inactive { background-color: rgba(235, 87, 87, 0.1); color: var(--alfa); border-color: rgba(235, 87, 87, 0.3); }
  
  .upload-area {
    background-color: #f9fafb;
    border: 1px solid var(--border);
    border-radius: 12px;
    padding: 24px;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    cursor: pointer;
  }
  
  .upload-icon {
    color: var(--text-secondary);
    margin-bottom: 8px;
  }
  
  .upload-icon.active {
    color: var(--primary);
  }
  
  .upload-text {
    color: var(--text-secondary);
    font-size: 14px;
  }
  
  .upload-text.active {
    color: var(--text-primary);
  }
  
  .upload-hint {
    font-size: 12px;
    color: var(--text-secondary);
    margin-top: 4px;
  }
  
  .hidden-input {
    display: none;
  }
  
  .submit-action {
    margin-top: 24px;
  }
</style>
