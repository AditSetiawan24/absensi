<script lang="ts">
  import { onMount } from 'svelte';
  import { guruApi } from '../../lib/api/guru';
  import { toast } from '../../lib/stores/toast';
  import PageLayout from '../../components/layout/PageLayout.svelte';
  import Loading from '../../components/ui/Loading.svelte';
  import EmptyState from '../../components/ui/EmptyState.svelte';
  import TextField from '../../components/ui/TextField.svelte';

  let listGuru = $state<any[]>([]);
  let filteredGuru = $state<any[]>([]);
  let searchQuery = $state('');
  let loading = $state(true);
  
  let selectedGuru = $state<any>(null);

  async function loadData() {
    loading = true;
    const res = await guruApi.getAll();
    loading = false;
    
    if (res.success && res.data) {
      listGuru = res.data;
      filteredGuru = res.data;
    }
  }

  onMount(() => {
    loadData();
  });

  $effect(() => {
    if (searchQuery) {
      filteredGuru = listGuru.filter(g => 
        g.nama.toLowerCase().includes(searchQuery.toLowerCase()) || 
        (g.nip && g.nip.includes(searchQuery))
      );
    } else {
      filteredGuru = listGuru;
    }
  });
  
  function getGender(g: any) {
    if (g.jenis_kelamin === 'L' || g.gender === 'L' || g.gender === 'Laki-laki') return 'Laki-laki';
    return 'Perempuan';
  }

  function handleCall(guru: any) {
    const phone = guru.no_hp || guru.noHp;
    if (phone) {
      window.location.href = `tel:${phone}`;
    } else {
      toast.info('Nomor telepon guru tidak tersedia');
    }
    selectedGuru = null;
  }

  function handleEmail(guru: any) {
    const email = guru.email;
    if (email) {
      window.location.href = `mailto:${email}`;
    } else {
      toast.info('Alamat email guru tidak tersedia');
    }
    selectedGuru = null;
  }
</script>

<PageLayout title="Daftar Guru" showBack={true}>
  <div class="list-container">
    <div class="search-container">
      <TextField 
        bind:value={searchQuery} 
        placeholder="Cari guru..." 
        prefixIcon="search"
      />
    </div>

    <div class="list-content">
      {#if loading}
        <Loading />
      {:else if filteredGuru.length === 0}
        <EmptyState message="Tidak ada guru ditemukan" />
      {:else}
        <div class="guru-list">
          {#each filteredGuru as guru}
            <div class="guru-card">
              <div class="avatar">{guru.nama.charAt(0).toUpperCase()}</div>
              
              <div class="info">
                <span class="nama">{guru.nama}</span>
                
                <div class="detail-row">
                  <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"></path></svg>
                  <span class="detail-text">NIP: {guru.nip || '-'}</span>
                </div>
                
                <div class="detail-row">
                  {#if getGender(guru) === 'Laki-laki'}
                    <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="10" cy="14" r="5"></circle><line x1="14" y1="10" x2="21" y2="3"></line><polyline points="15 3 21 3 21 9"></polyline></svg>
                  {:else}
                    <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="10" r="5"></circle><line x1="12" y1="15" x2="12" y2="22"></line><line x1="9" y1="19" x2="15" y2="19"></line></svg>
                  {/if}
                  <span class="detail-text">{getGender(guru)}</span>
                </div>
                
                {#if guru.no_hp || guru.noHp}
                  <div class="detail-row">
                    <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z"></path></svg>
                    <span class="detail-text">{guru.no_hp || guru.noHp}</span>
                  </div>
                {/if}
              </div>
              
              <!-- svelte-ignore a11y_consider_explicit_label -->
              <button class="more-btn" onclick={() => selectedGuru = guru}>
                <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="1"></circle><circle cx="12" cy="5" r="1"></circle><circle cx="12" cy="19" r="1"></circle></svg>
              </button>
            </div>
          {/each}
        </div>
      {/if}
    </div>
  </div>

  <!-- Bottom Sheet Options -->
  {#if selectedGuru}
    <!-- svelte-ignore a11y_click_events_have_key_events -->
    <!-- svelte-ignore a11y_no_static_element_interactions -->
    <div class="bottom-sheet-backdrop" onclick={() => selectedGuru = null}>
      <div class="bottom-sheet" onclick={e => e.stopPropagation()}>
        <div class="options-content">
          <div class="big-avatar">{selectedGuru.nama.charAt(0).toUpperCase()}</div>
          <h3 class="options-name">{selectedGuru.nama}</h3>
          <p class="options-nip">NIP: {selectedGuru.nip || '-'}</p>
          
          <div class="action-buttons">
            <button class="action-btn success" onclick={() => handleCall(selectedGuru)}>
              <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z"></path></svg>
              <span>Telepon</span>
            </button>
            
            <button class="action-btn primary" onclick={() => handleEmail(selectedGuru)}>
              <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"></path><polyline points="22,6 12,13 2,6"></polyline></svg>
              <span>Email</span>
            </button>
          </div>
        </div>
      </div>
    </div>
  {/if}
</PageLayout>

<style>
  .list-container {
    display: flex;
    flex-direction: column;
    height: 100%;
  }
  
  .search-container {
    padding: 16px;
    background-color: #f9fafb; /* grey[50] */
  }
  
  .list-content {
    padding: 16px;
    flex: 1;
  }
  
  .guru-list {
    display: flex;
    flex-direction: column;
    gap: 12px;
  }
  
  .guru-card {
    display: flex;
    align-items: center;
    background: white;
    padding: 16px;
    border-radius: 12px;
    box-shadow: 0 4px 10px rgba(0,0,0,0.05);
    gap: 16px;
  }
  
  .avatar {
    width: 50px;
    height: 50px;
    border-radius: 50%;
    background: var(--primary);
    color: white;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 18px;
    font-weight: bold;
    flex-shrink: 0;
  }
  
  .info {
    display: flex;
    flex-direction: column;
    flex: 1;
    overflow: hidden;
  }
  
  .nama {
    font-weight: 600;
    font-size: 16px;
    color: var(--text-primary);
    margin-bottom: 4px;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
  }
  
  .detail-row {
    display: flex;
    align-items: center;
    gap: 4px;
    margin-top: 2px;
    color: var(--text-secondary);
  }
  
  .detail-text {
    font-size: 12px;
  }
  
  .more-btn {
    background: none;
    border: none;
    color: var(--text-secondary);
    padding: 8px;
    cursor: pointer;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
  }
  
  /* Bottom Sheet */
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
  
  @keyframes slideUp {
    from { transform: translateY(100%); }
    to { transform: translateY(0); }
  }
  
  .options-content {
    padding: 24px;
    padding-bottom: max(24px, env(safe-area-inset-bottom));
    display: flex;
    flex-direction: column;
    align-items: center;
  }
  
  .big-avatar {
    width: 80px;
    height: 80px;
    border-radius: 50%;
    background: var(--primary);
    color: white;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 32px;
    font-weight: bold;
    margin-bottom: 16px;
  }
  
  .options-name {
    margin: 0 0 8px 0;
    font-size: 20px;
    font-weight: bold;
    color: var(--text-primary);
  }
  
  .options-nip {
    margin: 0 0 24px 0;
    color: var(--text-secondary);
  }
  
  .action-buttons {
    display: flex;
    width: 100%;
    gap: 12px;
  }
  
  .action-btn {
    flex: 1;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    gap: 4px;
    padding: 16px 0;
    border-radius: 12px;
    border: none;
    cursor: pointer;
    font-weight: 600;
    font-size: 14px;
  }
  
  .action-btn.success {
    background-color: rgba(76, 175, 80, 0.1);
    color: #4caf50;
  }
  
  .action-btn.primary {
    background-color: rgba(13, 71, 161, 0.1);
    color: var(--primary);
  }
</style>
