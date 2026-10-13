<script lang="ts">
  let { data, options = {} } = $props<{ data: any; options?: any }>();
  
  let hoveredIndex = $state<number | null>(null);

  let chartItems = $derived.by(() => {
    if (!data || !data.labels || !data.datasets || data.datasets.length === 0) {
      return [];
    }
    const labels: string[] = data.labels || [];
    const dataset = data.datasets[0] || {};
    const values: number[] = dataset.data || [];
    const color: string = dataset.backgroundColor || '#1E88E5';

    return labels.map((label, i) => {
      const rawVal = values[i] ?? 0;
      const numVal = typeof rawVal === 'number' ? rawVal : parseFloat(rawVal) || 0;
      const clampedVal = Math.max(0, Math.min(100, numVal));
      return {
        label,
        value: numVal,
        clampedVal,
        color
      };
    });
  });

  const yTicks = [100, 75, 50, 25, 0];
</script>

<div class="fl-chart-container">
  {#if !chartItems || chartItems.length === 0}
    <div class="empty-state">Tidak ada data</div>
  {:else}
    <div class="chart-content">
      <!-- Left Y-Axis Labels -->
      <div class="y-axis">
        {#each yTicks as tick}
          <div class="y-tick">{tick}%</div>
        {/each}
      </div>

      <!-- Main Plot Area with Grid and Bars -->
      <div class="plot-area">
        <!-- Horizontal Grid Lines -->
        <div class="grid-lines">
          {#each yTicks as _tick}
            <div class="grid-line"></div>
          {/each}
        </div>

        <!-- Bars Area -->
        <div class="bars-container">
          {#each chartItems as item, idx}
            <!-- svelte-ignore a11y_no_static_element_interactions -->
            <div 
              class="bar-column"
              onmouseenter={() => hoveredIndex = idx}
              onmouseleave={() => hoveredIndex = null}
            >
              <!-- Hover Tooltip matching fl_chart -->
              {#if hoveredIndex === idx}
                <div class="chart-tooltip" style="bottom: calc({item.clampedVal}% + 10px);">
                  <span class="tooltip-text">
                    {#if options?.tooltipPrefix}
                      {options.tooltipPrefix} {item.label}<br/>
                    {/if}
                    {item.value.toFixed(1)}%
                  </span>
                  <div class="tooltip-arrow"></div>
                </div>
              {/if}

              <!-- The Bar Track with Definite Height -->
              <div class="bar-track">
                <div 
                  class="bar-rod"
                  style="height: {item.clampedVal}%; background-color: {item.color};"
                ></div>
              </div>

              <!-- Bottom X-Axis Label below plot area -->
              <div class="x-label">{item.label}</div>
            </div>
          {/each}
        </div>
      </div>
    </div>
  {/if}
</div>

<style>
  .fl-chart-container {
    width: 100%;
    height: 100%;
    min-height: 180px;
    position: relative;
    display: flex;
    align-items: center;
    justify-content: center;
    font-family: inherit;
    user-select: none;
  }

  .empty-state {
    color: var(--text-secondary, #757575);
    font-size: 14px;
  }

  .chart-content {
    display: flex;
    width: 100%;
    height: 100%;
    min-height: 180px;
    position: relative;
  }

  .y-axis {
    width: 34px;
    display: flex;
    flex-direction: column;
    justify-content: space-between;
    padding-bottom: 24px; /* Space above X labels */
    align-items: flex-end;
    padding-right: 6px;
    z-index: 2;
  }

  .y-tick {
    font-size: 10px;
    color: var(--text-secondary, #757575);
    line-height: 1;
  }

  .plot-area {
    flex: 1;
    position: relative;
    display: flex;
    flex-direction: column;
  }

  .grid-lines {
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    bottom: 24px; /* Align with bottom of plot */
    display: flex;
    flex-direction: column;
    justify-content: space-between;
    pointer-events: none;
    z-index: 1;
  }

  .grid-line {
    width: 100%;
    height: 1px;
    background-color: rgba(0, 0, 0, 0.08);
  }

  .bars-container {
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    bottom: 24px;
    display: flex;
    justify-content: space-around;
    align-items: stretch;
    z-index: 2;
  }

  .bar-column {
    display: flex;
    flex-direction: column;
    align-items: center;
    height: 100%;
    flex: 1;
    position: relative;
    cursor: pointer;
  }

  .bar-track {
    position: relative;
    width: 100%;
    height: 100%;
    display: flex;
    align-items: flex-end;
    justify-content: center;
  }

  .bar-rod {
    width: 20px;
    max-width: 24px;
    border-radius: 4px 4px 0 0;
    transition: height 0.3s cubic-bezier(0.4, 0, 0.2, 1), filter 0.2s;
  }

  .bar-column:hover .bar-rod {
    filter: brightness(1.15);
  }

  .x-label {
    position: absolute;
    top: 100%;
    margin-top: 6px;
    height: 18px;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 11px;
    color: var(--text-secondary, #757575);
    white-space: nowrap;
  }

  /* Tooltip matching Flutter fl_chart */
  .chart-tooltip {
    position: absolute;
    left: 50%;
    transform: translateX(-50%);
    background-color: #333333;
    color: #ffffff;
    padding: 6px 10px;
    border-radius: 6px;
    font-size: 11px;
    font-weight: bold;
    text-align: center;
    white-space: nowrap;
    z-index: 10;
    pointer-events: none;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
    animation: fadeIn 0.15s ease-out;
  }

  .tooltip-arrow {
    position: absolute;
    bottom: -4px;
    left: 50%;
    transform: translateX(-50%);
    width: 0;
    height: 0;
    border-left: 4px solid transparent;
    border-right: 4px solid transparent;
    border-top: 4px solid #333333;
  }

  @keyframes fadeIn {
    from { opacity: 0; transform: translate(-50%, 4px); }
    to { opacity: 1; transform: translate(-50%, 0); }
  }
</style>
