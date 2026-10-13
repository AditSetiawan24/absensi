<script lang="ts">
  import { onMount } from 'svelte';
  import { push } from 'svelte-spa-router';
  import { authStore } from '../../lib/stores/auth';
  import { laporanApi } from '../../lib/api/laporan';
  import { kelasApi } from '../../lib/api/kelas';
  import { toast } from '../../lib/stores/toast';
  import { exportLaporanToExcel, printLaporanPdf, resolveTahunAjar, resolveSemester } from '../../lib/utils/export';
  import type { Laporan } from '../../lib/types/laporan';
  
  import PageLayout from '../../components/layout/PageLayout.svelte';
  import Loading from '../../components/ui/Loading.svelte';
  import TextField from '../../components/ui/TextField.svelte';
  import Dropdown from '../../components/ui/Dropdown.svelte';

  let listLaporan = $state<any[]>([]);
  let kelasList = $state<any[]>([]);
  let loading = $state(true);
  let isSubmitting = $state(false);
  let selectedKelas = $state<any>(null);
  
  // Modals state
  let showCreateModal = $state(false);
  let showDownloadModal = $state<number | null>(null);
  let showDetailModal = $state(false);
  let selectedDetailLaporan = $state<any>(null);
  let downloadTargetLaporan = $state<any>(null);
  let activeMenuId = $state<number | null>(null);

  // Form state
  function getAutoAcademic() {
    const now = new Date();
    const year = now.getFullYear();
    const month = now.getMonth() + 1;
    if (month >= 7) {
      return {
        tahunAjar: `${year}/${year + 1}`,
        semester: 'Ganjil'
      };
    } else {
      return {
        tahunAjar: `${year - 1}/${year}`,
        semester: 'Genap'
      };
    }
  }

  const defaultAcademic = getAutoAcademic();
  let tahunAjar = $state(defaultAcademic.tahunAjar);
  let selectedSemester = $state(defaultAcademic.semester);

  async function loadKelas() {
    loading = true;
    const nip = $authStore.user?.nip;
    
    if (nip) {
      const kelasRes = await kelasApi.getByGuru(nip);
      if (kelasRes.success && kelasRes.data && kelasRes.data.length > 0) {
        kelasList = kelasRes.data;
        if (!selectedKelas) {
          selectedKelas = kelasList[0];
        }
        await loadLaporan();
      } else {
        kelasList = [];
        selectedKelas = null;
        listLaporan = [];
      }
    }
    loading = false;
  }

  async function loadLaporan() {
    if (!selectedKelas) {
      listLaporan = [];
      return;
    }
    loading = true;
    const classId = selectedKelas.id_kelas || selectedKelas.idKelas;
    const res = await laporanApi.getByKelas(classId);
    if (res.success && res.data) {
      if (Array.isArray(res.data)) {
        listLaporan = res.data;
      } else if (res.data && Array.isArray((res.data as any).laporan)) {
        listLaporan = (res.data as any).laporan;
      } else {
        listLaporan = [];
      }
    } else {
      listLaporan = [];
    }
    loading = false;
  }

  onMount(() => {
    loadKelas();
    
    const handleOutsideClick = () => {
      activeMenuId = null;
    };
    document.addEventListener('click', handleOutsideClick);
    return () => document.removeEventListener('click', handleOutsideClick);
  });

  function openCreateModal() {
    const auto = getAutoAcademic();
    tahunAjar = auto.tahunAjar;
    selectedSemester = auto.semester;
    showCreateModal = true;
  }

  async function submitCreate() {
    const nip = $authStore.user?.nip;
    const kelas = selectedKelas?.kelas || selectedKelas?.nama_kelas;

    if (!tahunAjar || !nip || !kelas) {
      toast.error('Lengkapi semua field');
      return;
    }
    
    isSubmitting = true;
    const res = await laporanApi.createFromAbsensi({
      tahun_ajar: tahunAjar,
      semester: selectedSemester === 'Ganjil' ? 1 : 2,
      kelas,
      nip
    });
    
    isSubmitting = false;
    
    if (res.success) {
      toast.success('Laporan berhasil dibuat');
      showCreateModal = false;
      loadLaporan();
    } else {
      toast.error(res.message || 'Gagal membuat laporan');
    }
  }
  
  async function submitLaporan(laporan: any) {
    if (!confirm('Yakin ingin submit laporan ini?')) return;
    isSubmitting = true;
    const res = await laporanApi.submit(laporan.id_laporan || laporan.idLaporan);
    isSubmitting = false;
    if (res.success) {
      toast.success('Laporan berhasil disubmit');
      await loadLaporan();
    } else {
      toast.error(res.message);
    }
    activeMenuId = null;
  }
  
  async function unsubmitLaporan(laporan: any) {
    if (!confirm('Yakin ingin membatalkan submit laporan ini? Laporan akan kembali ke status draft.')) return;
    isSubmitting = true;
    const res = await laporanApi.unsubmit(laporan.id_laporan || laporan.idLaporan);
    isSubmitting = false;
    if (res.success) {
      toast.success('Submit laporan berhasil dibatalkan');
      await loadLaporan();
    } else {
      toast.error(res.message);
    }
    activeMenuId = null;
  }
  
  async function refreshLaporan(laporan: any) {
    isSubmitting = true;
    const res = await laporanApi.refresh(laporan.id_laporan || laporan.idLaporan);
    isSubmitting = false;
    if (res.success) {
      toast.success(res.message || 'Data berhasil diperbarui');
      await loadLaporan();
    } else {
      toast.error(res.message);
    }
    activeMenuId = null;
  }
  
  async function deleteLaporan(laporan: any) {
    if (!confirm(`Yakin ingin menghapus laporan ${laporan.semester}?`)) return;
    isSubmitting = true;
    const res = await laporanApi.delete(laporan.id_laporan || laporan.idLaporan);
    isSubmitting = false;
    if (res.success) {
      toast.success('Laporan berhasil dihapus');
      await loadLaporan();
    } else {
      toast.error(res.message);
    }
  }

  function openDetailModal(laporan: any) {
    selectedDetailLaporan = laporan;
    showDetailModal = true;
  }
  
  function openDownload(laporan: any) {
    downloadTargetLaporan = laporan;
    showDownloadModal = laporan.id_laporan || laporan.idLaporan;
  }

  function downloadLaporan(format: string) {
    if (!downloadTargetLaporan) return;
    const kelasName = selectedKelas?.kelas || selectedKelas?.nama_kelas || '';
    if (format === 'pdf') {
      toast.info('Membuka pratinjau cetak PDF...');
      printLaporanPdf(downloadTargetLaporan, kelasName);
    } else {
      toast.success('Mengunduh spreadsheet Excel...');
      exportLaporanToExcel(downloadTargetLaporan, kelasName);
    }
    showDownloadModal = null;
  }

  function formatDateStr(dateStr?: string) {
    if (!dateStr) return '';
    try {
      const d = new Date(dateStr);
      return d.toLocaleDateString('id-ID', { day: '2-digit', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit' });
    } catch {
      return dateStr;
    }
  }

  function isSubmitted(laporan: any) {
    if (!laporan) return false;
    if (laporan.is_submitted === true || laporan.is_submitted === 1 || laporan.is_submitted === '1' || laporan.isSubmitted === true) {
      return true;
    }
    const s = String(laporan.status || laporan.status_persetujuan || '').toLowerCase();
    return s === 'submitted' || s === 'disubmit' || s === 'approved' || s === 'disetujui';
  }
</script>

<PageLayout title="Laporan Kehadiran" hasBottomNav={true}>
  <!-- Custom Header Actions inside PageLayout body to avoid touching PageLayout -->
  <div class="top-actions">
    {#if kelasList.length > 0}
      <div class="class-selector">
        <select 
          class="class-select" 
          value={selectedKelas?.id_kelas || selectedKelas?.idKelas} 
          onchange={(e) => {
            const targetId = Number((e.target as HTMLSelectElement).value);
            selectedKelas = kelasList.find(k => (k.id_kelas || k.idKelas) === targetId);
            loadLaporan();
          }}
        >
          {#each kelasList as k}
            <option value={k.id_kelas || k.idKelas}>Kelas {k.kelas || k.nama_kelas}</option>
          {/each}
        </select>
      </div>
    {/if}
    <button class="rekap-btn" onclick={() => push('/guru/rekap-bulanan')}>
      <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect><line x1="16" y1="2" x2="16" y2="6"></line><line x1="8" y1="2" x2="8" y2="6"></line><line x1="3" y1="10" x2="21" y2="10"></line></svg>
      <span>Rekap Bulanan</span>
    </button>
  </div>

  <div class="laporan-content">
    {#if loading}
      <Loading />
    {:else if listLaporan.length === 0}
      <div class="empty-state">
        <svg class="empty-icon" xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="16" y1="13" x2="8" y2="13"></line><line x1="16" y1="17" x2="8" y2="17"></line><polyline points="10 9 9 9 8 9"></polyline></svg>
        <div class="empty-text">Belum ada laporan untuk kelas ini</div>
        <button class="empty-btn" onclick={openCreateModal}>Buat Laporan</button>
      </div>
    {:else}
      <div class="laporan-list">
        {#each listLaporan as laporan}
          {@const submitted = isSubmitted(laporan)}
          <div class="laporan-card" class:submitted-card={submitted}>
            <!-- Header with status badge -->
            <div class="card-header-row">
              <div class="card-type-icon" class:submitted-icon={submitted}>
                {#if submitted}
                  <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path><polyline points="22 4 12 14.01 9 11.01"></polyline></svg>
                {:else}
                  <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="16" y1="13" x2="8" y2="13"></line><line x1="16" y1="17" x2="8" y2="17"></line><polyline points="10 9 9 9 8 9"></polyline></svg>
                {/if}
              </div>
              <div class="header-titles">
                <div class="title-and-badge">
                  <span class="report-title">Laporan {resolveSemester(laporan)}</span>
                  <span class="status-chip" class:chip-submitted={submitted}>
                    {submitted ? 'Submitted' : 'Draft'}
                  </span>
                </div>
                <div class="sub-title">Tahun Ajaran {resolveTahunAjar(laporan)}</div>
                {#if submitted && (laporan.submitted_at || laporan.submittedAt)}
                  <div class="submitted-time">Disubmit: {formatDateStr(laporan.submitted_at || laporan.submittedAt)}</div>
                {/if}
              </div>
            </div>

            <hr class="card-divider" />

            <!-- Stats -->
            <div class="stats-grid">
              <div class="stat-column">
                <span class="stat-num text-hadir">{laporan.hadir ?? laporan.total_hadir ?? 0}</span>
                <span class="stat-name">Hadir</span>
              </div>
              <div class="stat-column">
                <span class="stat-num text-izin">{laporan.izin ?? laporan.total_izin ?? 0}</span>
                <span class="stat-name">Izin</span>
              </div>
              <div class="stat-column">
                <span class="stat-num text-sakit">{laporan.sakit ?? laporan.total_sakit ?? 0}</span>
                <span class="stat-name">Sakit</span>
              </div>
              <div class="stat-column">
                <span class="stat-num text-alfa">{laporan.alfa ?? laporan.total_alfa ?? 0}</span>
                <span class="stat-name">Alfa</span>
              </div>
            </div>

            <hr class="card-divider" />

            <!-- Action Buttons Row 1: Lihat, Download, Refresh Data -->
            <div class="action-row">
              <button class="btn-outlined btn-lihat" onclick={() => openDetailModal(laporan)}>
                <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path><circle cx="12" cy="12" r="3"></circle></svg>
                <span>Lihat</span>
              </button>

              <button class="btn-outlined btn-download" onclick={() => openDownload(laporan)}>
                <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path><polyline points="7 10 12 15 17 10"></polyline><line x1="12" y1="15" x2="12" y2="3"></line></svg>
                <span>Download</span>
              </button>

              {#if !submitted}
                <button class="btn-icon-refresh" onclick={() => refreshLaporan(laporan)} title="Refresh Data">
                  <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 2v6h-6"></path><path d="M3 12a9 9 0 0 1 15-6.7L21 8"></path><path d="M3 22v-6h6"></path><path d="M21 12a9 9 0 0 1-15 6.7L3 16"></path></svg>
                </button>
              {/if}
            </div>

            <!-- Action Buttons Row 2: Submit / Batal Submit, Hapus -->
            <div class="action-row mt-2">
              {#if submitted}
                <button class="btn-outlined btn-unsubmit" onclick={() => unsubmitLaporan(laporan)} disabled={isSubmitting}>
                  <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 7v6h6"></path><path d="M21 17a9 9 0 0 0-9-9 9 9 0 0 0-6 2.3l-3 2.7"></path></svg>
                  <span>Batal Submit</span>
                </button>
              {:else}
                <button class="btn-solid btn-submit" onclick={() => submitLaporan(laporan)} disabled={isSubmitting}>
                  <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="22" y1="2" x2="11" y2="13"></line><polygon points="22 2 15 22 11 13 2 9 22 2"></polygon></svg>
                  <span>Submit</span>
                </button>

                <button class="btn-outlined btn-hapus" onclick={() => deleteLaporan(laporan)} disabled={isSubmitting}>
                  <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path></svg>
                  <span>Hapus</span>
                </button>
              {/if}
            </div>
          </div>
        {/each}
      </div>
    {/if}
  </div>

  <button class="fab" onclick={openCreateModal}>
    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"></line><line x1="5" y1="12" x2="19" y2="12"></line></svg>
    <span>Buat Laporan</span>
  </button>
  
  <!-- Create Modal Bottom Sheet -->
  {#if showCreateModal}
    <!-- svelte-ignore a11y_click_events_have_key_events -->
    <!-- svelte-ignore a11y_no_static_element_interactions -->
    <div class="bottom-sheet-backdrop" onclick={() => !isSubmitting && (showCreateModal = false)}>
      <div class="bottom-sheet" onclick={e => e.stopPropagation()}>
        <div class="sheet-header">
          <h3>Buat Laporan Baru</h3>
          <button class="close-btn" onclick={() => !isSubmitting && (showCreateModal = false)} aria-label="Tutup">
            <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
          </button>
        </div>
        
        <div class="sheet-body">
          <TextField 
            bind:value={tahunAjar} 
            label="Tahun Ajaran" 
            placeholder="Contoh: 2024/2025" 
            prefixIcon="calendar" 
          />
          
          <div class="mt-4">
            <Dropdown 
              label="Semester" 
              bind:value={selectedSemester} 
              options={[{value: 'Ganjil', label: 'Ganjil'}, {value: 'Genap', label: 'Genap'}]} 
            />
          </div>
          
          {#if selectedKelas}
            <div class="kelas-info mt-4">
              <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"></path><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"></path></svg>
              <span>Kelas {selectedKelas.kelas || selectedKelas.nama_kelas}</span>
            </div>
          {/if}
          
          <p class="note mt-4">Catatan: Laporan akan dibuat sebagai draft. Anda dapat submit setelah memverifikasi data.</p>
          
          <button class="submit-btn mt-6" onclick={submitCreate} disabled={isSubmitting}>
            {isSubmitting ? 'Memproses...' : 'Buat Laporan'}
          </button>
        </div>
      </div>
    </div>
  {/if}
  
  <!-- Download Options Bottom Sheet -->
  {#if showDownloadModal !== null}
    <!-- svelte-ignore a11y_click_events_have_key_events -->
    <!-- svelte-ignore a11y_no_static_element_interactions -->
    <div class="bottom-sheet-backdrop" onclick={() => showDownloadModal = null}>
      <div class="bottom-sheet download-sheet" onclick={e => e.stopPropagation()}>
        <h3>Download Laporan</h3>
        
        <div class="download-options">
          <button class="download-item" onclick={() => downloadLaporan('pdf')}>
            <div class="icon-box pdf">
              <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="16" y1="13" x2="8" y2="13"></line><line x1="16" y1="17" x2="8" y2="17"></line><polyline points="10 9 9 9 8 9"></polyline></svg>
            </div>
            <div class="download-info">
              <span class="download-title">Download PDF</span>
              <span class="download-desc">Format dokumen PDF</span>
            </div>
          </button>
          
          <button class="download-item" onclick={() => downloadLaporan('excel')}>
            <div class="icon-box excel">
              <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"></rect><line x1="3" y1="9" x2="21" y2="9"></line><line x1="9" y1="21" x2="9" y2="9"></line></svg>
            </div>
            <div class="download-info">
              <span class="download-title">Download Excel</span>
              <span class="download-desc">Format spreadsheet Excel</span>
            </div>
          </button>
        </div>
      </div>
    </div>
  {/if}
  <!-- Detail Modal Bottom Sheet -->
  {#if showDetailModal && selectedDetailLaporan}
    {@const total = (selectedDetailLaporan.hadir || selectedDetailLaporan.total_hadir || 0) + 
                    (selectedDetailLaporan.izin || selectedDetailLaporan.total_izin || 0) + 
                    (selectedDetailLaporan.sakit || selectedDetailLaporan.total_sakit || 0) + 
                    (selectedDetailLaporan.alfa || selectedDetailLaporan.total_alfa || 0)}
    {@const persentaseHadir = total > 0 ? (((selectedDetailLaporan.hadir || selectedDetailLaporan.total_hadir || 0) / total) * 100) : 0}
    <!-- svelte-ignore a11y_click_events_have_key_events -->
    <!-- svelte-ignore a11y_no_static_element_interactions -->
    <div class="bottom-sheet-backdrop" onclick={() => showDetailModal = false}>
      <div class="bottom-sheet detail-sheet" onclick={e => e.stopPropagation()}>
        <div class="sheet-drag-handle"></div>

        <div class="detail-header-row">
          <div class="detail-icon-box">
            <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="16" y1="13" x2="8" y2="13"></line><line x1="16" y1="17" x2="8" y2="17"></line><polyline points="10 9 9 9 8 9"></polyline></svg>
          </div>
          <div class="detail-title-col">
            <div class="detail-title">Laporan {resolveSemester(selectedDetailLaporan)}</div>
            <div class="detail-subtitle">Tahun Ajaran {resolveTahunAjar(selectedDetailLaporan)}</div>
          </div>
        </div>

        <!-- Summary Card -->
        <div class="summary-card">
          <div class="percentage-big">{persentaseHadir.toFixed(1)}%</div>
          <div class="percentage-label">Tingkat Kehadiran</div>
        </div>

        <!-- Statistik Kehadiran -->
        <div class="section-title">Statistik Kehadiran</div>
        <div class="detail-stats-grid">
          <div class="detail-stat-box box-hadir">
            <div class="dstat-num">{selectedDetailLaporan.hadir ?? selectedDetailLaporan.total_hadir ?? 0}</div>
            <div class="dstat-label">Hadir</div>
          </div>
          <div class="detail-stat-box box-izin">
            <div class="dstat-num">{selectedDetailLaporan.izin ?? selectedDetailLaporan.total_izin ?? 0}</div>
            <div class="dstat-label">Izin</div>
          </div>
          <div class="detail-stat-box box-sakit">
            <div class="dstat-num">{selectedDetailLaporan.sakit ?? selectedDetailLaporan.total_sakit ?? 0}</div>
            <div class="dstat-label">Sakit</div>
          </div>
          <div class="detail-stat-box box-alfa">
            <div class="dstat-num">{selectedDetailLaporan.alfa ?? selectedDetailLaporan.total_alfa ?? 0}</div>
            <div class="dstat-label">Alfa</div>
          </div>
        </div>

        <!-- Informasi -->
        <div class="section-title mt-4">Informasi</div>
        <div class="info-table">
          <div class="info-row">
            <span class="info-label">Total Data Presensi</span>
            <span class="info-value">{total} catatan</span>
          </div>
          <div class="info-row">
            <span class="info-label">Total Kehadiran</span>
            <span class="info-value">{selectedDetailLaporan.hadir ?? selectedDetailLaporan.total_hadir ?? 0} siswa ({persentaseHadir.toFixed(1)}%)</span>
          </div>
          <div class="info-row">
            <span class="info-label">Jumlah Siswa</span>
            <span class="info-value">{selectedDetailLaporan.kelas?.siswa?.length || selectedKelas?.siswa?.length || 10} siswa</span>
          </div>
          <div class="info-row">
            <span class="info-label">Kelas</span>
            <span class="info-value">Kelas {selectedKelas?.kelas || selectedKelas?.nama_kelas || selectedDetailLaporan.kelas?.kelas || '-'}</span>
          </div>
          <div class="info-row">
            <span class="info-label">Tahun Ajaran</span>
            <span class="info-value">{resolveTahunAjar(selectedDetailLaporan)}</span>
          </div>
          <div class="info-row">
            <span class="info-label">Semester</span>
            <span class="info-value">{resolveSemester(selectedDetailLaporan)}</span>
          </div>
          {#if selectedDetailLaporan.periode_awal || selectedDetailLaporan.periodeAwal}
            <div class="info-row">
              <span class="info-label">Periode</span>
              <span class="info-value">{selectedDetailLaporan.periode_awal || selectedDetailLaporan.periodeAwal} s/d {selectedDetailLaporan.periode_akhir || selectedDetailLaporan.periodeAkhir}</span>
            </div>
          {/if}
        </div>

        <!-- Tutup Button -->
        <button class="btn-tutup mt-6" onclick={() => showDetailModal = false}>
          Tutup
        </button>
      </div>
    </div>
  {/if}
</PageLayout>

<style>
  .top-actions {
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 12px;
    padding: 16px 24px 0;
  }
  
  .class-selector {
    flex: 1;
    max-width: 240px;
  }
  
  .class-select {
    width: 100%;
    padding: 8px 12px;
    border-radius: 8px;
    border: 1px solid var(--border);
    background: white;
    font-size: 14px;
    font-weight: 500;
    color: var(--text-primary);
    cursor: pointer;
    outline: none;
  }
  
  .rekap-btn {
    display: flex;
    align-items: center;
    gap: 8px;
    background-color: var(--primary);
    color: white;
    border: none;
    padding: 8px 16px;
    border-radius: 8px;
    font-size: 14px;
    font-weight: 500;
    cursor: pointer;
  }
  
  .laporan-content {
    padding: 16px 24px 90px;
  }
  
  .empty-state {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    height: 100%;
    min-height: 400px;
  }
  
  .empty-icon {
    color: var(--border);
    margin-bottom: 16px;
  }
  
  .empty-text {
    color: var(--text-secondary);
    margin-bottom: 24px;
    text-align: center;
  }
  
  .empty-btn {
    background-color: var(--primary);
    color: white;
    border: none;
    padding: 12px 24px;
    border-radius: 12px;
    font-weight: 600;
    cursor: pointer;
  }
  
  .laporan-list {
    display: flex;
    flex-direction: column;
    gap: 16px;
  }
  
  .laporan-card {
    background: white;
    border-radius: 12px;
    padding: 16px;
    box-shadow: 0 4px 10px rgba(0,0,0,0.05);
    display: flex;
    flex-direction: column;
    border: 1px solid var(--border);
  }

  .laporan-card.submitted-card {
    border: 2px solid rgba(39, 174, 96, 0.5);
  }

  .card-header-row {
    display: flex;
    align-items: center;
    gap: 12px;
  }

  .card-type-icon {
    width: 44px;
    height: 44px;
    border-radius: 12px;
    background-color: rgba(13, 71, 161, 0.1);
    color: var(--primary);
    display: flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
  }

  .card-type-icon.submitted-icon {
    background-color: rgba(39, 174, 96, 0.1);
    color: #27AE60;
  }

  .header-titles {
    flex: 1;
    display: flex;
    flex-direction: column;
  }

  .title-and-badge {
    display: flex;
    justify-content: space-between;
    align-items: center;
  }

  .report-title {
    font-size: 16px;
    font-weight: bold;
    color: var(--text-primary);
  }

  .status-chip {
    padding: 2px 8px;
    border-radius: 6px;
    font-size: 11px;
    font-weight: 600;
    background-color: rgba(242, 153, 74, 0.1);
    color: #F2994A;
  }

  .status-chip.chip-submitted {
    background-color: rgba(39, 174, 96, 0.1);
    color: #27AE60;
  }

  .sub-title {
    font-size: 12px;
    color: var(--text-secondary);
    margin-top: 2px;
  }

  .submitted-time {
    font-size: 11px;
    color: #27AE60;
    margin-top: 2px;
  }

  .card-divider {
    border: none;
    border-top: 1px solid #f0f0f0;
    margin: 12px 0 8px 0;
  }

  .stats-grid {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    text-align: center;
  }

  .stat-column {
    display: flex;
    flex-direction: column;
    align-items: center;
  }

  .stat-num {
    font-size: 18px;
    font-weight: bold;
  }

  .text-hadir { color: #27AE60; }
  .text-izin { color: #F2C94C; }
  .text-sakit { color: #2D9CDB; }
  .text-alfa { color: #EB5757; }

  .stat-name {
    font-size: 12px;
    color: var(--text-secondary);
  }

  .action-row {
    display: flex;
    align-items: center;
    gap: 8px;
  }

  .mt-2 { margin-top: 8px; }

  .btn-outlined {
    flex: 1;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 6px;
    padding: 8px 12px;
    border-radius: 8px;
    font-size: 13px;
    font-weight: 500;
    cursor: pointer;
    background: transparent;
    border: 1px solid;
    transition: all 0.2s;
  }

  .btn-solid {
    flex: 1;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 6px;
    padding: 8px 12px;
    border-radius: 8px;
    font-size: 13px;
    font-weight: 500;
    cursor: pointer;
    border: none;
    transition: all 0.2s;
  }

  .btn-lihat {
    color: var(--primary);
    border-color: var(--primary);
  }

  .btn-download {
    color: #00897B;
    border-color: #00897B;
  }

  .btn-icon-refresh {
    background: none;
    border: none;
    color: var(--primary);
    cursor: pointer;
    padding: 8px;
    display: flex;
    align-items: center;
  }

  .btn-submit {
    background-color: #27AE60;
    color: white;
  }

  .btn-unsubmit {
    color: #F2994A;
    border-color: #F2994A;
  }

  .btn-hapus {
    color: var(--error);
    border-color: var(--error);
  }

  /* Detail Modal */
  .detail-sheet {
    max-height: 85vh;
    overflow-y: auto;
    padding: 24px;
    border-radius: 20px 20px 0 0;
  }

  .sheet-drag-handle {
    width: 40px;
    height: 4px;
    background: #e0e0e0;
    border-radius: 2px;
    margin: 0 auto 20px;
  }

  .detail-header-row {
    display: flex;
    align-items: center;
    gap: 16px;
    margin-bottom: 24px;
  }

  .detail-icon-box {
    width: 56px;
    height: 56px;
    border-radius: 16px;
    background: rgba(13, 71, 161, 0.1);
    color: var(--primary);
    display: flex;
    align-items: center;
    justify-content: center;
  }

  .detail-title {
    font-size: 20px;
    font-weight: bold;
    color: var(--text-primary);
  }

  .detail-subtitle {
    font-size: 14px;
    color: var(--text-secondary);
  }

  .summary-card {
    background: rgba(13, 71, 161, 0.05);
    border: 1px solid rgba(13, 71, 161, 0.2);
    border-radius: 12px;
    padding: 16px;
    text-align: center;
    margin-bottom: 24px;
  }

  .percentage-big {
    font-size: 36px;
    font-weight: bold;
    color: var(--primary);
  }

  .percentage-label {
    font-size: 13px;
    color: var(--text-secondary);
  }

  .section-title {
    font-size: 16px;
    font-weight: bold;
    color: var(--text-primary);
    margin-bottom: 12px;
  }

  .detail-stats-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 12px;
    margin-bottom: 24px;
  }

  .detail-stat-box {
    padding: 16px;
    border-radius: 12px;
    text-align: center;
  }

  .box-hadir { background: rgba(39, 174, 96, 0.1); color: #27AE60; }
  .box-izin { background: rgba(242, 201, 76, 0.1); color: #B79010; }
  .box-sakit { background: rgba(45, 156, 219, 0.1); color: #2D9CDB; }
  .box-alfa { background: rgba(235, 87, 87, 0.1); color: #EB5757; }

  .dstat-num {
    font-size: 24px;
    font-weight: bold;
  }

  .dstat-label {
    font-size: 13px;
    font-weight: 500;
  }

  .info-table {
    display: flex;
    flex-direction: column;
    gap: 8px;
    margin-bottom: 24px;
  }

  .info-row {
    display: flex;
    justify-content: space-between;
    font-size: 14px;
  }

  .info-label {
    color: var(--text-secondary);
  }

  .info-value {
    font-weight: 500;
    color: var(--text-primary);
  }

  .btn-tutup {
    width: 100%;
    padding: 14px;
    background-color: var(--primary);
    color: white;
    border: none;
    border-radius: 12px;
    font-size: 16px;
    font-weight: 600;
    cursor: pointer;
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
  
  /* Bottom Sheet Styles */
  .bottom-sheet-backdrop {
    position: fixed;
    inset: 0;
    background: rgba(0,0,0,0.5);
    z-index: 2000;
    display: flex;
    align-items: flex-end;
  }
  
  .bottom-sheet {
    background: white;
    width: 100%;
    border-radius: 20px 20px 0 0;
    animation: slideUp 0.3s ease-out;
  }
  
  .sheet-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 24px;
    padding-bottom: 16px;
  }
  
  .sheet-header h3 {
    margin: 0;
    font-size: 20px;
    color: var(--text-primary);
  }
  
  .close-btn {
    background: none;
    border: none;
    color: var(--text-secondary);
    cursor: pointer;
    display: flex;
    padding: 4px;
  }
  
  .sheet-body {
    padding: 0 24px 24px;
    padding-bottom: max(24px, env(safe-area-inset-bottom));
  }
  
  .mt-4 { margin-top: 16px; }
  .mt-6 { margin-top: 24px; }
  
  .kelas-info {
    display: flex;
    align-items: center;
    gap: 12px;
    padding: 16px;
    background-color: rgba(13, 71, 161, 0.1);
    color: var(--primary);
    border-radius: 12px;
    font-weight: 600;
  }
  
  .note {
    font-size: 12px;
    color: var(--text-secondary);
    line-height: 1.5;
  }
  
  .submit-btn {
    width: 100%;
    padding: 16px;
    background-color: var(--primary);
    color: white;
    border: none;
    border-radius: 12px;
    font-size: 16px;
    font-weight: 600;
    cursor: pointer;
  }
  
  .submit-btn:disabled {
    opacity: 0.7;
    cursor: not-allowed;
  }
  
  .download-sheet {
    padding: 24px;
    padding-bottom: max(24px, env(safe-area-inset-bottom));
  }
  
  .download-sheet h3 {
    margin: 0 0 20px 0;
    font-size: 18px;
    text-align: center;
  }
  
  .download-options {
    display: flex;
    flex-direction: column;
    gap: 12px;
  }
  
  .download-item {
    display: flex;
    align-items: center;
    gap: 16px;
    padding: 12px;
    background: none;
    border: none;
    width: 100%;
    text-align: left;
    cursor: pointer;
    border-radius: 12px;
  }
  
  .download-item:hover {
    background-color: #f9fafb;
  }
  
  .icon-box {
    width: 48px;
    height: 48px;
    border-radius: 12px;
    display: flex;
    align-items: center;
    justify-content: center;
  }
  
  .icon-box.pdf { background-color: rgba(235, 87, 87, 0.1); color: #EB5757; }
  .icon-box.excel { background-color: rgba(39, 174, 96, 0.1); color: #27AE60; }
  
  .download-info {
    display: flex;
    flex-direction: column;
  }
  
  .download-title {
    font-size: 16px;
    font-weight: 500;
    color: var(--text-primary);
  }
  
  .download-desc {
    font-size: 12px;
    color: var(--text-secondary);
  }
  
  @keyframes slideUp {
    from { transform: translateY(100%); }
    to { transform: translateY(0); }
  }
</style>
