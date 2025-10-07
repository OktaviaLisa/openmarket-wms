-- Tabel Suppliers
CREATE TABLE IF NOT EXISTS suppliers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    contact_person VARCHAR(150),
    phone VARCHAR(20),
    email VARCHAR(100),
    address TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel Customers
CREATE TABLE IF NOT EXISTS customers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    contact_person VARCHAR(150),
    phone VARCHAR(20),
    email VARCHAR(100),
    address TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel Units (Satuan)
CREATE TABLE IF NOT EXISTS units (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    symbol VARCHAR(10) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel Locations (Lokasi Penyimpanan)
CREATE TABLE IF NOT EXISTS locations (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    code VARCHAR(20) UNIQUE NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Update tabel warehouse_product untuk menambah unit_id
ALTER TABLE warehouse_product ADD COLUMN IF NOT EXISTS unit_id INTEGER REFERENCES units(id);

-- Tabel Receiving (Penerimaan Barang)
CREATE TABLE IF NOT EXISTS receiving (
    id SERIAL PRIMARY KEY,
    document_number VARCHAR(50) UNIQUE NOT NULL,
    receive_date DATE NOT NULL,
    supplier_id INTEGER REFERENCES suppliers(id) NOT NULL,
    product_id INTEGER REFERENCES warehouse_product(id) NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_id INTEGER REFERENCES units(id) NOT NULL,
    location_id INTEGER REFERENCES locations(id) NOT NULL,
    remarks TEXT,
    created_by INTEGER REFERENCES auth_user(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel Issuing (Pengeluaran Barang)
CREATE TABLE IF NOT EXISTS issuing (
    id SERIAL PRIMARY KEY,
    document_number VARCHAR(50) UNIQUE NOT NULL,
    issue_date DATE NOT NULL,
    customer_id INTEGER REFERENCES customers(id) NOT NULL,
    product_id INTEGER REFERENCES warehouse_product(id) NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_id INTEGER REFERENCES units(id) NOT NULL,
    location_id INTEGER REFERENCES locations(id) NOT NULL,
    remarks TEXT,
    created_by INTEGER REFERENCES auth_user(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Update tabel inventory untuk menambah location_id
ALTER TABLE inventory ADD COLUMN IF NOT EXISTS location_id INTEGER REFERENCES locations(id);

-- Insert data default
INSERT INTO units (name, symbol) VALUES 
('Pieces', 'pcs'),
('Box', 'box'),
('Kilogram', 'kg'),
('Liter', 'ltr')
ON CONFLICT DO NOTHING;

INSERT INTO locations (name, code, description) VALUES 
('Warehouse A', 'WH-A', 'Main warehouse storage'),
('Warehouse B', 'WH-B', 'Secondary warehouse storage'),
('Cold Storage', 'CS-01', 'Temperature controlled storage')
ON CONFLICT DO NOTHING;

-- Function untuk generate document number
CREATE OR REPLACE FUNCTION generate_document_number(prefix TEXT)
RETURNS TEXT AS $$
DECLARE
    next_number INTEGER;
    doc_number TEXT;
BEGIN
    SELECT COALESCE(MAX(CAST(SUBSTRING(document_number FROM LENGTH(prefix) + 1) AS INTEGER)), 0) + 1
    INTO next_number
    FROM (
        SELECT document_number FROM receiving WHERE document_number LIKE prefix || '%'
        UNION ALL
        SELECT document_number FROM issuing WHERE document_number LIKE prefix || '%'
    ) AS combined;
    
    doc_number := prefix || LPAD(next_number::TEXT, 6, '0');
    RETURN doc_number;
END;
$$ LANGUAGE plpgsql;