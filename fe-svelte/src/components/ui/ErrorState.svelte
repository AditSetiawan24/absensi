<script lang="ts">
  import Button from './Button.svelte';
  
  let { 
    message = 'Terjadi kesalahan', 
    onRetry
  } = $props<{
    message?: string;
    onRetry?: () => void;
  }>();
</script>

<div class="error-container">
  <div class="error-icon">
    <svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
  </div>
  <h3 class="error-title">Oops!</h3>
  <p class="error-message">{message}</p>
  {#if onRetry}
    <div class="retry-btn">
      <Button text="Coba Lagi" onClick={onRetry} />
    </div>
  {/if}
</div>

<style>
  .error-container {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    padding: 32px;
    text-align: center;
    height: 100%;
  }
  
  .error-icon {
    color: var(--error);
    margin-bottom: 16px;
  }
  
  .error-title {
    font-size: 18px;
    font-weight: 600;
    margin-bottom: 8px;
    color: var(--text-primary);
  }
  
  .error-message {
    color: var(--text-secondary);
    font-size: 14px;
    margin-bottom: 24px;
  }
  
  .retry-btn {
    width: 200px;
  }
</style>
