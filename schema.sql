# Shop Schema SQL
# Modelo de e-commerce listo para PostgreSQL (compatible con SQLite con mínimos cambios)

-- Extensiones (PostgreSQL)
-- CREATE EXTENSION IF NOT EXISTS "pgcrypto";

DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS categories CASCADE;
DROP TABLE IF EXISTS customers CASCADE;

CREATE TABLE customers (
  id            BIGSERIAL PRIMARY KEY,
  email         VARCHAR(180) NOT NULL UNIQUE,
  full_name     VARCHAR(120) NOT NULL,
  city          VARCHAR(80),
  country       CHAR(2) DEFAULT 'CO',
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE categories (
  id            SERIAL PRIMARY KEY,
  slug          VARCHAR(64) NOT NULL UNIQUE,
  name          VARCHAR(100) NOT NULL
);

CREATE TABLE products (
  id            BIGSERIAL PRIMARY KEY,
  category_id   INT NOT NULL REFERENCES categories(id),
  sku           VARCHAR(40) NOT NULL UNIQUE,
  name          VARCHAR(160) NOT NULL,
  description   TEXT,
  price_cents   INT NOT NULL CHECK (price_cents >= 0),
  stock         INT NOT NULL DEFAULT 0 CHECK (stock >= 0),
  is_active     BOOLEAN NOT NULL DEFAULT TRUE,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_products_category ON products(category_id);
CREATE INDEX idx_products_active_price ON products(is_active, price_cents);

CREATE TABLE orders (
  id            BIGSERIAL PRIMARY KEY,
  customer_id   BIGINT NOT NULL REFERENCES customers(id),
  status        VARCHAR(20) NOT NULL DEFAULT 'pending'
                CHECK (status IN ('pending','paid','shipped','cancelled')),
  total_cents   INT NOT NULL DEFAULT 0 CHECK (total_cents >= 0),
  placed_at     TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE order_items (
  id            BIGSERIAL PRIMARY KEY,
  order_id      BIGINT NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  product_id    BIGINT NOT NULL REFERENCES products(id),
  qty           INT NOT NULL CHECK (qty > 0),
  unit_price_cents INT NOT NULL CHECK (unit_price_cents >= 0),
  UNIQUE (order_id, product_id)
);

-- Seed
INSERT INTO categories (slug, name) VALUES
  ('libros', 'Libros'),
  ('tech', 'Tecnología'),
  ('hogar', 'Hogar');

INSERT INTO customers (email, full_name, city) VALUES
  ('ana@mail.com', 'Ana Pérez', 'Popayán'),
  ('luis@mail.com', 'Luis Gómez', 'Cali');

INSERT INTO products (category_id, sku, name, description, price_cents, stock) VALUES
  (1, 'BK-001', 'Clean Code', 'Buenas prácticas', 8900000, 12),
  (1, 'BK-002', 'Designing Data-Intensive Apps', 'Arquitectura de datos', 12500000, 5),
  (2, 'TC-010', 'Teclado mecánico', 'Switch brown', 21000000, 20),
  (3, 'HG-003', 'Lámpara LED', 'Escritorio regulable', 7500000, 15);

INSERT INTO orders (customer_id, status, total_cents) VALUES
  (1, 'paid', 8900000),
  (2, 'pending', 28500000);

INSERT INTO order_items (order_id, product_id, qty, unit_price_cents) VALUES
  (1, 1, 1, 8900000),
  (2, 3, 1, 21000000),
  (2, 4, 1, 7500000);
