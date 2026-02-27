-- ============================================================
--  Crop Advisor — MySQL Database Schema
--  Database: crop_advisor_db
-- ============================================================

CREATE DATABASE IF NOT EXISTS crop_advisor_db CHARACTER SET utf8mb4;
USE crop_advisor_db;

-- ------------------------------------------------------------
-- 1. SOIL TYPES reference table
-- ------------------------------------------------------------
CREATE TABLE soil_types (
    id          TINYINT      UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    code        VARCHAR(30)  NOT NULL UNIQUE,          -- e.g. 'BLACK', 'RED'
    name        VARCHAR(60)  NOT NULL,
    description TEXT
);

INSERT INTO soil_types (code, name, description) VALUES
  ('RED',      'Red Soil',              'Slightly acidic, good drainage, low moisture retention'),
  ('BLACK',    'Black Soil (Regur)',    'High clay content, excellent moisture, nutrient-rich'),
  ('SANDY',    'Sandy Soil',            'Well-drained, low nutrients, dries quickly'),
  ('CLAY',     'Clay / Alluvial Soil',  'Heavy, high water retention, fertile'),
  ('LOAMY',    'Loamy Soil',            'Balanced texture, best for most crops'),
  ('LATERITE', 'Laterite Soil',         'Iron-rich, acidic, good drainage');

-- ------------------------------------------------------------
-- 2. CROPS master table
-- ------------------------------------------------------------
CREATE TABLE crops (
    id                    INT          UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name                  VARCHAR(80)  NOT NULL UNIQUE,
    category              VARCHAR(40)  NOT NULL,   -- 'Vegetables','Cereals','Pulses','Commercial','Fruits','Spices'
    emoji                 VARCHAR(10),
    growing_weeks_min     TINYINT      UNSIGNED NOT NULL,
    growing_weeks_max     TINYINT      UNSIGNED NOT NULL,
    best_sowing_months    VARCHAR(60),             -- 'Jun–Jul / Nov–Dec'
    water_need            ENUM('High','Medium','Low') NOT NULL,
    created_at            TIMESTAMP    DEFAULT CURRENT_TIMESTAMP
);

-- ------------------------------------------------------------
-- 3. CROP ↔ SOIL compatibility (many-to-many)
-- ------------------------------------------------------------
CREATE TABLE crop_soil_compatibility (
    crop_id     INT          UNSIGNED NOT NULL,
    soil_id     TINYINT      UNSIGNED NOT NULL,
    suitability TINYINT      DEFAULT 100,   -- 0-100 score
    PRIMARY KEY (crop_id, soil_id),
    FOREIGN KEY (crop_id) REFERENCES crops(id)    ON DELETE CASCADE,
    FOREIGN KEY (soil_id) REFERENCES soil_types(id) ON DELETE CASCADE
);

-- ------------------------------------------------------------
-- 4. PREFERRED REGIONS per crop
-- ------------------------------------------------------------
CREATE TABLE crop_regions (
    id          INT          UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    crop_id     INT          UNSIGNED NOT NULL,
    region_name VARCHAR(80)  NOT NULL,   -- 'Madurai', 'Thanjavur', etc.
    climate     VARCHAR(40),             -- 'Tropical', 'Semi-arid'
    FOREIGN KEY (crop_id) REFERENCES crops(id) ON DELETE CASCADE
);

-- ------------------------------------------------------------
-- 5. MARKET PRICE HISTORY (actual recorded prices)
-- ------------------------------------------------------------
CREATE TABLE market_price_history (
    id              INT          UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    crop_id         INT          UNSIGNED NOT NULL,
    region_name     VARCHAR(80)  NOT NULL,
    price_date      DATE         NOT NULL,
    price_rs_quintal DECIMAL(10,2) NOT NULL,  -- ₹ per quintal
    market_name     VARCHAR(100),
    source          VARCHAR(60),              -- 'AGMARKNET', 'Manual', etc.
    created_at      TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (crop_id) REFERENCES crops(id) ON DELETE CASCADE,
    INDEX idx_crop_date (crop_id, price_date),
    INDEX idx_region_date (region_name, price_date)
);

-- ------------------------------------------------------------
-- 6. MARKET PRICE TREND (pre-computed — updated monthly by scheduler)
-- ------------------------------------------------------------
CREATE TABLE market_price_trend (
    id                  INT          UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    crop_id             INT          UNSIGNED NOT NULL UNIQUE,
    avg_price_1yr       DECIMAL(10,2),
    avg_price_6mo       DECIMAL(10,2),
    avg_price_3mo       DECIMAL(10,2),
    forecast_min_6mo    DECIMAL(10,2),   -- predicted min in next 3-6 months
    forecast_max_6mo    DECIMAL(10,2),   -- predicted max in next 3-6 months
    trend               ENUM('Rising','Stable','Falling') DEFAULT 'Stable',
    confidence_pct      TINYINT      DEFAULT 70,
    computed_at         TIMESTAMP    DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (crop_id) REFERENCES crops(id) ON DELETE CASCADE
);

-- ------------------------------------------------------------
-- 7. FARMER INPUT LOG (optional — analytics / personalisation)
-- ------------------------------------------------------------
CREATE TABLE recommendation_requests (
    id              BIGINT       UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    farmer_id       BIGINT       UNSIGNED,          -- nullable for anonymous
    soil_type_code  VARCHAR(30)  NOT NULL,
    water_need      ENUM('High','Medium','Low') NOT NULL,
    region          VARCHAR(80),
    requested_at    TIMESTAMP    DEFAULT CURRENT_TIMESTAMP
);

-- ------------------------------------------------------------
-- 8. RECOMMENDATION RESULTS LOG
-- ------------------------------------------------------------
CREATE TABLE recommendation_results (
    id              BIGINT       UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    request_id      BIGINT       UNSIGNED NOT NULL,
    crop_id         INT          UNSIGNED NOT NULL,
    rank            TINYINT,
    match_score     TINYINT,
    FOREIGN KEY (request_id) REFERENCES recommendation_requests(id) ON DELETE CASCADE,
    FOREIGN KEY (crop_id)    REFERENCES crops(id)
);
