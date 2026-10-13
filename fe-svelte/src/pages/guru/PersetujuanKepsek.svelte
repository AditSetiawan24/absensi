<script lang="ts">
  import { onMount } from 'svelte';
  import { guruApi } from '../../lib/api/guru';
  import { toast } from '../../lib/stores/toast';
  
  import PageLayout from '../../components/layout/PageLayout.svelte';
  import Loading from '../../components/ui/Loading.svelte';

  let pendingList = $state<any[]>([]);
  let loading = $state(true);
  let error = $state<string | null>(null);

  async function loadData() {
    loading = true;
    error = null;
    
    const res = await guruApi.getPendingKepsek();
    loading = false;
    
    if (res.success && res.data) {
      pendingList = res.data;
    } else {
      error = res.message || 'Gagal memuat data persetujuan';
    }
  }

  onMount(() => {
    loadData();
  });

  async function handleApprove(nip: string) {
    loading = true;
    const res = await guruApi.approveKepsek(nip);
    
    if (res.success) {
      toast.success(res.message || 'Akun berhasil disetujui');
      await loadData();
    } else {
      toast.error(res.message || 'Gagal menyetujui akun');
      loading = false;
    }
  }
</script>

<PageLayout title="Persetujuan Kepala Sekolah" showBack={true} hasBottomNav={false}>
  <!-- Top refresh action matching flutter -->
  <div class="top-actions">
    <button class="refresh-btn" onclick={loadData} aria-label="Refresh Data" title="Refresh Data">
      <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 2v6h-6"></path><path d="M3 12a9 9 0 0 1 15-6.7L21 8"></path><path d="M3 22v-6h6"></path><path d="M21 12a9 9 0 0 1-15 6.7L3 16"></path></svg>
    </button>
  </div>

  <div class="approval-content">
    {#if loading}
      <Loading />
    {:else if error}
      <div class="empty-state">
        <div class="error-text">{error}</div>
        <button class="retry-btn" onclick={loadData}>Coba Lagi</button>
      </div>
    {:else if pendingList.length === 0}
      <div class="empty-state">
        <div class="empty-text">Tidak ada pendaftaran Kepala Sekolah yang perlu disetujui.</div>
      </div>
    {:else}
      <div class="pending-list">
        {#each pendingList as user}
          {@const hasApproved = user.has_approved === true}
          {@const count = user.approvals_count || 0}
          
          <div class="pending-card">
            <div class="card-body">
              <div class="user-header">
                <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="var(--primary)" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path><circle cx="12" cy="7" r="4"></circle></svg>
                <div class="nama">{user.nama || 'Unknown'}</div>
              </div>
              
              <div class="info-details">
                <div class="info-row">NIP: {user.nip}</div>
                <div class="info-row">Email: {user.email}</div>
                <div class="info-row">No HP: {user.no_hp || '-'}</div>
              </div>
              
              <div class="status-text">
                Status: {count}/4 Persetujuan
              </div>
              
              <button 
                class="btn-approve {hasApproved ? 'disabled' : ''}" 
                disabled={hasApproved}
                onclick={() => !hasApproved && handleApprove(user.nip)}
              >
                {hasApproved ? 'Sudah Disetujui Anda' : 'Setujui'}
              </button>
            </div>
          </div>
        {/each}
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
  
  .refresh-btn {
    background: transparent;
    border: none;
    color: var(--text-primary);
    cursor: pointer;
    padding: 4px;
  }
  
  .approval-content {
    padding: 16px;
  }
  
  .pending-list {
    display: flex;
    flex-direction: column;
    gap: 12px;
  }
  
  .pending-card {
    background: white;
    border-radius: 12px;
    box-shadow: 0 1px 3px rgba(0,0,0,0.1);
    overflow: hidden;
  }
  
  .card-body {
    padding: 16px;
    display: flex;
    flex-direction: column;
  }
  
  .user-header {
    display: flex;
    align-items: center;
    gap: 8px;
    margin-bottom: 8px;
  }
  
  .nama {
    font-weight: bold;
    font-size: 16px;
    color: var(--text-primary);
    flex: 1;
  }
  
  .info-details {
    display: flex;
    flex-direction: column;
    gap: 4px;
    margin-bottom: 8px;
  }
  
  .info-row {
    font-size: 14px;
    color: var(--text-primary);
  }
  
  .status-text {
    font-weight: bold;
    color: var(--warning);
    margin-bottom: 16px;
    font-size: 14px;
  }
  
  .btn-approve {
    width: 100%;
    padding: 12px;
    background-color: var(--primary);
    color: white;
    border: none;
    border-radius: 8px;
    font-size: 14px;
    font-weight: 500;
    cursor: pointer;
    display: flex;
    justify-content: center;
    align-items: center;
  }
  
  .btn-approve.disabled {
    background-color: var(--text-secondary);
    cursor: not-allowed;
  }
  
  .empty-state {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    padding: 40px 16px;
    text-align: center;
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
