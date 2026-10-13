<script lang="ts">
  import { onMount, onDestroy } from 'svelte';
  import { push } from 'svelte-spa-router';
  import { authStore } from '../../lib/stores/auth';
  import { toast } from '../../lib/stores/toast';
  import { get } from 'svelte/store';
  import { absensiApi } from '../../lib/api/absensi';
  import { kelasApi } from '../../lib/api/kelas';
  import type { Absensi } from '../../lib/types/absensi';
  
  import PageLayout from '../../components/layout/PageLayout.svelte';
  import StatusBadge from '../../components/ui/StatusBadge.svelte';
  import Loading from '../../components/ui/Loading.svelte';

  let listAbsensi = $state<Absensi[]>([]);
  let listKelas = $state<any[]>([]);
  let loading = $state(true);
  let selectedDate = $state(new Date().toISOString().split('T')[0]);
  let selectedKelas = $state<number | null>(null);
  let activeMenuId = $state<number | null>(null);
  let datePickerInput = $state<HTMLInputElement>();

  async function loadKelas() {
    loading = true;
    const auth = get(authStore);
    const nip = auth.user?.nip || '';
    
    let res = await kelasApi.getByGuru(nip);
    if (!res.success || !res.data || res.data.length === 0) {
      res = await kelasApi.getAll();
    }
    
    if (res.success && res.data) {
      listKelas = res.data;
      if (listKelas.length > 0) {
        selectedKelas = listKelas[0].id_kelas;
      }
    }
    await loadAbsensi();
  }

  async function loadAbsensi() {
    if (!selectedKelas) {
      loading = false;
      return;
    }
    
    loading = true;
    const res = await absensiApi.getByKelas(selectedKelas, selectedDate);
    if (res.success && res.data) {
      listAbsensi = res.data;
    } else {
      listAbsensi = [];
    }
    
    loading = false;
  }

  async function handleDelete(absensi: Absensi) {
    if (confirm(`Yakin ingin menghapus absensi ${absensi.nama_siswa || absensi.nis}?`)) {
      if (absensi.id_absensi) {
        const res = await absensiApi.delete(absensi.id_absensi);
        if (res.success) {
          toast.success('Absensi berhasil dihapus');
          loadAbsensi();
        } else {
          toast.error(res.message || 'Gagal menghapus absensi');
        }
      }
    }
    activeMenuId = null;
  }
  
  function getCount(status: string) {
    return listAbsensi.filter(a => a.status_kehadiran === status).length;
  }

  function formatDateDisplay(dateStr: string) {
    const d = new Date(dateStr);
    return d.toLocaleDateString('id-ID', { day: 'numeric', month: 'short', year: 'numeric' });
  }
  
  onMount(() => {
    loadKelas();
    
    // Close menu when clicking outside
    const handleOutsideClick = () => {
      activeMenuId = null;
    };
    document.addEventListener('click', handleOutsideClick);
    return () => {
      document.removeEventListener('click', handleOutsideClick);
    };
  });
</script>

<PageLayout title="Data Absensi" hasBottomNav={true} showBack={false}>
  <div class="page-container">
    <div class="filter-section">
      <div class="filter-row">
        <div class="date-picker-wrapper">
          <input 
            type="date" 
            class="hidden-date-input"
            bind:this={datePickerInput}
            bind:value={selectedDate} 
            onchange={loadAbsensi}
            id="date-picker"
          />
          <!-- svelte-ignore a11y_click_events_have_key_events -->
          <!-- svelte-ignore a11y_no_static_element_interactions -->
          <div class="date-display" onclick={() => datePickerInput?.showPicker()}>
            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect><line x1="16" y1="2" x2="16" y2="6"></line><line x1="8" y1="2" x2="8" y2="6"></line><line x1="3" y1="10" x2="21" y2="10"></line></svg>
            <span>{formatDateDisplay(selectedDate)}</span>
          </div>
        </div>
        
        {#if listKelas.length > 0}
          <div class="dropdown-wrapper">
            <select bind:value={selectedKelas} onchange={loadAbsensi} class="kelas-dropdown">
              {#each listKelas as kelas}
                <option value={kelas.id_kelas || kelas.idKelas}>Kelas {kelas.kelas || kelas.nama_kelas}</option>
              {/each}
            </select>
          </div>
        {/if}
      </div>
    </div>
    
    <div class="list-container">
      {#if loading}
        <Loading />
      {:else if listAbsensi.length === 0}
        <div class="empty-state">
          <svg class="empty-icon" xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="16" y1="13" x2="8" y2="13"></line><line x1="16" y1="17" x2="8" y2="17"></line><polyline points="10 9 9 9 8 9"></polyline></svg>
          <div class="empty-text">Belum ada data absensi untuk tanggal ini</div>
          <button class="empty-btn" onclick={() => push('/guru/mulai-absensi')}>Mulai Absensi</button>
        </div>
      {:else}
        <div class="absensi-list">
          {#each listAbsensi as absensi, i}
            <div class="absensi-card">
              <div class="number-badge">{i + 1}</div>
              
              <div class="siswa-info">
                <span class="nama">{absensi.nama_siswa || `Siswa ${absensi.nis}`}</span>
                <span class="nis">NIS: {absensi.nis}</span>
                {#if absensi.keterangan}
                  <span class="keterangan">{absensi.keterangan}</span>
                {/if}
              </div>
              
              <StatusBadge status={absensi.status_kehadiran} />
              
              <div class="menu-container">
                <!-- svelte-ignore a11y_consider_explicit_label -->
                <!-- svelte-ignore a11y_click_events_have_key_events -->
                <!-- svelte-ignore a11y_no_static_element_interactions -->
                <button class="more-btn" onclick={(e) => { e.stopPropagation(); activeMenuId = activeMenuId === absensi.id_absensi ? null : (absensi.id_absensi ?? null); }}>
                  <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="1"></circle><circle cx="12" cy="5" r="1"></circle><circle cx="12" cy="19" r="1"></circle></svg>
                </button>
                
                {#if activeMenuId === absensi.id_absensi}
                  <!-- svelte-ignore a11y_click_events_have_key_events -->
                  <!-- svelte-ignore a11y_no_static_element_interactions -->
                  <div class="popup-menu" role="menu" tabindex="-1" onclick={(e) => e.stopPropagation()}>
                    <button class="menu-item" onclick={() => push(`/guru/edit-absensi/${absensi.id_absensi}`)}>
                      <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path></svg>
                      <span>Edit</span>
                    </button>
                    <button class="menu-item danger" onclick={() => handleDelete(absensi)}>
                      <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path></svg>
                      <span>Hapus</span>
                    </button>
                  </div>
                {/if}
              </div>
            </div>
          {/each}
        </div>
      {/if}
    </div>
    
    {#if listAbsensi.length > 0}
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

  <button class="fab" onclick={() => push('/guru/mulai-absensi')}>
    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"></line><line x1="5" y1="12" x2="19" y2="12"></line></svg>
    <span>Absensi</span>
  </button>
</PageLayout>

<style>
  .page-container {
    display: flex;
    flex-direction: column;
    height: 100%;
    padding-bottom: 90px;
  }
  
  .filter-section {
    padding: 16px;
    background-color: #f9fafb;
  }
  
  .filter-row {
    display: flex;
    gap: 12px;
  }
  
  .date-picker-wrapper {
    flex: 1;
    position: relative;
  }
  
  .hidden-date-input {
    position: absolute;
    opacity: 0;
    width: 1px;
    height: 1px;
    top: 0;
    left: 0;
  }
  
  .date-display {
    display: flex;
    align-items: center;
    gap: 8px;
    background-color: white;
    padding: 12px;
    border-radius: 12px;
    border: 1px solid var(--border);
    font-weight: 500;
    cursor: pointer;
  }
  
  .dropdown-wrapper {
    flex: 1;
    background-color: white;
    border-radius: 12px;
    border: 1px solid var(--border);
    overflow: hidden;
  }
  
  .kelas-dropdown {
    width: 100%;
    height: 100%;
    padding: 12px;
    border: none;
    background: transparent;
    font-size: 14px;
    font-family: inherit;
    outline: none;
  }
  
  .list-container {
    flex: 1;
    padding: 16px;
    overflow-y: auto;
  }
  
  .empty-state {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    height: 100%;
    min-height: 300px;
  }
  
  .empty-icon {
    color: var(--border);
    margin-bottom: 16px;
  }
  
  .empty-text {
    color: var(--text-secondary);
    margin-bottom: 16px;
    font-size: 14px;
    text-align: center;
  }
  
  .empty-btn {
    background-color: var(--primary);
    color: white;
    border: none;
    padding: 10px 24px;
    border-radius: 8px;
    font-weight: 600;
    cursor: pointer;
  }
  
  .absensi-list {
    display: flex;
    flex-direction: column;
    gap: 12px;
  }
  
  .absensi-card {
    display: flex;
    align-items: center;
    background: white;
    padding: 16px;
    border-radius: 12px;
    box-shadow: 0 4px 10px rgba(0,0,0,0.05);
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
    flex: 1;
    margin-right: 8px;
  }
  
  .nama {
    font-weight: 600;
    font-size: 16px;
    color: var(--text-primary);
  }
  
  .nis, .keterangan {
    font-size: 12px;
    color: var(--text-secondary);
    margin-top: 2px;
  }
  
  .menu-container {
    position: relative;
    margin-left: 8px;
  }
  
  .more-btn {
    background: none;
    border: none;
    color: var(--text-secondary);
    padding: 4px;
    cursor: pointer;
    display: flex;
  }
  
  .popup-menu {
    position: absolute;
    top: 100%;
    right: 0;
    background: white;
    border-radius: 8px;
    box-shadow: 0 4px 20px rgba(0,0,0,0.15);
    z-index: 100;
    min-width: 120px;
    overflow: hidden;
    display: flex;
    flex-direction: column;
  }
  
  .menu-item {
    display: flex;
    align-items: center;
    gap: 8px;
    padding: 12px 16px;
    background: none;
    border: none;
    width: 100%;
    text-align: left;
    cursor: pointer;
    font-size: 14px;
    color: var(--text-primary);
  }
  
  .menu-item:hover {
    background-color: #f5f5f5;
  }
  
  .menu-item.danger {
    color: var(--error);
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
  
  .fab {
    position: fixed;
    bottom: 90px;
    right: 24px;
    background-color: var(--primary);
    color: white;
    border: none;
    border-radius: 28px;
    padding: 12px 20px;
    display: flex;
    align-items: center;
    gap: 8px;
    font-weight: 600;
    box-shadow: 0 4px 12px rgba(13, 71, 161, 0.3);
    cursor: pointer;
    z-index: 50;
  }
  
  .fab:active {
    transform: scale(0.95);
  }
</style>
