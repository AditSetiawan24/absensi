import type { WeeklyStats, ConsecutiveAbsent } from './absensi';

export interface GuruDashboard {
  info_guru: any;
  info_kelas: any;
  stats_hari_ini: any;
  today_stats?: any;
  grafik_mingguan: WeeklyStats[];
  weekly_stats?: WeeklyStats[];
  siswa_absen_hari_ini: any[];
  absent_today?: any[];
  siswa_absen_berturut: ConsecutiveAbsent[];
  consecutive_absent?: ConsecutiveAbsent[];
  [key: string]: any;
}

export interface KepalaSekolahDashboard {
  info_sekolah: any;
  stats_total: any;
  stats_hari_ini: any;
  // Extended fields used by KepsekDashboard page
  total_siswa?: number;
  totalSiswa?: number;
  total_kelas?: number;
  totalKelas?: number;
  total_guru?: number;
  totalGuru?: number;
  nama_sekolah?: string;
  namaSekolah?: string;
  class_stats?: ClassStats[];
  kelasStats?: ClassStats[];
  [key: string]: any;
}

export interface OrangTuaDashboard {
  info_ortu: any;
  anak: any[];
  siswa?: any[];
  siswaList?: any[];
  [key: string]: any;
}

export interface ClassStats {
  id_kelas?: number;
  idKelas?: number;
  kelas: string;
  guru?: string;
  nip?: string;
  jumlah_siswa?: number;
  jumlahSiswa?: number;
  total_absensi?: number;
  totalAbsensi?: number;
  hadir: number;
  izin: number;
  sakit: number;
  alfa: number;
  persentase_hadir?: number;
  persentaseHadir?: number;
}
