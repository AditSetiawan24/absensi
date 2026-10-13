<script lang="ts">
  import { onMount } from 'svelte';
  import { siswaApi } from '../../lib/api/siswa';
  import { absensiApi } from '../../lib/api/absensi';
  import { apiClient } from '../../lib/api/client';
  
  import PageLayout from '../../components/layout/PageLayout.svelte';
  import Loading from '../../components/ui/Loading.svelte';
  import StatusBadge from '../../components/ui/StatusBadge.svelte';
  import { formatDate } from '../../lib/utils/date';

  let { params = {} } = $props<{ params?: any }>();
  
  let siswa = $state<any>(null);
  let absensi = $state<any[]>([]);
  let statistics = $state<any>(null);
  let loading = $state(true);
  let error = $state<string | null>(null);

  async function loadData() {
    loading = true;
    error = null;
    
    if (!params.nis) {
      error = 'NIS tidak valid';
      loading = false;
      return;
    }
    
    const [siswaRes, absensiRes, statsRes] = await Promise.all([
      siswaApi.getDetail(params.nis),
      absensiApi.getBySiswa(params.nis),
      apiClient.get(`/absensi/statistics?nis=${params.nis}`)
    ]);
    
    if (absensiRes.success && absensiRes.data) {
      if (Array.isArray(absensiRes.data)) {
        absensi = absensiRes.data;
      } else {
        if (Array.isArray(absensiRes.data.absensi)) {
          absensi = absensiRes.data.absensi;
        }
        if (absensiRes.data.statistics && !statistics) {
          statistics = absensiRes.data.statistics;
        }
        if (absensiRes.data.siswa && !siswa) {
          siswa = absensiRes.data.siswa;
        }
      }
    }
    
    if (siswaRes.success && siswaRes.data) {
      siswa = siswaRes.data;
    } else if (!siswa && !absensiRes.success) {
      error = siswaRes.message || 'Gagal memuat data siswa';
    }
    
    if (statsRes.success && statsRes.data && !statistics) {
      statistics = statsRes.data;
    }
    loading = false;
  }

  onMount(() => {
    loadData();
  });
</script>

<PageLayout title="Detail Siswa" showBack={true} hasBottomNav={false}>
  <!-- Top refresh action matching flutter -->
  <div class="top-actions">
    <button class="refresh-btn" onclick={loadData}>
      <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 2v6h-6"></path><path d="M3 12a9 9 0 0 1 15-6.7L21 8"></path><path d="M3 22v-6h6"></path><path d="M21 12a9 9 0 0 1-15 6.7L3 16"></path></svg>
    </button>
  </div>

  {#if loading}
    <Loading />
  {:else if error}
    <div class="empty-state">
      <div class="error-text">{error}</div>
      <button class="retry-btn" onclick={loadData}>Coba Lagi</button>
    </div>
  {:else if siswa}
    <div class="detail-content">
      <!-- Student Info Card -->
      <div class="profile-card">
        <div class="avatar-placeholder">{siswa.nama.charAt(0).toUpperCase()}</div>
        <div class="nama">{siswa.nama}</div>
        <div class="nis">NIS: {siswa.nis}</div>
        <div class="kelas">Kelas {siswa.kelas?.kelas || '-'}</div>
      </div>

      <!-- Statistics -->
      {#if statistics}
        <div class="section-title">Statistik Kehadiran</div>
        <div class="stats-grid">
          <!-- Hadir -->
          <div class="stat-card hadir-card">
            <div class="stat-header">
              <div class="stat-icon-wrapper">
                <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path><polyline points="22 4 12 14.01 9 11.01"></polyline></svg>
              </div>
            </div>
            <div class="stat-value">{statistics.hadir || 0}</div>
            <div class="stat-title">Hadir</div>
            <div class="stat-subtitle">{Number(statistics.persentase_hadir || 0).toFixed(1)}%</div>
          </div>
          
          <!-- Izin -->
          <div class="stat-card izin-card">
            <div class="stat-header">
              <div class="stat-icon-wrapper">
                <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="16" y1="13" x2="8" y2="13"></line><line x1="16" y1="17" x2="8" y2="17"></line><polyline points="10 9 9 9 8 9"></polyline></svg>
              </div>
            </div>
            <div class="stat-value">{statistics.izin || 0}</div>
            <div class="stat-title">Izin</div>
            <div class="stat-subtitle">hari</div>
          </div>
          
          <!-- Sakit -->
          <div class="stat-card sakit-card">
            <div class="stat-header">
              <div class="stat-icon-wrapper">
                <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M19 3v4"></path><path d="M5 3v4"></path><path d="M19 17v4"></path><path d="M5 17v4"></path><path d="M3 10h18v4H3z"></path><path d="M12 7v10"></path></svg>
              </div>
            </div>
            <div class="stat-value">{statistics.sakit || 0}</div>
            <div class="stat-title">Sakit</div>
            <div class="stat-subtitle">hari</div>
          </div>
          
          <!-- Alfa -->
          <div class="stat-card alfa-card">
            <div class="stat-header">
              <div class="stat-icon-wrapper">
                <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><line x1="15" y1="9" x2="9" y2="15"></line><line x1="9" y1="9" x2="15" y2="15"></line></svg>
              </div>
            </div>
            <div class="stat-value">{statistics.alfa || 0}</div>
            <div class="stat-title">Alfa</div>
            <div class="stat-subtitle">hari</div>
          </div>
        </div>
      {/if}
      
      <div class="section-title mt-6">Riwayat Absensi</div>
      {#if absensi.length === 0}
        <div class="empty-state">
          <svg class="empty-icon" xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="9" y1="15" x2="15" y2="15"></line></svg>
          <div class="empty-text">Belum ada riwayat absensi</div>
        </div>
      {:else}
        <div class="history-list">
          {#each absensi as a}
            <div class="history-item">
              <div class="icon-box">
                <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="var(--primary)" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect><line x1="16" y1="2" x2="16" y2="6"></line><line x1="8" y1="2" x2="8" y2="6"></line><line x1="3" y1="10" x2="21" y2="10"></line></svg>
              </div>
              <div class="date-info">
                <div class="date">{formatDate(a.tanggal) || a.tanggal}</div>
                {#if a.keterangan}
                  <div class="keterangan">{a.keterangan}</div>
                {/if}
              </div>
              <StatusBadge status={a.status_kehadiran || a.status} />
            </div>
          {/each}
        </div>
      {/if}
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
  
  .detail-content {
    padding: 16px;
  }
  
  .profile-card {
    display: flex;
    flex-direction: column;
    align-items: center;
    background: linear-gradient(to bottom, var(--primary), rgba(13, 71, 161, 0.8));
    padding: 20px;
    border-radius: 16px;
    margin-bottom: 24px;
    color: white;
  }
  
  .avatar-placeholder {
    width: 80px;
    height: 80px;
    border-radius: 50%;
    background: rgba(255, 255, 255, 0.2);
    color: white;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 32px;
    font-weight: 700;
    margin-bottom: 16px;
  }
  
  .nama {
    font-size: 20px;
    font-weight: 700;
    margin-bottom: 4px;
  }
  
  .nis {
    font-size: 14px;
    color: rgba(255, 255, 255, 0.9);
    margin-bottom: 4px;
  }
  
  .kelas {
    font-size: 14px;
    color: rgba(255, 255, 255, 0.9);
  }
  
  .section-title {
    font-size: 18px;
    font-weight: 700;
    margin-bottom: 12px;
    color: var(--text-primary);
  }
  
  .mt-6 {
    margin-top: 24px;
  }
  
  .stats-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 12px;
  }
  
  .stat-card {
    background: white;
    padding: 16px;
    border-radius: 12px;
    box-shadow: 0 4px 12px rgba(0,0,0,0.05);
    border: 1px solid var(--border);
    display: flex;
    flex-direction: column;
  }
  
  .stat-header {
    display: flex;
    margin-bottom: 8px;
  }
  
  .stat-icon-wrapper {
    padding: 8px;
    border-radius: 8px;
    display: flex;
    align-items: center;
    justify-content: center;
  }
  
  .stat-value {
    font-size: 24px;
    font-weight: 700;
    margin-bottom: 4px;
  }
  
  .stat-title {
    font-size: 14px;
    font-weight: 600;
    margin-bottom: 2px;
  }
  
  .stat-subtitle {
    font-size: 12px;
    color: var(--text-secondary);
  }
  
  .hadir-card .stat-icon-wrapper { background: rgba(39, 174, 96, 0.1); color: var(--hadir); }
  .hadir-card .stat-value { color: var(--hadir); }
  
  .izin-card .stat-icon-wrapper { background: rgba(242, 201, 76, 0.1); color: var(--izin); }
  .izin-card .stat-value { color: var(--izin); }
  
  .sakit-card .stat-icon-wrapper { background: rgba(45, 156, 219, 0.1); color: var(--sakit); }
  .sakit-card .stat-value { color: var(--sakit); }
  
  .alfa-card .stat-icon-wrapper { background: rgba(235, 87, 87, 0.1); color: var(--alfa); }
  .alfa-card .stat-value { color: var(--alfa); }
  
  .history-list {
    display: flex;
    flex-direction: column;
    gap: 8px;
  }
  
  .history-item {
    display: flex;
    align-items: center;
    padding: 12px;
    background: white;
    border-radius: 12px;
    box-shadow: 0 2px 10px rgba(0,0,0,0.05);
  }
  
  .icon-box {
    padding: 8px;
    background: rgba(13, 71, 161, 0.1);
    border-radius: 8px;
    display: flex;
    align-items: center;
    justify-content: center;
    margin-right: 12px;
  }
  
  .date-info {
    flex: 1;
    display: flex;
    flex-direction: column;
  }
  
  .date {
    font-weight: 600;
    color: var(--text-primary);
    font-size: 14px;
  }
  
  .keterangan {
    font-size: 12px;
    color: var(--text-secondary);
    margin-top: 2px;
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
