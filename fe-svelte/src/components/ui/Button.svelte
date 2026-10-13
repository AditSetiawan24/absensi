<script lang="ts">
  let { 
    text, 
    onClick = () => {}, 
    isLoading = false, 
    isOutlined = false, 
    backgroundColor = 'var(--primary)', 
    textColor = 'white', 
    disabled = false, 
    width = '100%',
    type = 'button'
  } = $props<{
    text: string;
    onClick?: () => void;
    isLoading?: boolean;
    isOutlined?: boolean;
    backgroundColor?: string;
    textColor?: string;
    disabled?: boolean;
    width?: string;
    type?: "button" | "submit" | "reset";
  }>();
</script>

<button 
  {type}
  class="btn {isOutlined ? 'outlined' : ''}" 
  style="--bg-color: {backgroundColor}; --txt-color: {textColor}; width: {width};"
  onclick={onClick}
  disabled={disabled || isLoading}
>
  {#if isLoading}
    <span class="spinner"></span>
  {:else}
    {text}
  {/if}
</button>

<style>
  .btn {
    padding: 14px 24px;
    border-radius: 12px;
    font-size: 16px;
    font-weight: 600;
    cursor: pointer;
    border: none;
    transition: all 0.2s ease;
    background-color: var(--bg-color);
    color: var(--txt-color);
    display: flex;
    justify-content: center;
    align-items: center;
    gap: 8px;
  }
  
  .btn:hover:not(:disabled) {
    opacity: 0.9;
    transform: translateY(-1px);
  }

  .btn:active:not(:disabled) {
    transform: translateY(0);
  }
  
  .btn:disabled {
    opacity: 0.6;
    cursor: not-allowed;
  }
  
  .btn.outlined {
    background-color: transparent;
    color: var(--bg-color);
    border: 2px solid var(--bg-color);
  }
  
  .spinner {
    width: 20px;
    height: 20px;
    border: 3px solid rgba(255,255,255,0.3);
    border-radius: 50%;
    border-top-color: currentColor;
    animation: spin 1s ease-in-out infinite;
  }
  
  @keyframes spin {
    to { transform: rotate(360deg); }
  }
</style>
