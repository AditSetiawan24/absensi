<script lang="ts">
  let { status = '' } = $props<{ status?: string }>();

  let badgeColor = $derived.by(() => {
    const s = (status || '').toLowerCase();
    switch(s) {
      case 'hadir': return 'var(--hadir)';
      case 'izin': return 'var(--izin)';
      case 'sakit': return 'var(--sakit)';
      case 'alfa': return 'var(--alfa)';
      case 'approved': case 'disetujui': return 'var(--success)';
      case 'pending': case 'menunggu persetujuan': return 'var(--warning)';
      default: return 'var(--text-secondary)';
    }
  });

  let badgeLabel = $derived.by(() => {
    if (!status) return '-';
    return status.charAt(0).toUpperCase() + status.slice(1);
  });
</script>

<div class="badge" style="--badge-color: {badgeColor}">
  {badgeLabel}
</div>

<style>
  .badge {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    padding: 6px 12px;
    border-radius: 20px;
    font-size: 12px;
    font-weight: 600;
    background-color: color-mix(in srgb, var(--badge-color) 15%, transparent);
    color: var(--badge-color);
    border: 1px solid color-mix(in srgb, var(--badge-color) 30%, transparent);
  }
</style>
