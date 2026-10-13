export interface Absensi {
  id_absensi?: number;
  id?: number;
  nis: string;
  nip: string;
  tanggal: string;
  status_kehadiran: 'hadir' | 'izin' | 'sakit' | 'alfa';
  status?: string;
  keterangan?: string;
  file_surat?: string;
  nama_siswa?: string;
  nama_guru?: string;
  siswa?: {
    nama?: string;
    nis?: string;
    [key: string]: any;
  };
}

export interface WeeklyStats {
  tanggal?: string;
  date?: string;
  hari?: string;
  hadir: number;
  sakit: number;
  izin: number;
  alfa: number;
  persentase_hadir?: number;
  persentaseHadir?: number;
}

export interface ConsecutiveAbsent {
  nis: string;
  nama_siswa?: string;
  namaSiswa?: string;
  nama?: string;
  kelas?: string;
  nama_orang_tua?: string;
  no_hp_orang_tua?: string;
  consecutive_days?: number;
  consecutiveDays?: number;
  hari_berurutan?: number;
  last_absent_date?: string;
  tanggal_mulai?: string;
  tanggal_akhir?: string;
  status_terakhir?: string;
  keterangan?: string;
  id_kelas?: number;
}
