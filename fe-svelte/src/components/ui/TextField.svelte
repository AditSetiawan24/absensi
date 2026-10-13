<script lang="ts">
  let { 
    value = $bindable(), 
    label, 
    hint = '', 
    type = 'text', 
    error = '', 
    disabled = false,
    placeholder = '',
    prefixIcon,
    isPassword = false,
    multiline = false,
    rows = 3
  } = $props<{
    value: string;
    label?: string;
    hint?: string;
    type?: string;
    error?: string;
    disabled?: boolean;
    placeholder?: string;
    prefixIcon?: string;
    isPassword?: boolean;
    multiline?: boolean;
    rows?: number;
  }>();

  let showPassword = $state(false);
  let inputType = $derived(isPassword ? (showPassword ? 'text' : 'password') : type);
</script>

<div class="field-container">
  {#if label}
    <label class="field-label">{label}</label>
  {/if}
  
  <div class="input-wrapper">
    {#if prefixIcon}
      <span class="material-icons prefix-icon">{prefixIcon}</span>
    {/if}
    {#if multiline}
      <textarea
        class="field-input {error ? 'error' : ''} {prefixIcon ? 'has-prefix' : ''}"
        bind:value
        {disabled}
        {placeholder}
        {rows}
      ></textarea>
    {:else}
      <input 
        type={inputType}
        class="field-input {error ? 'error' : ''} {prefixIcon ? 'has-prefix' : ''} {isPassword ? 'has-suffix' : ''}"
        bind:value
        {disabled}
        {placeholder}
      />
      {#if isPassword}
        <button 
          type="button"
          class="suffix-icon material-icons" 
          onclick={() => showPassword = !showPassword}
          aria-label={showPassword ? 'Sembunyikan password' : 'Lihat password'}
        >
          {showPassword ? 'visibility_off' : 'visibility'}
        </button>
      {/if}
    {/if}
  </div>
  
  {#if error}
    <span class="field-error">{error}</span>
  {:else if hint}
    <span class="field-hint">{hint}</span>
  {/if}
</div>

<style>
  .field-container {
    display: flex;
    flex-direction: column;
    gap: 8px;
    width: 100%;
    margin-bottom: 16px;
  }
  
  .field-label {
    font-size: 14px;
    font-weight: 500;
    color: var(--text-primary);
  }
  
  .input-wrapper {
    position: relative;
    width: 100%;
  }
  
  .field-input {
    width: 100%;
    padding: 16px;
    border-radius: 12px;
    border: 1px solid var(--border);
    background-color: var(--surface);
    color: var(--text-primary);
    font-size: 16px;
    transition: border-color 0.2s;
    font-family: inherit;
    box-sizing: border-box;
  }
  
  .field-input.has-prefix {
    padding-left: 48px;
  }

  .field-input.has-suffix {
    padding-right: 48px;
  }

  .prefix-icon, .suffix-icon {
    position: absolute;
    top: 50%;
    transform: translateY(-50%);
    color: var(--text-secondary);
  }

  .prefix-icon {
    left: 16px;
  }

  .suffix-icon {
    right: 16px;
    background: none;
    border: none;
    cursor: pointer;
    padding: 0;
    display: flex;
    align-items: center;
    justify-content: center;
  }
  
  .suffix-icon:hover {
    color: var(--primary);
  }
  
  .field-input:focus {
    outline: none;
    border-color: var(--primary);
    box-shadow: 0 0 0 2px var(--primary-light);
  }
  
  .field-input:disabled {
    background-color: var(--divider);
    cursor: not-allowed;
    opacity: 0.7;
  }
  
  .field-input.error {
    border-color: var(--error);
  }
  
  .field-input.error:focus {
    box-shadow: 0 0 0 2px rgba(239, 68, 68, 0.2);
  }
  
  .field-error {
    font-size: 12px;
    color: var(--error);
  }
  
  .field-hint {
    font-size: 12px;
    color: var(--text-secondary);
  }
</style>
