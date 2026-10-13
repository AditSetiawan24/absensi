<script lang="ts">
  import { onMount } from 'svelte';
  
  // Data format expected: { '2023-10-01': 'hadir', '2023-10-02': 'alfa', ... }
  let { attendanceData = {}, onDayClick }: { attendanceData?: Record<string, string>; onDayClick?: (dateStr: string) => void } = $props();
  
  let currentDate = $state(new Date());
  
  let currentMonth = $derived(currentDate.getMonth());
  let currentYear = $derived(currentDate.getFullYear());
  
  const monthNames = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];
  
  let calendarDays = $derived.by(() => {
    const days = [];
    const firstDay = new Date(currentYear, currentMonth, 1);
    const lastDay = new Date(currentYear, currentMonth + 1, 0);
    
    // Get day of week for 1st of month (0 = Sunday)
    let startingDay = firstDay.getDay();
    // Adjust to make Monday = 0, Sunday = 6
    startingDay = startingDay === 0 ? 6 : startingDay - 1;
    
    // Previous month padding
    const prevMonthLastDay = new Date(currentYear, currentMonth, 0).getDate();
    for (let i = startingDay - 1; i >= 0; i--) {
      days.push({
        date: prevMonthLastDay - i,
        month: currentMonth - 1,
        isCurrentMonth: false
      });
    }
    
    // Current month days
    for (let i = 1; i <= lastDay.getDate(); i++) {
      days.push({
        date: i,
        month: currentMonth,
        isCurrentMonth: true
      });
    }
    
    // Next month padding to complete the grid (usually 42 cells = 6 weeks)
    const remainingCells = 42 - days.length;
    for (let i = 1; i <= remainingCells; i++) {
      days.push({
        date: i,
        month: currentMonth + 1,
        isCurrentMonth: false
      });
    }
    
    return days;
  });

  function prevMonth() {
    currentDate = new Date(currentDate.setMonth(currentDate.getMonth() - 1));
  }
  
  function nextMonth() {
    currentDate = new Date(currentDate.setMonth(currentDate.getMonth() + 1));
  }
  
  function getStatusColor(day: any) {
    if (!day.isCurrentMonth) return 'transparent';
    
    const dateStr = `${currentYear}-${String(currentMonth + 1).padStart(2, '0')}-${String(day.date).padStart(2, '0')}`;
    const status = attendanceData[dateStr]?.toLowerCase();
    
    if (status === 'hadir') return 'var(--hadir)';
    if (status === 'izin') return 'var(--izin)';
    if (status === 'sakit') return 'var(--sakit)';
    if (status === 'alfa') return 'var(--alfa)';
    
    return 'transparent';
  }
</script>

<div class="calendar-container">
  <div class="calendar-header">
    <button class="nav-btn" onclick={prevMonth} aria-label="Bulan Sebelumnya" title="Bulan Sebelumnya">
      <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 18 9 12 15 6"/></svg>
    </button>
    <div class="current-month">{monthNames[currentMonth]} {currentYear}</div>
    <button class="nav-btn" onclick={nextMonth} aria-label="Bulan Berikutnya" title="Bulan Berikutnya">
      <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg>
    </button>
  </div>
  
  <div class="calendar-grid">
    <div class="day-name">Sen</div>
    <div class="day-name">Sel</div>
    <div class="day-name">Rab</div>
    <div class="day-name">Kam</div>
    <div class="day-name">Jum</div>
    <div class="day-name">Sab</div>
    <div class="day-name">Min</div>
    
    {#each calendarDays as day}
      <!-- svelte-ignore a11y_click_events_have_key_events -->
      <!-- svelte-ignore a11y_no_static_element_interactions -->
      <div 
        class="day-cell" 
        class:inactive={!day.isCurrentMonth}
        class:clickable={day.isCurrentMonth}
        onclick={() => {
          if (day.isCurrentMonth && onDayClick) {
            const dateStr = `${currentYear}-${String(currentMonth + 1).padStart(2, '0')}-${String(day.date).padStart(2, '0')}`;
            onDayClick(dateStr);
          }
        }}
      >
        <div 
          class="day-number" 
          style="background-color: {getStatusColor(day)}; color: {getStatusColor(day) !== 'transparent' ? 'white' : 'inherit'}"
        >
          {day.date}
        </div>
      </div>
    {/each}
  </div>
  
  <div class="legend">
    <div class="legend-item"><div class="dot hadir"></div>Hadir</div>
    <div class="legend-item"><div class="dot izin"></div>Izin</div>
    <div class="legend-item"><div class="dot sakit"></div>Sakit</div>
    <div class="legend-item"><div class="dot alfa"></div>Alfa</div>
  </div>
</div>

<style>
  .calendar-container {
    background: var(--surface);
    border: 1px solid var(--border);
    border-radius: 16px;
    padding: 16px;
  }
  
  .calendar-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 16px;
  }
  
  .current-month {
    font-weight: 700;
    font-size: 16px;
    color: var(--text-primary);
  }
  
  .nav-btn {
    background: none;
    border: none;
    color: var(--text-secondary);
    cursor: pointer;
    padding: 4px;
    border-radius: 4px;
    display: flex;
    align-items: center;
    justify-content: center;
  }
  
  .nav-btn:hover {
    background: var(--bg);
    color: var(--primary);
  }
  
  .calendar-grid {
    display: grid;
    grid-template-columns: repeat(7, 1fr);
    gap: 8px;
    text-align: center;
  }
  
  .day-name {
    font-size: 12px;
    font-weight: 600;
    color: var(--text-secondary);
    margin-bottom: 8px;
  }
  
  .day-cell {
    display: flex;
    justify-content: center;
    align-items: center;
    height: 36px;
  }
  
  .day-cell.clickable {
    cursor: pointer;
  }
  
  .day-cell.clickable:hover .day-number {
    box-shadow: 0 0 0 2px var(--primary);
  }
  
  .day-number {
    width: 32px;
    height: 32px;
    display: flex;
    justify-content: center;
    align-items: center;
    border-radius: 50%;
    font-size: 14px;
    font-weight: 500;
  }
  
  .day-cell.inactive .day-number {
    color: var(--text-disabled) !important;
  }
  
  .legend {
    display: flex;
    justify-content: space-between;
    margin-top: 20px;
    padding-top: 16px;
    border-top: 1px solid var(--border);
  }
  
  .legend-item {
    display: flex;
    align-items: center;
    gap: 6px;
    font-size: 12px;
    color: var(--text-secondary);
    font-weight: 500;
  }
  
  .dot {
    width: 10px;
    height: 10px;
    border-radius: 50%;
  }
  
  .dot.hadir { background: var(--hadir); }
  .dot.izin { background: var(--izin); }
  .dot.sakit { background: var(--sakit); }
  .dot.alfa { background: var(--alfa); }
</style>
