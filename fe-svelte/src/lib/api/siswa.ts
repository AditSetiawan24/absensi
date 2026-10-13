import { apiClient } from './client';
import type { Siswa } from '../types/siswa';

export const siswaApi = {
  getAll: () => apiClient.get<Siswa[]>('/siswa'),
  getByKelas: (idKelas: number) => apiClient.get<Siswa[]>(`/siswa/by-kelas/${idKelas}`),
  getDetail: (nis: string) => apiClient.get<Siswa>(`/siswa/${nis}`),
  create: (data: any) => apiClient.post('/siswa', data),
  update: (nis: string, data: any) => apiClient.put(`/siswa/${nis}`, data),
  delete: (nis: string) => apiClient.delete(`/siswa/${nis}`),
  importExcel: (formData: FormData) => apiClient.upload('/siswa/import', formData),
  import: (file: File, idKelas: number) => {
    const fd = new FormData();
    fd.append('file', file);
    fd.append('id_kelas', String(idKelas));
    return apiClient.upload('/siswa/import', fd);
  }
};
