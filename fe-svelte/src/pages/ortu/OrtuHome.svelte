<script lang="ts">
  import { location } from '../../lib/stores/router';
  import BottomNav from '../../components/layout/BottomNav.svelte';
  
  import OrtuDashboard from './OrtuDashboard.svelte';
  import LaporanOrtu from './LaporanOrtu.svelte';
  import Settings from '../shared/Settings.svelte';
  
  let currentTab = $derived.by(() => {
    if ($location.includes('/ortu/laporan')) return 'laporan';
    if ($location.includes('/ortu/pengaturan')) return 'pengaturan';
    return 'dashboard';
  });

  const navItems = [
    { path: '/ortu/dashboard', label: 'Kehadiran', icon: 'calendar' },
    { path: '/ortu/laporan', label: 'Laporan', icon: 'file-text' },
    { path: '/ortu/pengaturan', label: 'Pengaturan', icon: 'settings' }
  ];
</script>

<div class="ortu-home">
  {#if currentTab === 'dashboard'}
    <OrtuDashboard />
  {:else if currentTab === 'laporan'}
    <LaporanOrtu />
  {:else if currentTab === 'pengaturan'}
    <Settings />
  {/if}
  
  <BottomNav items={navItems} />
</div>

<style>
  .ortu-home {
    min-height: 100vh;
    width: 100%;
    position: relative;
    padding-bottom: 70px;
  }
</style>
