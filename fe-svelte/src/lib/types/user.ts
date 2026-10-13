export interface User {
  id?: string | number;
  nip?: string;
  id_ortu?: number;
  nama: string;
  email: string;
  username?: string;
  no_hp?: string;
  noHp?: string;
  gender?: string;
  jenis_kelamin?: string;
  alamat?: string;
  role: string;
  status?: string;
}

export interface Guru extends User {}
export interface KepalaSekolah extends User {}
export interface OrangTua extends User {}
