<script lang="ts">
  import { location } from '../../lib/stores/router';
  import BottomNav from '../../components/layout/BottomNav.svelte';
  
  import GuruDashboard from './GuruDashboard.svelte';
  import Absensi from './Absensi.svelte';
  import LaporanGuru from './LaporanGuru.svelte';
  import Settings from '../shared/Settings.svelte';
  
  let currentTab = $derived.by(() => {
    if ($location.includes('/guru/absensi')) return 'absensi';
    if ($location.includes('/guru/laporan')) return 'laporan';
    if ($location.includes('/guru/pengaturan')) return 'pengaturan';
    return 'dashboard';
  });

  const navItems = [
    { path: '/guru/dashboard', label: 'Dashboard', icon: 'dashboard' },
    { path: '/guru/absensi', label: 'Absensi', icon: 'calendar' },
    { path: '/guru/laporan', label: 'Laporan', icon: 'file-text' },
    { path: '/guru/pengaturan', label: 'Pengaturan', icon: 'settings' }
  ];
</script>

<div class="guru-home">
  {#if currentTab === 'dashboard'}
    <GuruDashboard />
  {:else if currentTab === 'absensi'}
    <Absensi />
  {:else if currentTab === 'laporan'}
    <LaporanGuru />
  {:else if currentTab === 'pengaturan'}
    <Settings />
  {/if}
  
  <BottomNav items={navItems} />
</div>

<style>
  .guru-home {
    min-height: 100vh;
    width: 100%;
    position: relative;
    padding-bottom: 70px;
  }
</style>
