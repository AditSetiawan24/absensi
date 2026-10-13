<script lang="ts">
  import { toast } from '../../lib/stores/toast';
</script>

<div class="toast-container">
  {#each $toast as t (t.id)}
    <div class="toast {t.type}">
      <span class="message">{t.message}</span>
    </div>
  {/each}
</div>

<style>
  .toast-container {
    position: fixed;
    bottom: 24px;
    left: 50%;
    transform: translateX(-50%);
    display: flex;
    flex-direction: column;
    gap: 8px;
    z-index: 9999;
  }
  
  .toast {
    padding: 12px 24px;
    border-radius: 8px;
    color: white;
    font-size: 14px;
    font-weight: 500;
    box-shadow: var(--shadow-lg);
    animation: slideUp 0.3s ease;
  }
  
  .success { background-color: var(--success); }
  .error { background-color: var(--error); }
  .warning { background-color: var(--warning); color: #000; }
  .info { background-color: var(--text-primary); }
  
  @keyframes slideUp {
    from { transform: translateY(100%); opacity: 0; }
    to { transform: translateY(0); opacity: 1; }
  }
</style>
