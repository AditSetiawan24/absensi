<script lang="ts">
  import { push } from 'svelte-spa-router';
  import { location } from '../../lib/stores/router';
  
  let { items } = $props<{
    items: { path: string; label: string; icon: string }[];
  }>();

  function isItemActive(itemPath: string) {
    const loc = ($location || '').toLowerCase();
    const target = itemPath.toLowerCase();

    // Direct match
    if (loc === target) return true;

    // Subpath match (e.g. /guru/absensi/xxx)
    if (loc.startsWith(target + '/')) return true;

    // Jika tab adalah Dashboard / Kehadiran (/guru/dashboard, /kepsek/dashboard, /ortu/dashboard),
    // aktif juga ketika URL masih di root role (/guru, /kepsek, /ortu, atau /guru/)
    if (target.endsWith('/dashboard')) {
      const baseRole = target.replace('/dashboard', ''); // '/guru', '/kepsek', '/ortu'
      if (loc === baseRole || loc === baseRole + '/' || loc === '') {
        return true;
      }
    }

    return false;
  }
</script>

<div class="bottom-nav">
  {#each items as item}
    <a 
      href={'#' + item.path} 
      class="nav-item {isItemActive(item.path) ? 'active' : ''}"
      onclick={(e) => { 
        e.preventDefault(); 
        push(item.path); 
      }}
    >
      <div class="nav-icon">
        {#if item.icon === 'home'}
          <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="m3 9 9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/></svg>
        {:else if item.icon === 'dashboard'}
          <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect width="7" height="9" x="3" y="3" rx="1"/><rect width="7" height="5" x="14" y="3" rx="1"/><rect width="7" height="9" x="14" y="12" rx="1"/><rect width="7" height="5" x="3" y="16" rx="1"/></svg>
        {:else if item.icon === 'calendar'}
          <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
        {:else if item.icon === 'file-text'}
          <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/><polyline points="10 9 9 9 8 9"/></svg>
        {:else if item.icon === 'settings'}
          <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1 0 2.83 2 2 0 0 1-2.83 0l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-2 2 2 2 0 0 1-2-2v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83 0 2 2 0 0 1 0-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1-2-2 2 2 0 0 1 2-2h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 0-2.83 2 2 0 0 1 2.83 0l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 2-2 2 2 0 0 1 2 2v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 0 2 2 0 0 1 0 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 2 2 2 2 0 0 1-2 2h-.09a1.65 1.65 0 0 0-1.51 1z"/></svg>
        {/if}
      </div>
      <span class="nav-label">{item.label}</span>
    </a>
  {/each}
</div>

<style>
  .bottom-nav {
    position: fixed;
    bottom: 0;
    left: 0;
    right: 0;
    height: 70px;
    background-color: var(--surface);
    display: flex;
    justify-content: space-around;
    align-items: center;
    box-shadow: var(--shadow-nav);
    z-index: 100;
  }
  
  .nav-item {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    color: var(--text-light);
    gap: 4px;
    flex: 1;
    height: 100%;
    transition: color 0.2s;
  }
  
  .nav-item.active {
    color: var(--primary);
  }
  
  .nav-icon {
    display: flex;
  }
  
  .nav-label {
    font-size: 12px;
    font-weight: 500;
  }
</style>
