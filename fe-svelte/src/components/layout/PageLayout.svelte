<script lang="ts">
  import AppBar from './AppBar.svelte';
  
  let { 
    title = '', 
    showBack = false, 
    onBack = null, 
    hasBottomNav = false,
    transparent = false,
    children
  } = $props<{
    title?: string;
    showBack?: boolean;
    onBack?: (() => void) | null;
    hasBottomNav?: boolean;
    transparent?: boolean;
    children?: any;
  }>();
</script>

<div class="page-container">
  {#if title || showBack}
    <AppBar {title} {showBack} {onBack} {transparent} />
  {/if}
  
  <main class="page-content {hasBottomNav ? 'with-nav' : ''}">
    {#if children}
      {@render children()}
    {/if}
  </main>
</div>

<style>
  .page-container {
    display: flex;
    flex-direction: column;
    width: 100%;
    min-height: 100%;
    background-color: var(--bg);
  }
  
  .page-content {
    flex: 1;
    width: 100%;
  }
  
  .page-content.with-nav {
    padding-bottom: 84px; /* Space for BottomNav */
  }
</style>
