<script lang="ts">
  import { onMount, onDestroy } from 'svelte';
  import Chart from 'chart.js/auto';

  let { data, options = {} } = $props<{ data: any; options?: any }>();
  
  let canvas: HTMLCanvasElement;
  let chartInstance: Chart;

  onMount(() => {
    if (canvas) {
      chartInstance = new Chart(canvas, {
        type: 'line',
        data,
        options: {
          responsive: true,
          maintainAspectRatio: false,
          ...options
        }
      });
    }
  });

  onDestroy(() => {
    if (chartInstance) {
      chartInstance.destroy();
    }
  });
  
  $effect(() => {
    if (chartInstance && data) {
      chartInstance.data = data;
      chartInstance.options = { ...chartInstance.options, ...options };
      chartInstance.update();
    }
  });
</script>

<div class="chart-container">
  <canvas bind:this={canvas}></canvas>
</div>

<style>
  .chart-container {
    position: relative;
    height: 100%;
    width: 100%;
  }
</style>
