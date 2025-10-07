-- Inventory Management Database Schema

-- Stock Opname table
CREATE TABLE IF NOT EXISTS stock_opnames (
    id SERIAL PRIMARY KEY,
    product_id INTEGER REFERENCES products(id),
    system_stock INTEGER NOT NULL,
    physical_stock INTEGER NOT NULL,
    difference INTEGER NOT NULL,
    status VARCHAR(20) DEFAULT 'PENDING',
    notes TEXT,
    created_by INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Stock Movement table
CREATE TABLE IF NOT EXISTS stock_movements (
    id SERIAL PRIMARY KEY,
    product_id INTEGER REFERENCES products(id),
    movement_type VARCHAR(20) NOT NULL, -- IN, OUT, TRANSFER
    quantity INTEGER NOT NULL,
    from_location VARCHAR(100),
    to_location VARCHAR(100),
    reference_type VARCHAR(20), -- RECEPTION, DISPATCH, RETURN, OPNAME
    reference_id INTEGER,
    notes TEXT,
    created_by INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Reception table
CREATE TABLE IF NOT EXISTS receptions (
    id SERIAL PRIMARY KEY,
    product_id INTEGER REFERENCES products(id),
    quantity INTEGER NOT NULL,
    supplier VARCHAR(100),
    status VARCHAR(20) DEFAULT 'PENDING',
    notes TEXT,
    created_by INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Dispatch table
CREATE TABLE IF NOT EXISTS dispatches (
    id SERIAL PRIMARY KEY,
    product_id INTEGER REFERENCES products(id),
    quantity INTEGER NOT NULL,
    customer VARCHAR(100),
    status VARCHAR(20) DEFAULT 'PENDING',
    notes TEXT,
    created_by INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Returns table
CREATE TABLE IF NOT EXISTS returns (
    id SERIAL PRIMARY KEY,
    product_id INTEGER REFERENCES products(id),
    quantity INTEGER NOT NULL,
    return_type VARCHAR(20) NOT NULL, -- CUSTOMER, SUPPLIER
    reason TEXT,
    status VARCHAR(20) DEFAULT 'PENDING',
    notes TEXT,
    created_by INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Quality Check table
CREATE TABLE IF NOT EXISTS quality_checks (
    id SERIAL PRIMARY KEY,
    product_id INTEGER REFERENCES products(id),
    check_type VARCHAR(20) NOT NULL, -- INCOMING, OUTGOING, RETURN
    reference_id INTEGER,
    status VARCHAR(20) DEFAULT 'PENDING',
    checked_qty INTEGER NOT NULL,
    passed_qty INTEGER NOT NULL,
    failed_qty INTEGER NOT NULL,
    notes TEXT,
    checked_by INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_stock_movements_product_id ON stock_movements(product_id);
CREATE INDEX IF NOT EXISTS idx_stock_movements_created_at ON stock_movements(created_at);
CREATE INDEX IF NOT EXISTS idx_receptions_product_id ON receptions(product_id);
CREATE INDEX IF NOT EXISTS idx_dispatches_product_id ON dispatches(product_id);
CREATE INDEX IF NOT EXISTS idx_returns_product_id ON returns(product_id);
CREATE INDEX IF NOT EXISTS idx_quality_checks_product_id ON quality_checks(product_id);