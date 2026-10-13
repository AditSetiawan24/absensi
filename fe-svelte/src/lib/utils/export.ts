import * as XLSX from 'xlsx';
import { downloadBlob } from './download';

export interface LaporanExportData {
  tahunAjar?: string;
  tahun_ajar?: string;
  semester?: string | number;
  periodeAwal?: string;
  periode_awal?: string;
  periodeAkhir?: string;
  periode_akhir?: string;
  hadir?: number;
  total_hadir?: number;
  izin?: number;
  total_izin?: number;
  sakit?: number;
  total_sakit?: number;
  alfa?: number;
  total_alfa?: number;
  nama_kelas?: string;
  kelas?: any;
}

export function resolveTahunAjar(laporan: LaporanExportData | any): string {
  if (laporan?.tahunAjar && laporan.tahunAjar !== '-') return String(laporan.tahunAjar);
  if (laporan?.tahun_ajar && laporan.tahun_ajar !== '-') return String(laporan.tahun_ajar);
  if (laporan?.kelas?.tahun_ajar && laporan.kelas?.tahun_ajar !== '-') return String(laporan.kelas.tahun_ajar);
  if (laporan?.kelas?.tahunAjar && laporan.kelas?.tahunAjar !== '-') return String(laporan.kelas.tahunAjar);
  const p = laporan?.periodeAwal || laporan?.periode_awal;
  if (p) {
    const parts = String(p).split('-');
    if (parts.length >= 2) {
      const year = parseInt(parts[0], 10);
      const month = parseInt(parts[1], 10);
      if (!isNaN(year) && !isNaN(month)) {
        return month >= 7 ? `${year}/${year + 1}` : `${year - 1}/${year}`;
      }
    }
  }
  const now = new Date();
  const y = now.getFullYear();
  const m = now.getMonth() + 1;
  return m >= 7 ? `${y}/${y + 1}` : `${y - 1}/${y}`;
}

export function resolveSemester(laporan: LaporanExportData | any): string {
  if (laporan?.semester === 1 || laporan?.semester === '1') {
    return 'Semester Ganjil';
  }
  if (laporan?.semester === 2 || laporan?.semester === '2') {
    return 'Semester Genap';
  }
  if (typeof laporan?.semester === 'string' && laporan.semester.trim() !== '' && laporan.semester !== '-') {
    const s = laporan.semester.trim();
    if (s.toLowerCase().includes('ganjil')) return 'Semester Ganjil';
    if (s.toLowerCase().includes('genap')) return 'Semester Genap';
    return s.startsWith('Semester') ? s : `Semester ${s}`;
  }
  const p = laporan?.periodeAwal || laporan?.periode_awal;
  if (p) {
    const parts = String(p).split('-');
    if (parts.length >= 2) {
      const month = parseInt(parts[1], 10);
      if (!isNaN(month)) {
        return month >= 7 ? 'Semester Ganjil' : 'Semester Genap';
      }
    }
  }
  const now = new Date();
  const m = now.getMonth() + 1;
  return m >= 7 ? 'Semester Ganjil' : 'Semester Genap';
}

export function resolvePeriode(laporan: LaporanExportData | any): string {
  const pAwal = laporan?.periodeAwal || laporan?.periode_awal;
  const pAkhir = laporan?.periodeAkhir || laporan?.periode_akhir;
  if (pAwal && pAkhir) {
    return `${pAwal} s/d ${pAkhir}`;
  }
  if (pAwal) return `${pAwal}`;
  const now = new Date();
  const y = now.getFullYear();
  const m = now.getMonth() + 1;
  return m >= 7 ? `${y}-07-01 s/d ${y}-12-31` : `${y}-01-01 s/d ${y}-06-30`;
}

export function exportLaporanToExcel(laporan: LaporanExportData, kelasName: string) {
  const hadir = laporan.hadir ?? laporan.total_hadir ?? 0;
  const izin = laporan.izin ?? laporan.total_izin ?? 0;
  const sakit = laporan.sakit ?? laporan.total_sakit ?? 0;
  const alfa = laporan.alfa ?? laporan.total_alfa ?? 0;
  const total = hadir + izin + sakit + alfa;

  const pctHadir = total > 0 ? ((hadir / total) * 100).toFixed(1) : '0';
  const pctIzin = total > 0 ? ((izin / total) * 100).toFixed(1) : '0';
  const pctSakit = total > 0 ? ((sakit / total) * 100).toFixed(1) : '0';
  const pctAlfa = total > 0 ? ((alfa / total) * 100).toFixed(1) : '0';

  const tahunAjar = resolveTahunAjar(laporan);
  const semester = resolveSemester(laporan);
  const periode = resolvePeriode(laporan);
  const safeKelas = kelasName || laporan.nama_kelas || (laporan.kelas?.kelas ? `Kelas ${laporan.kelas.kelas}` : (laporan.kelas?.nama_kelas ? `Kelas ${laporan.kelas.nama_kelas}` : '-'));

  const wb = XLSX.utils.book_new();
  const rows = [
    ['LAPORAN KEHADIRAN SISWA'],
    ['SD Negeri Kemutug Kidul'],
    [],
    ['Kelas', safeKelas],
    ['Tahun Ajaran', tahunAjar],
    ['Semester', semester],
    ['Periode', periode],
    [],
    ['Status', 'Jumlah', 'Persentase'],
    ['Hadir', hadir, `${pctHadir}%`],
    ['Izin', izin, `${pctIzin}%`],
    ['Sakit', sakit, `${pctSakit}%`],
    ['Alfa', alfa, `${pctAlfa}%`],
    ['TOTAL', total, '100%']
  ];

  const ws = XLSX.utils.aoa_to_sheet(rows);
  ws['!cols'] = [
    { wch: 18 },
    { wch: 30 },
    { wch: 15 }
  ];

  XLSX.utils.book_append_sheet(wb, ws, 'Laporan Kehadiran');
  const wbout = XLSX.write(wb, { bookType: 'xlsx', type: 'array' });
  const blob = new Blob([wbout], { type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' });

  const safeTa = tahunAjar.replace(/[/\\?%*:|"<>]/g, '-');
  const safeSem = semester.replace(/\s+/g, '_');
  const filename = `Laporan_Kehadiran_${safeTa}_${safeSem}.xlsx`;

  downloadBlob(blob, filename);
}

export function printLaporanPdf(laporan: LaporanExportData, kelasName: string) {
  const hadir = laporan.hadir ?? laporan.total_hadir ?? 0;
  const izin = laporan.izin ?? laporan.total_izin ?? 0;
  const sakit = laporan.sakit ?? laporan.total_sakit ?? 0;
  const alfa = laporan.alfa ?? laporan.total_alfa ?? 0;
  const total = hadir + izin + sakit + alfa;

  const pctHadir = total > 0 ? ((hadir / total) * 100).toFixed(1) : '0.0';
  const pctIzin = total > 0 ? ((izin / total) * 100).toFixed(1) : '0.0';
  const pctSakit = total > 0 ? ((sakit / total) * 100).toFixed(1) : '0.0';
  const pctAlfa = total > 0 ? ((alfa / total) * 100).toFixed(1) : '0.0';

  const tahunAjar = resolveTahunAjar(laporan);
  const semester = resolveSemester(laporan);
  const periode = resolvePeriode(laporan);
  const safeKelas = kelasName || laporan.nama_kelas || (laporan.kelas?.kelas ? `Kelas ${laporan.kelas.kelas}` : (laporan.kelas?.nama_kelas ? `Kelas ${laporan.kelas.nama_kelas}` : '-'));

  const todayStr = new Intl.DateTimeFormat('id-ID', { dateStyle: 'long' }).format(new Date());

  const html = `
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>Laporan Kehadiran Siswa</title>
  <style>
    @page { size: A4; margin: 20mm; }
    body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Arial, sans-serif; color: #222; margin: 0; padding: 20px; }
    .header { text-align: center; margin-bottom: 24px; border-bottom: 2px solid #333; padding-bottom: 12px; }
    .header h1 { font-size: 18pt; margin: 0 0 6px; text-transform: uppercase; letter-spacing: 0.5px; }
    .header h2 { font-size: 14pt; font-weight: normal; margin: 0; color: #444; }
    .info-box { border: 1px solid #ccc; border-radius: 6px; padding: 12px 16px; margin-bottom: 24px; background: #fafafa; }
    .info-row { display: flex; justify-content: space-between; margin-bottom: 6px; font-size: 11pt; }
    .info-row:last-child { margin-bottom: 0; }
    table { width: 100%; border-collapse: collapse; margin-bottom: 20px; font-size: 11pt; }
    th, td { border: 1px solid #ddd; padding: 10px 14px; text-align: left; }
    th { background: #f0f4f8; font-weight: 600; }
    td.num { text-align: right; }
    tr.total { font-weight: bold; background: #f9f9f9; }
    .summary { font-size: 12pt; font-weight: 600; margin-bottom: 40px; }
    .footer { display: flex; justify-content: flex-end; margin-top: 40px; }
    .signature { text-align: center; width: 220px; }
    .signature .date { margin-bottom: 8px; font-size: 11pt; }
    .signature .role { margin-bottom: 60px; font-size: 11pt; }
    .signature .line { border-bottom: 1px solid #333; }
  </style>
</head>
<body>
  <div class="header">
    <h1>LAPORAN KEHADIRAN SISWA</h1>
    <h2>SD Negeri Kemutug Kidul</h2>
  </div>

  <div class="info-box">
    <div class="info-row">
      <span><strong>Kelas:</strong> ${safeKelas}</span>
      <span><strong>Tahun Ajaran:</strong> ${tahunAjar}</span>
    </div>
    <div class="info-row">
      <span><strong>Semester:</strong> ${semester}</span>
      <span><strong>Periode:</strong> ${periode}</span>
    </div>
  </div>

  <table>
    <thead>
      <tr>
        <th>Status</th>
        <th style="text-align: right;">Jumlah</th>
        <th style="text-align: right;">Persentase</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td>Hadir</td>
        <td class="num">${hadir}</td>
        <td class="num">${pctHadir}%</td>
      </tr>
      <tr>
        <td>Izin</td>
        <td class="num">${izin}</td>
        <td class="num">${pctIzin}%</td>
      </tr>
      <tr>
        <td>Sakit</td>
        <td class="num">${sakit}</td>
        <td class="num">${pctSakit}%</td>
      </tr>
      <tr>
        <td>Alfa</td>
        <td class="num">${alfa}</td>
        <td class="num">${pctAlfa}%</td>
      </tr>
      <tr class="total">
        <td>TOTAL</td>
        <td class="num">${total}</td>
        <td class="num">100%</td>
      </tr>
    </tbody>
  </table>

  <div class="summary">
    Tingkat Kehadiran: ${pctHadir}%
  </div>

  <div class="footer">
    <div class="signature">
      <div class="date">Kemutug Kidul, ${todayStr}</div>
      <div class="role">Wali Kelas</div>
      <div class="line"></div>
    </div>
  </div>

  <script>
    window.onload = function() {
      window.print();
    };
  <\/script>
</body>
</html>
  `;

  const printWindow = window.open('', '_blank');
  if (printWindow) {
    printWindow.document.open();
    printWindow.document.write(html);
    printWindow.document.close();
  }
}

export interface RekapExportData {
  bulan?: number | string;
  namaBulan?: string;
  nama_bulan?: string;
  tahun?: number | string;
  periodeAwal?: string;
  periode_awal?: string;
  periodeAkhir?: string;
  periode_akhir?: string;
  hadir?: number;
  total_hadir?: number;
  totalHadir?: number;
  izin?: number;
  total_izin?: number;
  totalIzin?: number;
  sakit?: number;
  total_sakit?: number;
  totalSakit?: number;
  alfa?: number;
  total_alfa?: number;
  totalAlfa?: number;
  file_url?: string;
  nama_kelas?: string;
  kelas?: any;
}

const BULAN_NAMES = [
  '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
  'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
];

export function resolveNamaBulan(rekap: RekapExportData | any): string {
  if (rekap?.namaBulan && rekap.namaBulan !== '-') return String(rekap.namaBulan);
  if (rekap?.nama_bulan && rekap.nama_bulan !== '-') return String(rekap.nama_bulan);
  if (typeof rekap?.bulan === 'number' && rekap.bulan >= 1 && rekap.bulan <= 12) {
    return BULAN_NAMES[rekap.bulan];
  }
  if (typeof rekap?.bulan === 'string') {
    const num = parseInt(rekap.bulan, 10);
    if (!isNaN(num) && num >= 1 && num <= 12) {
      return BULAN_NAMES[num];
    }
  }
  const p = rekap?.periodeAwal || rekap?.periode_awal;
  if (p) {
    const parts = String(p).split('-');
    if (parts.length >= 2) {
      const monthNum = parseInt(parts[1], 10);
      if (!isNaN(monthNum) && monthNum >= 1 && monthNum <= 12) {
        return BULAN_NAMES[monthNum];
      }
    }
  }
  return '-';
}

export function resolveTahunRekap(rekap: RekapExportData | any): string {
  if (rekap?.tahun && String(rekap.tahun) !== '-') return String(rekap.tahun);
  const p = rekap?.periodeAwal || rekap?.periode_awal;
  if (p) {
    const parts = String(p).split('-');
    if (parts.length >= 1 && parts[0]) {
      return parts[0];
    }
  }
  return String(new Date().getFullYear());
}

export function exportRekapToExcel(rekap: RekapExportData, kelasName: string) {
  const hadir = rekap.hadir ?? rekap.total_hadir ?? rekap.totalHadir ?? 0;
  const izin = rekap.izin ?? rekap.total_izin ?? rekap.totalIzin ?? 0;
  const sakit = rekap.sakit ?? rekap.total_sakit ?? rekap.totalSakit ?? 0;
  const alfa = rekap.alfa ?? rekap.total_alfa ?? rekap.totalAlfa ?? 0;
  const total = hadir + izin + sakit + alfa;

  const pctHadir = total > 0 ? ((hadir / total) * 100).toFixed(1) : '0';
  const pctIzin = total > 0 ? ((izin / total) * 100).toFixed(1) : '0';
  const pctSakit = total > 0 ? ((sakit / total) * 100).toFixed(1) : '0';
  const pctAlfa = total > 0 ? ((alfa / total) * 100).toFixed(1) : '0';

  const namaBulan = resolveNamaBulan(rekap);
  const tahun = resolveTahunRekap(rekap);
  const periode = resolvePeriode(rekap);
  const safeKelas = kelasName || rekap.nama_kelas || (rekap.kelas?.kelas ? `Kelas ${rekap.kelas.kelas}` : (rekap.kelas?.nama_kelas ? `Kelas ${rekap.kelas.nama_kelas}` : '-'));

  const wb = XLSX.utils.book_new();
  const rows = [
    ['REKAP KEHADIRAN BULANAN'],
    ['SD Negeri Kemutug Kidul'],
    [],
    ['Kelas', safeKelas],
    ['Bulan', `${namaBulan} ${tahun}`],
    ['Periode', periode],
    [],
    ['Status', 'Jumlah', 'Persentase'],
    ['Hadir', hadir, `${pctHadir}%`],
    ['Izin', izin, `${pctIzin}%`],
    ['Sakit', sakit, `${pctSakit}%`],
    ['Alfa', alfa, `${pctAlfa}%`],
    ['TOTAL', total, '100%']
  ];

  const ws = XLSX.utils.aoa_to_sheet(rows);
  ws['!cols'] = [
    { wch: 18 },
    { wch: 30 },
    { wch: 15 }
  ];

  XLSX.utils.book_append_sheet(wb, ws, 'Rekap Bulanan');
  const wbout = XLSX.write(wb, { bookType: 'xlsx', type: 'array' });
  const blob = new Blob([wbout], { type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' });
  const filename = `Rekap_${namaBulan}_${tahun}.xlsx`;

  downloadBlob(blob, filename);
}

export function printRekapPdf(rekap: RekapExportData, kelasName: string) {
  const hadir = rekap.hadir ?? rekap.total_hadir ?? rekap.totalHadir ?? 0;
  const izin = rekap.izin ?? rekap.total_izin ?? rekap.totalIzin ?? 0;
  const sakit = rekap.sakit ?? rekap.total_sakit ?? rekap.totalSakit ?? 0;
  const alfa = rekap.alfa ?? rekap.total_alfa ?? rekap.totalAlfa ?? 0;
  const total = hadir + izin + sakit + alfa;

  const pctHadir = total > 0 ? ((hadir / total) * 100).toFixed(1) : '0.0';
  const pctIzin = total > 0 ? ((izin / total) * 100).toFixed(1) : '0.0';
  const pctSakit = total > 0 ? ((sakit / total) * 100).toFixed(1) : '0.0';
  const pctAlfa = total > 0 ? ((alfa / total) * 100).toFixed(1) : '0.0';

  const namaBulan = resolveNamaBulan(rekap);
  const tahun = resolveTahunRekap(rekap);
  const periode = resolvePeriode(rekap);
  const safeKelas = kelasName || rekap.nama_kelas || (rekap.kelas?.kelas ? `Kelas ${rekap.kelas.kelas}` : (rekap.kelas?.nama_kelas ? `Kelas ${rekap.kelas.nama_kelas}` : '-'));

  const todayStr = new Intl.DateTimeFormat('id-ID', { dateStyle: 'long' }).format(new Date());

  const html = `
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>Rekap Kehadiran Bulanan</title>
  <style>
    @page { size: A4; margin: 20mm; }
    body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Arial, sans-serif; color: #222; margin: 0; padding: 20px; }
    .header { text-align: center; margin-bottom: 24px; border-bottom: 2px solid #333; padding-bottom: 12px; }
    .header h1 { font-size: 18pt; margin: 0 0 6px; text-transform: uppercase; letter-spacing: 0.5px; }
    .header h2 { font-size: 14pt; font-weight: normal; margin: 0; color: #444; }
    .info-box { border: 1px solid #ccc; border-radius: 6px; padding: 12px 16px; margin-bottom: 24px; background: #fafafa; }
    .info-row { display: flex; justify-content: space-between; margin-bottom: 6px; font-size: 11pt; }
    .info-row:last-child { margin-bottom: 0; }
    table { width: 100%; border-collapse: collapse; margin-bottom: 20px; font-size: 11pt; }
    th, td { border: 1px solid #ddd; padding: 10px 14px; text-align: left; }
    th { background: #f0f4f8; font-weight: 600; }
    td.num { text-align: right; }
    tr.total { font-weight: bold; background: #f9f9f9; }
    .summary { font-size: 12pt; font-weight: 600; margin-bottom: 40px; }
    .footer { display: flex; justify-content: flex-end; margin-top: 40px; }
    .signature { text-align: center; width: 220px; }
    .signature .date { margin-bottom: 8px; font-size: 11pt; }
    .signature .role { margin-bottom: 60px; font-size: 11pt; }
    .signature .line { border-bottom: 1px solid #333; }
  </style>
</head>
<body>
  <div class="header">
    <h1>REKAP KEHADIRAN BULANAN</h1>
    <h2>SD Negeri Kemutug Kidul</h2>
  </div>

  <div class="info-box">
    <div class="info-row">
      <span><strong>Kelas:</strong> ${safeKelas}</span>
      <span><strong>Bulan:</strong> ${namaBulan} ${tahun}</span>
    </div>
    <div class="info-row">
      <span><strong>Periode:</strong> ${periode}</span>
      <span></span>
    </div>
  </div>

  <table>
    <thead>
      <tr>
        <th>Status</th>
        <th style="text-align: right;">Jumlah</th>
        <th style="text-align: right;">Persentase</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td>Hadir</td>
        <td class="num">${hadir}</td>
        <td class="num">${pctHadir}%</td>
      </tr>
      <tr>
        <td>Izin</td>
        <td class="num">${izin}</td>
        <td class="num">${pctIzin}%</td>
      </tr>
      <tr>
        <td>Sakit</td>
        <td class="num">${sakit}</td>
        <td class="num">${pctSakit}%</td>
      </tr>
      <tr>
        <td>Alfa</td>
        <td class="num">${alfa}</td>
        <td class="num">${pctAlfa}%</td>
      </tr>
      <tr class="total">
        <td>TOTAL</td>
        <td class="num">${total}</td>
        <td class="num">100%</td>
      </tr>
    </tbody>
  </table>

  <div class="summary">
    Tingkat Kehadiran: ${pctHadir}%
  </div>

  <div class="footer">
    <div class="signature">
      <div class="date">Kemutug Kidul, ${todayStr}</div>
      <div class="role">Wali Kelas</div>
      <div class="line"></div>
    </div>
  </div>

  <script>
    window.onload = function() {
      window.print();
    };
  <\/script>
</body>
</html>
  `;

  const printWindow = window.open('', '_blank');
  if (printWindow) {
    printWindow.document.open();
    printWindow.document.write(html);
    printWindow.document.close();
  }
}
