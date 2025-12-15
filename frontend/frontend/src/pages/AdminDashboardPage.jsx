import React, { useEffect, useState, useMemo } from "react";
import { getAdminMetrics } from "../api";

// Recharts
import {
  ResponsiveContainer,
  LineChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  BarChart,
  Bar,
  Legend
} from "recharts";

const REFRESH_INTERVAL_MS = 15000; // 15 seconds

function AdminDashboardPage() {
  const [metrics, setMetrics] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  async function loadMetrics() {
    try {
      setError("");
      const data = await getAdminMetrics();
      setMetrics(data);
      setLoading(false);
    } catch (err) {
      console.error("Admin metrics load error", err);
      setError(err?.response?.data?.message || "Unable to load metrics");
      setLoading(false);
    }
  }

  useEffect(() => {
    loadMetrics();
    const id = setInterval(loadMetrics, REFRESH_INTERVAL_MS);
    return () => clearInterval(id);
  }, []);

  const loginTrendData = useMemo(() => {
    if (!metrics?.login_trend) return [];

    return metrics.login_trend.map((point) => {
      const d = new Date(point.bucket);
      return {
        timeLabel: d.toLocaleTimeString([], {
          hour: "2-digit",
          minute: "2-digit"
        }),
        logins: point.logins
      };
    });
  }, [metrics]);

  const topProductsData = useMemo(() => {
    if (!metrics?.top_products) return [];
    return metrics.top_products.map((p) => ({
      name: p.name,
      units_sold: Number(p.units_sold) || 0
    }));
  }, [metrics]);

  if (loading && !metrics) {
    return (
      <div className="page">
        <h2 className="page-title">Admin Dashboard</h2>
        <p>Loading metrics...</p>
      </div>
    );
  }

  return (
    <div className="page">
      <h2 className="page-title">Admin Dashboard</h2>

      {error && <div className="error-text">{error}</div>}

      {metrics && (
        <>
          {/* KPI CARDS */}
          <div
            style={{
              display: "grid",
              gridTemplateColumns: "repeat(auto-fit, minmax(180px, 1fr))",
              gap: 16,
              marginBottom: 24
            }}
          >
            <KpiCard
              title="Total Users"
              value={metrics.total_users}
              accent="#2563eb"
            />
            <KpiCard
              title="Total Logins"
              value={metrics.total_logins}
              accent="#7c3aed"
            />
            <KpiCard
              title="Active Users (last 5 min)"
              value={metrics.active_users_realtime}
              accent="#16a34a"
            />
            <KpiCard
              title="Total Revenue"
              value={`₹${metrics.total_revenue.toFixed(2)}`}
              accent="#ea580c"
            />
            <KpiCard
              title="Total Orders"
              value={metrics.total_orders}
              accent="#0f766e"
            />
          </div>

          {/* CHARTS ROW */}
          <div
            style={{
              display: "grid",
              gridTemplateColumns: "minmax(0, 2fr) minmax(0, 1.5fr)",
              gap: 24,
              alignItems: "stretch"
            }}
          >
            {/* LOGIN TREND LINE CHART */}
            <div
              className="product-card"
              style={{ height: 320, display: "flex", flexDirection: "column" }}
            >
              <div className="product-body" style={{ flex: "0 0 auto" }}>
                <h3 className="product-name">Login Trend (last 12 hours)</h3>
                <p
                  style={{
                    fontSize: 12,
                    margin: "2px 0 10px",
                    color: "#6b7280"
                  }}
                >
                  Number of logins grouped by hour.
                </p>
              </div>
              <div style={{ flex: "1 1 auto", padding: "0 12px 12px" }}>
                {loginTrendData.length === 0 ? (
                  <p style={{ fontSize: 13, color: "#6b7280" }}>
                    No login activity in the last 12 hours.
                  </p>
                ) : (
                  <ResponsiveContainer width="100%" height="100%">
                    <LineChart data={loginTrendData}>
                      <CartesianGrid strokeDasharray="3 3" />
                      <XAxis dataKey="timeLabel" minTickGap={20} />
                      <YAxis allowDecimals={false} />
                      <Tooltip />
                      <Line
                        type="monotone"
                        dataKey="logins"
                        stroke="#2563eb"
                        strokeWidth={2}
                        dot={{ r: 3 }}
                        activeDot={{ r: 5 }}
                      />
                    </LineChart>
                  </ResponsiveContainer>
                )}
              </div>
            </div>

            {/* TOP PRODUCTS BAR CHART */}
            <div
              className="product-card"
              style={{ height: 320, display: "flex", flexDirection: "column" }}
            >
              <div className="product-body" style={{ flex: "0 0 auto" }}>
                <h3 className="product-name">Top Products</h3>
                <p
                  style={{
                    fontSize: 12,
                    margin: "2px 0 10px",
                    color: "#6b7280"
                  }}
                >
                  Based on units sold across all time.
                </p>
              </div>
              <div style={{ flex: "1 1 auto", padding: "0 12px 12px" }}>
                {topProductsData.length === 0 ? (
                  <p style={{ fontSize: 13, color: "#6b7280" }}>
                    No products sold yet.
                  </p>
                ) : (
                  <ResponsiveContainer width="100%" height="100%">
                    <BarChart data={topProductsData} layout="vertical">
                      <CartesianGrid strokeDasharray="3 3" />
                      <XAxis type="number" allowDecimals={false} />
                      <YAxis
                        type="category"
                        dataKey="name"
                        width={120}
                        tick={{ fontSize: 11 }}
                      />
                      <Tooltip />
                      <Legend />
                      <Bar dataKey="units_sold" name="Units Sold" />
                    </BarChart>
                  </ResponsiveContainer>
                )}
              </div>
            </div>
          </div>
        </>
      )}
    </div>
  );
}

/* Simple KPI card component */
function KpiCard({ title, value, accent }) {
  return (
    <div
      className="product-card"
      style={{
        borderTop: `3px solid ${accent}`,
        boxShadow: "0 8px 18px rgba(15, 23, 42, 0.06)"
      }}
    >
      <div className="product-body">
        <div
          style={{
            fontSize: 12,
            textTransform: "uppercase",
            letterSpacing: 0.08,
            color: "#6b7280",
            marginBottom: 4
          }}
        >
          {title}
        </div>
        <div
          style={{
            fontSize: 24,
            fontWeight: 700,
            color: "#0f172a"
          }}
        >
          {value}
        </div>
      </div>
    </div>
  );
}

export default AdminDashboardPage;

