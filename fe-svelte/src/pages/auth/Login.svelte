<script lang="ts">
  import Button from '../../components/ui/Button.svelte';
  import TextField from '../../components/ui/TextField.svelte';
  import PageLayout from '../../components/layout/PageLayout.svelte';
  import { push } from 'svelte-spa-router';
  import { authApi } from '../../lib/api/auth';
  import { authStore } from '../../lib/stores/auth';
  import { toast } from '../../lib/stores/toast';

  let role = $state('guru');
  let identifier = $state('');
  let password = $state('');
  let isLoading = $state(false);

  const roles = [
    { id: 'guru', label: 'Guru' },
    { id: 'kepala_sekolah', label: 'Kepsek' },
    { id: 'orang_tua', label: 'Orang Tua' }
  ];

  async function handleLogin() {
    if (!identifier.trim()) {
      toast.error('Username tidak boleh kosong');
      return;
    }
    if (!password) {
      toast.error('Password tidak boleh kosong');
      return;
    }
    
    isLoading = true;
    
    let loginData: any = { 
      username: identifier.trim(), 
      password, 
      role 
    };

    const res = await authApi.login(loginData);
    isLoading = false;

    if (res.success && res.data) {
      authStore.set({
        user: { ...res.data.user, role: res.data.role },
        role: res.data.role,
        token: res.data.token,
        isLoading: false,
        error: null
      });
      
      if (res.data.role === 'guru') push('/guru/dashboard');
      else if (res.data.role === 'kepala_sekolah') push('/kepsek/dashboard');
      else push('/ortu/dashboard');
    } else {
      toast.error(res.message || 'Login gagal');
    }
  }
</script>

<PageLayout title="" showBack={true} transparent={true}>
  <div class="login-content">
    <div class="header">
      <h1 class="title">Selamat Datang</h1>
      <p class="subtitle">Masuk ke akun Anda untuk melanjutkan</p>
    </div>

    <div class="form-section">
      <label class="section-label">Masuk Sebagai</label>
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

      <form class="login-form" onsubmit={(e) => { e.preventDefault(); handleLogin(); }}>
        <div class="input-group">
          <TextField 
            bind:value={identifier} 
            label="Username" 
            placeholder="Masukkan username" 
            prefixIcon="person_outline"
          />
        </div>
        
        <div class="input-group">
          <TextField 
            bind:value={password} 
            label="Password" 
            type="password" 
            placeholder="Masukkan password" 
            prefixIcon="lock_outline"
            isPassword={true}
          />
        </div>
        
        <div class="forgot-pwd">
          <a href="#/forgot-password" class="link-text">Lupa Password?</a>
        </div>

        <div class="mt-6">
          <Button text="Masuk" type="submit" {isLoading} />
        </div>
      </form>
      
      <div class="register-prompt">
        <span class="text-secondary">Belum punya akun? </span>
        <a href="#/register" class="link-text bold">Daftar</a>
      </div>
    </div>
  </div>
</PageLayout>

<style>
  .login-content {
    padding: 24px;
    display: flex;
    flex-direction: column;
    min-height: calc(100vh - 64px); /* Account for app bar height roughly */
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
    font-size: 14px;
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
  
  .login-form {
    display: flex;
    flex-direction: column;
  }

  .input-group {
    margin-bottom: 16px;
  }
  
  .forgot-pwd {
    display: flex;
    justify-content: flex-end;
    margin-bottom: 24px;
  }
  
  .link-text {
    color: var(--primary);
    font-size: 14px;
    text-decoration: none;
    font-weight: 500;
  }
  
  .link-text.bold {
    font-weight: 600;
  }
  
  .mt-6 {
    margin-bottom: 24px;
  }
  
  .register-prompt {
    text-align: center;
    font-size: 14px;
  }

  .text-secondary {
    color: var(--text-secondary);
  }
</style>
