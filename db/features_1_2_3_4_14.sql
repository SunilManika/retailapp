---------------------------------------------------------
-- FEATURE PACK 1,2,3,4,14 – DB CHANGES
---------------------------------------------------------

-- 1) Wishlist – simple table per user/product
CREATE TABLE IF NOT EXISTS wishlist_items (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  product_id INTEGER NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (user_id, product_id)
);

-- 2) Product Reviews & Ratings
CREATE TABLE IF NOT EXISTS product_reviews (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  product_id INTEGER NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  rating INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
  comment TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4) User profile – is_admin flag (default false) if not present
ALTER TABLE users
  ADD COLUMN IF NOT EXISTS is_admin BOOLEAN DEFAULT FALSE;

-- Mark first user as admin (id = 1) if it exists
UPDATE users
SET is_admin = TRUE
WHERE id = 1;

-- 3) Advanced order history and 14) admin dashboard use existing orders / order_items / products tables.
