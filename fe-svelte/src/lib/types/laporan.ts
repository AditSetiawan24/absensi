export interface Laporan {
  id_laporan: number;
  idLaporan?: number;
  id_kelas: number;
  idKelas?: number;
  nip: string;
  bulan?: number;
  namaBulan?: string;
  tahun?: number;
  tahun_ajar?: string;
  tahunAjar?: string;
  semester?: number | string;
  total_hadir: number;
  hadir?: number;
  total_sakit: number;
  sakit?: number;
  total_izin: number;
  izin?: number;
  total_alfa: number;
  alfa?: number;
  periode_awal?: string;
  periodeAwal?: string;
  periode_akhir?: string;
  periodeAkhir?: string;
  status?: string;
  status_persetujuan?: string;
  kelas?: {
    kelas?: string;
    nama_kelas?: string;
    [key: string]: any;
  };
  nama_kelas?: string;
  [key: string]: any;
}

export interface LaporanGenerated {
  success: boolean;
  message: string;
}
