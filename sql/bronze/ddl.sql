-- Drop the table if it exists in the "bronze" schema
DROP TABLE IF EXISTS bronze.crm_cust_info;

-- Create the table in the "bronze" schema
CREATE TABLE bronze.crm_cust_info (
    cst_id              INTEGER,
    cst_key             VARCHAR(50),
    cst_firstname       VARCHAR(50),
    cst_lastname        VARCHAR(50),
    cst_marital_status  VARCHAR(50),
    cst_gndr            VARCHAR(50),
    cst_create_date     DATE
);

-- Drop the table if it exists in the "bronze" schema
DROP TABLE IF EXISTS bronze.crm_prd_info;

-- Create the table in the "bronze" schema
CREATE TABLE bronze.crm_prd_info (
    prd_id       INTEGER,
    prd_key      VARCHAR(50),
    prd_nm       VARCHAR(50),
    prd_cost     INTEGER,
    prd_line     VARCHAR(50),
    prd_start_dt DATE,
    prd_end_dt   DATE
);

-- Drop the table if it exists in the "bronze" schema
DROP TABLE IF EXISTS bronze.crm_sales_details;

-- Create the table in the "bronze" schema
CREATE TABLE bronze.crm_sales_details (
    sls_ord_num  VARCHAR(50),
    sls_prd_key  VARCHAR(50),
    sls_cust_id  INTEGER,
    sls_order_dt INTEGER,  -- Changed to DATE to store date values
    sls_ship_dt  INTEGER,  -- Changed to DATE to store date values
    sls_due_dt   INTEGER,  -- Changed to DATE to store date values
    sls_sales    INTEGER,
    sls_quantity INTEGER,
    sls_price    INTEGER
);

-- Drop the table if it exists in the "bronze" schema
DROP TABLE IF EXISTS bronze.erp_loc_a101;

-- Create the table in the "bronze" schema
CREATE TABLE bronze.erp_loc_a101 (
    cid    VARCHAR(50),
    cntry  VARCHAR(50)
);

-- Drop the table if it exists in the "bronze" schema
DROP TABLE IF EXISTS bronze.erp_cust_az12;

-- Create the table in the "bronze" schema
CREATE TABLE bronze.erp_cust_az12 (
    cid    VARCHAR(50),
    bdate  DATE,
    gen    VARCHAR(50)
);

-- Drop the table if it exists in the "bronze" schema
DROP TABLE IF EXISTS bronze.erp_px_cat_g1v2;

-- Create the table in the "bronze" schema
CREATE TABLE bronze.erp_px_cat_g1v2 (
    id           VARCHAR(50),
    cat          VARCHAR(50),
    subcat       VARCHAR(50),
    maintenance  VARCHAR(50)
);
