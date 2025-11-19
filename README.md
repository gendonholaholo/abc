# HRIS Attendance App (Flutter)

A simple HRIS attendance application scaffolded for web/mobile with Flutter, featuring login, clock-in/out, attendance history, and leave requests. Docker assets are included for a production-grade web deployment using Flutter Web + Nginx.

## Fitur utama
- Login sederhana (mock) dan sesi karyawan.
- Clock-in / Clock-out dengan riwayat dan lokasi opsional.
- Rekap riwayat absensi.
- Pengajuan cuti (tahunan, sakit, tanpa bayar) dengan status awal pending.
- Arsitektur terpisah per fitur dengan Riverpod.

## Struktur proyek
```
lib/
  core/           # model, provider, service, tema dasar
  features/
    auth/         # layar login
    attendance/   # clock-in/out + riwayat ringkas
    history/      # riwayat lengkap
    leave/        # pengajuan cuti
  widgets/        # komponen umum (navigasi)
docker/           # Dockerfile, nginx.conf, entrypoint
```

## Menjalankan secara lokal
Pastikan Flutter SDK sudah terpasang.
```
flutter pub get
flutter run -d chrome
```

## Build Flutter Web
```
flutter build web --release
```

## Docker (produksi)
Build multi-stage image dan jalankan via Compose:
```
docker build -t hris-attendance -f docker/Dockerfile .
docker compose up -d
```

### Variabel lingkungan
Salin `.env.example` menjadi `.env` lalu sesuaikan:
- `APP_BASE_PATH`: prefix URL jika di-serve di subpath.
- `API_BASE_URL`: URL backend HRIS aktual (saat ini mock di sisi klien).

## Catatan produksi
- Nginx sudah dikonfigurasi untuk cache dan gzip dasar.
- Gunakan TLS termination (LetsEncrypt) di layer reverse proxy.
- Untuk skala, jalankan beberapa replica container di depan load balancer.
