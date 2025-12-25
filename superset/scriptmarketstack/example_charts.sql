-- ============================================================
-- MARKETSTACK DATA - EXAMPLE SQL QUERIES FOR SUPERSET
-- ============================================================
-- Sử dụng các queries này trong SQL Lab để tạo charts

-- ------------------------------------------------------------
-- 1. STOCK PRICE COMPARISON - So sánh giá đóng cửa
-- ------------------------------------------------------------
-- Visualization: Line Chart
-- X-axis: date
-- Y-axis: close (grouped by symbol)
SELECT 
    date::date,
    symbol,
    close
FROM marketstack_data
WHERE date >= CURRENT_DATE - INTERVAL '30 days'
ORDER BY date, symbol;

-- ------------------------------------------------------------
-- 2. DAILY VOLUME LEADERS - Top volumes mỗi ngày
-- ------------------------------------------------------------
-- Visualization: Bar Chart
SELECT 
    date::date,
    symbol,
    volume,
    RANK() OVER (PARTITION BY date::date ORDER BY volume DESC) as volume_rank
FROM marketstack_data
WHERE date >= CURRENT_DATE - INTERVAL '7 days'
ORDER BY date DESC, volume DESC;

-- ------------------------------------------------------------
-- 3. PRICE CHANGE PERCENTAGE - % thay đổi giá
-- ------------------------------------------------------------
-- Visualization: Table or Heatmap
SELECT 
    symbol,
    date::date,
    open,
    close,
    (close - open) AS price_change,
    ROUND(((close - open) / open * 100)::numeric, 2) AS price_change_pct,
    CASE 
        WHEN close > open THEN 'Tăng'
        WHEN close < open THEN 'Giảm'
        ELSE 'Không đổi'
    END as trend
FROM marketstack_data
WHERE date >= CURRENT_DATE - INTERVAL '7 days'
ORDER BY date DESC, price_change_pct DESC;

-- ------------------------------------------------------------
-- 4. MOVING AVERAGE - Trung bình động 7 ngày
-- ------------------------------------------------------------
-- Visualization: Line Chart (Multi-metric)
SELECT 
    date::date,
    symbol,
    close,
    ROUND(AVG(close) OVER (
        PARTITION BY symbol 
        ORDER BY date 
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    )::numeric, 2) AS moving_avg_7day,
    ROUND(AVG(close) OVER (
        PARTITION BY symbol 
        ORDER BY date 
        ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
    )::numeric, 2) AS moving_avg_30day
FROM marketstack_data
WHERE symbol IN ('AAPL', 'MSFT', 'GOOGL')
ORDER BY date DESC, symbol;

-- ------------------------------------------------------------
-- 5. HIGH-LOW RANGE - Biên độ dao động trong ngày
-- ------------------------------------------------------------
-- Visualization: Box Plot or Bar Chart
SELECT 
    symbol,
    date::date,
    low,
    high,
    close,
    (high - low) AS daily_range,
    ROUND(((high - low) / low * 100)::numeric, 2) AS range_pct
FROM marketstack_data
WHERE date >= CURRENT_DATE - INTERVAL '14 days'
ORDER BY daily_range DESC;

-- ------------------------------------------------------------
-- 6. VOLUME TRENDS - Xu hướng khối lượng giao dịch
-- ------------------------------------------------------------
-- Visualization: Area Chart
SELECT 
    date::date,
    symbol,
    volume,
    AVG(volume) OVER (
        PARTITION BY symbol 
        ORDER BY date 
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS avg_volume_7day
FROM marketstack_data
WHERE symbol IN ('AAPL', 'TSLA', 'NVDA')
ORDER BY date, symbol;

-- ------------------------------------------------------------
-- 7. WEEKLY SUMMARY - Tổng hợp theo tuần
-- ------------------------------------------------------------
-- Visualization: Table
SELECT 
    symbol,
    DATE_TRUNC('week', date) AS week,
    MIN(low) AS week_low,
    MAX(high) AS week_high,
    AVG(close)::numeric(10,2) AS avg_close,
    SUM(volume) AS total_volume
FROM marketstack_data
WHERE date >= CURRENT_DATE - INTERVAL '60 days'
GROUP BY symbol, DATE_TRUNC('week', date)
ORDER BY week DESC, symbol;

-- ------------------------------------------------------------
-- 8. CORRELATION MATRIX DATA - Dữ liệu cho correlation
-- ------------------------------------------------------------
-- Visualization: Heatmap (cần pivot)
SELECT 
    a.date::date,
    a.close AS aapl_close,
    m.close AS msft_close,
    g.close AS googl_close,
    t.close AS tsla_close
FROM 
    (SELECT date, close FROM marketstack_data WHERE symbol = 'AAPL') a
    FULL OUTER JOIN 
    (SELECT date, close FROM marketstack_data WHERE symbol = 'MSFT') m ON a.date = m.date
    FULL OUTER JOIN 
    (SELECT date, close FROM marketstack_data WHERE symbol = 'GOOGL') g ON a.date = g.date
    FULL OUTER JOIN 
    (SELECT date, close FROM marketstack_data WHERE symbol = 'TSLA') t ON a.date = t.date
WHERE a.date >= CURRENT_DATE - INTERVAL '90 days'
ORDER BY a.date DESC;

-- ------------------------------------------------------------
-- 9. TOP GAINERS & LOSERS - Cổ phiếu tăng/giảm nhiều nhất
-- ------------------------------------------------------------
-- Visualization: Big Number or Table
WITH daily_change AS (
    SELECT 
        symbol,
        MAX(date)::date AS latest_date,
        FIRST_VALUE(close) OVER (PARTITION BY symbol ORDER BY date DESC) AS latest_close,
        FIRST_VALUE(close) OVER (PARTITION BY symbol ORDER BY date DESC ROWS BETWEEN 1 FOLLOWING AND 1 FOLLOWING) AS prev_close
    FROM marketstack_data
    GROUP BY symbol, date, close
)
SELECT 
    symbol,
    latest_date,
    latest_close,
    prev_close,
    (latest_close - prev_close) AS price_change,
    ROUND(((latest_close - prev_close) / prev_close * 100)::numeric, 2) AS change_pct
FROM daily_change
WHERE prev_close IS NOT NULL
ORDER BY change_pct DESC;

-- ------------------------------------------------------------
-- 10. CANDLESTICK DATA - Dữ liệu cho biểu đồ nến
-- ------------------------------------------------------------
-- Visualization: Custom (cần plugin hoặc export)
SELECT 
    date::date,
    symbol,
    open,
    high,
    low,
    close,
    volume,
    CASE 
        WHEN close >= open THEN 'bull'
        ELSE 'bear'
    END as candle_type
FROM marketstack_data
WHERE symbol = 'AAPL'
    AND date >= CURRENT_DATE - INTERVAL '30 days'
ORDER BY date;

-- ============================================================
-- TIPS:
-- - Sử dụng WHERE để filter theo symbol hoặc date range
-- - Thêm LIMIT khi test query
-- - Cache results cho query phức tạp
-- - Tạo virtual dataset từ query để reuse
-- ============================================================
