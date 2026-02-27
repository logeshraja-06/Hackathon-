-- ============================================================
--  Profitability Calculator — MySQL Schema
--  Database: crop_advisor_db (extend the existing schema)
-- ============================================================

USE crop_advisor_db;

-- ------------------------------------------------------------
-- 9. CROP COST BASELINES (per acre, updated annually)
-- ------------------------------------------------------------
CREATE TABLE crop_cost_baselines (
    id                          INT          UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    crop_id                     INT          UNSIGNED NOT NULL,
    season                      VARCHAR(20)  DEFAULT 'Annual',   -- 'Kharif','Rabi','Zaid','Annual'
    reference_year              YEAR         NOT NULL,
    seed_cost_per_acre          DECIMAL(10,2) NOT NULL,
    fertilizer_cost_per_acre    DECIMAL(10,2) NOT NULL,
    pesticide_cost_per_acre     DECIMAL(10,2) NOT NULL,
    labor_cost_per_acre         DECIMAL(10,2) NOT NULL,
    irrigation_cost_per_acre    DECIMAL(10,2) NOT NULL,
    other_cost_per_acre         DECIMAL(10,2) DEFAULT 0,
    expected_yield_quintals_pa  DECIMAL(10,3) NOT NULL,  -- quintals per acre
    market_price_per_quintal    DECIMAL(10,2) NOT NULL,  -- current/predicted
    state                       VARCHAR(60)  DEFAULT 'Tamil Nadu',
    source                      VARCHAR(100),             -- 'TNAU 2024', 'Manual'
    created_at                  TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
    updated_at                  TIMESTAMP    DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (crop_id) REFERENCES crops(id) ON DELETE CASCADE,
    UNIQUE KEY idx_crop_year_season (crop_id, reference_year, season)
);

-- ------------------------------------------------------------
-- 10. PROFITABILITY CALCULATION LOG (per farmer request)
-- ------------------------------------------------------------
CREATE TABLE profitability_calculations (
    id                      BIGINT       UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    farmer_id               BIGINT       UNSIGNED,            -- nullable for anonymous
    crop_id                 INT          UNSIGNED NOT NULL,
    land_area_acres         DECIMAL(10,3) NOT NULL,
    seed_cost               DECIMAL(12,2),
    fertilizer_cost         DECIMAL(12,2),
    pesticide_cost          DECIMAL(12,2),
    labor_cost              DECIMAL(12,2),
    irrigation_cost         DECIMAL(12,2),
    other_cost              DECIMAL(12,2),
    total_cost              DECIMAL(12,2) NOT NULL,
    expected_yield_quintals DECIMAL(12,3),
    market_price_per_quintal DECIMAL(10,2),
    gross_income            DECIMAL(14,2),
    net_profit              DECIMAL(14,2),
    roi_pct                 DECIMAL(6,2),
    profit_margin_pct       DECIMAL(6,2),
    assessment              ENUM('Excellent','Good','Moderate','Poor') DEFAULT 'Moderate',
    calculated_at           TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (crop_id) REFERENCES crops(id)
);

-- ── Sample data rows ──────────────────────────────────────────────────────────
-- (Assuming crop IDs match the crops table populated from the advisor schema)
-- INSERT INTO crop_cost_baselines
--   (crop_id, reference_year, seed_cost_per_acre, fertilizer_cost_per_acre,
--    pesticide_cost_per_acre, labor_cost_per_acre, irrigation_cost_per_acre,
--    other_cost_per_acre, expected_yield_quintals_pa, market_price_per_quintal)
-- VALUES
--   (1, 2025, 1200, 4500, 1800, 8000, 3500, 1000, 25.0, 2100),    -- Paddy
--   (2, 2025, 2500, 6000, 3500, 10000, 4000, 2000, 120.0, 1500),   -- Tomato
--   (3, 2025, 3000, 5500, 2500, 9000, 3500, 1500, 80.0, 1800),     -- Onion
--   ...
