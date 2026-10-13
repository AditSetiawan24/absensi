<script lang="ts">
  import { onMount } from 'svelte';
  import { authStore } from '../../lib/stores/auth';
  import { dashboardApi } from '../../lib/api/dashboard';
  
  import PageLayout from '../../components/layout/PageLayout.svelte';
  import Loading from '../../components/ui/Loading.svelte';
  import ErrorState from '../../components/ui/ErrorState.svelte';
  import BarChart from '../../components/charts/BarChart.svelte';

  let dashboardData = $state<any>(null);
  let loading = $state(true);
  let error = $state<string | null>(null);
  
  // Filter state
  let selectedTahunAjar = $state<string | null>(null);
  let selectedSemester = $state<string>('Ganjil');
  let tahunAjarOptions = $state<string[]>([]);
  
  function initFilters() {
    const now = new Date();
    const currentYear = now.getFullYear();
    const currentMonth = now.getMonth() + 1; // 1-12
    
    let currentTahunAjar;
    if (currentMonth >= 7) {
      currentTahunAjar = `${currentYear}/${currentYear + 1}`;
      selectedSemester = 'Ganjil';
    } else {
      currentTahunAjar = `${currentYear - 1}/${currentYear}`;
      selectedSemester = 'Genap';
    }
    
    const options = new Set<string>();
    for (let i = 0; i < 3; i++) {
      const year = currentYear - i;
      options.add(`${year}/${year + 1}`);
      if (i < 2) {
        options.add(`${year - 1}/${year}`);
      }
    }
    
    tahunAjarOptions = Array.from(options).sort((a, b) => b.localeCompare(a));
    selectedTahunAjar = currentTahunAjar;
  }

  async function loadData() {
    loading = true;
    error = null;
    
    let tahunAjarYear = null;
    if (selectedTahunAjar && selectedTahunAjar.includes('/')) {
      tahunAjarYear = selectedTahunAjar.split('/')[0];
    }
    
    const semesterNum = selectedSemester === 'Ganjil' ? 1 : 2;
    
    try {
      const res = await dashboardApi.getKepsekDashboard({
        tahunAjar: tahunAjarYear || undefined,
        semester: semesterNum
      });
      
      if (res.success && res.data) {
        const d = res.data;
        d.totalSiswa = d.total_siswa ?? d.totalSiswa ?? 0;
        d.totalKelas = d.total_kelas ?? d.totalKelas ?? 0;
        d.totalGuru = d.total_guru ?? d.totalGuru ?? 0;
        d.namaSekolah = d.nama_sekolah ?? d.namaSekolah ?? 'SD Negeri Kemutug Kidul';

        const rawList = d.class_stats || d.kelasStats || [];
        d.kelasStats = rawList.map((k: any) => ({
          idKelas: k.id_kelas ?? k.idKelas,
          kelas: k.kelas,
          guru: k.guru,
          nip: k.nip,
          jumlahSiswa: k.jumlah_siswa ?? k.jumlahSiswa ?? 0,
          totalAbsensi: k.total_absensi ?? k.totalAbsensi ?? 0,
          hadir: k.hadir ?? k.total_hadir ?? k.totalHadir ?? 0,
          izin: k.izin ?? k.total_izin ?? k.totalIzin ?? 0,
          sakit: k.sakit ?? k.total_sakit ?? k.totalSakit ?? 0,
          alfa: k.alfa ?? k.total_alfa ?? k.totalAlfa ?? 0,
          persentaseHadir: k.persentase_hadir !== undefined 
            ? (typeof k.persentase_hadir === 'number' ? k.persentase_hadir : parseFloat(k.persentase_hadir) || 0)
            : (k.persentaseHadir ?? 0)
        }));
        d.class_stats = d.kelasStats;

        dashboardData = d;
      } else {
        error = res.message || 'Gagal memuat dashboard kepala sekolah';
      }
    } catch (e) {
      error = 'Terjadi kesalahan jaringan';
    } finally {
      loading = false;
    }
  }

  onMount(() => {
    initFilters();
    loadData();
  });

  let chartData = $derived.by(() => {
    const list = dashboardData?.kelasStats || dashboardData?.class_stats;
    if (!list || !Array.isArray(list) || list.length === 0) return null;
    
    const labels = list.map((k: any) => `${k.kelas}`);
    const dataY = list.map((k: any) => {
      const p = k.persentaseHadir !== undefined ? k.persentaseHadir : (k.persentase_hadir !== undefined ? k.persentase_hadir : 0);
      return typeof p === 'number' ? p : parseFloat(p) || 0;
    });
    
    return {
      labels,
      datasets: [
        { 
          label: 'Persentase Kehadiran (%)', 
          data: dataY, 
          backgroundColor: '#1E88E5',
          borderRadius: 4,
          barPercentage: 0.6
        }
      ]
    };
  });
  
  function totals() {
    let hadir = 0, izin = 0, sakit = 0, alfa = 0, absensi = 0;
    const list = dashboardData?.kelasStats || dashboardData?.class_stats;
    if (list && Array.isArray(list)) {
      list.forEach((k: any) => {
        hadir += k.hadir || 0;
        izin += k.izin || 0;
        sakit += k.sakit || 0;
        alfa += k.alfa || 0;
        absensi += (k.totalAbsensi || k.total_absensi || (k.hadir + k.izin + k.sakit + k.alfa) || 0);
      });
    }
    const tidakHadir = izin + sakit + alfa;
    const persentase = absensi > 0 ? (hadir / absensi) * 100 : 0;
    return { hadir, izin, sakit, alfa, tidakHadir, absensi, persentase };
  }
</script>

<PageLayout title="" hasBottomNav={true}>
  <div class="kepsek-dashboard">
    <!-- Header -->
    <div class="header-row">
      <div class="avatar">
        {($authStore.user?.nama || 'K').charAt(0).toUpperCase()}
      </div>
      <div class="welcome-text">
        <div class="greeting">Selamat Datang,</div>
        <div class="name">{$authStore.user?.nama || 'Kepala Sekolah'}</div>
      </div>
    </div>
    
    <!-- Filter Section -->
    <div class="filter-section">
      <div class="filter-box">
        <select class="filter-select" bind:value={selectedTahunAjar} onchange={loadData}>
          {#each tahunAjarOptions as t}
            <option value={t}>TA {t}</option>
          {/each}
        </select>
      </div>
      <div class="filter-box">
        <select class="filter-select" bind:value={selectedSemester} onchange={loadData}>
          <option value="Ganjil">Semester Ganjil</option>
          <option value="Genap">Semester Genap</option>
        </select>
      </div>
    </div>
    
    {#if loading}
      <Loading />
    {:else if error}
      <ErrorState message={error} onRetry={loadData} />
    {:else if dashboardData}
      <!-- Overall Stats Card -->
      <div class="overall-card">
        <div class="card-title">Rekapitulasi Kehadiran</div>
        <div class="card-subtitle">Semester {selectedSemester} - TA {selectedTahunAjar}</div>
        
        <div class="overall-grid">
          <div class="overall-item">
            <svg xmlns="http://www.w3.org/2000/svg" width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle><path d="M23 21v-2a4 4 0 0 0-3-3.87"></path><path d="M16 3.13a4 4 0 0 1 0 7.75"></path></svg>
            <div class="overall-val">{dashboardData.totalSiswa || 0}</div>
            <div class="overall-lbl">Total Siswa</div>
          </div>
          <div class="overall-item">
            <svg xmlns="http://www.w3.org/2000/svg" width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path><polyline points="22 4 12 14.01 9 11.01"></polyline></svg>
            <div class="overall-val">{totals().hadir}</div>
            <div class="overall-lbl">Hadir</div>
          </div>
          <div class="overall-item">
            <svg xmlns="http://www.w3.org/2000/svg" width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><line x1="15" y1="9" x2="9" y2="15"></line><line x1="9" y1="9" x2="15" y2="15"></line></svg>
            <div class="overall-val">{totals().tidakHadir}</div>
            <div class="overall-lbl">Tidak Hadir</div>
          </div>
        </div>
        
        <div class="persentase-bubble">
          Tingkat Kehadiran: {totals().persentase.toFixed(1)}%
        </div>
      </div>
      
      <!-- Detail Kehadiran Semester Ini -->
      <div class="section-title">Detail Kehadiran Semester Ini</div>
      <div class="detail-grid">
        <div class="stat-card">
          <div class="stat-icon-wrapper izin-bg">
            <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="izin-color"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="16" y1="13" x2="8" y2="13"></line><line x1="16" y1="17" x2="8" y2="17"></line><polyline points="10 9 9 9 8 9"></polyline></svg>
          </div>
          <div class="stat-val">{totals().izin}</div>
          <div class="stat-lbl">Izin</div>
          <div class="stat-sub">siswa</div>
        </div>
        
        <div class="stat-card">
          <div class="stat-icon-wrapper sakit-bg">
            <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="sakit-color"><path d="M19 3v4"></path><path d="M5 3v4"></path><path d="M19 17v4"></path><path d="M5 17v4"></path><path d="M3 10h18v4H3z"></path><path d="M12 7v10"></path></svg>
          </div>
          <div class="stat-val">{totals().sakit}</div>
          <div class="stat-lbl">Sakit</div>
          <div class="stat-sub">siswa</div>
        </div>
        
        <div class="stat-card">
          <div class="stat-icon-wrapper alfa-bg">
            <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="alfa-color"><circle cx="12" cy="12" r="10"></circle><line x1="15" y1="9" x2="9" y2="15"></line><line x1="9" y1="9" x2="15" y2="15"></line></svg>
          </div>
          <div class="stat-val">{totals().alfa}</div>
          <div class="stat-lbl">Alfa</div>
          <div class="stat-sub">siswa</div>
        </div>
      </div>
      
      <!-- Statistik Per Kelas -->
      <div class="section-title">Statistik Per Kelas</div>
      {#if dashboardData.kelasStats && dashboardData.kelasStats.length > 0}
        <div class="chart-container">
          {#if chartData}
            <BarChart data={chartData} options={{ tooltipPrefix: 'Kelas' }} />
          {:else}
             <div class="empty-text">Data grafik tidak tersedia</div>
          {/if}
        </div>
      {/if}
      
      <!-- Detail Per Kelas -->
      <div class="section-title">Detail Per Kelas</div>
      {#if dashboardData.kelasStats && dashboardData.kelasStats.length > 0}
        <div class="kelas-list">
          {#each dashboardData.kelasStats as kelas}
            {@const pct = kelas.persentaseHadir || 0}
            {@const pctColor = pct >= 90 ? 'var(--success)' : (pct >= 75 ? 'var(--warning)' : 'var(--error)')}
            
            <div class="kelas-card">
              <div class="kelas-header">
                <div class="kelas-icon">
                  <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="var(--primary)" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"></path><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"></path></svg>
                </div>
                <div class="kelas-info">
                  <div class="kelas-name">Kelas {kelas.kelas}</div>
                  <div class="kelas-total">Total {kelas.jumlahSiswa || 0} siswa</div>
                </div>
                <div class="kelas-pct" style="background-color: {pctColor}">
                  {pct.toFixed(1)}%
                </div>
              </div>
              
              <div class="kelas-mini-stats">
                <div class="mini-stat-col">
                  <div class="mini-val hadir-color">{kelas.hadir || 0}</div>
                  <div class="mini-lbl">Hadir</div>
                </div>
                <div class="mini-stat-col">
                  <div class="mini-val izin-color">{kelas.izin || 0}</div>
                  <div class="mini-lbl">Izin</div>
                </div>
                <div class="mini-stat-col">
                  <div class="mini-val sakit-color">{kelas.sakit || 0}</div>
                  <div class="mini-lbl">Sakit</div>
                </div>
                <div class="mini-stat-col">
                  <div class="mini-val alfa-color">{kelas.alfa || 0}</div>
                  <div class="mini-lbl">Alfa</div>
                </div>
              </div>
            </div>
          {/each}
        </div>
      {/if}
      
      <!-- Comparison (if exists) -->
      {#if dashboardData.comparison}
        <div class="section-title">Perbandingan</div>
        <div class="comparison-grid">
          <div class="comp-card">
            <svg class="comp-icon" xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="23 6 13.5 15.5 8.5 10.5 1 18"></polyline><polyline points="17 6 23 6 23 12"></polyline></svg>
            <div class="comp-lbl">Semester Ini</div>
            <div class="comp-val {dashboardData.comparison.currentSemester >= 0 ? 'success-color' : 'error-color'}">
               <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="23 6 13.5 15.5 8.5 10.5 1 18"></polyline><polyline points="17 6 23 6 23 12"></polyline></svg>
               {dashboardData.comparison.currentSemester >= 0 ? '+' : ''}{dashboardData.comparison.currentSemester.toFixed(1)}%
            </div>
          </div>
          <div class="comp-card">
            <svg class="comp-icon" xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect><line x1="16" y1="2" x2="16" y2="6"></line><line x1="8" y1="2" x2="8" y2="6"></line><line x1="3" y1="10" x2="21" y2="10"></line></svg>
            <div class="comp-lbl">Peningkatan</div>
            <div class="comp-val {dashboardData.comparison.improvement >= 0 ? 'success-color' : 'error-color'}">
               <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="23 6 13.5 15.5 8.5 10.5 1 18"></polyline><polyline points="17 6 23 6 23 12"></polyline></svg>
               {dashboardData.comparison.improvement >= 0 ? '+' : ''}{dashboardData.comparison.improvement.toFixed(1)}%
            </div>
          </div>
        </div>
      {/if}
      
    {/if}
  </div>
</PageLayout>

<style>
  .kepsek-dashboard {
    padding: 16px;
    padding-bottom: 90px;
  }
  
  .header-row {
    display: flex;
    align-items: center;
    margin-bottom: 16px;
  }
  
  .avatar {
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
  
  .welcome-text {
    flex: 1;
  }
  
  .greeting {
    font-size: 14px;
    color: var(--text-secondary);
  }
  
  .name {
    font-size: 18px;
    font-weight: bold;
    color: var(--text-primary);
  }
  
  .filter-section {
    display: flex;
    gap: 8px;
    background-color: #f5f5f5;
    padding: 12px;
    border-radius: 12px;
    margin-bottom: 24px;
  }
  
  .filter-box {
    flex: 1;
    background: white;
    border: 1px solid var(--border);
    border-radius: 8px;
    padding: 0 12px;
  }
  
  .filter-select {
    width: 100%;
    padding: 12px 0;
    border: none;
    background: transparent;
    font-size: 13px;
    outline: none;
    color: var(--text-primary);
  }
  
  .overall-card {
    background: linear-gradient(to bottom, var(--primary), rgba(13, 71, 161, 0.8));
    border-radius: 16px;
    padding: 20px;
    color: white;
    display: flex;
    flex-direction: column;
    align-items: center;
    margin-bottom: 24px;
  }
  
  .card-title {
    font-size: 16px;
  }
  
  .card-subtitle {
    font-size: 12px;
    color: rgba(255,255,255,0.9);
    margin-bottom: 16px;
  }
  
  .overall-grid {
    display: flex;
    justify-content: space-around;
    width: 100%;
    margin-bottom: 16px;
  }
  
  .overall-item {
    display: flex;
    flex-direction: column;
    align-items: center;
  }
  
  .overall-val {
    font-size: 24px;
    font-weight: bold;
    margin-top: 8px;
  }
  
  .overall-lbl {
    font-size: 12px;
    color: rgba(255,255,255,0.9);
  }
  
  .persentase-bubble {
    background: rgba(255,255,255,0.2);
    padding: 8px 16px;
    border-radius: 20px;
    font-weight: bold;
    font-size: 14px;
  }
  
  .section-title {
    font-size: 18px;
    font-weight: bold;
    margin-bottom: 12px;
    margin-top: 24px;
    color: var(--text-primary);
  }
  
  .section-title:first-of-type {
    margin-top: 0;
  }
  
  .detail-grid {
    display: flex;
    gap: 12px;
  }
  
  .stat-card {
    flex: 1;
    background: white;
    border: 1px solid var(--border);
    border-radius: 12px;
    padding: 16px;
    display: flex;
    flex-direction: column;
    align-items: center;
    box-shadow: 0 2px 8px rgba(0,0,0,0.05);
  }
  
  .stat-icon-wrapper {
    padding: 8px;
    border-radius: 8px;
    margin-bottom: 8px;
  }
  
  .izin-bg { background-color: rgba(242, 201, 76, 0.1); }
  .sakit-bg { background-color: rgba(45, 156, 219, 0.1); }
  .alfa-bg { background-color: rgba(235, 87, 87, 0.1); }
  
  .izin-color { color: var(--izin); }
  .sakit-color { color: var(--sakit); }
  .alfa-color { color: var(--alfa); }
  
  .stat-val {
    font-size: 20px;
    font-weight: bold;
    color: var(--text-primary);
  }
  
  .stat-lbl {
    font-size: 12px;
    font-weight: 500;
  }
  
  .stat-sub {
    font-size: 10px;
    color: var(--text-secondary);
  }
  
  .chart-container {
    background: white;
    border: 1px solid var(--border);
    border-radius: 12px;
    height: 250px;
    padding: 16px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.05);
  }
  
  .empty-text {
    display: flex;
    align-items: center;
    justify-content: center;
    height: 100%;
    color: var(--text-secondary);
    font-size: 14px;
  }
  
  .kelas-list {
    display: flex;
    flex-direction: column;
    gap: 12px;
  }
  
  .kelas-card {
    background: white;
    border-radius: 12px;
    padding: 16px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.05);
  }
  
  .kelas-header {
    display: flex;
    align-items: center;
    margin-bottom: 12px;
  }
  
  .kelas-icon {
    background: rgba(13, 71, 161, 0.1);
    padding: 12px;
    border-radius: 12px;
    margin-right: 12px;
  }
  
  .kelas-info {
    flex: 1;
  }
  
  .kelas-name {
    font-weight: bold;
    font-size: 16px;
    color: var(--text-primary);
  }
  
  .kelas-total {
    font-size: 12px;
    color: var(--text-secondary);
  }
  
  .kelas-pct {
    padding: 6px 12px;
    border-radius: 20px;
    color: white;
    font-weight: bold;
    font-size: 12px;
  }
  
  .kelas-mini-stats {
    display: flex;
  }
  
  .mini-stat-col {
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
  
  .mini-lbl {
    font-size: 11px;
    color: var(--text-secondary);
  }
  
  .comparison-grid {
    display: flex;
    gap: 12px;
  }
  
  .comp-card {
    flex: 1;
    background: white;
    border-radius: 12px;
    padding: 16px;
    display: flex;
    flex-direction: column;
    align-items: center;
    box-shadow: 0 2px 8px rgba(0,0,0,0.05);
  }
  
  .comp-icon {
    color: var(--text-secondary);
    margin-bottom: 8px;
  }
  
  .comp-lbl {
    font-size: 12px;
    color: var(--text-secondary);
    margin-bottom: 4px;
  }
  
  .comp-val {
    display: flex;
    align-items: center;
    gap: 4px;
    font-weight: bold;
    font-size: 14px;
  }
  
  .success-color { color: var(--success); }
  .error-color { color: var(--error); }
</style>
