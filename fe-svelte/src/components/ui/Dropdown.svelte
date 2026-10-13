<script lang="ts">
  let { 
    value = $bindable(), 
    options, 
    label, 
    error = '', 
    disabled = false 
  } = $props<{
    value: any;
    options: { value: any, label: string }[];
    label?: string;
    error?: string;
    disabled?: boolean;
  }>();
</script>

<div class="field-container">
  {#if label}
    <label class="field-label">{label}</label>
  {/if}
  
  <div class="input-wrapper">
    <select 
      class="field-input {error ? 'error' : ''}"
      bind:value
      {disabled}
    >
      <option value="" disabled>Pilih salah satu</option>
      {#each options as option}
        <option value={option.value}>{option.label}</option>
      {/each}
    </select>
    <div class="select-icon">
      <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="m6 9 6 6 6-6"/></svg>
    </div>
  </div>
  
  {#if error}
    <span class="field-error">{error}</span>
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
    padding-right: 40px;
    border-radius: 12px;
    border: 1px solid var(--border);
    background-color: var(--surface);
    color: var(--text-primary);
    font-size: 16px;
    transition: border-color 0.2s;
    font-family: inherit;
    appearance: none;
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
  
  .select-icon {
    position: absolute;
    right: 16px;
    top: 50%;
    transform: translateY(-50%);
    pointer-events: none;
    color: var(--text-secondary);
  }
  
  .field-error {
    font-size: 12px;
    color: var(--error);
  }
</style>
