import { writable, derived } from 'svelte/store';
import type { User } from '../types/user';

interface AuthState {
  user: User | null;
  role: string | null;
  token: string | null;
  isLoading: boolean;
  error: string | null;
}

const storedAuth = localStorage.getItem('auth');
const initialAuth: AuthState = storedAuth ? JSON.parse(storedAuth) : {
  user: null,
  role: null,
  token: null,
  isLoading: false,
  error: null
};

export const authStore = writable<AuthState>(initialAuth);

authStore.subscribe(value => {
  if (value.user && value.token) {
    localStorage.setItem('auth', JSON.stringify({
      user: value.user,
      role: value.role,
      token: value.token
    }));
  } else {
    localStorage.removeItem('auth');
  }
});

export const isAuthenticated = derived(authStore, $auth => !!$auth.user && !!$auth.token);
