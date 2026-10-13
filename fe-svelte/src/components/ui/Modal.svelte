<script lang="ts">
  import Button from './Button.svelte';
  
  let { 
    isOpen = false, 
    title = '', 
    content = '', 
    confirmText = 'Ya', 
    cancelText = 'Batal',
    isDanger = false,
    onConfirm, 
    onCancel,
    children
  } = $props<{
    isOpen?: boolean;
    title?: string;
    content?: string;
    confirmText?: string;
    cancelText?: string;
    isDanger?: boolean;
    onConfirm?: () => void;
    onCancel?: () => void;
    children?: any;
  }>();
</script>

{#if isOpen}
  <!-- svelte-ignore a11y_click_events_have_key_events -->
  <!-- svelte-ignore a11y_no_static_element_interactions -->
  <div class="modal-backdrop" onclick={onCancel}>
    <div class="modal-content" onclick={e => e.stopPropagation()}>
      {#if title}
        <h3 class="modal-title">{title}</h3>
      {/if}
      <div class="modal-body">
        {#if content}
          <p style="white-space: pre-line;">{content}</p>
        {:else if children}
          {@render children()}
        {/if}
      </div>
      <div class="modal-actions">
        {#if cancelText}
          <button class="dialog-btn cancel-btn" onclick={onCancel}>
            {cancelText}
          </button>
        {/if}
        {#if confirmText}
          <button class="dialog-btn confirm-btn {isDanger ? 'danger' : ''}" onclick={onConfirm}>
            {confirmText}
          </button>
        {/if}
      </div>
    </div>
  </div>
{/if}

<style>
  .modal-backdrop {
    position: fixed;
    inset: 0;
    background-color: rgba(0, 0, 0, 0.5);
    display: flex;
    align-items: center;
    justify-content: center;
    z-index: 1000;
    padding: 24px;
  }
  
  .modal-content {
    background-color: var(--surface);
    border-radius: 16px;
    padding: 24px;
    width: 100%;
    max-width: 400px;
    box-shadow: var(--shadow-lg);
    animation: zoomIn 0.2s ease;
  }
  
  .modal-title {
    font-size: 20px;
    font-weight: 700;
    margin-bottom: 16px;
    color: var(--text-primary);
  }
  
  .modal-body {
    margin-bottom: 24px;
    color: var(--text-secondary);
    font-size: 14px;
    line-height: 1.5;
  }
  
  .modal-actions {
    display: flex;
    justify-content: flex-end;
    gap: 8px;
  }

  .dialog-btn {
    background: transparent;
    border: none;
    padding: 8px 16px;
    border-radius: 8px;
    font-size: 14px;
    font-weight: 600;
    cursor: pointer;
    transition: background-color 0.2s;
  }

  .dialog-btn:hover {
    background-color: rgba(0, 0, 0, 0.05);
  }

  .cancel-btn {
    color: var(--text-primary);
  }

  .confirm-btn {
    color: var(--primary);
  }

  .confirm-btn.danger {
    color: var(--error, #e53935);
  }
  
  @keyframes zoomIn {
    from { transform: scale(0.95); opacity: 0; }
    to { transform: scale(1); opacity: 1; }
  }
</style>
