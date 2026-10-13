import { apiClient } from './client';
import type { Guru } from '../types/user';

export const guruApi = {
  getAll: () => apiClient.get<Guru[]>('/guru'),
  getByNip: (nip: string) => apiClient.get<Guru>(`/guru/${nip}`),
  getPendingKepsek: () => apiClient.get<any[]>('/kepala-sekolah/pending'),
  approveKepsek: (nipKepsek: string) => apiClient.post('/kepala-sekolah/approve', { nip_kepsek: nipKepsek })
};
