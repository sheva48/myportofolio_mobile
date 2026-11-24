Nama: Sheva Aquila Mahardika  
NPM: 2506622033  
Kelas: A

### Tugas 7

1. **Apa itu widget tree dan hubungan parent-child?**

   Widget tree adalah susunan widget yang membentuk tampilan Flutter secara bertingkat. Parent adalah widget pembungkus, sedangkan child adalah widget di dalamnya. `child` dipakai untuk satu anak, sementara `children` untuk beberapa anak.

   Di proyek ini, `MyApp` membangun `MaterialApp` dengan halaman awal `MyHomePage`. Halaman tersebut memakai `Scaffold`, lalu menyusun kartu profil dalam `Row` dan kartu aksi dalam `GridView.count`. Parent juga mengirim data ke child, misalnya judul dan isi untuk `InfoCard`.

2. **Widget apa saja yang dipakai dan apa fungsinya?**

   Berikut widget yang disusun langsung dalam kode proyek:

   - `MyApp`: Membungkus konfigurasi aplikasi.
   - `MaterialApp`: Mengatur tema, judul, dan halaman awal.
   - `MyHomePage`: Menyusun halaman profil dan menu.
   - `Scaffold`: Menyediakan kerangka halaman.
   - `AppBar`: Menampilkan judul di bagian atas.
   - `SingleChildScrollView`: Membuat halaman bisa digulir.
   - `Padding`: Memberi jarak di sekitar child.
   - `Column`: Menyusun widget secara vertikal.
   - `Row`: Menyusun widget secara horizontal.
   - `Flexible`: Menyesuaikan ruang kartu dalam Row.
   - `SizedBox`: Memberi jarak antarwidget.
   - `Center`: Memusatkan posisi child.
   - `GridView.count`: Menyusun kartu aksi dalam tiga kolom.
   - `InfoCard`: Menampilkan NPM, nama, dan kelas.
   - `Card`: Memberi tampilan kartu pada profil.
   - `Container`: Mengatur ukuran dan padding kartu.
   - `Text`: Menampilkan teks.
   - `ItemCard`: Menampilkan kartu aksi yang bisa ditekan.
   - `Material`: Memberi warna dan permukaan efek sentuhan.
   - `InkWell`: Menangani ketukan dan efek sentuhan.
   - `Icon`: Menampilkan ikon tombol.
   - `SnackBar`: Menampilkan pesan setelah tombol ditekan.

   Kode juga mengakses `Theme` untuk tema, `MediaQuery` untuk ukuran layar, dan `ScaffoldMessenger` untuk mengatur SnackBar. Ketiganya tersedia dari tree aplikasi. `StatelessWidget` menjadi kelas dasar widget buatan sendiri, sedangkan `ItemHomepage` adalah model data, bukan widget.

3. **Apa fungsi MaterialApp dan kenapa biasanya menjadi root widget?**

   `MaterialApp` menyediakan pengaturan aplikasi Material Design, seperti tema, halaman awal, dan navigasi. Biasanya dipasang dekat akar tree supaya halaman di bawahnya memakai pengaturan yang sama.

   Di proyek ini, widget tersebut mengatur judul MyPortfolio, tema indigo, dan halaman awal `MyHomePage`. Sebenarnya `runApp()` menerima `MyApp`, lalu `MyApp` membangun `MaterialApp` sebagai pembungkus utama.

4. **Apa bedanya StatelessWidget dan StatefulWidget?**

   `StatelessWidget` tidak mengelola state internal yang berubah. Cocok untuk komponen seperti `InfoCard` dan `ItemCard`. Widget ini tetap bisa dibangun ulang ketika konfigurasi dari parent atau tema berubah.

   `StatefulWidget` memiliki objek `State` untuk menyimpan data yang berubah selama digunakan. Perubahan lewat `setState()` menjadwalkan rebuild, misalnya untuk penghitung atau status loading.

   Di proyek ini, tombol cukup stateless karena hanya menjalankan callback dan meminta `ScaffoldMessenger` menampilkan SnackBar. Kalau nanti halaman mengelola daftar proyek yang berubah secara lokal, saya bisa memakai StatefulWidget.

5. **Apa itu BuildContext dan penggunaannya dalam build?**

   `BuildContext` menunjukkan posisi widget dalam tree. Parameter ini diberikan pada `build(BuildContext context)` untuk mengakses data atau layanan dari ancestor yang sesuai.

   Di proyek ini, `Theme.of(context)` mengambil tema, `MediaQuery.sizeOf(context)` membaca ukuran layar, dan `ScaffoldMessenger.of(context)` mengatur SnackBar. Posisi context penting karena pencarian menuju ancestor, sehingga layanan yang berada di bawah context tersebut belum bisa ditemukan.

6. **Apa bedanya hot reload, hot restart, dan full restart?**

   Hot reload menerapkan perubahan kode dan membangun ulang tampilan sambil mempertahankan state. Cocok untuk mengubah teks atau layout, tetapi tidak menjalankan ulang `main()` dan `initState()`.

   Hot restart memulai ulang aplikasi Flutter dan mereset state di memori. Ini diperlukan untuk menjalankan ulang inisialisasi di `main()` atau `initState()`, mengubah initializer global/static yang sudah dipakai, atau perubahan tipe yang ditolak hot reload.

   Full restart menghentikan lalu menjalankan kembali aplikasi beserta proses build yang diperlukan. Ini dibutuhkan untuk perubahan kode native seperti Kotlin atau Swift, atau plugin yang memerlukan kompilasi native. Hot reload dan hot restart digunakan dalam mode debug.

**AI Disclosure**

Untuk Tugas 7 saya memakai AI (Codex) buat membantu men guide dan menulis perubahan profil, warna kartu aksi, widget test, dan draf jawaban reflektif. Saya memberikan identitas dan meminta untuk diberikan contoh. Jawaban dicocokkan dengan kode dan dokumentasi Flutter. Pemeriksaan kode menghasilkan `No issues found` dan minta di cek apakah empat widget test lulus.

Contoh prompt yang saya gunakan:

- tolong kasih opsi pengerjaan nya mau pakai method yang kayak gimana biar mudah di kerjakan




### Tugas 8


1. `Navigator.push()` menambahkan halaman baru ke tumpukan navigasi, sehingga pengguna bisa kembali ke halaman sebelumnya. `Navigator.pushReplacement()` mengganti halaman aktif, sedangkan `Navigator.pop()` menutup halaman paling atas. Kartu **Tambah Sertifikasi** menggunakan `Navigator.push()`. Pada opsi **Home** di drawer, `Navigator.pop()` menutup drawer terlebih dahulu, lalu `Navigator.pushReplacement()` mengganti halaman formulir dengan `MyHomePage`.

2. `Scaffold` menyediakan struktur dasar halaman, `AppBar` menampilkan judul dan akses drawer, sedangkan `Drawer` menyediakan menu navigasi yang sama antarhalaman. Contohnya, AppBar halaman utama dan formulir sertifikasi sama-sama menggunakan `Theme.of(context).colorScheme.primary`, sehingga warna tema indigo tetap konsisten.

3. Formulir menggunakan `Column` agar input tersusun vertikal dan mudah diisi. `Padding` memberi jarak dari tepi layar, sedangkan `SizedBox` memberi jarak antarinput dan tombol. `SingleChildScrollView` memungkinkan formulir digulir saat layar sempit atau keyboard muncul, sehingga tombol **Simpan** tetap dapat dijangkau. `SafeArea` menjaga isi halaman dari area sistem perangkat.

4. `GlobalKey<FormState>` digunakan untuk mengakses keadaan formulir. Saat **Simpan** ditekan, `validate()` menjalankan `validator` setiap kolom. Jika semuanya valid, isian disimpan melalui `save()` dan ditampilkan dalam dialog. Contohnya, `example.com` ditolak karena URL kredensial harus menggunakan `http://` atau `https://`. Papan ketik URL hanya mempermudah pengetikan; pengguna tetap bisa mengetik atau menempelkan nilai yang salah, sehingga validasi tetap diperlukan.



**AI Disclosure**


Saya menggunakan ChatGPT untuk membantu memahami konsep navigasi Flutter, struktur halaman, validasi formulir, dan dialog ringkasan. AI juga membantu menyusun implementasi formulir sertifikasi serta pengujiannya. Penjelasan konsep digunakan sebagai pendamping untuk memahami alur kode yang diterapkan

Contoh prompt yang saya gunakan:

- “Apa perbedaan Navigator.push(), pushReplacement(), dan pop()? Kapan masing-masing digunakan?”
- “Bagaimana hubungan GlobalKey<FormState>, validator, dan validate() dalam validasi formulir Flutter?”
- “Mengapa formulir perlu menggunakan SingleChildScrollView saat layar sempit atau keyboard muncul?”