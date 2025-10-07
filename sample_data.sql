-- Insert sample suppliers
INSERT INTO suppliers (name, contact_person, phone, email, address) VALUES 
('PT Supplier Utama', 'John Doe', '021-1234567', 'john@supplier.com', 'Jakarta Selatan'),
('CV Mitra Barang', 'Jane Smith', '021-7654321', 'jane@mitra.com', 'Jakarta Barat'),
('UD Sumber Rejeki', 'Ahmad Rahman', '021-9876543', 'ahmad@sumber.com', 'Tangerang')
ON CONFLICT DO NOTHING;

-- Insert sample customers
INSERT INTO customers (name, contact_person, phone, email, address) VALUES 
('PT Customer Prima', 'Bob Wilson', '021-1111111', 'bob@customer.com', 'Jakarta Utara'),
('CV Toko Sejahtera', 'Alice Brown', '021-2222222', 'alice@toko.com', 'Jakarta Timur'),
('UD Makmur Jaya', 'Charlie Davis', '021-3333333', 'charlie@makmur.com', 'Bekasi')
ON CONFLICT DO NOTHING;

-- Insert sample products with units
INSERT INTO warehouse_product (name, sku, description, price, unit_id) VALUES 
('Laptop Dell Inspiron', 'LAPTOP-001', 'Laptop untuk kantor', 8500000.00, 1),
('Mouse Wireless', 'MOUSE-001', 'Mouse wireless ergonomis', 150000.00, 1),
('Keyboard Mechanical', 'KEYBOARD-001', 'Keyboard gaming mechanical', 750000.00, 1),
('Monitor 24 inch', 'MONITOR-001', 'Monitor LED 24 inch', 2500000.00, 1),
('Printer Inkjet', 'PRINTER-001', 'Printer untuk kantor', 1200000.00, 1)
ON CONFLICT (sku) DO NOTHING;

-- Insert initial inventory
INSERT INTO inventory (product_id, quantity, min_stock, location_id) VALUES 
(1, 0, 5, 1),
(2, 0, 20, 1),
(3, 0, 10, 1),
(4, 0, 8, 1),
(5, 0, 3, 1);

-- Update inventory table to add unique constraint if not exists
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint 
        WHERE conname = 'inventory_product_location_unique'
    ) THEN
        ALTER TABLE inventory ADD CONSTRAINT inventory_product_location_unique 
        UNIQUE (product_id, location_id);
    END IF;
END $$;