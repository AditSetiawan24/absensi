<script lang="ts">
  import { onMount } from 'svelte';
  import { pop } from 'svelte-spa-router';
  import { authStore } from '../../lib/stores/auth';
  import { dashboardApi } from '../../lib/api/dashboard';
  import { absensiApi } from '../../lib/api/absensi';
  import { kelasApi } from '../../lib/api/kelas';
  import { siswaApi } from '../../lib/api/siswa';
  import { toast } from '../../lib/stores/toast';
  
  import PageLayout from '../../components/layout/PageLayout.svelte';
  import Loading from '../../components/ui/Loading.svelte';

  let listSiswa = $state<any[]>([]);
  let listKelas = $state<any[]>([]);
  let loadingKelas = $state(true);
  let loadingSiswa = $state(false);
  let submitting = $state(false);
  
  const today = new Date();
  let tanggal = $state(today.toISOString().split('T')[0]);
  let selectedKelas = $state<number | null>(null);

  function formatDate(date: Date) {
    const days = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
    const months = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
    return `${days[date.getDay()]}, ${date.getDate()} ${months[date.getMonth()]} ${date.getFullYear()}`;
  }

  async function loadKelas() {
    loadingKelas = true;
    const nip = $authStore.user?.nip || '';
    
    let res = await kelasApi.getByGuru(nip);
    if (!res.success || !res.data || res.data.length === 0) {
      res = await kelasApi.getAll();
    }
    if (res.success && res.data) {
      listKelas = res.data;
      if (listKelas.length > 0) {
        selectedKelas = listKelas[0].id_kelas;
        await loadSiswa();
      }
    }
    loadingKelas = false;
  }

  async function loadSiswa() {
    if (!selectedKelas) return;
    
    loadingSiswa = true;

    const siswaRes = await siswaApi.getByKelas(selectedKelas);
    
    if (siswaRes.success && siswaRes.data) {
      listSiswa = siswaRes.data.map(s => ({
        ...s,
        status_kehadiran: 'hadir',
        keterangan: ''
      }));
    } else {
      listSiswa = [];
    }
    
    loadingSiswa = false;
  }

  onMount(() => {
    loadKelas();
  });

  async function submitForm() {
    if (!selectedKelas || listSiswa.length === 0) return;
    
    const nip = $authStore.user?.nip || '';

    // Check if absensi already exists for this class and date
    const existingRes = await absensiApi.getByKelas(selectedKelas, tanggal);
    if (existingRes.success && existingRes.data && existingRes.data.length > 0) {
      if (!confirm(`Sudah ada ${existingRes.data.length} data absensi untuk hari ini. Apakah Anda ingin mengganti data yang sudah ada?`)) {
        return;
      }
    }
    
    submitting = true;
    const absensiList = listSiswa.map(s => ({
      nis: s.nis,
      nip,
      tanggal,
      status_kehadiran: s.status_kehadiran,
      keterangan: s.keterangan || ''
    }));
    
    const res = await absensiApi.submitBulk({ absensi: absensiList });
    submitting = false;
    
    if (res.success) {
      toast.success('Absensi berhasil disimpan');
      pop();
    } else {
      toast.error(res.message || 'Gagal menyimpan absensi');
    }
  }
  
  function setStatus(index: number, status: string) {
    listSiswa[index].status_kehadiran = status;
  }
  
  function getCount(status: string) {
    return listSiswa.filter(s => s.status_kehadiran === status).length;
  }
</script>

<PageLayout title="Mulai Absensi" showBack={true} hasBottomNav={false}>
  <div class="top-actions">
    <button class="simpan-btn" onclick={submitForm} disabled={submitting || listSiswa.length === 0}>
      {#if submitting}
        <div class="spinner"></div>
      {:else}
        <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"></polyline></svg>
      {/if}
      <span>Simpan</span>
    </button>
  </div>

  <div class="absensi-container">
    <div class="filter-section">
      <div class="date-row">
        <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect><line x1="16" y1="2" x2="16" y2="6"></line><line x1="8" y1="2" x2="8" y2="6"></line><line x1="3" y1="10" x2="21" y2="10"></line></svg>
        <span class="date-text">{formatDate(today)}</span>
      </div>
      
      {#if loadingKelas}
        <div class="kelas-loading"><Loading /></div>
      {:else if listKelas.length > 0}
        <div class="dropdown-wrapper mt-4">
          <select bind:value={selectedKelas} onchange={loadSiswa} class="kelas-dropdown">
            <option value={null} disabled>Pilih Kelas</option>
            {#each listKelas as kelas}
              <option value={kelas.id_kelas}>Kelas {kelas.nama_kelas || kelas.kelas}</option>
            {/each}
          </select>
        </div>
      {/if}
    </div>

    <div class="list-container">
      {#if loadingSiswa}
        <Loading />
      {:else if listSiswa.length === 0}
        <div class="empty-state">Tidak ada siswa di kelas ini</div>
      {:else}
        <div class="siswa-list">
          {#each listSiswa as siswa, i}
            <div class="siswa-card">
              <div class="card-header">
                <div class="number-badge">{i + 1}</div>
                <div class="siswa-info">
                  <span class="nama">{siswa.nama}</span>
                  <span class="nis">NIS: {siswa.nis}</span>
                </div>
              </div>
              
              <div class="status-selector mt-3">
                <button 
                  class="status-btn {siswa.status_kehadiran === 'hadir' ? 'hadir-active' : 'hadir-inactive'}" 
                  onclick={() => setStatus(i, 'hadir')}
                >Hadir</button>
                <button 
                  class="status-btn {siswa.status_kehadiran === 'izin' ? 'izin-active' : 'izin-inactive'}" 
                  onclick={() => setStatus(i, 'izin')}
                >Izin</button>
                <button 
                  class="status-btn {siswa.status_kehadiran === 'sakit' ? 'sakit-active' : 'sakit-inactive'}" 
                  onclick={() => setStatus(i, 'sakit')}
                >Sakit</button>
                <button 
                  class="status-btn {siswa.status_kehadiran === 'alfa' ? 'alfa-active' : 'alfa-inactive'}" 
                  onclick={() => setStatus(i, 'alfa')}
                >Alfa</button>
              </div>
              
              {#if siswa.status_kehadiran !== 'hadir'}
                <div class="keterangan-wrapper mt-3">
                  <input 
                    type="text" 
                    placeholder="Keterangan (opsional)" 
                    bind:value={siswa.keterangan} 
                    class="keterangan-input" 
                  />
                </div>
              {/if}
            </div>
          {/each}
        </div>
      {/if}
    </div>

    {#if listSiswa.length > 0}
      <div class="summary-section">
        <div class="summary-item">
          <div class="summary-count" style="color: var(--hadir); background: rgba(39, 174, 96, 0.1)">{getCount('hadir')}</div>
          <div class="summary-label">Hadir</div>
        </div>
        <div class="summary-item">
          <div class="summary-count" style="color: var(--izin); background: rgba(242, 201, 76, 0.1)">{getCount('izin')}</div>
          <div class="summary-label">Izin</div>
        </div>
        <div class="summary-item">
          <div class="summary-count" style="color: var(--sakit); background: rgba(45, 156, 219, 0.1)">{getCount('sakit')}</div>
          <div class="summary-label">Sakit</div>
        </div>
        <div class="summary-item">
          <div class="summary-count" style="color: var(--alfa); background: rgba(235, 87, 87, 0.1)">{getCount('alfa')}</div>
          <div class="summary-label">Alfa</div>
        </div>
      </div>
    {/if}
  </div>
</PageLayout>

<style>
  .top-actions {
    position: absolute;
    top: 16px;
    right: 16px;
    z-index: 100;
  }
  
  .simpan-btn {
    display: flex;
    align-items: center;
    gap: 8px;
    background: transparent;
    color: white;
    border: none;
    font-size: 14px;
    font-weight: 500;
    cursor: pointer;
  }
  
  .simpan-btn:disabled {
    color: rgba(255, 255, 255, 0.5);
    cursor: not-allowed;
  }
  
  .spinner {
    width: 20px;
    height: 20px;
    border: 2px solid rgba(255,255,255,0.3);
    border-radius: 50%;
    border-top-color: white;
    animation: spin 1s ease-in-out infinite;
  }
  
  @keyframes spin {
    to { transform: rotate(360deg); }
  }
  
  .absensi-container {
    display: flex;
    flex-direction: column;
    height: 100%;
  }
  
  .filter-section {
    padding: 16px;
    background-color: #f9fafb;
  }
  
  .date-row {
    display: flex;
    align-items: center;
    gap: 8px;
  }
  
  .date-text {
    font-weight: 600;
    font-size: 16px;
    color: var(--text-primary);
  }
  
  .mt-4 { margin-top: 16px; }
  .mt-3 { margin-top: 12px; }
  
  .dropdown-wrapper {
    background-color: white;
    border-radius: 12px;
    border: 1px solid var(--border);
    overflow: hidden;
  }
  
  .kelas-dropdown {
    width: 100%;
    padding: 12px;
    border: none;
    background: transparent;
    font-size: 14px;
    font-family: inherit;
    outline: none;
  }
  
  .kelas-loading {
    padding: 20px;
  }
  
  .list-container {
    flex: 1;
    overflow-y: auto;
  }
  
  .empty-state {
    padding: 40px;
    text-align: center;
    color: var(--text-secondary);
  }
  
  .siswa-list {
    display: flex;
    flex-direction: column;
    padding: 16px;
  }
  
  .siswa-card {
    background: white;
    padding: 16px;
    border-radius: 12px;
    box-shadow: 0 4px 10px rgba(0,0,0,0.05);
    margin-bottom: 12px;
  }
  
  .card-header {
    display: flex;
    align-items: center;
  }
  
  .number-badge {
    width: 40px;
    height: 40px;
    border-radius: 10px;
    background-color: rgba(13, 71, 161, 0.1);
    color: var(--primary);
    display: flex;
    align-items: center;
    justify-content: center;
    font-weight: bold;
    margin-right: 12px;
    flex-shrink: 0;
  }
  
  .siswa-info {
    display: flex;
    flex-direction: column;
  }
  
  .nama {
    font-weight: 600;
    font-size: 16px;
    color: var(--text-primary);
  }
  
  .nis {
    font-size: 12px;
    color: var(--text-secondary);
  }
  
  .status-selector {
    display: flex;
    gap: 8px;
  }
  
  .status-btn {
    flex: 1;
    padding: 8px 0;
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
  
  .keterangan-input {
    width: 100%;
    padding: 12px;
    border-radius: 8px;
    border: 1px solid var(--border);
    font-size: 14px;
    font-family: inherit;
    outline: none;
  }
  
  .summary-section {
    display: flex;
    justify-content: space-around;
    padding: 16px;
    background: white;
    box-shadow: 0 -4px 10px rgba(0,0,0,0.05);
  }
  
  .summary-item {
    display: flex;
    flex-direction: column;
    align-items: center;
  }
  
  .summary-count {
    width: 40px;
    height: 40px;
    border-radius: 10px;
    display: flex;
    align-items: center;
    justify-content: center;
    font-weight: bold;
    font-size: 18px;
    margin-bottom: 4px;
  }
  
  .summary-label {
    font-size: 12px;
    color: var(--text-secondary);
  }
</style>
