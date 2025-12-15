const express = require("express");
const cors = require("cors");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const db = require("./db");
const featureRoutes = require("./features_1_2_3_4_14");

const app = express();
const PORT = process.env.PORT || 4000;
const JWT_SECRET = process.env.JWT_SECRET || "changeme-in-prod";

// Debug environment
console.log("===== BACKEND STARTING =====");
console.log("[ENV] DB_HOST:", process.env.DB_HOST);
console.log("[ENV] DB_PORT:", process.env.DB_PORT);
console.log("[ENV] DB_NAME:", process.env.DB_NAME);
console.log("[ENV] DB_USER:", process.env.DB_USER);

// Middleware
app.use(cors({ origin: true, credentials: true }));
app.use(express.json());

// Mount feature routes
app.use("/api", featureRoutes);

/* -------------------------------------------------------------
 * HEALTH CHECKS
 * ----------------------------------------------------------- */
app.get("/health/live", (req, res) => {
  res.json({ status: "ok" });
});

app.get("/health/ready", async (req, res) => {
  try {
    await db.query("SELECT 1");
    res.json({ status: "ready" });
  } catch (err) {
    console.error("Readiness check failed:", err.message);
    res.status(500).json({ status: "not_ready" });
  }
});

/* -------------------------------------------------------------
 * AUTH MIDDLEWARE
 * ----------------------------------------------------------- */
function authMiddleware(req, res, next) {
  const header = req.headers["authorization"];
  if (!header) {
    return res.status(401).json({ message: "Missing Authorization header" });
  }

  const [scheme, token] = header.split(" ");
  if (scheme !== "Bearer" || !token) {
    return res.status(401).json({ message: "Invalid Authorization header" });
  }

  try {
    const payload = jwt.verify(token, JWT_SECRET);
    req.user = {
      id: payload.userId,
      username: payload.username,
      is_admin: payload.is_admin || false
    };
    next();
  } catch (err) {
    console.error("JWT verification failed:", err);
    return res.status(401).json({ message: "Invalid or expired token" });
  }
}

/* -------------------------------------------------------------
 * HELPER
 * ----------------------------------------------------------- */
async function getOrCreateCart(userId, client = null) {
  const executor = client || db;

  const result = await executor.query(
    "SELECT id FROM carts WHERE user_id = $1 AND status = 'OPEN' ORDER BY id DESC LIMIT 1",
    [userId]
  );

  if (result.rows.length > 0) {
    return result.rows[0].id;
  }

  const insert = await executor.query(
    "INSERT INTO carts (user_id, status) VALUES ($1, 'OPEN') RETURNING id",
    [userId]
  );
  return insert.rows[0].id;
}

/* -------------------------------------------------------------
 * LOGIN ROUTE WITH FULL DEBUG LOGGING
 * ----------------------------------------------------------- */
app.post("/api/auth/login", async (req, res) => {
  const { username, password } = req.body || {};

  console.log("=========================================");
  console.log("[LOGIN] Attempted login");
  console.log("[LOGIN] username received:", username);
  console.log("[LOGIN] password received:", password);

  if (!username || !password) {
    console.warn("[LOGIN] Missing username/password");
    return res.status(400).json({ message: "Username and password required" });
  }

  try {
    console.log("[LOGIN] Fetching user from DB...");
    const result = await db.query(
      `SELECT id, username, password_hash, default_address, is_admin
       FROM users
       WHERE username = $1`,
      [username]
    );

    console.log("[LOGIN] SQL result rows:", result.rows);

    if (result.rows.length === 0) {
      console.warn("[LOGIN] INVALID → User not found:", username);
      return res.status(401).json({ message: "Invalid credentials" });
    }

    const user = result.rows[0];

    console.log("[LOGIN] Stored password_hash (length:", user.password_hash.length, "):");
    console.log(user.password_hash);

    let match = false;

    // BCRYPT CHECK
    if (user.password_hash && user.password_hash.startsWith("$2")) {
      console.log("[LOGIN] Detected bcrypt hash, running bcrypt.compare");
      console.log("[LOGIN] Comparing:");
      console.log("   entered password:", password);
      console.log("   stored hash     :", user.password_hash);

      match = await bcrypt.compare(password, user.password_hash);

      console.log("[LOGIN] bcrypt.compare result:", match);
    } else {
      // PLAINTEXT CHECK (for legacy users)
      console.log("[LOGIN] Plaintext password detected, comparing directly");
      match = password === user.password_hash;

      if (match) {
        console.log("[LOGIN] plaintext match → converting to bcrypt...");
        const newHash = await bcrypt.hash(password, 10);

        await db.query(
          "UPDATE users SET password_hash = $1 WHERE id = $2",
          [newHash, user.id]
        );

        console.log("[LOGIN] plaintext converted to bcrypt for user:", user.id);
      }
    }

    if (!match) {
      console.warn("[LOGIN] INVALID → Wrong password for user:", username);
      return res.status(401).json({ message: "Invalid credentials" });
    }

    console.log("[LOGIN] SUCCESS! Creating login_events entry...");
    await db.query("INSERT INTO login_events (user_id) VALUES ($1)", [
      user.id
    ]);
    console.log("[LOGIN] login_events entry added");

    const token = jwt.sign(
      {
        userId: user.id,
        username: user.username,
        is_admin: user.is_admin
      },
      JWT_SECRET,
      { expiresIn: "8h" }
    );

    console.log("[LOGIN] Login completed successfully for:", username);

    res.json({
      token,
      user: {
        id: user.id,
        username: user.username,
        default_address: user.default_address,
        is_admin: user.is_admin
      }
    });

  } catch (err) {
    console.error("[LOGIN] INTERNAL ERROR:", err);
    res.status(500).json({ message: "Internal server error" });
  }
});

/* -------------------------------------------------------------
 * LOGOUT
 * ----------------------------------------------------------- */
app.post("/api/auth/logout", authMiddleware, async (req, res) => {
  try {
    console.log("[LOGOUT] User logging out:", req.user.username, "(id:", req.user.id, ")");
    res.json({ message: "Logged out" });
  } catch (err) {
    console.error("[LOGOUT] Error:", err);
    res.status(500).json({ message: "Internal server error" });
  }
});

/* -------------------------------------------------------------
 * OTHER ROUTES (unchanged except minor logs)
 * ----------------------------------------------------------- */

app.get("/api/products", async (req, res) => {
  console.log("[PRODUCTS] Fetching products...");
  const { search, category, sort } = req.query;

  let query = "SELECT * FROM products WHERE 1=1";
  const params = [];
  let idx = 1;

  if (search) {
    query += ` AND (LOWER(name) LIKE $${idx} OR LOWER(description) LIKE $${idx})`;
    params.push(`%${search.toLowerCase()}%`);
    idx++;
  }

  if (category) {
    query += ` AND category = $${idx}`;
    params.push(category);
    idx++;
  }

  if (sort === "price_asc") {
    query += " ORDER BY price ASC";
  } else if (sort === "price_desc") {
    query += " ORDER BY price DESC";
  } else if (sort === "rating_desc") {
    query += " ORDER BY rating DESC NULLS LAST";
  } else {
    query += " ORDER BY id ASC";
  }

  try {
    const result = await db.query(query, params);
    res.json(result.rows);
  } catch (err) {
    console.error("[PRODUCTS] Error:", err);
    res.status(500).json({ message: "Internal server error" });
  }
});

/* -------------------------------------------------------------
 * START SERVER
 * ----------------------------------------------------------- */
app.listen(PORT, () => {
  console.log("=========================================");
  console.log(`Retail backend running on port ${PORT}`);
  console.log("=========================================");
});

