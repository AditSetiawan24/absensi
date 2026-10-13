<script lang="ts">
  let { 
    title, 
    value, 
    subtitle = '', 
    color = 'var(--primary)'
  } = $props<{
    title: string;
    value: string | number;
    subtitle?: string;
    color?: string;
  }>();
</script>

<div class="stat-card">
  <div class="stat-content">
    <div class="stat-title">{title}</div>
    <div class="stat-value" style="color: {color}">{value}</div>
    {#if subtitle}
      <div class="stat-subtitle">{subtitle}</div>
    {/if}
  </div>
</div>

<style>
  .stat-card {
    background-color: var(--surface);
    border-radius: 16px;
    padding: 20px;
    box-shadow: var(--shadow-card);
    border: 1px solid var(--border);
    display: flex;
    flex-direction: column;
    width: 100%;
  }
  
  .stat-title {
    font-size: 14px;
    color: var(--text-secondary);
    font-weight: 500;
    margin-bottom: 8px;
  }
  
  .stat-value {
    font-size: 28px;
    font-weight: 700;
    margin-bottom: 4px;
  }
  
  .stat-subtitle {
    font-size: 12px;
    color: var(--text-light);
  }
</style>
