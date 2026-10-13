<script lang="ts">
  import { onMount } from 'svelte';
  import { authStore } from '../../lib/stores/auth';
  import { laporanApi } from '../../lib/api/laporan';
  
  import PageLayout from '../../components/layout/PageLayout.svelte';
  import Loading from '../../components/ui/Loading.svelte';

  let laporanData = $state<any[]>([]);
  let loading = $state(true);
  let error = $state<string | null>(null);

  async function loadData() {
    loading = true;
    error = null;
    const userId = $authStore.user?.id_ortu || $authStore.user?.id;
    
    if (userId) {
      try {
        const res = await laporanApi.getByOrtu(userId);
        
        if (res.success && res.data) {
          laporanData = res.data;
        } else {
          error = res.message || 'Gagal memuat laporan';
        }
      } catch (e) {
        error = 'Terjadi kesalahan jaringan';
      } finally {
        loading = false;
      }
    } else {
      loading = false;
      error = 'ID Orang Tua tidak ditemukan';
    }
  }

  onMount(() => {
    loadData();
  });
</script>

<PageLayout title="Laporan Kehadiran" showBack={false} hasBottomNav={true}>
  <div class="page-container">
    {#if loading}
      <Loading />
    {:else if error}
      <div class="empty-state">
        <div class="error-text">{error}</div>
        <button class="retry-btn" onclick={loadData}>Coba Lagi</button>
      </div>
    {:else if laporanData.length === 0}
      <div class="empty-state">
        <svg class="empty-icon" xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="9" y1="15" x2="15" y2="15"></line></svg>
        <div class="empty-text">Belum ada laporan untuk anak Anda</div>
      </div>
    {:else}
      <div class="laporan-list">
        {#each laporanData as data}
          {@const siswa = data.siswa || {}}
          {@const kelas = data.kelas || {}}
          {@const statistik = data.statistik || {}}
          
          {@const hadir = statistik.total_hadir || 0}
          {@const sakit = statistik.total_sakit || 0}
          {@const izin = statistik.total_izin || 0}
          {@const alfa = statistik.total_alfa || 0}
          {@const total = hadir + sakit + izin + alfa}
          {@const pct = total > 0 ? (hadir / total * 100) : 0}
          {@const pctColor = pct >= 90 ? 'var(--success)' : (pct >= 75 ? 'var(--warning)' : 'var(--error)')}
          
          <div class="report-card">
            <!-- Header -->
            <div class="card-header">
              <div class="icon-box">
                <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path><circle cx="12" cy="7" r="4"></circle></svg>
              </div>
              <div class="header-info">
                <div class="siswa-name">{siswa.nama || 'Siswa'}</div>
                <div class="kelas-name">Kelas {kelas.kelas || '-'}</div>
              </div>
              <div class="pct-bubble" style="background-color: {pctColor}">
                {pct.toFixed(1)}%
              </div>
            </div>
            
            <!-- Body -->
            <div class="card-body">
              <div class="nis-row">
                <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="var(--text-secondary)" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect><line x1="16" y1="2" x2="16" y2="6"></line><line x1="8" y1="2" x2="8" y2="6"></line><line x1="3" y1="10" x2="21" y2="10"></line></svg>
                <span>NIS: {siswa.nis || '-'}</span>
              </div>
              
              <div class="divider"></div>
              
              <!-- Stats -->
              <div class="stats-row">
                <div class="stat-item hadir-bg">
                  <div class="stat-val hadir-color">{hadir}</div>
                  <div class="stat-lbl hadir-color">Hadir</div>
                </div>
                <div class="stat-item izin-bg">
                  <div class="stat-val izin-color">{izin}</div>
                  <div class="stat-lbl izin-color">Izin</div>
                </div>
                <div class="stat-item sakit-bg">
                  <div class="stat-val sakit-color">{sakit}</div>
                  <div class="stat-lbl sakit-color">Sakit</div>
                </div>
                <div class="stat-item alfa-bg">
                  <div class="stat-val alfa-color">{alfa}</div>
                  <div class="stat-lbl alfa-color">Alfa</div>
                </div>
              </div>
              
              <!-- Progress Bar -->
              <div class="progress-section">
                <div class="progress-label">Tingkat Kehadiran</div>
                <div class="progress-bar-bg">
                  <div class="progress-bar-fill" style="width: {pct}%; background-color: {pctColor}"></div>
                </div>
              </div>
            </div>
          </div>
        {/each}
      </div>
    {/if}
  </div>
</PageLayout>

<style>
  .page-container {
    padding: 16px;
    padding-bottom: 90px;
    background-color: var(--bg);
    min-height: 100vh;
  }
  
  .laporan-list {
    display: flex;
    flex-direction: column;
    gap: 16px;
  }
  
  .report-card {
    background: white;
    border-radius: 16px;
    box-shadow: 0 1px 10px rgba(0,0,0,0.05);
    overflow: hidden;
  }
  
  .card-header {
    background-color: rgba(13, 71, 161, 0.1);
    padding: 16px;
    display: flex;
    align-items: center;
  }
  
  .icon-box {
    background-color: var(--primary);
    padding: 10px;
    border-radius: 10px;
    display: flex;
    align-items: center;
    justify-content: center;
    margin-right: 12px;
  }
  
  .header-info {
    flex: 1;
  }
  
  .siswa-name {
    font-weight: bold;
    font-size: 16px;
    color: var(--text-primary);
  }
  
  .kelas-name {
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
  
  .card-body {
    padding: 16px;
  }
  
  .nis-row {
    display: flex;
    align-items: center;
    gap: 8px;
    color: var(--text-primary);
    font-weight: 500;
  }
  
  .divider {
    height: 1px;
    background-color: var(--border);
    margin: 16px 0;
  }
  
  .stats-row {
    display: flex;
    gap: 8px;
    margin-bottom: 16px;
  }
  
  .stat-item {
    flex: 1;
    padding: 12px 0;
    border-radius: 12px;
    display: flex;
    flex-direction: column;
    align-items: center;
  }
  
  .stat-val {
    font-weight: bold;
    font-size: 20px;
    margin-bottom: 4px;
  }
  
  .stat-lbl {
    font-size: 11px;
  }
  
  .hadir-bg { background-color: rgba(39, 174, 96, 0.1); }
  .izin-bg { background-color: rgba(242, 201, 76, 0.1); }
  .sakit-bg { background-color: rgba(45, 156, 219, 0.1); }
  .alfa-bg { background-color: rgba(235, 87, 87, 0.1); }
  
  .hadir-color { color: var(--hadir); }
  .izin-color { color: var(--izin); }
  .sakit-color { color: var(--sakit); }
  .alfa-color { color: var(--alfa); }
  
  .progress-section {
    display: flex;
    flex-direction: column;
    gap: 8px;
  }
  
  .progress-label {
    font-size: 12px;
    color: var(--text-secondary);
  }
  
  .progress-bar-bg {
    width: 100%;
    height: 10px;
    background-color: #eee;
    border-radius: 5px;
    overflow: hidden;
  }
  
  .progress-bar-fill {
    height: 100%;
    border-radius: 5px;
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
