-- Tabel penerimaan_barang
CREATE TABLE penerimaan_barang (
    id SERIAL PRIMARY KEY,
    no_dokumen VARCHAR(50) UNIQUE NOT NULL,
    tanggal DATE NOT NULL,
    supplier VARCHAR(100) NOT NULL,
    no_po VARCHAR(50),
    status VARCHAR(20) DEFAULT 'draft' CHECK (status IN ('draft', 'in_progress', 'completed', 'cancelled')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel detail_penerimaan
CREATE TABLE detail_penerimaan (
    id SERIAL PRIMARY KEY,
    penerimaan_id INTEGER REFERENCES penerimaan_barang(id) ON DELETE CASCADE,
    sku VARCHAR(50) NOT NULL,
    nama_barang VARCHAR(200) NOT NULL,
    jumlah INTEGER NOT NULL,
    batch VARCHAR(50),
    expired_date DATE,
    satuan VARCHAR(20) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel pemeriksaan_kualitas
CREATE TABLE pemeriksaan_kualitas (
    id SERIAL PRIMARY KEY,
    detail_penerimaan_id INTEGER REFERENCES detail_penerimaan(id) ON DELETE CASCADE,
    status VARCHAR(20) NOT NULL CHECK (status IN ('diterima', 'ditolak')),
    keterangan TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_penerimaan_no_dokumen ON penerimaan_barang(no_dokumen);
CREATE INDEX idx_penerimaan_tanggal ON penerimaan_barang(tanggal);
CREATE INDEX idx_detail_penerimaan_id ON detail_penerimaan(penerimaan_id);
CREATE INDEX idx_pemeriksaan_detail_id ON pemeriksaan_kualitas(detail_penerimaan_id);