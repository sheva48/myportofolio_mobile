# myportofolio_mobile

Hasil Tutorial 08: Basic Flutter, Pemrograman Berbasis Platform UI,
Semester Gasal 2026/2027. Proyek Flutter ini terpisah dari backend Django
`myportofolio`.

## Menjalankan di macOS dan VS Code

Flutter SDK sudah menyertakan Dart SDK. Pastikan direktori `flutter/bin`
terdaftar pada PATH dan ekstensi resmi Flutter serta Dart terpasang di VS Code.
Buka folder ini sebagai root proyek.

```sh
flutter --version
dart --version
flutter doctor -v
flutter pub get
flutter devices
flutter run -d chrome
```

Pilih konfigurasi **MyPortfolio (Chrome)** di panel Run and Debug VS Code,
atau gunakan perintah terminal di atas. Target pengujian tutorial ini adalah
Google Chrome. Android SDK diperlukan saat membangun aplikasi Android;
Xcode lengkap dan CocoaPods diperlukan untuk pengembangan native Apple.

## Implementasi Tutorial 08

- `lib/main.dart`: titik masuk, `MyApp`, dan tema Material 3 dengan seed
  `Colors.indigo` serta secondary `Colors.amber[700]`.
- `lib/menu.dart`: halaman `MyHomePage` berupa `StatelessWidget`, widget
  `InfoCard`, model `ItemHomepage`, dan widget interaktif `ItemCard`.
- Identitas contoh: NPM **2406000001**, nama **Burhan**, kelas **PBP A**.
- Tiga tombol: **Lihat Proyek**, **Tambah Proyek**, dan **Logout**.
- Setiap tombol menampilkan `Kamu telah menekan tombol <nama tombol>!`
  melalui `SnackBar`. Tombol pada tahap tutorial ini belum melakukan navigasi
  atau logout sesungguhnya.
- Tampilan mengacu pada halaman 29: AppBar indigo, tiga kartu identitas,
  sambutan, dan tiga kartu aksi amber dengan ikon putih.
- Penyesuaian untuk mencegah overflow: lebar InfoCard dibatasi `Flexible`,
  halaman dapat di-scroll, dan kartu aksi diberi tinggi tambahan pada layar
  di bawah 400 piksel. Pada ukuran contoh, kartu aksi tetap berbentuk persegi.

Individual Assignment 7 belum dikerjakan. Identitas dan menu tetap menggunakan
contoh Burhan; belum ada integrasi API Django.

## Pemeriksaan

Lingkungan yang digunakan: Flutter **3.47.9 stable**, Dart **3.13.7**,
macOS Apple Silicon, dan Google Chrome. `flutter analyze` bersih dan
keempat widget test lulus. Ketiga SnackBar juga diuji langsung di Chrome.

```sh
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

Widget test memeriksa identitas, pesan ketiga tombol, dan penggunaan menu
pada ukuran layar ponsel serta browser desktop.

## Pengumpulan ke SCELE

Gunakan repositori GitHub publik baru bernama `myportofolio_mobile`.
Tautan yang dikumpulkan harus menuju **commit hasil akhir**, dengan format:

```text
https://github.com/<username>/myportofolio_mobile/commit/<hash-commit>
```

Hash commit dapat diperiksa dengan `git rev-parse HEAD`. Pastikan commit
tersebut sudah di-push dan dapat diakses publik sebelum mengumpulkan link.
Folder `build/` dan `.dart_tool/` diabaikan oleh Git.
