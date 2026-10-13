<script lang="ts">
  let { 
    message = 'Tidak ada data', 
    icon = 'box'
  } = $props<{
    message?: string;
    icon?: string;
  }>();
</script>

<div class="empty-container">
  <div class="empty-icon">
    {#if icon === 'box'}
      <svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"/><polyline points="3.27 6.96 12 12.01 20.73 6.96"/><line x1="12" y1="22.08" x2="12" y2="12"/></svg>
    {:else}
      <svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
    {/if}
  </div>
  <p class="empty-message">{message}</p>
</div>

<style>
  .empty-container {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    padding: 32px;
    text-align: center;
    height: 100%;
  }
  
  .empty-icon {
    color: var(--text-light);
    margin-bottom: 16px;
  }
  
  .empty-message {
    color: var(--text-secondary);
    font-size: 16px;
    font-weight: 500;
  }
</style>
