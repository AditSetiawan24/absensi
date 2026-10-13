<script lang="ts">
  import { onMount } from 'svelte';
  import { authStore } from '../../lib/stores/auth';
  import { laporanApi } from '../../lib/api/laporan';
  import { kelasApi } from '../../lib/api/kelas';
  import { toast } from '../../lib/stores/toast';
  import { exportRekapToExcel, printRekapPdf } from '../../lib/utils/export';
  
  import PageLayout from '../../components/layout/PageLayout.svelte';
  import Loading from '../../components/ui/Loading.svelte';

  let listRekap = $state<any[]>([]);
  let kelasList = $state<any[]>([]);
  let selectedKelas = $state<any>(null);
  let loading = $state(true);
  let error = $state<string | null>(null);
  
  // Dialog state
  let showCreateDialog = $state(false);
  let isCreating = $state(false);

  // Download sheet state
  let showDownloadOptions = $state(false);
  let selectedRekapDownload = $state<any>(null);
  
  const currDate = new Date();
  let selectedBulan = $state(currDate.getMonth() + 1);
  let selectedTahun = $state(currDate.getFullYear());
  
  const namaBulan = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];

  function formatNamaBulan(bulan: any): string {
    if (!bulan) return '-';
    if (typeof bulan === 'number' && bulan >= 1 && bulan <= 12) {
      return namaBulan[bulan - 1];
    }
    const num = parseInt(bulan, 10);
    if (!isNaN(num) && num >= 1 && num <= 12) {
      return namaBulan[num - 1];
    }
    return String(bulan);
  }

  async function loadKelas() {
    loading = true;
    error = null;
    const nip = $authStore.user?.nip;
    
    if (nip) {
      const res = await kelasApi.getByGuru(nip);
      if (res.success && res.data) {
        kelasList = res.data;
        if (kelasList.length > 0) {
          selectedKelas = kelasList[0];
          await loadRekap();
        } else {
          loading = false;
        }
      } else {
        error = 'Gagal memuat data kelas';
        loading = false;
      }
    } else {
      loading = false;
    }
  }
  
  async function loadRekap() {
    const idKelas = selectedKelas?.id_kelas || selectedKelas?.idKelas;
    if (!idKelas) {
      listRekap = [];
      loading = false;
      return;
    }
    
    loading = true;
    error = null;
    
    const res = await laporanApi.getRekapBulanan({ id_kelas: idKelas });
    
    if (res.success && res.data) {
      listRekap = Array.isArray(res.data) ? res.data : ((res.data as any).data || []);
    } else {
      error = res.message || 'Gagal memuat rekap';
    }
    
    loading = false;
  }

  onMount(() => {
    loadKelas();
  });
  
  async function createRekap() {
    const idKelas = selectedKelas?.id_kelas || selectedKelas?.idKelas;
    if (!idKelas) {
      toast.error('Pilih kelas terlebih dahulu');
      return;
    }
    
    const nip = $authStore.user?.nip || '';
    isCreating = true;
    
    const res = await laporanApi.createRekap({
      id_kelas: idKelas,
      nip: nip,
      bulan: selectedBulan,
      tahun: selectedTahun
    });
    
    isCreating = false;
    showCreateDialog = false;
    
    if (res.success) {
      toast.success(res.message || 'Rekap berhasil dibuat');
      loadRekap();
    } else {
      toast.error(res.message || 'Gagal membuat rekap');
    }
  }

  async function deleteRekap(rekap: any) {
    const id = rekap.id_laporan || rekap.idLaporan;
    const bName = formatNamaBulan(rekap.bulan || rekap.namaBulan);
    if (confirm(`Yakin ingin menghapus rekap ${bName} ${rekap.tahun}?`)) {
      const res = await laporanApi.deleteRekap(id);
      
      if (res.success) {
        toast.success('Rekap berhasil dihapus');
        loadRekap();
      } else {
        toast.error(res.message || 'Gagal menghapus rekap');
      }
    }
  }
  
  function checkIsSubmitted(rekap: any): boolean {
    if (!rekap) return false;
    if (rekap.is_submitted === true || rekap.is_submitted === 1 || rekap.is_submitted === '1' || rekap.isSubmitted === true || rekap.isSubmitted === 1) {
      return true;
    }
    const s = String(rekap.status || rekap.status_persetujuan || '').toLowerCase();
    return s === 'submitted' || s === 'disubmit' || s === 'approved' || s === 'disetujui';
  }

  async function submitRekap(rekap: any) {
    const id = rekap.id_laporan || rekap.idLaporan;
    const bName = formatNamaBulan(rekap.bulan || rekap.namaBulan);
    if (confirm(`Submit rekap ${bName} ${rekap.tahun}?\nRekap yang sudah disubmit tidak dapat diedit.`)) {
      const res = await laporanApi.submitRekap(id);
      
      if (res.success) {
        toast.success('Rekap berhasil disubmit');
        await loadRekap();
      } else {
        toast.error(res.message || 'Gagal submit rekap');
      }
    }
  }
  
  async function unsubmitRekap(rekap: any) {
    const id = rekap.id_laporan || rekap.idLaporan;
    const bName = formatNamaBulan(rekap.bulan || rekap.namaBulan);
    if (confirm(`Batalkan submit rekap ${bName} ${rekap.tahun}?`)) {
      const res = await laporanApi.unsubmitRekap(id);
      
      if (res.success) {
        toast.success('Submit rekap berhasil dibatalkan');
        await loadRekap();
      } else {
        toast.error(res.message || 'Gagal membatalkan submit');
      }
    }
  }
  
  async function refreshRekapData(rekap: any) {
    const id = rekap.id_laporan || rekap.idLaporan;
    const res = await laporanApi.refreshRekap(id);
    
    if (res.success) {
      toast.success('Data rekap berhasil di-refresh');
      loadRekap();
    } else {
      toast.error(res.message || 'Gagal refresh data');
    }
  }

  function openDownloadModal(rekap: any) {
    selectedRekapDownload = rekap;
    showDownloadOptions = true;
  }

  function handleDownloadPdf() {
    if (!selectedRekapDownload) return;
    const kelasName = selectedKelas?.kelas || selectedKelas?.nama_kelas || '-';
    printRekapPdf(selectedRekapDownload, kelasName);
    showDownloadOptions = false;
  }

  function handleDownloadExcel() {
    if (!selectedRekapDownload) return;
    const kelasName = selectedKelas?.kelas || selectedKelas?.nama_kelas || '-';
    exportRekapToExcel(selectedRekapDownload, kelasName);
    showDownloadOptions = false;
  }
  
  function getStatColor(label: string) {
    switch (label) {
      case 'Hadir': return 'var(--hadir)';
      case 'Izin': return 'var(--izin)';
      case 'Sakit': return 'var(--sakit)';
      case 'Alfa': return 'var(--alfa)';
      default: return 'var(--primary)';
    }
  }
</script>

<PageLayout title="Rekap Bulanan" showBack={true} hasBottomNav={true}>
  <!-- FAB -->
  <div class="fab-container">
    <button class="fab" onclick={() => showCreateDialog = true} title="Buat Rekap">
      <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"></line><line x1="5" y1="12" x2="19" y2="12"></line></svg>
    </button>
  </div>

  <div class="page-content">
    <!-- Kelas Selector -->
    {#if kelasList.length > 0}
      <div class="kelas-selector">
        <span class="kelas-label">Kelas: </span>
        <select 
          class="kelas-dropdown" 
          value={selectedKelas?.id_kelas || selectedKelas?.idKelas}
          onchange={(e) => {
            const targetId = Number((e.target as HTMLSelectElement).value);
            selectedKelas = kelasList.find(k => (k.id_kelas || k.idKelas) === targetId);
            loadRekap();
          }}
        >
          {#each kelasList as kelas}
            <option value={kelas.id_kelas || kelas.idKelas}>Kelas {kelas.kelas || kelas.nama_kelas}</option>
          {/each}
        </select>
      </div>
    {/if}

    <div class="main-content">
      {#if loading}
        <Loading />
      {:else if error}
        <div class="empty-state">
          <div class="error-text">{error}</div>
          <button class="retry-btn" onclick={loadRekap}>Coba Lagi</button>
        </div>
      {:else if listRekap.length === 0}
        <div class="empty-state">
          <svg xmlns="http://www.w3.org/2000/svg" width="64" height="64" viewBox="0 0 24 24" fill="none" stroke="var(--text-secondary)" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" class="empty-icon"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect><line x1="16" y1="2" x2="16" y2="6"></line><line x1="8" y1="2" x2="8" y2="6"></line><line x1="3" y1="10" x2="21" y2="10"></line></svg>
          <div class="empty-text">Belum ada rekap bulanan</div>
          <div class="empty-subtext">Tap + untuk membuat rekap baru</div>
        </div>
      {:else}
        <div class="rekap-list">
          {#each listRekap as rekap}
            {@const isSubmitted = checkIsSubmitted(rekap)}
            {@const colorCode = isSubmitted ? 'var(--success)' : 'var(--warning)'}
            {@const total = (rekap.hadir || rekap.total_hadir || 0) + (rekap.izin || rekap.total_izin || 0) + (rekap.sakit || rekap.total_sakit || 0) + (rekap.alfa || rekap.total_alfa || 0)}
            {@const persentaseHadir = total > 0 ? (((rekap.hadir || rekap.total_hadir || 0) / total) * 100) : 0}
            {@const progressColor = persentaseHadir >= 80 ? 'var(--success)' : (persentaseHadir >= 60 ? 'var(--warning)' : 'var(--error)')}
            
            <div class="rekap-card" style="border-color: {colorCode}">
              <!-- Header -->
              <div class="card-header" style="background-color: {isSubmitted ? 'rgba(39, 174, 96, 0.1)' : 'rgba(242, 201, 76, 0.1)'}">
                <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke={colorCode} stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="header-icon"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect><line x1="16" y1="2" x2="16" y2="6"></line><line x1="8" y1="2" x2="8" y2="6"></line><line x1="3" y1="10" x2="21" y2="10"></line></svg>
                
                <div class="header-info">
                  <div class="bulan-tahun">{formatNamaBulan(rekap.bulan || rekap.namaBulan)} {rekap.tahun}</div>
                  <div class="periode">{rekap.periode_awal || rekap.periodeAwal || '-'} - {rekap.periode_akhir || rekap.periodeAkhir || '-'}</div>
                </div>
                
                <div class="status-badge" style="background-color: {colorCode}">
                  {isSubmitted ? 'Submitted' : 'Draft'}
                </div>
              </div>
              
              <!-- Stats -->
              <div class="card-stats">
                <div class="stats-row">
                  {#each [
                    {label: 'Hadir', value: rekap.hadir ?? rekap.total_hadir ?? 0, color: 'var(--success)'},
                    {label: 'Izin', value: rekap.izin ?? rekap.total_izin ?? 0, color: 'var(--info)'},
                    {label: 'Sakit', value: rekap.sakit ?? rekap.total_sakit ?? 0, color: 'var(--warning)'},
                    {label: 'Alfa', value: rekap.alfa ?? rekap.total_alfa ?? 0, color: 'var(--error)'}
                  ] as stat}
                    <div class="stat-item">
                      <div class="stat-circle" style="background-color: {stat.color}1a; color: {stat.color}">
                        {stat.value}
                      </div>
                      <div class="stat-label">{stat.label}</div>
                    </div>
                  {/each}
                </div>
                
                <div class="progress-container">
                  <div class="progress-bar">
                    <div class="progress-fill" style="width: {persentaseHadir}%; background-color: {progressColor}"></div>
                  </div>
                  <div class="progress-text">Kehadiran: {persentaseHadir.toFixed(1)}%</div>
                </div>
              </div>
              
              <!-- Actions -->
              <div class="card-actions">
                {#if !isSubmitted}
                  <button class="icon-btn" title="Refresh Data" onclick={() => refreshRekapData(rekap)}>
                    <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 2v6h-6"></path><path d="M3 12a9 9 0 0 1 15-6.7L21 8"></path><path d="M3 22v-6h6"></path><path d="M21 12a9 9 0 0 1-15 6.7L3 16"></path></svg>
                  </button>
                  <button class="icon-btn delete" title="Hapus" onclick={() => deleteRekap(rekap)}>
                    <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="var(--error)" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path></svg>
                  </button>
                  <button class="icon-btn success" title="Submit" onclick={() => submitRekap(rekap)}>
                    <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="var(--success)" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path><polyline points="22 4 12 14.01 9 11.01"></polyline></svg>
                  </button>
                {:else}
                  <button class="icon-btn warning" title="Batal Submit" onclick={() => unsubmitRekap(rekap)}>
                    <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="var(--warning)" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 7v6h6"></path><path d="M21 17a9 9 0 0 0-9-9 9 9 0 0 0-6 2.3l-3 2.7"></path></svg>
                  </button>
                {/if}
                <button class="icon-btn primary" title="Download" onclick={() => openDownloadModal(rekap)}>
                  <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="var(--primary)" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path><polyline points="7 10 12 15 17 10"></polyline><line x1="12" y1="15" x2="12" y2="3"></line></svg>
                </button>
              </div>
            </div>
          {/each}
        </div>
      {/if}
    </div>
  </div>

  <!-- Create Dialog (BottomSheet style) -->
  {#if showCreateDialog}
    <!-- svelte-ignore a11y_click_events_have_key_events -->
    <!-- svelte-ignore a11y_no_static_element_interactions -->
    <div class="bottom-sheet-backdrop" onclick={() => !isCreating && (showCreateDialog = false)}>
      <div class="bottom-sheet" onclick={e => e.stopPropagation()}>
        <div class="sheet-title">Buat Rekap Bulanan</div>
        
        <div class="form-group mt-4">
          <label class="form-label" for="bulan">Bulan</label>
          <select id="bulan" class="form-select" bind:value={selectedBulan}>
            {#each namaBulan as bulan, i}
              <option value={i + 1}>{bulan}</option>
            {/each}
          </select>
        </div>
        
        <div class="form-group mt-4">
          <label class="form-label" for="tahun">Tahun</label>
          <select id="tahun" class="form-select" bind:value={selectedTahun}>
            {#each Array(10) as _, i}
              {@const year = currDate.getFullYear() - 2 + i}
              <option value={year}>{year}</option>
            {/each}
          </select>
        </div>
        
        <button class="btn-create mt-6" onclick={createRekap} disabled={isCreating}>
          {#if isCreating}
            <div class="spinner"></div>
          {:else}
            Buat Rekap
          {/if}
        </button>
      </div>
    </div>
  {/if}

  <!-- Download Options BottomSheet -->
  {#if showDownloadOptions}
    <!-- svelte-ignore a11y_click_events_have_key_events -->
    <!-- svelte-ignore a11y_no_static_element_interactions -->
    <div class="bottom-sheet-backdrop" onclick={() => showDownloadOptions = false}>
      <div class="bottom-sheet" onclick={e => e.stopPropagation()}>
        <div class="sheet-title">Download Rekap</div>
        <p class="sheet-subtitle">Pilih format dokumen untuk {formatNamaBulan(selectedRekapDownload?.bulan || selectedRekapDownload?.namaBulan)} {selectedRekapDownload?.tahun || ''}</p>
        
        <div class="download-options-list">
          <button class="download-option-item" onclick={handleDownloadPdf}>
            <div class="download-icon pdf-icon">
              <svg xmlns="http://www.w3.org/2000/svg" width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="#e53935" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="16" y1="13" x2="8" y2="13"></line><line x1="16" y1="17" x2="8" y2="17"></line><polyline points="10 9 9 9 8 9"></polyline></svg>
            </div>
            <div class="download-info">
              <div class="download-title">Download PDF</div>
              <div class="download-desc">Untuk dicetak atau dikirim</div>
            </div>
          </button>

          <button class="download-option-item" onclick={handleDownloadExcel}>
            <div class="download-icon excel-icon">
              <svg xmlns="http://www.w3.org/2000/svg" width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="#2e7d32" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="8" y1="13" x2="16" y2="13"></line><line x1="8" y1="17" x2="16" y2="17"></line><polyline points="10 9 9 9 8 9"></polyline></svg>
            </div>
            <div class="download-info">
              <div class="download-title">Download Excel</div>
              <div class="download-desc">Untuk diolah lebih lanjut</div>
            </div>
          </button>
        </div>
      </div>
    </div>
  {/if}
</PageLayout>

<style>
  .page-content {
    display: flex;
    flex-direction: column;
    min-height: 100vh;
    padding-bottom: 90px;
  }
  
  .fab-container {
    position: fixed;
    bottom: 90px;
    right: 16px;
    z-index: 50;
  }
  
  .fab {
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
  
  .kelas-selector {
    padding: 16px;
    background-color: #f5f5f5;
    display: flex;
    align-items: center;
  }
  
  .kelas-label {
    font-weight: bold;
    margin-right: 12px;
  }
  
  .kelas-dropdown {
    flex: 1;
    padding: 8px 12px;
    border: 1px solid var(--border);
    border-radius: 4px;
    background-color: white;
    font-size: 14px;
  }
  
  .main-content {
    flex: 1;
    padding: 16px;
  }
  
  .empty-state {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    height: 300px;
  }
  
  .empty-icon {
    margin-bottom: 16px;
    width: 64px;
    height: 64px;
    opacity: 0.5;
  }
  
  .empty-text {
    font-size: 16px;
    color: var(--text-secondary);
  }
  
  .empty-subtext {
    font-size: 14px;
    color: var(--text-secondary);
    margin-top: 8px;
  }
  
  .error-text {
    color: var(--error);
    margin-bottom: 16px;
  }
  
  .retry-btn {
    background-color: var(--primary);
    color: white;
    border: none;
    padding: 8px 16px;
    border-radius: 4px;
    cursor: pointer;
  }
  
  .rekap-list {
    display: flex;
    flex-direction: column;
    gap: 12px;
  }
  
  .rekap-card {
    background: white;
    border-radius: 12px;
    border: 2px solid;
    overflow: hidden;
  }
  
  .card-header {
    padding: 12px;
    display: flex;
    align-items: center;
  }
  
  .header-icon {
    margin-right: 8px;
  }
  
  .header-info {
    flex: 1;
  }
  
  .bulan-tahun {
    font-weight: bold;
    font-size: 16px;
    color: var(--text-primary);
  }
  
  .periode {
    font-size: 12px;
    color: var(--text-secondary);
  }
  
  .status-badge {
    padding: 4px 8px;
    border-radius: 12px;
    color: white;
    font-size: 12px;
    font-weight: 500;
  }
  
  .card-stats {
    padding: 12px;
  }
  
  .stats-row {
    display: flex;
    justify-content: space-around;
    margin-bottom: 12px;
  }
  
  .stat-item {
    display: flex;
    flex-direction: column;
    align-items: center;
  }
  
  .stat-circle {
    width: 40px;
    height: 40px;
    border-radius: 20px;
    display: flex;
    align-items: center;
    justify-content: center;
    font-weight: bold;
    font-size: 16px;
    margin-bottom: 4px;
  }
  
  .stat-label {
    font-size: 12px;
    color: var(--text-secondary);
  }
  
  .progress-container {
    margin-top: 12px;
  }
  
  .progress-bar {
    height: 4px;
    background-color: var(--divider);
    border-radius: 2px;
    overflow: hidden;
    margin-bottom: 4px;
  }
  
  .progress-fill {
    height: 100%;
    transition: width 0.3s ease;
  }
  
  .progress-text {
    font-size: 12px;
    color: var(--text-secondary);
  }
  
  .card-actions {
    padding: 4px 8px;
    background-color: #fafafa;
    display: flex;
    justify-content: flex-end;
    gap: 8px;
  }
  
  .icon-btn {
    background: transparent;
    border: none;
    padding: 8px;
    border-radius: 20px;
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
  }
  
  .icon-btn:hover {
    background-color: rgba(0,0,0,0.05);
  }
  
  /* Bottom Sheet */
  .bottom-sheet-backdrop {
    position: fixed;
    inset: 0;
    background-color: rgba(0, 0, 0, 0.5);
    z-index: 1000;
    display: flex;
    align-items: flex-end;
  }
  
  .bottom-sheet {
    background-color: white;
    width: 100%;
    border-radius: 20px 20px 0 0;
    padding: 20px;
    padding-bottom: calc(20px + env(safe-area-inset-bottom));
    animation: slideUp 0.3s ease-out;
  }
  
  .sheet-title {
    font-size: 18px;
    font-weight: bold;
    color: var(--text-primary);
  }
  
  .mt-4 { margin-top: 16px; }
  .mt-6 { margin-top: 24px; }
  
  .form-group {
    display: flex;
    flex-direction: column;
    gap: 8px;
  }
  
  .form-label {
    font-size: 14px;
    color: var(--text-secondary);
  }
  
  .form-select {
    padding: 12px;
    border: 1px solid var(--border);
    border-radius: 4px;
    background-color: white;
    font-size: 16px;
  }
  
  .btn-create {
    width: 100%;
    padding: 14px;
    background-color: var(--primary);
    color: white;
    border: none;
    border-radius: 4px;
    font-size: 16px;
    font-weight: 500;
    cursor: pointer;
    display: flex;
    justify-content: center;
  }
  
  .btn-create:disabled {
    opacity: 0.7;
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
  
  @keyframes slideUp {
    from { transform: translateY(100%); }
    to { transform: translateY(0); }
  }

  .sheet-subtitle {
    margin: 4px 0 16px 0;
    font-size: 13px;
    color: var(--text-secondary);
  }

  .download-options-list {
    display: flex;
    flex-direction: column;
    gap: 8px;
    margin-top: 8px;
  }

  .download-option-item {
    display: flex;
    align-items: center;
    gap: 16px;
    padding: 12px 14px;
    background: #f8fafc;
    border: 1px solid var(--border);
    border-radius: 12px;
    cursor: pointer;
    text-align: left;
    width: 100%;
    transition: background 0.15s ease, border-color 0.15s ease;
  }

  .download-option-item:hover {
    background: #f1f5f9;
    border-color: #cbd5e1;
  }

  .download-icon {
    width: 44px;
    height: 44px;
    border-radius: 10px;
    display: flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
  }

  .pdf-icon {
    background: #ffebee;
  }

  .excel-icon {
    background: #e8f5e9;
  }

  .download-info {
    flex: 1;
  }

  .download-title {
    font-size: 15px;
    font-weight: 600;
    color: var(--text-primary);
  }

  .download-desc {
    font-size: 13px;
    color: var(--text-secondary);
    margin-top: 2px;
  }
</style>
