-- =====================================================================


DROP TABLE IF EXISTS fact_returns CASCADE;
DROP TABLE IF EXISTS fact_tradein CASCADE;
DROP TABLE IF EXISTS fact_inventory CASCADE;
DROP TABLE IF EXISTS fact_marketing CASCADE;
DROP TABLE IF EXISTS fact_sales CASCADE;
DROP TABLE IF EXISTS dim_market CASCADE;
DROP TABLE IF EXISTS dim_date CASCADE;
DROP TABLE IF EXISTS dim_store CASCADE;
DROP TABLE IF EXISTS dim_customer CASCADE;
DROP TABLE IF EXISTS dim_product CASCADE;



CREATE TABLE dim_product (
    product_id      VARCHAR(10)   PRIMARY KEY,
    iphone_model    VARCHAR(50)   NOT NULL,
    generation      SMALLINT      NOT NULL,
    series          VARCHAR(20)   NOT NULL,
    pro_flag        VARCHAR(3)    NOT NULL CHECK (pro_flag IN ('Yes','No')),
    storage         VARCHAR(10)   NOT NULL,
    color           VARCHAR(20)   NOT NULL,
    launch_date     DATE          NOT NULL,
    mrp_usd         NUMERIC(10,2) NOT NULL,
    unit_cost_usd   NUMERIC(10,2) NOT NULL,
    price_tier      VARCHAR(20)   NOT NULL
);

CREATE TABLE dim_customer (
    customer_id                VARCHAR(10)  PRIMARY KEY,
    customer_name               VARCHAR(100) NOT NULL,
    country                     VARCHAR(50)  NOT NULL,
    age_group                   VARCHAR(10)  NOT NULL,
    customer_segment            VARCHAR(30)  NOT NULL,
    previous_device             VARCHAR(50)  NOT NULL,
    existing_apple_customer     VARCHAR(3)   NOT NULL CHECK (existing_apple_customer IN ('Yes','No')),
    customer_since              DATE         NOT NULL,
    upgrade_eligible             VARCHAR(3)   NOT NULL CHECK (upgrade_eligible IN ('Yes','No'))
);

CREATE TABLE dim_store (
    store_id     VARCHAR(10)  PRIMARY KEY,
    store_name   VARCHAR(100) NOT NULL,
    country      VARCHAR(50)  NOT NULL,
    city         VARCHAR(50)  NOT NULL,
    region       VARCHAR(50)  NOT NULL,
    channel      VARCHAR(30)  NOT NULL,
    store_type   VARCHAR(30)  NOT NULL
);

CREATE TABLE dim_date (
    date          DATE PRIMARY KEY,
    year          SMALLINT NOT NULL,
    quarter       VARCHAR(2) NOT NULL,
    month_number  SMALLINT NOT NULL,
    month_name    VARCHAR(15) NOT NULL,
    year_month    VARCHAR(7) NOT NULL,
    week_number   SMALLINT NOT NULL,
    day_name      VARCHAR(10) NOT NULL
);

CREATE TABLE dim_market (
    country                             VARCHAR(50) NOT NULL,
    month                                VARCHAR(7)  NOT NULL,
    apple_market_share_pct              NUMERIC(5,2) NOT NULL,
    samsung_market_share_pct            NUMERIC(5,2) NOT NULL,
    google_market_share_pct             NUMERIC(5,2) NOT NULL,
    oneplus_market_share_pct            NUMERIC(5,2) NOT NULL,
    other_market_share_pct              NUMERIC(5,2) NOT NULL,
    total_smartphone_market_units       BIGINT NOT NULL,
    premium_smartphone_market_units     BIGINT NOT NULL,
    PRIMARY KEY (country, month)
);


CREATE TABLE fact_sales (
    order_id                INTEGER      PRIMARY KEY,
    order_date               DATE         NOT NULL,
    customer_id              VARCHAR(10)  NOT NULL REFERENCES dim_customer(customer_id),
    product_id               VARCHAR(10)  NOT NULL REFERENCES dim_product(product_id),
    store_id                 VARCHAR(10)  NOT NULL REFERENCES dim_store(store_id),
    campaign_id               VARCHAR(10)  NOT NULL,
    mrp_usd                   NUMERIC(10,2) NOT NULL,
    discount_usd               NUMERIC(10,2) NOT NULL,
    discount_percentage        SMALLINT     NOT NULL,
    bank_cashback_usd           NUMERIC(10,2) NOT NULL,
    exchange_benefit_usd        NUMERIC(10,2) NOT NULL,
    effective_price_usd         NUMERIC(10,2) NOT NULL,
    has_tradein                 VARCHAR(3)   NOT NULL CHECK (has_tradein IN ('Yes','No')),
    has_return                  VARCHAR(3)   NOT NULL CHECK (has_return IN ('Yes','No')),
    quantity_assumed            SMALLINT     NOT NULL DEFAULT 1,  -- PLACEHOLDER, see note above
    revenue_proxy_usd            NUMERIC(10,2) NOT NULL           -- PLACEHOLDER, see note above
);


CREATE TABLE fact_marketing (
    campaign_id                  VARCHAR(10)  PRIMARY KEY,
    country                      VARCHAR(50)  NOT NULL,
    month                        VARCHAR(7)   NOT NULL,
    campaign_channel             VARCHAR(30)  NOT NULL,
    campaign_name                VARCHAR(100) NOT NULL,
    marketing_spend_usd           NUMERIC(12,2) NOT NULL,
    impressions                  BIGINT NOT NULL,
    clicks                       BIGINT NOT NULL,
    leads                        BIGINT NOT NULL,
    conversions                  BIGINT NOT NULL,
    ctr_pct                      NUMERIC(6,2),
    lead_conversion_rate_pct      NUMERIC(6,2),
    cost_per_lead_usd             NUMERIC(10,2),
    cac_usd                      NUMERIC(10,2)
);


CREATE TABLE fact_inventory (
    month           DATE          NOT NULL,
    store_id        VARCHAR(10)   NOT NULL REFERENCES dim_store(store_id),
    product_id      VARCHAR(10)   NOT NULL REFERENCES dim_product(product_id),
    opening_stock   INTEGER NOT NULL,
    stock_received  INTEGER NOT NULL,
    units_sold      INTEGER NOT NULL,
    closing_stock   INTEGER NOT NULL,
    stock_days      NUMERIC(8,2) NOT NULL,
    stock_status    VARCHAR(20) NOT NULL,
    PRIMARY KEY (month, store_id, product_id)
);


CREATE TABLE fact_tradein (
    tradein_id                VARCHAR(10) PRIMARY KEY,
    order_id                  INTEGER NOT NULL REFERENCES fact_sales(order_id),
    tradein_date               DATE NOT NULL,
    old_device                 VARCHAR(50) NOT NULL,
    old_device_brand            VARCHAR(30) NOT NULL,
    estimated_value_usd          NUMERIC(10,2) NOT NULL,
    final_tradein_value_usd       NUMERIC(10,2) NOT NULL,
    new_iphone_model             VARCHAR(50) NOT NULL,
    upgrade_flag                VARCHAR(3) NOT NULL
);


CREATE TABLE fact_returns (
    return_id           VARCHAR(10) PRIMARY KEY,
    order_id             INTEGER NOT NULL REFERENCES fact_sales(order_id),
    return_date           DATE NOT NULL,
    iphone_model          VARCHAR(50) NOT NULL,
    return_quantity        INTEGER NOT NULL,
    refund_amount_usd       NUMERIC(10,2) NOT NULL,
    return_reason          VARCHAR(50) NOT NULL,
    return_status          VARCHAR(20) NOT NULL
);

CREATE INDEX idx_fact_sales_customer ON fact_sales(customer_id);
CREATE INDEX idx_fact_sales_product  ON fact_sales(product_id);
CREATE INDEX idx_fact_sales_store    ON fact_sales(store_id);
CREATE INDEX idx_fact_sales_date     ON fact_sales(order_date);
CREATE INDEX idx_fact_inventory_month ON fact_inventory(month);
