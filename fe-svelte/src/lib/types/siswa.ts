export interface Siswa {
  nis: string;
  nama: string;
  gender: string;
  tanggal_lahir: string;
  tanggalLahir?: string;
  alamat: string;
  id_ortu?: number;
  id_kelas: number;
  idKelas?: number;
  kelas?: Kelas;
  // Extended fields used in MulaiAbsensi and other pages
  status_kehadiran?: string;
  keterangan?: string;
}

export interface Kelas {
  id_kelas: number;
  idKelas?: number;
  nip?: string;
  nama_kelas?: string;
  kelas?: string;
  kode_kelas?: string;
  kodeKelas?: string;
  guru?: string;
}
