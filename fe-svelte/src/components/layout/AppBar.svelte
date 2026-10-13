<script lang="ts">
  import { pop } from 'svelte-spa-router';
  
  let { 
    title = '', 
    showBack = false, 
    onBack = null,
    transparent = false
  } = $props<{
    title?: string;
    showBack?: boolean;
    onBack?: (() => void) | null;
    transparent?: boolean;
  }>();
  
  function handleBack() {
    if (onBack) onBack();
    else pop();
  }
</script>

<header class="app-bar {transparent ? 'transparent' : ''}">
  <div class="app-bar-content">
    {#if showBack}
      <button class="back-btn {transparent ? 'dark-icon' : ''}" onclick={handleBack} aria-label="Kembali">
        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="19" y1="12" x2="5" y2="12"/><polyline points="12 19 5 12 12 5"/></svg>
      </button>
    {/if}
    {#if title}
      <h1 class="app-title {showBack ? '' : 'centered'} {transparent ? 'dark-text' : ''}">{title}</h1>
    {/if}
  </div>
</header>

<style>
  .app-bar {
    position: sticky;
    top: 0;
    left: 0;
    right: 0;
    height: 60px;
    background-color: var(--primary);
    color: white;
    z-index: 100;
    box-shadow: var(--shadow-md);
  }

  .app-bar.transparent {
    background-color: transparent;
    box-shadow: none;
    color: var(--text-primary);
  }
  
  .app-bar-content {
    display: flex;
    align-items: center;
    height: 100%;
    padding: 0 16px;
  }
  
  .back-btn {
    background: transparent;
    border: none;
    color: white;
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 8px;
    margin-right: 8px;
    border-radius: 50%;
  }

  .back-btn.dark-icon {
    color: var(--text-primary);
  }
  
  .back-btn:active {
    background-color: rgba(0,0,0,0.05);
  }
  
  .app-title {
    font-size: 18px;
    font-weight: 600;
    margin: 0;
    flex: 1;
  }

  .app-title.dark-text {
    color: var(--text-primary);
  }
  
  .app-title.centered {
    text-align: center;
  }
</style>
