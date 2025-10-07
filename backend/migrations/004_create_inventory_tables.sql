-- Create inventory table
CREATE TABLE IF NOT EXISTS inventory (
    id SERIAL PRIMARY KEY,
    product_name VARCHAR(255) NOT NULL,
    category VARCHAR(100),
    quantity INTEGER NOT NULL DEFAULT 0,
    location VARCHAR(255),
    min_stock INTEGER DEFAULT 10,
    updated_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(product_name, category)
);

-- Create receptions table
CREATE TABLE IF NOT EXISTS receptions (
    id SERIAL PRIMARY KEY,
    product_name VARCHAR(255) NOT NULL,
    category VARCHAR(100),
    quantity INTEGER NOT NULL,
    location VARCHAR(255),
    notes TEXT,
    received_date TIMESTAMP DEFAULT NOW(),
    status VARCHAR(50) DEFAULT 'pending'
);

-- Create dispatches table
CREATE TABLE IF NOT EXISTS dispatches (
    id SERIAL PRIMARY KEY,
    product_name VARCHAR(255) NOT NULL,
    category VARCHAR(100),
    quantity INTEGER NOT NULL,
    location VARCHAR(255),
    notes TEXT,
    dispatch_date TIMESTAMP DEFAULT NOW(),
    status VARCHAR(50) DEFAULT 'pending'
);

-- Create stock_movements table
CREATE TABLE IF NOT EXISTS stock_movements (
    id SERIAL PRIMARY KEY,
    product_name VARCHAR(255) NOT NULL,
    category VARCHAR(100),
    movement_type VARCHAR(10) NOT NULL, -- 'IN' or 'OUT'
    quantity INTEGER NOT NULL,
    reference VARCHAR(255),
    created_at TIMESTAMP DEFAULT NOW()
);

-- Insert sample data
INSERT INTO inventory (product_name, category, quantity, location) VALUES
('Laptop Dell', 'Electronics', 50, 'A-01'),
('Mouse Wireless', 'Electronics', 100, 'A-02'),
('Kertas A4', 'Office Supplies', 200, 'B-01')
ON CONFLICT (product_name, category) DO NOTHING;