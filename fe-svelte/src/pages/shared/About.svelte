<script lang="ts">
  import PageLayout from '../../components/layout/PageLayout.svelte';
  import { AppConstants } from '../../lib/utils/constants';
</script>

<PageLayout title="Tentang Aplikasi" showBack={true}>
  <div class="about-content">
    <div class="logo-container">
      <div class="logo-circle">
        <svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 10v6M2 10l10-5 10 5-10 5z"/><path d="M6 12v5c3 3 9 3 12 0v-5"/></svg>
      </div>
      <h2>{AppConstants.appName}</h2>
      <p class="version">Versi {AppConstants.appVersion}</p>
    </div>
    
    <div class="info-card">
      <h3>{AppConstants.schoolName}</h3>
      <p>Aplikasi absensi siswa untuk memudahkan pencatatan dan pemantauan kehadiran siswa secara elektronik oleh guru, kepala sekolah, dan orang tua murid.</p>
    </div>
    
    <div class="developer-info">
      <p>Dikembangkan oleh</p>
      <h4>Tim Pengembang</h4>
      <p>&copy; {new Date().getFullYear()} All Rights Reserved</p>
    </div>
  </div>
</PageLayout>

<style>
  .about-content {
    padding: 24px;
    display: flex;
    flex-direction: column;
    align-items: center;
  }
  
  .logo-container {
    display: flex;
    flex-direction: column;
    align-items: center;
    margin-bottom: 32px;
    margin-top: 24px;
  }
  
  .logo-circle {
    width: 100px;
    height: 100px;
    background: var(--primary);
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    color: white;
    margin-bottom: 16px;
    box-shadow: 0 4px 12px rgba(13, 71, 161, 0.3);
  }
  
  .logo-container h2 {
    margin: 0 0 4px 0;
    color: var(--text-primary);
  }
  
  .version {
    margin: 0;
    color: var(--text-secondary);
    font-size: 14px;
  }
  
  .info-card {
    background: var(--surface);
    padding: 24px;
    border-radius: 16px;
    border: 1px solid var(--border);
    width: 100%;
    margin-bottom: 40px;
  }
  
  .info-card h3 {
    margin: 0 0 12px 0;
    color: var(--primary);
    font-size: 18px;
  }
  
  .info-card p {
    margin: 0;
    color: var(--text-secondary);
    line-height: 1.6;
    font-size: 14px;
  }
  
  .developer-info {
    text-align: center;
    color: var(--text-secondary);
  }
  
  .developer-info p {
    margin: 0 0 4px 0;
    font-size: 12px;
  }
  
  .developer-info h4 {
    margin: 0 0 8px 0;
    color: var(--text-primary);
    font-size: 16px;
  }
</style>
