<script lang="ts">
  import { onMount } from 'svelte';
  import { authStore } from '../../lib/stores/auth';
  import { dashboardApi } from '../../lib/api/dashboard';
  
  import PageLayout from '../../components/layout/PageLayout.svelte';
  import StatCard from '../../components/ui/StatCard.svelte';
  import Loading from '../../components/ui/Loading.svelte';
  import ErrorState from '../../components/ui/ErrorState.svelte';
  import Calendar from '../../components/ui/Calendar.svelte';
  import StatusBadge from '../../components/ui/StatusBadge.svelte';

  let dashboardData = $state<any>(null);
  let loading = $state(true);
  let error = $state<string | null>(null);
  let selectedDayDetail = $state<any>(null);

  async function loadData() {
    loading = true;
    error = null;
    const userId = $authStore.user?.id_ortu || $authStore.user?.id;
    
    if (userId) {
      try {
        const res = await dashboardApi.getOrtuDashboard(userId);
        
        if (res.success && res.data) {
          const d = res.data;
          const rawSiswa = d.siswa || d.siswaList || d.anak || [];
          d.siswaList = rawSiswa.map((s: any) => ({
            ...s,
            persentaseHadir: s.statistics?.persentaseHadir ?? s.statistics?.persentase_hadir ?? (s.persentaseHadir || 0),
            calendar: (s.calendar || []).map((c: any) => ({
              ...c,
              date: c.tanggal || c.date
            }))
          }));
          d.siswa = d.siswaList;
          dashboardData = d;
        } else {
          error = res.message || 'Gagal memuat dashboard orang tua';
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

  function handleDayClick(dateStr: string) {
    const list = dashboardData?.siswaList || dashboardData?.siswa;
    if (!list || list.length === 0) return;
    
    // Cari anak yang memiliki catatan absensi aktif (status tidak null) pada tanggal ini
    const entriesWithStatus: any[] = [];
    
    for (const siswa of list) {
      if (siswa.calendar) {
        for (const c of siswa.calendar) {
          const dt = c.tanggal || c.date;
          if (dt && dt.substring(0, 10) === dateStr && c.status) {
            entriesWithStatus.push({
              nama: siswa.nama,
              nis: siswa.nis,
              kelas: siswa.kelas,
              status: c.status,
              keterangan: c.keterangan
            });
            break;
          }
        }
      }
    }
    
    // Jika tidak ada absensi tercatat pada tanggal yang diklik, jangan buka modal (sesuai perilaku Flutter)
    if (entriesWithStatus.length === 0) {
      return;
    }
    
    const [y, m, d] = dateStr.split('-').map(Number);
    const dateObj = new Date(y, m - 1, d);
    const formattedDate = new Intl.DateTimeFormat('id-ID', {
      weekday: 'long',
      day: 'numeric',
      month: 'long',
      year: 'numeric'
    }).format(dateObj);
    
    selectedDayDetail = {
      date: dateStr,
      formattedDate,
      entries: entriesWithStatus
    };
  }

  // Gabungkan penanda kalender untuk semua anak
  let calendarData = $derived.by(() => {
    const data: Record<string, string> = {};
    const list = dashboardData?.siswaList || dashboardData?.siswa || [];
    
    // Prioritas status jika ada lebih dari 1 anak yang punya status di hari yang sama:
    // alfa > sakit > izin > hadir
    const priority: Record<string, number> = {
      alfa: 4,
      sakit: 3,
      izin: 2,
      hadir: 1
    };

    list.forEach((siswa: any) => {
      if (siswa.calendar) {
        siswa.calendar.forEach((c: any) => {
          const dt = c.tanggal || c.date;
          if (dt && c.status) {
            const dateKey = dt.substring(0, 10);
            const currentStatus = (c.status || '').toLowerCase();
            const existingStatus = data[dateKey]?.toLowerCase();
            
            if (!existingStatus) {
              data[dateKey] = currentStatus;
            } else {
              const currentPrio = priority[currentStatus] || 0;
              const existingPrio = priority[existingStatus] || 0;
              if (currentPrio > existingPrio) {
                data[dateKey] = currentStatus;
              }
            }
          }
        });
      }
    });
    return data;
  });
  
  // Statistik kehadiran bulan ini untuk semua anak
  function statsBulanIni() {
    let hadir = 0, izin = 0, sakit = 0, alfa = 0;
    const now = new Date();
    const currYear = now.getFullYear();
    const currMonth = now.getMonth();
    
    const list = dashboardData?.siswaList || dashboardData?.siswa || [];

    list.forEach((siswa: any) => {
      if (siswa.calendar) {
        siswa.calendar.forEach((c: any) => {
          const dt = c.tanggal || c.date;
          if (dt && c.status) {
            const [y, m, d] = dt.substring(0, 10).split('-').map(Number);
            const date = new Date(y, m - 1, d);
            if (date.getFullYear() === currYear && date.getMonth() === currMonth) {
              const st = (c.status || '').toLowerCase();
              if (st === 'hadir') hadir++;
              else if (st === 'izin') izin++;
              else if (st === 'sakit') sakit++;
              else if (st === 'alfa') alfa++;
            }
          }
        });
      }
    });
    return { hadir, izin, sakit, alfa };
  }

</script>

<PageLayout title="" hasBottomNav={true}>
  <div class="ortu-dashboard">
    <!-- Header -->
    <div class="header-row">
      <div class="avatar">
        {($authStore.user?.nama || 'O').charAt(0).toUpperCase()}
      </div>
      <div class="welcome-text">
        <div class="greeting">Selamat Datang,</div>
        <div class="name">{$authStore.user?.nama || 'Orang Tua'}</div>
      </div>
    </div>
    
    {#if loading}
      <Loading />
    {:else if error}
      <ErrorState message={error} onRetry={loadData} />
    {:else if dashboardData}
      <!-- Data Anak -->
      {#if dashboardData.siswaList && dashboardData.siswaList.length > 0}
        <div class="section-title">Data Anak</div>
        <div class="child-cards-container">
          {#each dashboardData.siswaList as siswa}
            {@const pct = siswa.persentaseHadir || 0}
            <div class="child-card">
              <div class="child-avatar">
                {siswa.nama ? siswa.nama.charAt(0).toUpperCase() : 'S'}
              </div>
              <div class="child-info">
                <div class="child-name">{siswa.nama}</div>
                <div class="child-sub">NIS: {siswa.nis}</div>
                <div class="child-sub">Kelas: {siswa.kelas}</div>
              </div>
              <div class="child-pct">
                {pct.toFixed(0)}%
              </div>
            </div>
          {/each}
        </div>
      {/if}

      <!-- Kalender Kehadiran -->
      <div class="section-title">Kalender Kehadiran</div>
      <Calendar attendanceData={calendarData} onDayClick={handleDayClick} />
      
      <!-- Statistik -->
      {#if dashboardData.siswaList && dashboardData.siswaList.length > 0}
        <div class="section-title mt-24">Statistik Bulan Ini</div>
        <div class="stats-row">
          <StatCard title="Hadir" value={statsBulanIni().hadir} subtitle="hari" color="var(--hadir)" />
          <StatCard title="Izin" value={statsBulanIni().izin} subtitle="hari" color="var(--izin)" />
          <StatCard title="Sakit" value={statsBulanIni().sakit} subtitle="hari" color="var(--sakit)" />
          <StatCard title="Alfa" value={statsBulanIni().alfa} subtitle="hari" color="var(--alfa)" />
        </div>
      {/if}
    {/if}
  </div>

  {#if selectedDayDetail}
    <!-- svelte-ignore a11y_click_events_have_key_events -->
    <!-- svelte-ignore a11y_no_static_element_interactions -->
    <div class="bottom-sheet-backdrop" onclick={() => selectedDayDetail = null}>
      <div class="bottom-sheet" onclick={e => e.stopPropagation()}>
        <div class="sheet-header">
          <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="var(--primary)" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect><line x1="16" y1="2" x2="16" y2="6"></line><line x1="8" y1="2" x2="8" y2="6"></line><line x1="3" y1="10" x2="21" y2="10"></line></svg>
          <span class="sheet-date">{selectedDayDetail.formattedDate}</span>
          <button class="sheet-close" onclick={() => selectedDayDetail = null} aria-label="Tutup">&times;</button>
        </div>
        <div class="sheet-divider"></div>
        <div class="sheet-body">
          {#each selectedDayDetail.entries as item}
            <div class="student-entry">
              <div class="sheet-student">{item.nama}</div>
              <div class="sheet-sub">NIS: {item.nis} • Kelas: {item.kelas || '-'}</div>
              <div class="sheet-row">
                <span class="sheet-label">Status:</span>
                <StatusBadge status={item.status} />
              </div>
              {#if item.keterangan}
                <div class="sheet-keterangan">
                  <strong>Keterangan:</strong> {item.keterangan}
                </div>
              {/if}
            </div>
          {/each}
        </div>
      </div>
    </div>
  {/if}
</PageLayout>

<style>
  .ortu-dashboard {
    padding: 16px;
    padding-bottom: 90px;
  }
  
  .header-row {
    display: flex;
    align-items: center;
    margin-bottom: 24px;
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
  
  .section-title {
    font-size: 18px;
    font-weight: bold;
    margin-bottom: 12px;
    color: var(--text-primary);
  }
  
  .mt-24 {
    margin-top: 24px;
  }

  .child-cards-container {
    display: flex;
    flex-direction: column;
    gap: 12px;
    margin-bottom: 24px;
  }
  
  .child-card {
    display: flex;
    align-items: center;
    padding: 16px;
    background: linear-gradient(135deg, var(--primary), #1e3a8a);
    border-radius: 16px;
    color: white;
  }
  
  .child-avatar {
    width: 56px;
    height: 56px;
    border-radius: 28px;
    background-color: rgba(255, 255, 255, 0.2);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 22px;
    font-weight: bold;
    margin-right: 16px;
    flex-shrink: 0;
  }
  
  .child-info {
    flex: 1;
    min-width: 0;
  }
  
  .child-name {
    font-size: 18px;
    font-weight: bold;
    margin-bottom: 4px;
  }
  
  .child-sub {
    font-size: 12px;
    color: rgba(255, 255, 255, 0.9);
  }
  
  .child-pct {
    padding: 6px 12px;
    background-color: rgba(255, 255, 255, 0.2);
    border-radius: 20px;
    font-weight: bold;
    font-size: 14px;
  }

  .stats-row {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 8px;
  }
  
  .bottom-sheet-backdrop {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background-color: rgba(0, 0, 0, 0.5);
    display: flex;
    justify-content: center;
    align-items: flex-end;
    z-index: 1000;
  }
  
  .bottom-sheet {
    background: white;
    width: 100%;
    max-width: 500px;
    border-radius: 20px 20px 0 0;
    padding: 24px;
    box-shadow: 0 -4px 20px rgba(0,0,0,0.15);
    animation: slideUp 0.25s ease-out;
    max-height: 85vh;
    overflow-y: auto;
  }
  
  @keyframes slideUp {
    from { transform: translateY(100%); }
    to { transform: translateY(0); }
  }
  
  .sheet-header {
    display: flex;
    align-items: center;
    gap: 12px;
  }
  
  .sheet-date {
    font-size: 16px;
    font-weight: bold;
    color: var(--text-primary);
    flex: 1;
  }
  
  .sheet-close {
    background: none;
    border: none;
    font-size: 24px;
    line-height: 1;
    color: var(--text-secondary);
    cursor: pointer;
  }
  
  .sheet-divider {
    height: 1px;
    background-color: var(--border);
    margin: 16px 0;
  }
  
  .sheet-body {
    display: flex;
    flex-direction: column;
    gap: 16px;
  }

  .student-entry {
    display: flex;
    flex-direction: column;
    gap: 6px;
    padding-bottom: 12px;
    border-bottom: 1px dashed var(--border);
  }

  .student-entry:last-child {
    border-bottom: none;
    padding-bottom: 0;
  }
  
  .sheet-student {
    font-size: 16px;
    font-weight: 700;
    color: var(--text-primary);
  }

  .sheet-sub {
    font-size: 12px;
    color: var(--text-secondary);
    margin-bottom: 4px;
  }
  
  .sheet-row {
    display: flex;
    align-items: center;
    gap: 12px;
  }
  
  .sheet-label {
    font-size: 14px;
    color: var(--text-secondary);
  }
  
  .sheet-keterangan {
    font-size: 13px;
    color: var(--text-secondary);
    background-color: var(--bg);
    padding: 10px 14px;
    border-radius: 8px;
    margin-top: 4px;
  }
</style>
