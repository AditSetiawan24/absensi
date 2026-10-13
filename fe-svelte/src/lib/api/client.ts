import type { ApiResponse } from '../types/api';
import { authStore } from '../stores/auth';
import { get } from 'svelte/store';

const BASE_URL = import.meta.env.VITE_API_BASE_URL;

function getToken(): string | null {
  const auth = get(authStore);
  return auth?.token || null;
}

export async function request<T>(method: string, endpoint: string, options: RequestInit = {}): Promise<ApiResponse<T>> {
  const headers: Record<string, string> = {
    'Accept': 'application/json',
  };

  if (!(options.body instanceof FormData)) {
    headers['Content-Type'] = 'application/json';
  }

  const token = getToken();
  if (token) {
    headers['Authorization'] = `Bearer ${token}`;
  }

  try {
    const response = await fetch(`${BASE_URL}${endpoint}`, {
      method,
      headers: { ...headers, ...(options.headers as any) },
      ...options,
    });
    
    // We expect backend to always return JSON
    const body = await response.json().catch(() => ({}));

    if (response.ok) {
      let data = body.data !== undefined ? body.data : body;
      if (data && typeof data === 'object') {
        if ('data' in data && data.data !== undefined) {
          data = data.data;
        } else if ('items' in data && data.items !== undefined) {
          data = data.items;
        } else if ('list' in data && data.list !== undefined) {
          data = data.list;
        }
      }

      return { 
        success: body.success !== undefined ? body.success : true, 
        message: body.message || 'Berhasil', 
        data 
      };
    } else {
      if (response.status === 401 && !endpoint.includes('/auth/login') && !endpoint.includes('/auth/change-password')) {
        authStore.update(s => ({ ...s, user: null, role: null, token: null }));
        localStorage.removeItem('auth');
      }

      let msg = body.message || 'Terjadi kesalahan';
      if (body.errors && typeof body.errors === 'object') {
        const errorValues = Object.values(body.errors);
        if (errorValues.length > 0) {
          const firstErr: any = errorValues[0];
          if (Array.isArray(firstErr) && firstErr[0]) {
            msg = firstErr[0];
          } else if (typeof firstErr === 'string') {
            msg = firstErr;
          }
        }
      }

      return { 
        success: false, 
        message: msg, 
        errors: body.errors 
      };
    }
  } catch (error: any) {
    return {
      success: false,
      message: 'Koneksi gagal: ' + (error.message || 'Network Error'),
    };
  }
}

export const apiClient = {
  get: <T>(endpoint: string, options?: RequestInit) => request<T>('GET', endpoint, options),
  post: <T>(endpoint: string, body?: any, options?: RequestInit) => 
    request<T>('POST', endpoint, { ...options, body: body instanceof FormData ? body : JSON.stringify(body) }),
  put: <T>(endpoint: string, body?: any, options?: RequestInit) => 
    request<T>('PUT', endpoint, { ...options, body: body instanceof FormData ? body : JSON.stringify(body) }),
  delete: <T>(endpoint: string, options?: RequestInit) => request<T>('DELETE', endpoint, options),
  upload: <T>(endpoint: string, formData: FormData, options?: RequestInit) => request<T>('POST', endpoint, { ...options, body: formData }),
};
