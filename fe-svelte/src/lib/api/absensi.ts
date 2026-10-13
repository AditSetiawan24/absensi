import { apiClient } from './client';
import type { Absensi } from '../types/absensi';

export const absensiApi = {
  getAll: (params?: any) => {
    const qs = params ? '?' + new URLSearchParams(params).toString() : '';
    return apiClient.get<Absensi[]>(`/absensi${qs}`);
  },

  getToday: (params?: { nip?: string; id_kelas?: number }) => {
    const qs = params ? '?' + new URLSearchParams(params as any).toString() : '';
    return apiClient.get<Absensi[]>(`/absensi/today${qs}`);
  },

  getByDate: (tanggal: string, idKelas?: number, nip?: string) => {
    const params: any = { tanggal };
    if (idKelas) params.id_kelas = idKelas;
    if (nip) params.nip = nip;
    return apiClient.get<Absensi[]>(`/absensi/by-date?${new URLSearchParams(params).toString()}`);
  },
    
  getByKelas: (idKelas: number, date?: string) => 
    apiClient.get<Absensi[]>(`/absensi/by-kelas/${idKelas}${date ? `?date=${date}` : ''}`),

  getBySiswa: (nis: string) => 
    apiClient.get<any>(`/absensi/by-siswa/${nis}`),

  getById: (idAbsensi: number | string) =>
    apiClient.get<any>(`/absensi/${idAbsensi}`),

  getWeeklyStats: (params?: { nip?: string; id_kelas?: number }) => {
    const qs = params ? '?' + new URLSearchParams(params as any).toString() : '';
    return apiClient.get<any[]>(`/absensi/weekly-stats${qs}`);
  },

  getConsecutiveAbsent: (idKelas?: number) => {
    const qs = idKelas ? `?id_kelas=${idKelas}` : '';
    return apiClient.get<any[]>(`/absensi/consecutive-absent${qs}`);
  },

  getStatistics: (params?: { nis?: string; id_kelas?: number }) => {
    const qs = params ? '?' + new URLSearchParams(params as any).toString() : '';
    return apiClient.get<any>(`/absensi/statistics${qs}`);
  },
    
  create: (data: any) => 
    apiClient.post('/absensi', data),

  submitBulk: (data: any) => 
    apiClient.post('/absensi/bulk', data),
    
  update: (idAbsensi: number, data: any) => 
    apiClient.put(`/absensi/${idAbsensi}`, data),

  delete: (idAbsensi: number) => 
    apiClient.delete(`/absensi/${idAbsensi}`)
};
