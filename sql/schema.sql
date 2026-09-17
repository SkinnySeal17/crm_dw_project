-- ============================================================
-- CRM Sales Opportunities Data Warehouse
-- Database: crm_dw
-- ============================================================

DROP DATABASE IF EXISTS crm_dw;
CREATE DATABASE crm_dw CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE crm_dw;

-- ------------------------------------------------------------
-- 1. sales_teams  (source: sales_teams.xml)
-- ------------------------------------------------------------
CREATE TABLE sales_teams (
    agent_id         INT AUTO_INCREMENT PRIMARY KEY,
    sales_agent      VARCHAR(100) NOT NULL UNIQUE,
    manager          VARCHAR(100),
    regional_office  VARCHAR(50)
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 2. products  (source: products.csv)
-- ------------------------------------------------------------
CREATE TABLE products (
    product_id    INT AUTO_INCREMENT PRIMARY KEY,
    product_name  VARCHAR(100) NOT NULL UNIQUE,
    series        VARCHAR(50),
    sales_price   DECIMAL(12,2)
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 3. accounts  (source: accounts.xml)
-- subsidiary_of is self-referencing (points to another account_id).
-- Nullable because most accounts are not subsidiaries.
-- ------------------------------------------------------------
CREATE TABLE accounts (
    account_id        INT AUTO_INCREMENT PRIMARY KEY,
    account_name      VARCHAR(150) NOT NULL UNIQUE,
    sector            VARCHAR(50),
    year_established  INT,
    revenue           DECIMAL(14,2),
    employees         INT,
    office_location   VARCHAR(100),
    subsidiary_of     INT NULL,
    CONSTRAINT fk_accounts_parent
        FOREIGN KEY (subsidiary_of) REFERENCES accounts(account_id)
        ON DELETE SET NULL
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 4. sales_pipeline (source: sales_pipeline.csv)
-- Natural key opportunity_id kept as PK (already unique in source).
-- account_id nullable: ~1,425 rows have no account recorded in source data.
-- engage_date / close_date / close_value nullable: null for deals
-- still in "Prospecting" / "Engaging" stage (not yet closed).
-- ------------------------------------------------------------
CREATE TABLE sales_pipeline (
    opportunity_id  VARCHAR(20) PRIMARY KEY,
    agent_id        INT,
    product_id      INT,
    account_id      INT NULL,
    deal_stage      VARCHAR(20) NOT NULL,
    engage_date     DATE NULL,
    close_date      DATE NULL,
    close_value     DECIMAL(14,2) NULL,
    CONSTRAINT fk_pipeline_agent
        FOREIGN KEY (agent_id) REFERENCES sales_teams(agent_id),
    CONSTRAINT fk_pipeline_product
        FOREIGN KEY (product_id) REFERENCES products(product_id),
    CONSTRAINT fk_pipeline_account
        FOREIGN KEY (account_id) REFERENCES accounts(account_id)
        ON DELETE SET NULL
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- Helpful indexes for the reports/analyses we need to run
-- ------------------------------------------------------------
CREATE INDEX idx_pipeline_stage   ON sales_pipeline(deal_stage);
CREATE INDEX idx_pipeline_product ON sales_pipeline(product_id);
CREATE INDEX idx_pipeline_account ON sales_pipeline(account_id);
CREATE INDEX idx_accounts_year    ON accounts(year_established);
