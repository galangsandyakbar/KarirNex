# 📊 Analisis Penjualan FMCG — Data Cleaning, SQL, Excel & Power BI Dashboard

**Author:** Galang Sandy Akbar
**Program:** Bootcamp Data Analyst — KarirNex x Ebiz Karisma Internasional
**Tools:** Excel · SQL (SQLite) · Power BI

🔗 [LinkedIn](https://www.linkedin.com/in/galangsandyakbar) · 📧 [galangsandyakbar@gmail.com](mailto:galangsandyakbar@gmail.com)


---

## 1. Business Understanding

**Konteks.** Dataset ini mensimulasikan satu tahun transaksi (2025) dari sebuah retailer FMCG (*Fast-Moving Consumer Goods*) yang berjualan lewat tiga channel — **Offline**, **Online - Toko Oren**, dan **Online - Toko Hijau** — dengan tiga kategori produk: **Makanan**, **Pembersih**, dan **Perawatan**.

**Masalah bisnis.** Sebagai data mentah hasil ekspor, data ini "kotor" (*messy*): penulisan teks tidak konsisten, format tanggal campur aduk, quantity tidak valid, serta label channel & status yang tidak seragam. Ini adalah masalah data quality klasik yang harus dibereskan lebih dulu sebelum satu pun keputusan bisnis bisa diambil dari data ini dengan aman.

**Tujuan project.** Bertindak sebagai analyst untuk retailer ini, project ini menjawab tiga lapis pertanyaan bisnis:
1. **Metrik skala dasar** (jumlah kota, total revenue, volume order, basis pelanggan) — lewat **SQL**
2. **Performa pelanggan & kategori** (loyalitas, demand lintas channel) — lewat **Excel (Pivot Table & Chart)**
3. **Pertanyaan strategis & operasional** yang benar-benar relevan bagi pemilik toko FMCG — lewat **dashboard Power BI**

Alur kerja mengikuti kerangka **CRISP-DM**: Business Understanding → Data Understanding → Data Preparation → Analysis → Insight/Evaluation → Deployment (dashboard).

---

## 2. Data Understanding

- **Sumber:** `Data_FMCG_BT_Data_Analyst_-_Messy.csv`
- **Ukuran:** 20.000 baris × 15 kolom
- **Field utama:** `sales_date`, `order_id`, `product_name`, `category`, `price`, `quantity`, `discount`, `shipping_fee`, `total_sales`, `customer_name`, `customer_address` (kota), `channel`, `rating`, `status`

**Masalah kualitas data yang teridentifikasi saat audit:**

| Masalah | Contoh | Dampak ke Analisis |
|---|---|---|
| Penulisan teks tidak konsisten | `makanan` / `Makanan` / `MAKANAN` | Kategori "pecah" jadi banyak grup semu saat `GROUP BY` |
| Format tanggal campuran (text) | `MM/DD/YYYY` tersimpan sebagai string | Urutan waktu salah, gagal di-parse sebagai date |
| Quantity tidak valid | `-99`, `0` | Tidak masuk akal secara bisnis, mendistorsi total penjualan |
| Label channel tidak seragam | `Toko_Oren_Online` vs `Online - Toko Oren` | Performa channel under-counted |
| Duplikasi `order_id` | Baris identik lebih dari satu kali | Revenue & quantity ter-double count |
| Missing values | Kosong pada beberapa kolom numerik | Perlu direkalkulasi, bukan asal dihapus |

> **Catatan analitis:** setiap KPI yang dibangun di atas kategori yang belum distandarkan atau quantity yang tidak valid akan **diam-diam salah merepresentasikan revenue dan demand** — ini alasan utama kenapa tahap cleaning tidak boleh dilewati atau dianggap remeh sebelum EDA/dashboard dibuat.

---

## 3. Data Preparation (Cleaning & Transformation)

Proses cleaning dilakukan dengan dua pendekatan untuk menunjukkan fleksibilitas tools:

### 🔹 SQL (SQLite) — lihat [`Latihan1_sql.sql`](./Assets/Latihan1_sql.sql)
- Membuat tabel baru `fmcg_clean` dari tabel mentah `fmcg`
- Standardisasi format tanggal dari string ke `YYYY-MM-DD`:
  ```sql
  DATE(substr(sales_date,7,4) || '-' ||
       substr(sales_date,4,2) || '-' ||
       substr(sales_date,1,2)) AS sales_date
  ```
- Perbaikan quantity error dengan `CASE WHEN quantity = -99 THEN 1 ELSE quantity END`
- Standardisasi teks dengan `TRIM()` dan `UPPER()` pada kolom `product_name`, `category`, `customer_name`, `customer_address`, `channel`
- Rekalkulasi kolom turunan (bukan percaya pada nilai mentah):
  ```sql
  total       = price * quantity
  total_sales = (price * quantity) * (1 - discount) + shipping_fee
  ```
- Deteksi & penghapusan duplikat `order_id` (menyisakan `MIN(rowid)` per grup)
- Validasi ulang untuk memastikan tidak ada `quantity IS NULL` yang tersisa

### 🔹 Excel — lihat [`Data_FMCG_BT_Data_Analyst_-_Clean_Fix.xlsx`](./Assets/Data/Data_FMCG_BT_Data_Analyst_-_Clean_Fix.xlsx)
- `PROPER()` / `UPPER()` untuk menyeragamkan penulisan `product_name` dan `category`
- `Find & Replace` untuk menyamakan label `channel` dan `status`
- Pivot Table untuk agregasi pelanggan (jumlah order, total quantity, total belanja) dan performa kategori per channel
- Sheet `Pivot Data` dan `Dashboard` disiapkan sebagai staging area sebelum data ditarik ke Power BI

**Hasil akhir:** satu dataset bersih (20.000 baris, tanpa duplikat/null/quantity invalid) yang menjadi rujukan tunggal untuk seluruh analisis SQL, Excel, maupun dashboard — memastikan angka yang dilaporkan **konsisten di semua tools**, bukan sekadar konsisten di satu file saja.

---

## 4. Analysis & Key Findings

*(Seluruh angka di bawah telah diverifikasi ulang langsung dari dataset bersih, bukan hanya dikutip dari hasil query/pivot.)*

### 📌 Metrik fondasi (SQL)

| Metrik | Nilai |
|---|---|
| Jumlah kota (`customer_address`) | 15 kota |
| Total revenue (`total_sales`) | **Rp 875.574.250** |
| Total quantity terjual | 39.933 unit |
| Jumlah order via Online - Toko Hijau | 6.685 |
| Jumlah pelanggan unik | 93 |

### 📌 Performa pelanggan (Excel — Pivot & Chart)

**Top 10 Pelanggan Berdasarkan Jumlah Order**
![Top Customer by Total Order](https://github.com/galangsandyakbar/KarirNex/blob/b6cd4b1e9882b01ba85f99e5e8ceb5b8f018314d/Assets/Top%20Customer%20by%20Total%20Order.png)

**Top 10 Pelanggan Berdasarkan Total Belanja**
![Top Customer by Total Spend](https://github.com/galangsandyakbar/KarirNex/blob/b6cd4b1e9882b01ba85f99e5e8ceb5b8f018314d/Assets/Top%20Customer%20by%20Total%20Spend.png)

| Rank | Pelanggan (Order) | Jumlah Order | Pelanggan (Belanja) | Total Belanja |
|---|---|---|---|---|
| 1 | Eka | 418 | Wira | Rp 18.261.350 |
| 2 | Wira | 410 | Eka | Rp 17.838.650 |
| 3 | Yusuf | 389 | Yusuf | Rp 16.774.650 |

> **So what:** Eka, Wira, dan Yusuf konsisten menjadi **top 3 baik dari sisi frekuensi maupun nilai belanja** — bukan kebetulan bahwa pelanggan paling sering belanja juga paling besar nilainya. Ini mengindikasikan mereka adalah pelanggan **high-frequency & high-value sekaligus**, kandidat utama untuk program retensi/loyalitas prioritas, bukan sekadar diskon massal ke semua pelanggan.
>
> Perlu dicatat, gap antara top 3 (~Rp 17–18 juta, ~390–418 order) dengan peringkat 4–10 (~Rp 9,8–10,8 juta, ~234–244 order) **hampir dua kali lipat** — ini pola *Pareto* yang layak divalidasi lebih lanjut lewat segmentasi RFM (Recency, Frequency, Monetary), bukan cuma ranking sederhana.

### 📌 Performa kategori per channel (Excel — Pivot & Chart)

![Top Category per Channel](https://github.com/galangsandyakbar/KarirNex/blob/b6cd4b1e9882b01ba85f99e5e8ceb5b8f018314d/Assets/Top%20Category.png)

| Channel | Makanan | Pembersih | Perawatan |
|---|---|---|---|
| Offline | **Rp 114.146.400** | Rp 82.802.100 | Rp 96.116.300 |
| Online - Toko Hijau | **Rp 108.796.150** | Rp 85.059.000 | Rp 96.409.950 |
| Online - Toko Oren | **Rp 110.332.750** | Rp 85.143.950 | Rp 93.816.400 |

> **So what:** kategori **Makanan mendominasi di ketiga channel tanpa kecuali** — bukan cuma unggul di satu platform. Ini artinya Makanan adalah **structural demand driver** bisnis ini, terlepas dari jalur distribusinya. Implikasinya langsung ke alokasi stok, prioritas ruang rak/etalase, dan default budget promosi jika tidak ada sinyal lain.
>
> Namun, gap antar kategori (Makanan vs Perawatan vs Pembersih) **relatif tidak terlalu jauh** (rasio ~1.2–1.4x), berbeda dengan gap pelanggan yang jauh lebih tajam. Ini sinyal bahwa strategi "all-in ke Makanan" berisiko meninggalkan potensi upsell di Perawatan yang sebenarnya cukup kompetitif, terutama di channel Offline.

### 📌 Status pengiriman & risiko operasional (dari data bersih)

| Status | Jumlah Order |
|---|---|
| Gagal | 5.089 |
| Sukses | 5.043 |
| Dikembalikan | 4.998 |
| Tertunda | 4.870 |

> **Red flag:** hampir **51% order berstatus non-sukses** (Gagal + Dikembalikan + Tertunda ≈ 14.957 dari 20.000). Ini bukan angka kecil — kalau ini data riil, ini akan jadi prioritas #1 di atas pembahasan kategori produk manapun, karena tingkat kegagalan order sebesar ini mengindikasikan **masalah fulfillment/logistik sistemik**, bukan sekadar variasi acak.

---

## 5. Dashboard (Power BI)

File: [`Galang_Sandy_A_Power_BI_Sales_Dashboard.pbix`]((https://github.com/galangsandyakbar/KarirNex/blob/171d6d134b1b036b781b435a768cdee8bd242e75/Assets/Dashboard/Galang%20Sandy%20A_Power%20BI_Sales%20Dashboard.pbix))

**Layout:** `Card (KPI)` → `Matrix Table` → `3 visual inti` → `Slicer` (kategori, bulan, kota)

Tiga pertanyaan bisnis yang mendasari desain dashboard (dari sudut pandang pemilik toko):
1. **Produk apa yang paling berkontribusi terhadap revenue dan paling cepat habis?**
2. **Kota mana yang punya tingkat gagal/retur pengiriman paling tinggi?** (pemetaan risiko fulfillment)
3. **Bagaimana tren penjualan per channel dan kategori sepanjang tahun?**

Komponen dashboard:
- **Card:** Total Sales (Rp 876 Jt), Total Quantity (40K unit)
- **Combo chart:** Revenue & quantity per produk — mengidentifikasi produk *best value* vs *best volume*
- **Matrix table:** Status pengiriman (Gagal/Tertunda/Dikembalikan/Sukses) per kota — dipakai untuk menandai area risiko operasional, bukan sekadar performa penjualan
- **Donut + grouped bar chart:** Pangsa transaksi per channel (hampir merata ±33%) dan performa kategori per channel
- **Line chart:** Tren revenue bulanan — relatif flat (Rp 67–76 Jt/bulan), tidak terdeteksi pola musiman kuat pada dataset ini
- **Slicer:** filter interaktif berdasarkan kategori, bulan, dan kota untuk eksplorasi mandiri oleh user

---

## 6. Recommendations

- **Prioritaskan retensi untuk pelanggan high-frequency & high-value** (Eka, Wira, Yusuf) — gap belanja mereka terhadap pelanggan lain cukup besar (~2x) untuk dijadikan basis program loyalitas bertingkat (tiering), bukan diskon generik.
- **Default alokasi stok & promosi ke kategori Makanan**, karena terbukti mendominasi di seluruh channel — namun tetap uji coba promosi terarah di Perawatan, karena gapnya dengan Makanan tidak sebesar gap di level pelanggan, artinya masih ada ruang pertumbuhan yang belum tergarap.
- **Investigasi akar masalah status Gagal/Tertunda/Dikembalikan (±51% dari total order)** sebagai isu operasional prioritas tinggi — breakdown per kota di matrix table dashboard bisa jadi titik awal untuk mengecek apakah masalah ada di kurir tertentu, kualitas alamat, atau kapasitas gudang regional.
- **Pantau keseimbangan channel** (Offline/Toko Oren/Toko Hijau hampir 33/33/33) tiap kuartal — perlu dicek apakah ini pola stabil atau sekadar artefak dari satu tahun sampel data ini.

---

## 7. Limitations & Next Steps

- **Data sintetis/dummy:** pola yang sangat merata (channel share ±33%, tren bulanan flat) kemungkinan besar tidak merefleksikan variasi dunia nyata — kesimpulan di project ini sebaiknya dibaca sebagai **demonstrasi metodologi**, bukan business truth yang final.
- **Belum ada segmentasi RFM formal:** ranking "top customer" di sini berbasis total kumulatif satu tahun, belum memisahkan recency/frequency/monetary secara terpisah — akan lebih tajam untuk keputusan program loyalitas nyata.
- **Belum ada uji signifikansi statistik:** perbedaan antar kategori/channel dijelaskan secara deskriptif-direksional, belum diuji signifikansinya — untuk keputusan bisnis riil, gap ini idealnya divalidasi dulu sebelum jadi dasar alokasi anggaran.
- **Rencana lanjutan bila project ini live:** analisis YoY, segmentasi RFM pelanggan, dan root-cause breakdown status pengiriman per kurir/wilayah (bukan hanya per kota).

---

## 8. Struktur Repository

```
├── Assets/
│   ├── Data/
│   │   ├── Data_FMCG_BT_Data_Analyst_-_Messy.csv        # data mentah
│   │   └── Data_FMCG_BT_Data_Analyst_-_Clean_Fix.xlsx   # data bersih + pivot
│   ├── Dashboard/
│   │   └── Galang_Sandy_A_Power_BI_Sales_Dashboard.pbix # dashboard Power BI
│   ├── GALANG_SANDY_A__PORTFOLIO_BT_DATA_ANALYST_KARIRNEX.pdf  # slide portofolio lengkap
│   ├── Latihan1_sql.sql                                 # query cleaning & analisis SQL
│   ├── Top_Category.png                                 # chart performa kategori per channel
│   ├── Top_Customer_by_Total_Order.png                  # chart top 10 pelanggan (order)
│   └── Top_Customer_by_Total_Spend.png                  # chart top 10 pelanggan (belanja)
└── README.md
```

## 9. Tools & Skills yang Ditunjukkan

`SQL (SQLite: CREATE TABLE AS, CASE WHEN, dedup via rowid, data validation)` · `Excel (Pivot Table, Pivot Chart, PROPER, Find & Replace)` · `Power BI (Card, Matrix, Slicer, storytelling layout)` · `Business Storytelling & Insight Framing (CRISP-DM)`

---

## Contact

**Galang Sandy Akbar**
📧 galangsandyakbar@gmail.com
🔗 [linkedin.com/in/galangsandyakbar](https://www.linkedin.com/in/galangsandyakbar)
