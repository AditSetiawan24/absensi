<script lang="ts">
  import { onMount } from 'svelte';
  import { push } from 'svelte-spa-router';
  import { siswaApi } from '../../lib/api/siswa';
  import { kelasApi } from '../../lib/api/kelas';
  import { toast } from '../../lib/stores/toast';
  import { authStore } from '../../lib/stores/auth';
  import PageLayout from '../../components/layout/PageLayout.svelte';
  import Button from '../../components/ui/Button.svelte';

  let file: File | null = $state(null);
  let loading = $state(false);
  let kelasList = $state<any[]>([]);
  let selectedKelas = $state<any>(null);

  onMount(async () => {
    const nip = $authStore.user?.nip;
    if (nip) {
      const res = await kelasApi.getByGuru(nip);
      if (res.success && res.data && res.data.length > 0) {
        kelasList = res.data;
        selectedKelas = kelasList[0];
      }
    }
  });

  function handleFileChange(e: Event) {
    const target = e.target as HTMLInputElement;
    if (target.files && target.files.length > 0) {
      file = target.files[0];
    }
  }

  async function handleImport() {
    if (!file) {
      toast.error('Pilih file Excel terlebih dahulu');
      return;
    }

    const idKelas = selectedKelas?.id_kelas || selectedKelas?.idKelas;
    if (!idKelas) {
      toast.error('Kelas belum dipilih atau guru belum memiliki kelas.');
      return;
    }
    
    loading = true;
    try {
      const res = await siswaApi.import(file, idKelas);
      if (res.success) {
        toast.success(res.message || 'Siswa berhasil diimport');
        push('/guru/kelola-siswa');
      } else {
        toast.error(res.message || 'Gagal mengimport file');
      }
    } catch (e: any) {
      toast.error(e?.message || 'Gagal mengimport file');
    } finally {
      loading = false;
    }
  }
</script>

<PageLayout title="Import Siswa" showBack={true}>
  <div class="import-content">
    <div class="info-card">
      <h3>Panduan Import</h3>
      <ol>
        <li>Gunakan format file .xlsx atau .xls</li>
        <li>Pastikan kolom pertama adalah NIS dan kolom kedua Nama Siswa</li>
        <li>Ukuran file maksimal 2MB</li>
      </ol>
      <a href="#" class="text-primary text-sm font-semibold" style="text-decoration: none;">Download Template Excel</a>
    </div>

    {#if kelasList.length > 0}
      <div class="kelas-target-box">
        <label for="target-kelas" class="font-semibold text-sm">Target Kelas:</label>
        <select id="target-kelas" class="form-select mt-1" bind:value={selectedKelas}>
          {#each kelasList as k}
            <option value={k}>Kelas {k.kelas || k.nama_kelas}</option>
          {/each}
        </select>
      </div>
    {/if}

    <div class="upload-area">
      <label class="file-label">
        <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="upload-icon"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="17 8 12 3 7 8"/><line x1="12" y1="3" x2="12" y2="15"/></svg>
        <span>{file ? file.name : 'Pilih File Excel'}</span>
        <input type="file" accept=".xlsx,.xls" onchange={handleFileChange} />
      </label>
    </div>

    <div class="mt-6">
      <Button 
        text="Mulai Import" 
        onClick={handleImport} 
        isLoading={loading}
      />
    </div>
  </div>
</PageLayout>

<style>
  .import-content {
    padding: 24px;
  }
  
  .info-card {
    background: var(--surface);
    padding: 20px;
    border-radius: 12px;
    border: 1px solid var(--border);
    margin-bottom: 24px;
  }
  
  .info-card h3 {
    margin: 0 0 12px 0;
    font-size: 16px;
    color: var(--primary);
  }
  
  .info-card ol {
    margin: 0 0 16px 0;
    padding-left: 20px;
    color: var(--text-secondary);
    font-size: 14px;
    line-height: 1.6;
  }
  
  .upload-area {
    margin-top: 24px;
  }
  
  .file-label {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    border: 2px dashed var(--border);
    border-radius: 12px;
    padding: 40px 20px;
    cursor: pointer;
    background: var(--bg);
    transition: all 0.2s;
  }
  
  .file-label:hover {
    border-color: var(--primary);
    background: rgba(13, 71, 161, 0.05);
  }
  
  .file-label input {
    display: none;
  }
  
  .upload-icon {
    color: var(--primary);
    margin-bottom: 12px;
  }
  
  .file-label span {
    font-weight: 500;
    color: var(--text-primary);
  }

  .kelas-target-box {
    margin-bottom: 20px;
    background: var(--surface);
    padding: 16px;
    border-radius: 12px;
    border: 1px solid var(--border);
  }

  .form-select {
    width: 100%;
    padding: 10px 12px;
    border: 1px solid var(--border);
    border-radius: 8px;
    background-color: white;
    font-size: 14px;
    margin-top: 6px;
  }
</style>
