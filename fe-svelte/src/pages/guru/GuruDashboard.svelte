<script lang="ts">
  import { onMount } from 'svelte';
  import { push } from 'svelte-spa-router';
  import { authStore } from '../../lib/stores/auth';
  import { dashboardApi } from '../../lib/api/dashboard';
  import type { GuruDashboard } from '../../lib/types/dashboard';
  import Loading from '../../components/ui/Loading.svelte';
  import ErrorState from '../../components/ui/ErrorState.svelte';
  import PageLayout from '../../components/layout/PageLayout.svelte';
  import BarChart from '../../components/charts/BarChart.svelte';

  let dashboardData = $state<GuruDashboard | null>(null);
  let loading = $state(true);
  let error = $state('');

  async function loadData() {
    loading = true;
    error = '';
    const nip = $authStore.user?.nip;
    
    if (!nip) {
      error = 'NIP tidak ditemukan';
      loading = false;
      return;
    }

    const res = await dashboardApi.getGuruDashboard(nip);
    loading = false;
    
    if (res.success && res.data) {
      const d = res.data;
      const todayStats = d.today_stats || d.stats_hari_ini || {};
      const weeklyStats = d.weekly_stats || d.grafik_mingguan || [];
      const consecutiveAbsent = d.consecutive_absent || d.siswa_absen_berturut || [];
      const absentToday = d.absent_today || d.siswa_absen_hari_ini || [];
      
      d.today_stats = todayStats;
      d.stats_hari_ini = todayStats;
      d.weekly_stats = weeklyStats;
      d.grafik_mingguan = weeklyStats;
      d.consecutive_absent = consecutiveAbsent;
      d.siswa_absen_berturut = consecutiveAbsent;
      d.absent_today = absentToday;
      d.siswa_absen_hari_ini = absentToday;
      
      dashboardData = d;
    } else {
      error = res.message || 'Gagal memuat dashboard';
    }
  }

  onMount(() => {
    loadData();
  });

  let chartData = $derived.by(() => {
    const weekly = dashboardData?.weekly_stats || dashboardData?.grafik_mingguan;
    if (!weekly || !Array.isArray(weekly) || weekly.length === 0) return null;
    
    const daysShort = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    const labels = weekly.map((d: any) => {
      if (d.hari) {
        const h = d.hari.toLowerCase();
        if (h.startsWith('sen')) return 'Sen';
        if (h.startsWith('sel')) return 'Sel';
        if (h.startsWith('rab')) return 'Rab';
        if (h.startsWith('kam')) return 'Kam';
        if (h.startsWith('jum')) return 'Jum';
        if (h.startsWith('sab')) return 'Sab';
        if (h.startsWith('min')) return 'Min';
        return d.hari;
      }
      if (d.tanggal || d.date) {
        const date = new Date(d.tanggal || d.date);
        return daysShort[(date.getDay() + 6) % 7];
      }
      return '';
    });
    
    const hadirData = weekly.map((d: any) => {
      const val = d.persentase_hadir !== undefined ? d.persentase_hadir : (d.persentaseHadir !== undefined ? d.persentaseHadir : 0);
      return typeof val === 'number' ? val : parseFloat(val) || 0;
    });
    
    return {
      labels,
      datasets: [
        { 
          label: 'Persentase Hadir (%)', 
          data: hadirData, 
          backgroundColor: '#27AE60', 
          borderRadius: 4, 
          barPercentage: 0.5 
        }
      ]
    };
  });
  
  function getPersentaseHadir() {
    const stats = dashboardData?.today_stats || dashboardData?.stats_hari_ini;
    if (!stats) return '0.0';
    if (stats.persentase_hadir !== undefined) return Number(stats.persentase_hadir).toFixed(1);
    if (stats.persentaseHadir !== undefined) return Number(stats.persentaseHadir).toFixed(1);
    const hadir = stats.hadir || 0;
    const total = hadir + (stats.izin || 0) + (stats.sakit || 0) + (stats.alfa || 0);
    if (total === 0) return '0.0';
    return ((hadir / total) * 100).toFixed(1);
  }
</script>

<PageLayout title="" hasBottomNav={true}>
  <div class="page-container">
    <div class="header-section">
      <div class="avatar-circle">
        {($authStore.user?.nama || 'G').charAt(0).toUpperCase()}
      </div>
      <div class="header-text">
        <div class="greeting">Selamat Datang,</div>
        <div class="name">{$authStore.user?.nama || 'Guru'}</div>
      </div>
    </div>
    
    <div class="quick-actions">
      <button class="action-btn main-action" onclick={() => push('/guru/mulai-absensi')}>
        <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><polygon points="10 8 16 12 10 16 10 8"></polygon></svg>
        <span>Mulai Absensi Hari Ini</span>
      </button>
      
      <div class="secondary-actions">
        <button class="action-btn secondary-action" onclick={() => push('/guru/kelola-siswa')}>
          <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle><path d="M23 21v-2a4 4 0 0 0-3-3.87"></path><path d="M16 3.13a4 4 0 0 1 0 7.75"></path></svg>
          <span>Kelola Siswa</span>
        </button>
        <button class="action-btn secondary-action" onclick={() => push('/guru/persetujuan-kepsek')}>
          <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"></path><polyline points="9 12 11 14 15 10"></polyline></svg>
          <span>Setujui Kepsek</span>
        </button>
      </div>
    </div>
    
    {#if loading}
      <Loading />
    {:else if error}
      <ErrorState message={error} onRetry={loadData} />
    {:else if dashboardData}
      <div class="section-title">Statistik Hari Ini</div>
      <div class="stats-grid">
        <div class="stat-card" style="border-left: 4px solid var(--hadir)">
          <div class="stat-header">
            <span class="stat-title">Hadir</span>
            <svg class="stat-icon" style="color: var(--hadir)" xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path><polyline points="22 4 12 14.01 9 11.01"></polyline></svg>
          </div>
          <div class="stat-value" style="color: var(--hadir)">{dashboardData.stats_hari_ini?.hadir || 0}</div>
          <div class="stat-subtitle">{getPersentaseHadir()}%</div>
        </div>
        
        <div class="stat-card" style="border-left: 4px solid var(--izin)">
          <div class="stat-header">
            <span class="stat-title">Izin</span>
            <svg class="stat-icon" style="color: var(--izin)" xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="16" y1="13" x2="8" y2="13"></line><line x1="16" y1="17" x2="8" y2="17"></line><polyline points="10 9 9 9 8 9"></polyline></svg>
          </div>
          <div class="stat-value" style="color: var(--izin)">{dashboardData.stats_hari_ini?.izin || 0}</div>
          <div class="stat-subtitle">siswa</div>
        </div>
        
        <div class="stat-card" style="border-left: 4px solid var(--sakit)">
          <div class="stat-header">
            <span class="stat-title">Sakit</span>
            <svg class="stat-icon" style="color: var(--sakit)" xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"></rect><line x1="12" y1="8" x2="12" y2="16"></line><line x1="8" y1="12" x2="16" y2="12"></line></svg>
          </div>
          <div class="stat-value" style="color: var(--sakit)">{dashboardData.stats_hari_ini?.sakit || 0}</div>
          <div class="stat-subtitle">siswa</div>
        </div>
        
        <div class="stat-card" style="border-left: 4px solid var(--alfa)">
          <div class="stat-header">
            <span class="stat-title">Alfa</span>
            <svg class="stat-icon" style="color: var(--alfa)" xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><line x1="15" y1="9" x2="9" y2="15"></line><line x1="9" y1="9" x2="15" y2="15"></line></svg>
          </div>
          <div class="stat-value" style="color: var(--alfa)">{dashboardData.stats_hari_ini?.alfa || 0}</div>
          <div class="stat-subtitle">siswa</div>
        </div>
      </div>
      
      {#if dashboardData.siswa_absen_berturut && dashboardData.siswa_absen_berturut.length > 0}
        <div class="warning-alert">
          <div class="warning-header">
            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"></path><line x1="12" y1="9" x2="12" y2="13"></line><line x1="12" y1="17" x2="12.01" y2="17"></line></svg>
            <span>Peringatan: Siswa Tidak Hadir 3+ Hari</span>
          </div>
          <div class="warning-list">
            {#each dashboardData.siswa_absen_berturut as item}
              <div class="warning-item">
                <div class="warning-badge">{item.consecutiveDays || item.consecutive_days || 3}</div>
                <div class="warning-info">
                  <div class="warning-name">{item.namaSiswa || item.nama_siswa || item.nama}</div>
                  <div class="warning-desc">{(item.consecutiveDays || item.consecutive_days || 3)} hari tidak hadir</div>
                </div>
                <button class="warning-btn" onclick={() => push(`/guru/siswa/${item.nis}`)}>Lihat</button>
              </div>
            {/each}
          </div>
        </div>
      {/if}
      
      <div class="section-title mt-6">Statistik Mingguan</div>
      <div class="chart-container">
        {#if chartData}
          <BarChart data={chartData} />
        {:else}
          <div class="empty-chart">Tidak ada data</div>
        {/if}
      </div>
      
      {#if (dashboardData.absent_today && dashboardData.absent_today.length > 0) || (dashboardData.siswa_absen_hari_ini && dashboardData.siswa_absen_hari_ini.length > 0)}
        <div class="section-title mt-6">Siswa Tidak Hadir Hari Ini</div>
        <div class="absent-list">
          {#each (dashboardData.absent_today || dashboardData.siswa_absen_hari_ini) as student}
            <div class="absent-item">
              <span class="status-badge {student.status || student.status_kehadiran}">{student.status || student.status_kehadiran}</span>
              <div class="absent-info">
                <div class="absent-name">{student.nama}</div>
                {#if student.keterangan}
                  <div class="absent-desc">{student.keterangan}</div>
                {/if}
              </div>
            </div>
          {/each}
        </div>
      {/if}
    {/if}
  </div>
</PageLayout>

<style>
  .page-container {
    padding: 16px;
    padding-bottom: 90px; /* Space for bottom nav */
  }
  
  .header-section {
    display: flex;
    align-items: center;
    margin-bottom: 24px;
    margin-top: 8px;
  }
  
  .avatar-circle {
    width: 48px;
    height: 48px;
    border-radius: 24px;
    background-color: var(--primary);
    color: white;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 20px;
    font-weight: bold;
    margin-right: 12px;
  }
  
  .header-text {
    display: flex;
    flex-direction: column;
  }
  
  .greeting {
    color: var(--text-secondary);
    font-size: 14px;
  }
  
  .name {
    font-weight: bold;
    font-size: 18px;
    color: var(--text-primary);
  }
  
  .quick-actions {
    display: flex;
    flex-direction: column;
    gap: 12px;
    margin-bottom: 24px;
  }
  
  .action-btn {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 8px;
    border: none;
    border-radius: 12px;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.2s;
  }
  
  .main-action {
    background-color: var(--primary);
    color: white;
    padding: 16px;
    width: 100%;
    font-size: 14px;
  }
  
  .main-action:active {
    opacity: 0.9;
  }
  
  .secondary-actions {
    display: flex;
    gap: 12px;
  }
  
  .secondary-action {
    flex: 1;
    background-color: white;
    color: var(--primary);
    border: 1px solid var(--primary);
    padding: 12px;
    font-size: 12px;
  }
  
  .secondary-action:active {
    background-color: #f5f5f5;
  }
  
  .section-title {
    font-size: 18px;
    font-weight: bold;
    margin-bottom: 12px;
    color: var(--text-primary);
  }
  
  .mt-6 {
    margin-top: 24px;
  }
  
  .stats-grid {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: 12px;
    margin-bottom: 24px;
  }
  
  .stat-card {
    background: white;
    border-radius: 12px;
    padding: 16px;
    box-shadow: 0 2px 10px rgba(0,0,0,0.05);
    display: flex;
    flex-direction: column;
  }
  
  .stat-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 8px;
  }
  
  .stat-title {
    font-size: 14px;
    font-weight: 600;
    color: var(--text-secondary);
  }
  
  .stat-value {
    font-size: 24px;
    font-weight: bold;
    margin-bottom: 4px;
  }
  
  .stat-subtitle {
    font-size: 12px;
    color: var(--text-secondary);
  }
  
  .warning-alert {
    background-color: rgba(235, 87, 87, 0.1);
    border: 1px solid rgba(235, 87, 87, 0.3);
    border-radius: 12px;
    padding: 16px;
    margin-bottom: 24px;
  }
  
  .warning-header {
    display: flex;
    align-items: center;
    gap: 8px;
    color: var(--error);
    font-weight: bold;
    margin-bottom: 12px;
  }
  
  .warning-list {
    display: flex;
    flex-direction: column;
    gap: 8px;
  }
  
  .warning-item {
    display: flex;
    align-items: center;
    gap: 12px;
  }
  
  .warning-badge {
    width: 32px;
    height: 32px;
    background-color: var(--error);
    color: white;
    border-radius: 8px;
    display: flex;
    align-items: center;
    justify-content: center;
    font-weight: bold;
  }
  
  .warning-info {
    flex: 1;
  }
  
  .warning-name {
    font-weight: 600;
    font-size: 14px;
    color: var(--text-primary);
  }
  
  .warning-desc {
    font-size: 12px;
    color: var(--text-secondary);
  }
  
  .warning-btn {
    background: transparent;
    border: none;
    color: var(--primary);
    font-weight: 600;
    cursor: pointer;
    padding: 4px 8px;
  }
  
  .chart-container {
    background-color: white;
    border-radius: 12px;
    padding: 16px;
    height: 200px;
    box-shadow: 0 2px 10px rgba(0,0,0,0.05);
  }
  
  .empty-chart {
    height: 100%;
    display: flex;
    align-items: center;
    justify-content: center;
    color: var(--text-secondary);
  }
  
  .absent-list {
    display: flex;
    flex-direction: column;
    gap: 8px;
  }
  
  .absent-item {
    display: flex;
    align-items: center;
    background-color: white;
    padding: 12px;
    border-radius: 12px;
    box-shadow: 0 2px 10px rgba(0,0,0,0.05);
    gap: 12px;
  }
  
  .status-badge {
    padding: 6px 12px;
    border-radius: 8px;
    font-size: 12px;
    font-weight: 600;
    text-transform: capitalize;
  }
  
  .status-badge.izin, .status-badge.i { background-color: rgba(242, 201, 76, 0.2); color: #B79010; }
  .status-badge.sakit, .status-badge.s { background-color: rgba(45, 156, 219, 0.2); color: #1875A8; }
  .status-badge.alfa, .status-badge.a { background-color: rgba(235, 87, 87, 0.2); color: #C52929; }
  .status-badge.hadir, .status-badge.h { background-color: rgba(39, 174, 96, 0.2); color: #1E874B; }
  
  .absent-info {
    display: flex;
    flex-direction: column;
  }
  
  .absent-name {
    font-weight: 600;
    color: var(--text-primary);
  }
  
  .absent-desc {
    font-size: 12px;
    color: var(--text-secondary);
  }
</style>
