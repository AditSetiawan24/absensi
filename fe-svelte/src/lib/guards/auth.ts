import { get } from 'svelte/store';
import { authStore } from '../stores/auth';
import { replace } from 'svelte-spa-router';

export function isAuthGuard() {
  const auth = get(authStore);
  if (!auth.token || !auth.user) {
    replace('/login');
    return false;
  }
  return true;
}

export function isGuruGuard() {
  const auth = get(authStore);
  if (!auth.token || !auth.user) {
    replace('/login');
    return false;
  }
  if (auth.role !== 'guru') {
    replace('/login');
    return false;
  }
  return true;
}

export function isKepsekGuard() {
  const auth = get(authStore);
  if (!auth.token || !auth.user) {
    replace('/login');
    return false;
  }
  if (auth.role !== 'kepala_sekolah') {
    replace('/login');
    return false;
  }
  return true;
}

export function isOrtuGuard() {
  const auth = get(authStore);
  if (!auth.token || !auth.user) {
    replace('/login');
    return false;
  }
  if (auth.role !== 'orang_tua') {
    replace('/login');
    return false;
  }
  return true;
}

export function isGuestGuard() {
  const auth = get(authStore);
  if (auth.token && auth.user) {
    if (auth.role === 'guru') replace('/guru/dashboard');
    else if (auth.role === 'kepala_sekolah') replace('/kepsek/dashboard');
    else if (auth.role === 'orang_tua') replace('/ortu/dashboard');
    else replace('/');
    return false;
  }
  return true;
}
