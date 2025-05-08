/*
===============================================================================
Quality Checks
===============================================================================
Script Purpose:
    This script performs quality checks for data consistency, accuracy, 
    and standardization across the 'silver' layer. It includes checks for:
    - Null or duplicate primary keys.
    - Unwanted spaces in string fields.
    - Data standardization and consistency.
    - Invalid date ranges and orders.
    - Data consistency between related fields.

Usage Notes:
    - Run these checks after data is loaded into the Silver Layer.
    - Investigate and resolve any discrepancies found during the checks.
===============================================================================
*/

-- ====================================================================
-- Checking 'silver.crm_cust_info'
-- ====================================================================
-- Check for NULLs or Duplicates in Primary Key
-- Expectation: No duplicates or NULLs in 'cst_id'
SELECT 
    cst_id,
    COUNT(*) 
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

-- Check for Unwanted Spaces in 'cst_key'
-- Expectation: No extra spaces in 'cst_key'
SELECT 
    cst_key 
FROM silver.crm_cust_info
WHERE cst_key != TRIM(cst_key);

-- Check for Distinct 'cst_marital_status' for Standardization
-- Expectation: Values should be consistent
SELECT DISTINCT 
    cst_marital_status 
FROM silver.crm_cust_info;

-- ====================================================================
-- Checking 'silver.crm_prd_info'
-- ====================================================================
-- Check for NULLs or Duplicates in Primary Key
-- Expectation: No duplicates or NULLs in 'prd_id'
SELECT 
    prd_id,
    COUNT(*) 
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

-- Check for Unwanted Spaces in 'prd_nm'
-- Expectation: No extra spaces in 'prd_nm'
SELECT 
    prd_nm 
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);

-- Check for NULLs or Negative Values in 'prd_cost'
-- Expectation: No negative or NULL values in 'prd_cost'
SELECT 
    prd_cost 
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;

-- Check for Distinct 'prd_line' for Standardization
-- Expectation: Values should be consistent
SELECT DISTINCT 
    prd_line 
FROM silver.crm_prd_info;

-- Check for Invalid Date Orders (Start Date > End Date)
-- Expectation: 'prd_start_dt' should not be later than 'prd_end_dt'
SELECT 
    * 
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt;

-- ====================================================================
-- Checking 'silver.crm_sales_details'
-- ====================================================================
-- Check for Invalid Dates in 'sls_due_dt'
-- Expectation: 'sls_due_dt' should be a valid date (8-digit number within a valid range)
SELECT 
    CASE 
        WHEN sls_due_dt <= 0 OR LENGTH(sls_due_dt::TEXT) != 8 
            OR sls_due_dt > 20500101 OR sls_due_dt < 19000101 
        THEN sls_due_dt
    END AS sls_due_dt 
FROM silver.crm_sales_details
WHERE sls_due_dt <= 0 
    OR LENGTH(sls_due_dt::TEXT) != 8 
    OR sls_due_dt > 20500101 
    OR sls_due_dt < 19000101;

-- Check for Invalid Date Orders (Order Date > Shipping/Due Dates)
-- Expectation: 'sls_order_dt' should not be later than 'sls_ship_dt' or 'sls_due_dt'
SELECT 
    * 
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt 
    OR sls_order_dt > sls_due_dt;

-- Check Data Consistency: Sales = Quantity * Price
-- Expectation: 'sls_sales' should equal 'sls_quantity' * 'sls_price'
SELECT DISTINCT 
    sls_sales,
    sls_quantity,
    sls_price 
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
    OR sls_sales IS NULL 
    OR sls_quantity IS NULL 
    OR sls_price IS NULL
    OR sls_sales <= 0 
    OR sls_quantity <= 0 
    OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price;

-- ====================================================================
-- Checking 'silver.erp_cust_az12'
-- ====================================================================
-- Identify Out-of-Range Dates for 'bdate' (Birthdate)
-- Expectation: 'bdate
