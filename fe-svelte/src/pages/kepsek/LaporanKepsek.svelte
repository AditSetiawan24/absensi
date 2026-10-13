<script lang="ts">
  import { onMount } from 'svelte';
  import { laporanApi } from '../../lib/api/laporan';
  import { kelasApi } from '../../lib/api/kelas';
  import { toast } from '../../lib/stores/toast';
  import { printLaporanPdf, exportLaporanToExcel, resolveTahunAjar, resolveSemester } from '../../lib/utils/export';
  
  import PageLayout from '../../components/layout/PageLayout.svelte';
  import Loading from '../../components/ui/Loading.svelte';

  let listRekap = $state<any[]>([]);
  let listKelas = $state<any[]>([]);
  let loading = $state(true);
  let error = $state<string | null>(null);
  
  // Filters
  let selectedKelas = $state<string | null>(null);
  let selectedSemester = $state<string | null>(null);
  let selectedTahunAjar = $state<string | null>(null);

  // Bottom Sheet
  let showDownloadOptions = $state(false);
  let selectedLaporan = $state<any>(null);

  async function loadInitial() {
    loading = true;
    error = null;
    
    try {
      const kelasRes = await kelasApi.getAll();
      if (kelasRes.success && kelasRes.data) {
        listKelas = kelasRes.data;
      }
      
      await fetchLaporan();
    } catch (e) {
      error = 'Gagal memuat data';
    } finally {
      loading = false;
    }
  }

  async function fetchLaporan() {
    loading = true;
    const res = await laporanApi.getAll();
    loading = false;
    
    if (res.success && res.data) {
      listRekap = res.data;
    } else {
      error = res.message || 'Gagal mengambil laporan';
    }
  }

  onMount(() => {
    loadInitial();
  });
  
  let tahunAjarOptions = $derived.by(() => {
    const opts = new Set<string>();
    listRekap.forEach(l => {
      const ta = resolveTahunAjar(l);
      if (ta && ta !== '-') opts.add(ta);
    });
    return Array.from(opts);
  });
  
  let filteredLaporan = $derived.by(() => {
    return listRekap.filter(l => {
      if (selectedKelas && String(l.id_kelas) !== selectedKelas && String(l.idKelas) !== selectedKelas) return false;
      
      const lSemester = resolveSemester(l);
      if (selectedSemester && lSemester !== selectedSemester) return false;
      
      const lTahunAjar = resolveTahunAjar(l);
      if (selectedTahunAjar && lTahunAjar !== selectedTahunAjar) return false;
      
      return true;
    });
  });

  function openDownload(laporan: any) {
    selectedLaporan = laporan;
    showDownloadOptions = true;
  }
  
  function downloadPdf() {
    showDownloadOptions = false;
    if (selectedLaporan) {
      const kelasObj = listKelas.find(k => String(k.id_kelas) === String(selectedLaporan.id_kelas || selectedLaporan.idKelas));
      const kelasName = selectedLaporan.kelas?.kelas || selectedLaporan.nama_kelas || (kelasObj ? `Kelas ${kelasObj.kelas}` : '-');
      toast.info('Membuka pratinjau cetak PDF...');
      printLaporanPdf(selectedLaporan, kelasName);
    }
  }
  
  function downloadExcel() {
    showDownloadOptions = false;
    if (selectedLaporan) {
      const kelasObj = listKelas.find(k => String(k.id_kelas) === String(selectedLaporan.id_kelas || selectedLaporan.idKelas));
      const kelasName = selectedLaporan.kelas?.kelas || selectedLaporan.nama_kelas || (kelasObj ? `Kelas ${kelasObj.kelas}` : '-');
      toast.success('Mengunduh spreadsheet Excel...');
      exportLaporanToExcel(selectedLaporan, kelasName);
    }
  }
</script>

<PageLayout title="Laporan Kehadiran" showBack={false} hasBottomNav={true}>
  <div class="page-container">
    <!-- Filter Section -->
    <div class="filter-section">
      <div class="filter-row">
        <div class="filter-box">
          <select class="filter-select" bind:value={selectedKelas}>
            <option value={null}>Semua Kelas</option>
            {#each listKelas as k}
              <option value={String(k.id_kelas)}>Kelas {k.kelas}</option>
            {/each}
          </select>
        </div>
        <div class="filter-box">
          <select class="filter-select" bind:value={selectedSemester}>
            <option value={null}>Semester</option>
            <option value="Semester Ganjil">Semester Ganjil</option>
            <option value="Semester Genap">Semester Genap</option>
          </select>
        </div>
      </div>
      
      {#if tahunAjarOptions.length > 0}
        <div class="filter-box mt-12">
          <select class="filter-select" bind:value={selectedTahunAjar}>
            <option value={null}>Semua Tahun Ajaran</option>
            {#each tahunAjarOptions as t}
              <option value={t}>TA {t}</option>
            {/each}
          </select>
        </div>
      {/if}
    </div>

    <!-- Laporan List -->
    <div class="laporan-content">
      {#if loading}
        <Loading />
      {:else if error}
        <div class="empty-state">
          <div class="error-text">{error}</div>
          <button class="retry-btn" onclick={fetchLaporan}>Coba Lagi</button>
        </div>
      {:else if filteredLaporan.length === 0}
        <div class="empty-state">
          <svg class="empty-icon" xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="9" y1="15" x2="15" y2="15"></line></svg>
          <div class="empty-text">Tidak ada laporan yang ditemukan</div>
        </div>
      {:else}
        <div class="laporan-list">
          {#each filteredLaporan as laporan}
            {@const hadir = laporan.hadir ?? laporan.total_hadir ?? laporan.totalHadir ?? 0}
            {@const izin = laporan.izin ?? laporan.total_izin ?? laporan.totalIzin ?? 0}
            {@const sakit = laporan.sakit ?? laporan.total_sakit ?? laporan.totalSakit ?? 0}
            {@const alfa = laporan.alfa ?? laporan.total_alfa ?? laporan.totalAlfa ?? 0}
            {@const total = hadir + izin + sakit + alfa}
            {@const pct = total > 0 ? (hadir / total * 100) : 0}
            {@const pctColor = pct >= 90 ? 'var(--success)' : (pct >= 75 ? 'var(--warning)' : 'var(--error)')}
            {@const kelasObj = listKelas.find(k => String(k.id_kelas) === String(laporan.id_kelas || laporan.idKelas))}
            {@const kelasStr = laporan.kelas?.kelas || laporan.nama_kelas || (kelasObj ? kelasObj.kelas : '-')}
            {@const taStr = resolveTahunAjar(laporan)}
            {@const semStr = resolveSemester(laporan)}
            
            <div class="laporan-card">
              <!-- Top Row -->
              <div class="card-top">
                <div class="icon-box">
                  <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="var(--primary)" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="16" y1="13" x2="8" y2="13"></line><line x1="16" y1="17" x2="8" y2="17"></line><polyline points="10 9 9 9 8 9"></polyline></svg>
                </div>
                <div class="card-info">
                  <div class="kelas-name">Kelas {kelasStr}</div>
                  <div class="periode">{semStr.replace('Semester ', '')} - TA {taStr}</div>
                </div>
                <div class="pct-bubble" style="background-color: {pctColor}">
                  {pct.toFixed(1)}%
                </div>
              </div>
              
              <!-- Mini Stats -->
              <div class="mini-stats">
                <div class="mini-stat">
                  <div class="mini-val hadir-color">{hadir}</div>
                  <div class="mini-lbl">Hadir</div>
                </div>
                <div class="mini-stat">
                  <div class="mini-val izin-color">{izin}</div>
                  <div class="mini-lbl">Izin</div>
                </div>
                <div class="mini-stat">
                  <div class="mini-val sakit-color">{sakit}</div>
                  <div class="mini-lbl">Sakit</div>
                </div>
                <div class="mini-stat">
                  <div class="mini-val alfa-color">{alfa}</div>
                  <div class="mini-lbl">Alfa</div>
                </div>
              </div>
              
              <div class="divider"></div>
              
              <!-- Action -->
              <div class="card-actions">
                <button class="btn-download" onclick={() => openDownload(laporan)}>
                  <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path><polyline points="7 10 12 15 17 10"></polyline><line x1="12" y1="15" x2="12" y2="3"></line></svg>
                  <span>Download</span>
                </button>
              </div>
            </div>
          {/each}
        </div>
      {/if}
    </div>
  </div>

  <!-- Bottom Sheet Download -->
  {#if showDownloadOptions}
    <!-- svelte-ignore a11y_click_events_have_key_events -->
    <!-- svelte-ignore a11y_no_static_element_interactions -->
    <div class="bottom-sheet-backdrop" onclick={() => showDownloadOptions = false}>
      <div class="bottom-sheet" onclick={e => e.stopPropagation()}>
        <div class="sheet-title">Download Laporan</div>
        
        <div class="download-options mt-24">
          <button class="dl-option pdf-option" onclick={downloadPdf}>
            <svg xmlns="http://www.w3.org/2000/svg" width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="var(--error)" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><path d="M9 15v-4"></path><path d="M12 15v-4"></path><path d="M15 15v-4"></path></svg>
            <span>PDF</span>
          </button>
          
          <button class="dl-option excel-option" onclick={downloadExcel}>
            <svg xmlns="http://www.w3.org/2000/svg" width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="var(--success)" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><path d="M8 13h8"></path><path d="M8 17h8"></path><path d="M10 9h4"></path></svg>
            <span>Excel</span>
          </button>
        </div>
      </div>
    </div>
  {/if}
</PageLayout>

<style>
  .page-container {
    display: flex;
    flex-direction: column;
    min-height: 100vh;
    background-color: var(--bg);
  }
  
  .filter-section {
    padding: 16px;
    background-color: #f5f5f5;
  }
  
  .filter-row {
    display: flex;
    gap: 12px;
  }
  
  .filter-box {
    flex: 1;
    background: white;
    border: 1px solid var(--border);
    border-radius: 12px;
    padding: 0 12px;
  }
  
  .mt-12 {
    margin-top: 12px;
  }
  
  .filter-select {
    width: 100%;
    padding: 12px 0;
    border: none;
    background: transparent;
    font-size: 14px;
    outline: none;
    color: var(--text-primary);
  }
  
  .laporan-content {
    flex: 1;
    padding: 16px;
    padding-bottom: 90px;
  }
  
  .laporan-list {
    display: flex;
    flex-direction: column;
    gap: 12px;
  }
  
  .laporan-card {
    background: white;
    border-radius: 12px;
    padding: 16px;
    box-shadow: 0 1px 3px rgba(0,0,0,0.05);
  }
  
  .card-top {
    display: flex;
    align-items: center;
    margin-bottom: 12px;
  }
  
  .icon-box {
    background: rgba(13, 71, 161, 0.1);
    padding: 12px;
    border-radius: 12px;
    margin-right: 12px;
  }
  
  .card-info {
    flex: 1;
  }
  
  .kelas-name {
    font-weight: bold;
    font-size: 16px;
    color: var(--text-primary);
  }
  
  .periode {
    font-size: 12px;
    color: var(--text-secondary);
  }
  
  .pct-bubble {
    padding: 6px 12px;
    border-radius: 20px;
    color: white;
    font-weight: bold;
    font-size: 12px;
  }
  
  .mini-stats {
    display: flex;
    margin-top: 12px;
  }
  
  .mini-stat {
    flex: 1;
    display: flex;
    flex-direction: column;
    align-items: center;
  }
  
  .mini-val {
    font-size: 16px;
    font-weight: bold;
  }
  
  .hadir-color { color: var(--hadir); }
  .izin-color { color: var(--izin); }
  .sakit-color { color: var(--sakit); }
  .alfa-color { color: var(--alfa); }
  
  .mini-lbl {
    font-size: 11px;
    color: var(--text-secondary);
  }
  
  .divider {
    height: 1px;
    background-color: var(--border);
    margin: 12px 0;
  }
  
  .card-actions {
    display: flex;
    justify-content: flex-end;
  }
  
  .btn-download {
    background: transparent;
    border: none;
    color: var(--primary);
    display: flex;
    align-items: center;
    gap: 8px;
    padding: 8px 12px;
    border-radius: 8px;
    font-weight: 500;
    cursor: pointer;
  }
  
  .btn-download:hover {
    background-color: rgba(13, 71, 161, 0.05);
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
    padding: 24px;
    padding-bottom: calc(24px + env(safe-area-inset-bottom));
    animation: slideUp 0.3s ease-out;
  }
  
  .sheet-title {
    font-size: 18px;
    font-weight: bold;
    color: var(--text-primary);
    text-align: center;
  }
  
  .mt-24 {
    margin-top: 24px;
  }
  
  .download-options {
    display: flex;
    gap: 16px;
  }
  
  .dl-option {
    flex: 1;
    padding: 24px;
    border-radius: 16px;
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 8px;
    cursor: pointer;
    background: transparent;
  }
  
  .pdf-option {
    border: 1px solid rgba(235, 87, 87, 0.3);
    background-color: rgba(235, 87, 87, 0.1);
  }
  
  .pdf-option span {
    color: var(--error);
    font-weight: bold;
  }
  
  .excel-option {
    border: 1px solid rgba(39, 174, 96, 0.3);
    background-color: rgba(39, 174, 96, 0.1);
  }
  
  .excel-option span {
    color: var(--success);
    font-weight: bold;
  }
  
  @keyframes slideUp {
    from { transform: translateY(100%); }
    to { transform: translateY(0); }
  }
  
  .empty-state {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    padding: 40px 0;
  }
  
  .empty-icon {
    color: var(--text-secondary);
    margin-bottom: 12px;
    opacity: 0.5;
  }
  
  .empty-text {
    color: var(--text-secondary);
    font-size: 14px;
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
</style>
