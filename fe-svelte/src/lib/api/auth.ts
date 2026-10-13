import { apiClient } from './client';
import type { User } from '../types/user';

export const authApi = {
  login: (data: any) => apiClient.post<{ user: User; role: string; token: string }>('/auth/login', data),
  register: (data: any) => apiClient.post('/auth/register', data),
  forgotPassword: (data: any) => apiClient.post('/auth/forgot-password', data),
  resetPassword: (data: any) => apiClient.post('/auth/reset-password', data),
  changePassword: (data: any) => apiClient.post('/auth/change-password', data),
  logout: () => apiClient.post('/logout'),
  profile: () => apiClient.get('/profile'),
  updateProfile: (data: any) => apiClient.put('/profile/update', data),
  getGuruClass: (nip: string) => apiClient.get(`/guru/my-class?nip=${nip}`),
  releaseClass: (data: any) => apiClient.post('/guru/release-class', data),
  changeClass: (data: any) => apiClient.post('/guru/change-class', data),
};
