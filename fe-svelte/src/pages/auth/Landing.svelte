<script lang="ts">
  import Button from '../../components/ui/Button.svelte';
  import { push } from 'svelte-spa-router';
  import { AppConstants } from '../../lib/utils/constants';
</script>

<div class="landing-container">
  <div class="spacer"></div>
  
  <div class="header">
    <div class="logo-container">
      <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="64" height="64" fill="currentColor">
        <path d="M12 3L1 9l4 2.18v6L12 21l7-3.82v-6l2-1.09V17h2V9L12 3zm6.82 6L12 12.72 5.18 9 12 5.28 18.82 9zM17 15.99l-5 2.73-5-2.73v-3.72l5 2.73 5-2.73v3.72z"/>
      </svg>
    </div>
    <h1 class="title">{AppConstants.appName}</h1>
    <p class="subtitle">{AppConstants.schoolName}</p>
  </div>
  
  <div class="features">
    <div class="feature-item">
      <div class="feature-icon-container">
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="24" height="24" fill="currentColor">
          <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm0 18c-4.41 0-8-3.59-8-8s3.59-8 8-8 8 3.59 8 8-3.59 8-8 8zm4.59-12.42L10 14.17l-2.59-2.58L6 13l4 4 8-8z"/>
        </svg>
      </div>
      <div class="feature-text">
        <h3>Pencatatan Kehadiran</h3>
        <p>Catat kehadiran siswa dengan mudah dan cepat</p>
      </div>
    </div>
    
    <div class="feature-item">
      <div class="feature-icon-container">
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="24" height="24" fill="currentColor">
          <path d="M19 3H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm0 16H5V5h14v14z"/>
          <path d="M7 12h2v5H7zm4-3h2v8h-2zm4-3h2v11h-2z"/>
        </svg>
      </div>
      <div class="feature-text">
        <h3>Laporan Lengkap</h3>
        <p>Lihat statistik dan laporan kehadiran</p>
      </div>
    </div>
  </div>
  
  <div class="spacer"></div>
  
  <div class="actions">
    <Button 
      text="Masuk" 
      onClick={() => push('/login')} 
    />
    <Button 
      text="Daftar" 
      isOutlined={true} 
      onClick={() => push('/register')} 
    />
  </div>
</div>

<style>
  .landing-container {
    display: flex;
    flex-direction: column;
    min-height: 100vh;
    padding: 24px;
    background-color: var(--bg);
    box-sizing: border-box;
  }
  
  .spacer {
    flex: 1;
  }
  
  .header {
    display: flex;
    flex-direction: column;
    align-items: center;
    margin-bottom: 48px;
  }
  
  .logo-container {
    width: 120px;
    height: 120px;
    background-color: rgba(13, 71, 161, 0.1); /* AppColors.primary.withOpacity(0.1) */
    color: var(--primary);
    border-radius: 30px;
    display: flex;
    align-items: center;
    justify-content: center;
    margin-bottom: 32px;
  }
  
  .title {
    font-size: 32px;
    font-weight: bold;
    color: var(--primary);
    margin: 0 0 8px 0;
    text-align: center;
  }
  
  .subtitle {
    font-size: 18px;
    color: var(--text-secondary);
    margin: 0;
    text-align: center;
  }
  
  .features {
    display: flex;
    flex-direction: column;
    gap: 16px;
    width: 100%;
  }
  
  .feature-item {
    display: flex;
    align-items: center;
  }
  
  .feature-icon-container {
    padding: 12px;
    background-color: rgba(13, 71, 161, 0.1);
    border-radius: 12px;
    color: var(--primary);
    display: flex;
    align-items: center;
    justify-content: center;
    margin-right: 16px;
  }
  
  .feature-text {
    flex: 1;
    display: flex;
    flex-direction: column;
  }
  
  .feature-text h3 {
    font-size: 16px;
    font-weight: 600;
    color: var(--text-primary);
    margin: 0 0 4px 0;
  }
  
  .feature-text p {
    font-size: 14px;
    color: var(--text-secondary);
    margin: 0;
  }
  
  .actions {
    display: flex;
    flex-direction: column;
    gap: 12px;
    width: 100%;
    margin-bottom: 24px;
  }
</style>
