-- Database initialization for retail demo

CREATE TABLE IF NOT EXISTS users (
  id SERIAL PRIMARY KEY,
  username VARCHAR(50) UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS products (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  price NUMERIC(10,2) NOT NULL,
  stock INTEGER NOT NULL DEFAULT 0,
  image_url TEXT,
  category VARCHAR(100),
  rating NUMERIC(2,1)
);

CREATE TABLE IF NOT EXISTS carts (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users(id),
  status VARCHAR(20) NOT NULL DEFAULT 'OPEN',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS cart_items (
  id SERIAL PRIMARY KEY,
  cart_id INTEGER NOT NULL REFERENCES carts(id) ON DELETE CASCADE,
  product_id INTEGER NOT NULL REFERENCES products(id),
  quantity INTEGER NOT NULL DEFAULT 1,
  UNIQUE (cart_id, product_id)
);

CREATE TABLE IF NOT EXISTS orders (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users(id),
  total_amount NUMERIC(10,2) NOT NULL,
  status VARCHAR(20) NOT NULL,
  delivery_address TEXT NOT NULL,
  payment_method VARCHAR(20) NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS order_items (
  id SERIAL PRIMARY KEY,
  order_id INTEGER NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  product_id INTEGER NOT NULL REFERENCES products(id),
  quantity INTEGER NOT NULL,
  price NUMERIC(10,2) NOT NULL
);

-- Sample products
INSERT INTO products (name, description, price, stock, image_url, category, rating) VALUES
('Lenovo Laptop', '14-inch business laptop with 16GB RAM, 512GB SSD', 65000.00, 10, NULL, 'Electronics', 4.5),
('Dell Monitor', '24-inch full HD IPS monitor', 12000.00, 15, NULL, 'Electronics', 4.2),
('Apple iPhone', 'Latest iPhone model with 128GB storage', 90000.00, 5, NULL, 'Mobiles', 4.8),
('Samsung Galaxy', 'Android phone with AMOLED display', 55000.00, 8, NULL, 'Mobiles', 4.4),
('Sony Headphones', 'Noise cancelling over-ear headphones', 15000.00, 20, NULL, 'Accessories', 4.6),
('Logitech Mouse', 'Wireless mouse with ergonomic design', 1500.00, 50, NULL, 'Accessories', 4.1),
('HP Printer', 'All-in-one color printer', 8000.00, 7, NULL, 'Electronics', 3.9),
('Amazon Echo', 'Smart speaker with voice assistant', 6000.00, 12, NULL, 'Smart Home', 4.3),
('Mi Power Bank', '10000mAh fast charging power bank', 1200.00, 30, NULL, 'Accessories', 4.0),
('Office Chair', 'Ergonomic office chair with lumbar support', 7000.00, 6, NULL, 'Furniture', 4.2);

-- Seed demo users with a common password (Password@123).
-- Initially stored as plaintext; backend will transparently migrate them to bcrypt hashes
-- on first successful login.

DO $$
DECLARE
  i INT;
BEGIN
  FOR i IN 1..50 LOOP
    INSERT INTO users (username, password_hash)
    VALUES (format('user%1$s', i), 'Password@123')
    ON CONFLICT (username) DO NOTHING;
  END LOOP;
END $$;
