import { apiClient } from './client';
import type { GuruDashboard, KepalaSekolahDashboard, OrangTuaDashboard, ClassStats } from '../types/dashboard';

export const dashboardApi = {
  getGuruDashboard: (nip: string) => 
    apiClient.get<GuruDashboard>(`/dashboard/guru/${nip}`),
    
  getKepsekDashboard: (params?: { tahunAjar?: string; semester?: number }) => {
    const query: Record<string, string> = {};
    if (params?.tahunAjar) query.tahun_ajar = params.tahunAjar;
    if (params?.semester !== undefined) query.semester = String(params.semester);
    const qs = Object.keys(query).length > 0 ? '?' + new URLSearchParams(query).toString() : '';
    return apiClient.get<KepalaSekolahDashboard>(`/dashboard/kepala-sekolah${qs}`);
  },
    
  getOrtuDashboard: (idOrtu: number | string) => 
    apiClient.get<OrangTuaDashboard>(`/dashboard/orang-tua/${idOrtu}`),
    
  getClassComparison: (tahunAjar?: string) => {
    const qs = tahunAjar ? `?tahun_ajar=${tahunAjar}` : '';
    return apiClient.get<ClassStats[]>(`/dashboard/class-comparison${qs}`);
  },
    
  getSemesterComparison: (params?: { tahunAjar?: string; kelas?: string }) => {
    const query: Record<string, string> = {};
    if (params?.tahunAjar) query.tahun_ajar = params.tahunAjar;
    if (params?.kelas) query.kelas = params.kelas;
    const qs = Object.keys(query).length > 0 ? '?' + new URLSearchParams(query).toString() : '';
    return apiClient.get<any>(`/dashboard/semester-comparison${qs}`);
  }
};
