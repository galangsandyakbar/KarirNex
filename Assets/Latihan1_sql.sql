-- =====================================================
-- CLEANING DATA
-- =====================================================
-- TABLE BARU >> 'fmcg_clean'
CREATE TABLE fmcg_clean AS
SELECT
    -- Fix format tanggal
    DATE(substr(sales_date,7,4) || '-' ||
         substr(sales_date,4,2) || '-' ||
         substr(sales_date,1,2)) AS sales_date,
    order_id,
    TRIM(product_name) AS product_name,
    UPPER(TRIM(category)) AS category,
    price,
-- Fix quantity error
    CASE
        WHEN quantity = -99 THEN 1
        ELSE quantity
    END AS quantity,
    discount,
    shipping_fee,
    TRIM(customer_name) AS customer_name,
    TRIM(customer_address) AS customer_address,
    TRIM(channel) AS channel,
    rating,
    status
FROM fmcg;

-- =====================================================
-- TAMBAH KOLOM PERHITUNGAN
-- =====================================================
ALTER TABLE fmcg_clean ADD COLUMN total;
ALTER TABLE fmcg_clean ADD COLUMN total_sales;

UPDATE fmcg_clean
SET total = price * quantity;

UPDATE fmcg_clean
SET total_sales = (price * quantity) * (1 - discount) + shipping_fee;

-- =====================================================
-- HAPUS DUPLIKAT
-- =====================================================
--- Cek Duplikat
SELECT order_id, COUNT(*)
FROM fmcg_clean
GROUP BY order_id
HAVING COUNT(*) > 1;
--- Hapus Duplikat
DELETE FROM fmcg_clean
WHERE rowid NOT IN (
    SELECT MIN(rowid)
    FROM fmcg_clean
    GROUP BY order_id
);

-- =====================================================
-- VALIDASI DATA
-- =====================================================
SELECT *
FROM fmcg_clean
WHERE quantity IS NULL;
-- Hapus Missing VALUES
DELETE FROM fmcg_clean
WHERE quantity IS NULL;

-- =====================================================
-- ANALYSIS -- Answering Questions
-- =====================================================
--- 1. Ada berapa kota dalam kolom customer_address?
SELECT COUNT(DISTINCT customer_address) AS total_kota
FROM fmcg_clean;

--- 2. Berapakah jumlah keseluruhan dari total_sales?
SELECT SUM(total_sales) AS total_sales
FROM fmcg_clean;

--- 3. Ada berapa banyak orderan di Toko Hijau?
SELECT COUNT(*) AS jumlah_order_toko_hijau
FROM fmcg_clean
WHERE channel LIKE '%Toko Hijau%';

--- 4. Ada berapa pelanggan yang pernah berbelanja?
SELECT COUNT(DISTINCT customer_name) AS jumlah_pelanggan
FROM fmcg_clean;

--- 5. Putra dan Putri sudah berbelanja berapa kali, mengeluarkan uang berapa, dan membeli berapa barang?
SELECT
    customer_name,
    COUNT(order_id) AS jumlah_transaksi,
    SUM(total_sales) AS total_pengeluaran,
    SUM(quantity) AS total_barang_dibeli
FROM fmcg_clean
WHERE customer_name IN ('Putra','Putri')
GROUP BY customer_name;

-- CEK TABLE 'fmcg_clean'
SELECT * FROM fmcg_clean
LIMIT 15;