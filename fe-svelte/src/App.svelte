<script lang="ts">
  import Router from 'svelte-spa-router';
  import { wrap } from 'svelte-spa-router/wrap';
  import { isAuthGuard, isGuestGuard, isGuruGuard, isKepsekGuard, isOrtuGuard } from './lib/guards/auth';
  import { onMount } from 'svelte';
  import { authStore } from './lib/stores/auth';
  import ToastContainer from './components/ui/ToastContainer.svelte';

  import Landing from './pages/auth/Landing.svelte';
  import Login from './pages/auth/Login.svelte';
  import Register from './pages/auth/Register.svelte';
  import ForgotPassword from './pages/auth/ForgotPassword.svelte';

  import GuruHome from './pages/guru/GuruHome.svelte';
  import MulaiAbsensi from './pages/guru/MulaiAbsensi.svelte';
  import EditAbsensi from './pages/guru/EditAbsensi.svelte';
  import KelolaSiswa from './pages/guru/KelolaSiswa.svelte';
  import SiswaDetail from './pages/guru/SiswaDetail.svelte';
  import RekapBulanan from './pages/guru/RekapBulanan.svelte';
  import PersetujuanKepsek from './pages/guru/PersetujuanKepsek.svelte';
  import ImportSiswa from './pages/guru/ImportSiswa.svelte';
  import KepsekHome from './pages/kepsek/KepsekHome.svelte';
  import OrtuHome from './pages/ortu/OrtuHome.svelte';
  import Settings from './pages/shared/Settings.svelte';
  import About from './pages/shared/About.svelte';
  import ListGuru from './pages/shared/ListGuru.svelte';
  import ListSiswa from './pages/shared/ListSiswa.svelte';
  
  const routes = {
    '/': wrap({ component: Landing as any, conditions: [isGuestGuard] }),
    '/login': wrap({ component: Login as any, conditions: [isGuestGuard] }),
    '/register': wrap({ component: Register as any, conditions: [isGuestGuard] }),
    '/forgot-password': wrap({ component: ForgotPassword as any, conditions: [isGuestGuard] }),
    '/guru': wrap({ component: GuruHome as any, conditions: [isGuruGuard] }),
    '/guru/mulai-absensi': wrap({ component: MulaiAbsensi as any, conditions: [isGuruGuard] }),
    '/guru/edit-absensi/:id': wrap({ component: EditAbsensi as any, conditions: [isGuruGuard] }),
    '/guru/kelola-siswa': wrap({ component: KelolaSiswa as any, conditions: [isGuruGuard] }),
    '/guru/import-siswa': wrap({ component: ImportSiswa as any, conditions: [isGuruGuard] }),
    '/guru/siswa/:nis': wrap({ component: SiswaDetail as any, conditions: [isGuruGuard] }),
    '/guru/rekap-bulanan': wrap({ component: RekapBulanan as any, conditions: [isGuruGuard] }),
    '/guru/persetujuan-kepsek': wrap({ component: PersetujuanKepsek as any, conditions: [isGuruGuard] }),
    '/guru/*': wrap({ component: GuruHome as any, conditions: [isGuruGuard] }),
    
    '/kepsek': wrap({ component: KepsekHome as any, conditions: [isKepsekGuard] }),
    '/kepsek/list-guru': wrap({ component: ListGuru as any, conditions: [isKepsekGuard] }),
    '/kepsek/list-siswa': wrap({ component: ListSiswa as any, conditions: [isKepsekGuard] }),
    '/kepsek/siswa/:nis': wrap({ component: SiswaDetail as any, conditions: [isKepsekGuard] }),
    '/kepsek/*': wrap({ component: KepsekHome as any, conditions: [isKepsekGuard] }),
    
    '/ortu': wrap({ component: OrtuHome as any, conditions: [isOrtuGuard] }),
    '/ortu/*': wrap({ component: OrtuHome as any, conditions: [isOrtuGuard] }),
    
    '/settings': wrap({ component: Settings as any, conditions: [isAuthGuard] }),
    '/about': wrap({ component: About as any }),
    '*': Landing
  };

  onMount(() => {
    // Optionally check if token is valid with backend API
  });
</script>

<main>
  <Router {routes} />
  <ToastContainer />
</main>
