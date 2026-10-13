<script lang="ts">
  let { text = 'Memuat data...' } = $props<{ text?: string }>();
</script>

<div class="loading-container">
  <div class="spinner"></div>
  <p class="loading-text">{text}</p>
</div>

<style>
  .loading-container {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    padding: 32px;
    height: 100%;
    width: 100%;
  }
  
  .spinner {
    width: 40px;
    height: 40px;
    border: 4px solid var(--border);
    border-top-color: var(--primary);
    border-radius: 50%;
    animation: spin 1s linear infinite;
    margin-bottom: 16px;
  }
  
  .loading-text {
    color: var(--text-secondary);
    font-size: 14px;
  }
  
  @keyframes spin {
    to { transform: rotate(360deg); }
  }
</style>
