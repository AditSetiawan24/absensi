<script lang="ts">
  import { location } from '../../lib/stores/router';
  import BottomNav from '../../components/layout/BottomNav.svelte';
  
  import KepsekDashboard from './KepsekDashboard.svelte';
  import LaporanKepsek from './LaporanKepsek.svelte';
  import Settings from '../shared/Settings.svelte';
  
  let currentTab = $derived.by(() => {
    if ($location.includes('/kepsek/laporan')) return 'laporan';
    if ($location.includes('/kepsek/pengaturan')) return 'pengaturan';
    return 'dashboard';
  });

  const navItems = [
    { path: '/kepsek/dashboard', label: 'Rekapitulasi', icon: 'dashboard' },
    { path: '/kepsek/laporan', label: 'Laporan', icon: 'file-text' },
    { path: '/kepsek/pengaturan', label: 'Pengaturan', icon: 'settings' }
  ];
</script>

<div class="kepsek-home">
  {#if currentTab === 'dashboard'}
    <KepsekDashboard />
  {:else if currentTab === 'laporan'}
    <LaporanKepsek />
  {:else if currentTab === 'pengaturan'}
    <Settings />
  {/if}
  
  <BottomNav items={navItems} />
</div>

<style>
  .kepsek-home {
    min-height: 100vh;
    width: 100%;
    position: relative;
    padding-bottom: 70px;
  }
</style>
