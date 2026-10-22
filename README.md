# Dapur Dunia

Aplikasi katalog resep makanan dunia berbasis Flutter yang mengambil data secara dinamis dari [TheMealDB API](https://www.themealdb.com/api.php).

Proyek ini dibuat sebagai tugas Ujian Tengah Semester (UTS) mata kuliah Pemrograman Mobile, Praktikum Mobile Programming Kelas G.

## Deskripsi Singkat

Dapur Dunia membantu pengguna menemukan ide masakan. Pengguna dapat menjelajahi resep berdasarkan kategori, mencari resep berdasarkan nama, melihat daftar bahan beserta takarannya, membaca langkah memasak, dan mendapatkan resep acak saat bingung memilih menu. Seluruh data berasal dari API publik tanpa API key, sehingga aplikasi selalu menampilkan data terbaru dari server.

## Fitur Utama

- **Daftar resep per kategori**: resep ditampilkan dalam grid berisi foto dan nama. Kategori (Beef, Chicken, Dessert, dan lainnya) diambil langsung dari API.
- **Pencarian resep**: cari resep berdasarkan nama, misalnya `pasta` atau `chicken`.
- **Detail resep**: foto, kategori, asal negara, tag, daftar bahan beserta takaran, langkah memasak, dan tautan video tutorial.
- **Resep acak**: tombol dadu di pojok kanan atas untuk membuka satu resep secara acak.
- **Penanganan kondisi pengambilan data**: tampilan Loading, Success, dan Error (dengan tombol *Coba Lagi*) menggunakan `FutureBuilder`, ditambah tampilan khusus saat hasil kosong.
- **Tarik untuk memuat ulang** (pull to refresh) pada daftar resep.

## Teknologi dan Package

| Teknologi / Package | Kegunaan |
|---|---|
| Flutter dan Dart | Kerangka kerja dan bahasa pemrograman aplikasi |
| [`http`](https://pub.dev/packages/http) | Mengirim permintaan HTTP GET ke API |
| `flutter_lints` (dev) | Aturan analisis kode agar gaya penulisan konsisten |
| `flutter_test` (dev) | Pengujian unit |
| TheMealDB API | Sumber data resep |

Konsep yang diterapkan: *asynchronous programming* (`Future`, `async`/`await`), `FutureBuilder`, model class dengan `fromJson`, pemisahan lapisan (model, service, screen, widget), dan Material 3.

## Struktur Folder

```
lib/
├── main.dart                      # Titik masuk aplikasi
├── models/
│   ├── meal.dart                  # Model Meal dan Ingredient
│   └── meal_category.dart         # Model MealCategory
├── services/
│   └── meal_api_service.dart      # Permintaan HTTP, pengecekan status, parsing JSON
├── screens/
│   ├── home_screen.dart           # Pencarian, filter kategori, grid resep
│   └── detail_screen.dart         # Detail resep
└── widgets/
    ├── meal_card.dart             # Kartu resep
    ├── meal_image.dart            # Gambar jaringan dengan loading dan fallback
    ├── loading_view.dart          # Tampilan loading
    └── error_view.dart            # Tampilan error dan tombol coba lagi
test/
├── meal_model_test.dart           # Pengujian parsing JSON ke model
└── meal_api_service_test.dart     # Pengujian service (respons sukses, kosong, error)
```

## Endpoint API yang Digunakan

Base URL: `https://www.themealdb.com/api/json/v1/1`

| Endpoint | Fungsi |
|---|---|
| `/categories.php` | Daftar kategori resep |
| `/filter.php?c={kategori}` | Daftar resep pada satu kategori |
| `/search.php?s={kata kunci}` | Pencarian resep berdasarkan nama |
| `/lookup.php?i={id}` | Detail lengkap satu resep |
| `/random.php` | Satu resep acak |

## Langkah Menjalankan Aplikasi

1. Pastikan [Flutter SDK](https://docs.flutter.dev/get-started/install) sudah terpasang, lalu periksa dengan `flutter doctor`.
2. Clone repositori ini:
   ```bash
   git clone https://github.com/Dwireski/dapur_dunia.git
   cd dapur_dunia
   ```
3. Unduh dependensi:
   ```bash
   flutter pub get
   ```
4. Hubungkan perangkat Android atau jalankan emulator, lalu jalankan aplikasi:
   ```bash
   flutter run
   ```
5. (Opsional) Jalankan pengujian unit:
   ```bash
   flutter test
   ```

Aplikasi memerlukan koneksi internet karena seluruh data diambil dari API.

## Pengembang

- Nama: Dwi Ahmad Reski
- NIM: 240605110245
- Program Studi Teknik Informatika
