<script lang="ts">
  import Button from '../../components/ui/Button.svelte';
  import TextField from '../../components/ui/TextField.svelte';
  import PageLayout from '../../components/layout/PageLayout.svelte';
  import { push } from 'svelte-spa-router';
  import { authApi } from '../../lib/api/auth';
  import { toast } from '../../lib/stores/toast';

  let role = $state('guru');
  let email = $state('');
  let password = $state('');
  let password_confirmation = $state('');
  let isLoading = $state(false);
  let emailSent = $state(false);

  const roles = [
    { id: 'guru', label: 'Guru' },
    { id: 'kepala_sekolah', label: 'Kepsek' },
    { id: 'orang_tua', label: 'Ortu' }
  ];

  async function handleSendRequest() {
    const trimmedEmail = email.trim();
    if (!trimmedEmail) {
      toast.error('Email tidak boleh kosong');
      return;
    }
    if (!trimmedEmail.includes('@')) {
      toast.error('Email tidak valid');
      return;
    }
    
    isLoading = true;
    const res = await authApi.forgotPassword({ email: trimmedEmail, role });
    isLoading = false;

    if (res.success) {
      emailSent = true;
    } else {
      toast.error(res.message || 'Gagal menemukan email');
    }
  }

  async function handleReset() {
    if (!password) {
      toast.error('Password tidak boleh kosong');
      return;
    }
    if (password.length < 6) {
      toast.error('Password minimal 6 karakter');
      return;
    }
    if (!password_confirmation) {
      toast.error('Konfirmasi password tidak boleh kosong');
      return;
    }
    if (password !== password_confirmation) {
      toast.error('Password tidak cocok');
      return;
    }
    
    isLoading = true;
    const res = await authApi.resetPassword({ 
      email: email.trim(), 
      role, 
      password, 
      password_confirmation 
    });
    isLoading = false;

    if (res.success) {
      toast.success('Password berhasil direset! Silakan login');
      push('/login');
    } else {
      toast.error(res.message || 'Gagal mereset password');
    }
  }
</script>

<PageLayout title="" showBack={true} transparent={true}>
  <div class="forgot-content">
    <div class="header">
      <h1 class="title">Lupa Password</h1>
      <p class="subtitle">
        {emailSent ? 'Masukkan password baru Anda' : 'Masukkan email untuk mereset password'}
      </p>
    </div>

    {#if !emailSent}
      <div class="form-section">
        <label class="section-label">Tipe Akun</label>
        <div class="role-selector">
          {#each roles as r}
            <!-- svelte-ignore a11y_click_events_have_key_events -->
            <!-- svelte-ignore a11y_no_static_element_interactions -->
            <div 
              class="role-chip {role === r.id ? 'active' : ''}" 
              onclick={() => role = r.id}
            >
              {r.label}
            </div>
          {/each}
        </div>

        <form onsubmit={(e) => { e.preventDefault(); handleSendRequest(); }}>
          <div class="input-group">
            <TextField bind:value={email} label="Email" type="email" placeholder="Masukkan email terdaftar" prefixIcon="email_outlined" />
          </div>
          
          <div class="mt-6">
            <Button text="Kirim" type="submit" {isLoading} />
          </div>
        </form>
      </div>
    {:else}
      <div class="form-section">
        <div class="success-box">
          <span class="success-icon">✓</span>
          <span>Email ditemukan: {email}</span>
        </div>

        <form onsubmit={(e) => { e.preventDefault(); handleReset(); }}>
          <div class="input-group">
            <TextField bind:value={password} label="Password Baru" type="password" placeholder="Masukkan password baru" prefixIcon="lock_outline" isPassword={true} />
          </div>
          
          <div class="input-group">
            <TextField bind:value={password_confirmation} label="Konfirmasi Password" type="password" placeholder="Masukkan ulang password" prefixIcon="lock_outline" isPassword={true} />
          </div>
          
          <div class="mt-6">
            <Button text="Reset Password" type="submit" {isLoading} />
          </div>
        </form>
      </div>
    {/if}
  </div>
</PageLayout>

<style>
  .forgot-content {
    padding: 24px;
    display: flex;
    flex-direction: column;
    min-height: calc(100vh - 64px);
  }
  
  .header {
    margin-bottom: 32px;
  }
  
  .title {
    font-size: 28px;
    font-weight: bold;
    color: var(--text-primary);
    margin: 0 0 8px 0;
  }
  
  .subtitle {
    font-size: 16px;
    color: var(--text-secondary);
    margin: 0;
  }

  .form-section {
    display: flex;
    flex-direction: column;
  }

  .section-label {
    font-size: 14px;
    font-weight: 500;
    color: var(--text-primary);
    margin-bottom: 12px;
    display: block;
  }
  
  .role-selector {
    display: flex;
    gap: 8px;
    margin-bottom: 24px;
  }
  
  .role-chip {
    flex: 1;
    padding: 12px 0;
    border-radius: 12px;
    border: 1px solid #e0e0e0;
    background-color: #f5f5f5;
    color: var(--text-primary);
    font-size: 12px;
    font-weight: 600;
    text-align: center;
    cursor: pointer;
    transition: all 0.2s;
  }
  
  .role-chip.active {
    background-color: var(--primary);
    color: white;
    border-color: var(--primary);
  }

  .input-group {
    margin-bottom: 16px;
  }
  
  .mt-6 {
    margin-top: 8px;
    margin-bottom: 24px;
  }

  .success-box {
    display: flex;
    align-items: center;
    padding: 16px;
    border-radius: 12px;
    background-color: rgba(76, 175, 80, 0.1);
    border: 1px solid #4caf50;
    color: #4caf50;
    margin-bottom: 24px;
    gap: 12px;
    font-size: 14px;
  }

  .success-icon {
    font-size: 20px;
    font-weight: bold;
  }
</style>
