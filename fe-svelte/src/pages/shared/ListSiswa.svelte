<script lang="ts">
  import { onMount } from 'svelte';
  import { push } from 'svelte-spa-router';
  import { authStore } from '../../lib/stores/auth';
  import { siswaApi } from '../../lib/api/siswa';
  import { kelasApi } from '../../lib/api/kelas';
  import PageLayout from '../../components/layout/PageLayout.svelte';
  import Loading from '../../components/ui/Loading.svelte';
  import EmptyState from '../../components/ui/EmptyState.svelte';
  import TextField from '../../components/ui/TextField.svelte';
  import Dropdown from '../../components/ui/Dropdown.svelte';

  let listSiswa = $state<any[]>([]);
  let filteredSiswa = $state<any[]>([]);
  let listKelas = $state<any[]>([{ value: '', label: 'Semua Kelas' }]);
  
  let searchQuery = $state('');
  let selectedKelas = $state('');
  let loading = $state(true);

  async function loadData() {
    loading = true;
    
    const [siswaRes, kelasRes] = await Promise.all([
      siswaApi.getAll(),
      kelasApi.getAll()
    ]);
    
    if (kelasRes.success && kelasRes.data) {
      const options = kelasRes.data.map((k: any) => ({
        value: k.id_kelas.toString(),
        label: `Kelas ${k.kelas || k.nama_kelas}`
      }));
      listKelas = [{ value: '', label: 'Semua Kelas' }, ...options];
    }
    
    if (siswaRes.success && siswaRes.data) {
      listSiswa = siswaRes.data;
      filteredSiswa = listSiswa;
    }
    
    loading = false;
  }

  onMount(() => {
    loadData();
  });

  $effect(() => {
    let result = listSiswa;
    
    if (selectedKelas) {
      result = result.filter(s => (s.id_kelas && s.id_kelas.toString() === selectedKelas));
    }
    
    if (searchQuery) {
      result = result.filter(s => 
        s.nama.toLowerCase().includes(searchQuery.toLowerCase()) || 
        (s.nis && s.nis.includes(searchQuery))
      );
    }
    
    filteredSiswa = result;
  });
</script>

<PageLayout title="Daftar Siswa" showBack={true}>
  <div class="list-container">
    <div class="filter-container">
      <TextField 
        bind:value={searchQuery} 
        placeholder="Cari siswa..." 
        prefixIcon="search"
      />
      <div class="mt-3">
        <Dropdown 
          options={listKelas} 
          bind:value={selectedKelas} 
        />
      </div>
    </div>

    <div class="list-content">
      {#if loading}
        <Loading />
      {:else if filteredSiswa.length === 0}
        <EmptyState message="Tidak ada siswa ditemukan" />
      {:else}
        <div class="siswa-list">
          {#each filteredSiswa as siswa}
            <div class="siswa-card" onclick={() => {
              const prefix = $authStore.role === 'guru' ? '/guru' : '/kepsek';
              push(`${prefix}/siswa/${siswa.nis}`);
            }}>
              
              <div class="avatar-container">
                <span class="avatar-text">{siswa.nama.charAt(0).toUpperCase()}</span>
              </div>
              
              <div class="info">
                <span class="nama">{siswa.nama}</span>
                <span class="nis">NIS: {siswa.nis || '-'}</span>
                {#if siswa.kelas}
                  <span class="kelas">Kelas {siswa.kelas.nama_kelas || siswa.kelas.kelas}</span>
                {/if}
              </div>
              
              <div class="trailing">
                <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"></polyline></svg>
              </div>
            </div>
          {/each}
        </div>
      {/if}
    </div>
  </div>
</PageLayout>

<style>
  .list-container {
    display: flex;
    flex-direction: column;
    height: 100%;
  }
  
  .filter-container {
    padding: 16px;
    background-color: #f9fafb; /* grey[50] */
  }
  
  .mt-3 {
    margin-top: 12px;
  }
  
  .list-content {
    padding: 16px;
    flex: 1;
  }
  
  .siswa-list {
    display: flex;
    flex-direction: column;
    gap: 12px;
  }
  
  .siswa-card {
    display: flex;
    align-items: center;
    background: white;
    padding: 12px;
    border-radius: 12px;
    box-shadow: 0 4px 10px rgba(0,0,0,0.05);
    cursor: pointer;
    transition: background 0.2s;
  }
  
  .siswa-card:active {
    background: #f5f5f5;
  }
  
  .avatar-container {
    width: 45px;
    height: 45px;
    border-radius: 10px;
    background: rgba(13, 71, 161, 0.1);
    display: flex;
    align-items: center;
    justify-content: center;
    margin-right: 16px;
    flex-shrink: 0;
  }
  
  .avatar-text {
    font-size: 18px;
    font-weight: bold;
    color: var(--primary);
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
    margin-bottom: 2px;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
  }
  
  .nis {
    font-size: 12px;
    color: var(--text-secondary);
  }
  
  .kelas {
    font-size: 12px;
    color: var(--text-secondary);
  }
  
  .trailing {
    color: var(--text-secondary);
    display: flex;
    align-items: center;
    justify-content: center;
    padding-left: 8px;
  }
</style>
