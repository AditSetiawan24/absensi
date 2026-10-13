import { apiClient } from './client';
import type { Kelas } from '../types/siswa';

export const kelasApi = {
  getAll: () => apiClient.get<Kelas[]>('/kelas'),
  getById: (id: number) => apiClient.get<Kelas>(`/kelas/${id}`),
  getByGuru: (nip: string) => apiClient.get<Kelas[]>(`/kelas/by-guru/${nip}`),
};
