import { apiClient } from './client';
import type { Laporan } from '../types/laporan';

function buildQuery(params?: any): string {
  if (!params) return '';
  const clean: Record<string, string> = {};
  for (const [k, v] of Object.entries(params)) {
    if (v !== undefined && v !== null && v !== '') {
      clean[k] = String(v);
    }
  }
  const str = new URLSearchParams(clean).toString();
  return str ? `?${str}` : '';
}

export const laporanApi = {
  getAll: (params?: { nip?: string; id_kelas?: number }) => {
    return apiClient.get<Laporan[]>(`/laporan${buildQuery(params)}`);
  },
  getByKelas: (idKelas: number) => apiClient.get<any>(`/laporan/by-kelas/${idKelas}`),
  getByOrtu: (idOrtu: string | number) => apiClient.get<any[]>(`/laporan/by-orangtua/${idOrtu}`),
  getById: (id: number) => apiClient.get<Laporan>(`/laporan/${id}`),
  createFromAbsensi: (data: { tahun_ajar: string; semester: number; kelas: string; nip: string }) => 
    apiClient.post<Laporan>('/laporan/create-from-absensi', data),
  create: (data: any) => apiClient.post<Laporan>('/laporan', data),
  update: (id: number, data: any) => apiClient.put<Laporan>(`/laporan/${id}`, data),
  delete: (idLaporan: number) => apiClient.delete(`/laporan/${idLaporan}`),
  submit: (idLaporan: number) => apiClient.post<Laporan>(`/laporan/${idLaporan}/submit`),
  unsubmit: (idLaporan: number) => apiClient.post<Laporan>(`/laporan/${idLaporan}/unsubmit`),
  refresh: (idLaporan: number) => apiClient.post<Laporan>(`/laporan/${idLaporan}/refresh`),
  generate: (params?: { tahun_ajar?: string; semester?: number; kelas?: string }) => {
    return apiClient.get<any>(`/laporan/generate${buildQuery(params)}`);
  },
  downloadPdf: (params?: { tahun_ajar?: string; semester?: number; kelas?: string }) => {
    return apiClient.get<any>(`/laporan/download/pdf${buildQuery(params)}`);
  },
  downloadExcel: (params?: { tahun_ajar?: string; semester?: number; kelas?: string }) => {
    return apiClient.get<any>(`/laporan/download/excel${buildQuery(params)}`);
  },

  // Rekap Bulanan methods
  getRekapBulanan: (params?: { id_kelas?: number; nip?: string; tahun?: number }) => {
    return apiClient.get<any[]>(`/rekap-bulanan${buildQuery(params)}`);
  },
  createRekap: (data: { id_kelas: number; nip: string; bulan: number; tahun: number }) => 
    apiClient.post<Laporan>('/rekap-bulanan', data),
  updateRekap: (id: number, data: any) => apiClient.put<Laporan>(`/rekap-bulanan/${id}`, data),
  deleteRekap: (idRekap: number) => apiClient.delete(`/rekap-bulanan/${idRekap}`),
  refreshRekap: (idRekap: number) => apiClient.post<Laporan>(`/rekap-bulanan/${idRekap}/refresh`),
  submitRekap: (idRekap: number) => apiClient.post<Laporan>(`/rekap-bulanan/${idRekap}/submit`),
  unsubmitRekap: (idRekap: number) => apiClient.post<Laporan>(`/rekap-bulanan/${idRekap}/unsubmit`),
};
