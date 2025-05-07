-- Ensure the function is created or replaced
CREATE OR REPLACE FUNCTION silver.load_silver() 
RETURNS VOID AS
$$
DECLARE
    start_time TIMESTAMP;
    end_time TIMESTAMP;
    batch_start_time TIMESTAMP;
    batch_end_time TIMESTAMP;
BEGIN
    -- Initialize the batch start time
    batch_start_time := CURRENT_TIMESTAMP;
    RAISE NOTICE '================================================';
    RAISE NOTICE 'Loading Silver Layer';
    RAISE NOTICE '================================================';

    -- Loading CRM Tables
    RAISE NOTICE '------------------------------------------------';
    RAISE NOTICE 'Loading CRM Tables';
    RAISE NOTICE '------------------------------------------------';

    -- Loading silver.crm_cust_info
    start_time := CURRENT_TIMESTAMP;
    RAISE NOTICE '>> Truncating Table: silver.crm_cust_info';
    TRUNCATE silver.crm_cust_info;
    RAISE NOTICE '>> Inserting Data Into: silver.crm_cust_info';
    INSERT INTO silver.crm_cust_info (
        cst_id, 
        cst_key, 
        cst_firstname, 
        cst_lastname, 
        cst_marital_status, 
        cst_gndr,
        cst_create_date
    )
    SELECT
        cst_id,
        cst_key,
        TRIM(cst_firstname) AS cst_firstname,
        TRIM(cst_lastname) AS cst_lastname,
        CASE 
            WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
            WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
            ELSE 'n/a'
        END AS cst_marital_status,
        CASE 
            WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
            WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
            ELSE 'n/a'
        END AS cst_gndr,
        cst_create_date
    FROM (
        SELECT
            *,
            ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
        FROM bronze.crm_cust_info
        WHERE cst_id IS NOT NULL
    ) t
    WHERE flag_last = 1; -- Select the most recent record per customer
    end_time := CURRENT_TIMESTAMP;
    RAISE NOTICE '>> Load Duration: % seconds', EXTRACT(EPOCH FROM (end_time - start_time));

    -- Loading silver.crm_prd_info
    start_time := CURRENT_TIMESTAMP;
    RAISE NOTICE '>> Truncating Table: silver.crm_prd_info';
    TRUNCATE silver.crm_prd_info;
    RAISE NOTICE '>> Inserting Data Into: silver.crm_prd_info';
    INSERT INTO silver.crm_prd_info (
        prd_id,
        cat_id,
        prd_key,
        prd_nm,
        prd_cost,
        prd_line,
        prd_start_dt,
        prd_end_dt
    )
    SELECT
        prd_id,
        REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
        SUBSTRING(prd_key, 7, LENGTH(prd_key)) AS prd_key,
        prd_nm,
        COALESCE(prd_cost, 0) AS prd_cost,
        CASE 
            WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
            WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
            WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
            WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
            ELSE 'n/a'
        END AS prd_line,
        CAST(prd_start_dt AS DATE) AS prd_start_dt,
        CAST(
            LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) - INTERVAL '1 day' 
            AS DATE
        ) AS prd_end_dt
    FROM bronze.crm_prd_info;
    end_time := CURRENT_TIMESTAMP;
    RAISE NOTICE '>> Load Duration: % seconds', EXTRACT(EPOCH FROM (end_time - start_time));

    -- Loading crm_sales_details
    start_time := CURRENT_TIMESTAMP;
    RAISE NOTICE '>> Truncating Table: silver.crm_sales_details';
    TRUNCATE silver.crm_sales_details;
    RAISE NOTICE '>> Inserting Data Into: silver.crm_sales_details';
    INSERT INTO silver.crm_sales_details (
        sls_ord_num,
        sls_prd_key,
        sls_cust_id,
        sls_order_dt,
        sls_ship_dt,
        sls_due_dt,
        sls_sales,
        sls_quantity,
        sls_price
    )
    SELECT 
        sls_ord_num,
        sls_prd_key,
        sls_cust_id,
        CASE 
            WHEN sls_order_dt = 0 OR LENGTH(CAST(sls_order_dt AS TEXT)) != 8 THEN NULL
            ELSE TO_DATE(CAST(sls_order_dt AS TEXT), 'YYYYMMDD')
        END AS sls_order_dt,

        CASE 
            WHEN sls_ship_dt = 0 OR LENGTH(CAST(sls_ship_dt AS TEXT)) != 8 THEN NULL
            ELSE TO_DATE(CAST(sls_ship_dt AS TEXT), 'YYYYMMDD')
        END AS sls_ship_dt,

        CASE 
            WHEN sls_due_dt = 0 OR LENGTH(CAST(sls_due_dt AS TEXT)) != 8 THEN NULL
            ELSE TO_DATE(CAST(sls_due_dt AS TEXT), 'YYYYMMDD')
        END AS sls_due_dt,
        COALESCE(sls_sales, sls_quantity * ABS(sls_price)) AS sls_sales,
        sls_quantity,
        COALESCE(sls_price, sls_sales / NULLIF(sls_quantity, 0)) AS sls_price
    FROM bronze.crm_sales_details;
    end_time := CURRENT_TIMESTAMP;
    RAISE NOTICE '>> Load Duration: % seconds', EXTRACT(EPOCH FROM (end_time - start_time));

    -- Loading other tables...
    -- Repeat similar pattern for the other tables like erp_cust_az12, erp_loc_a101, etc.

    -- Final log
    batch_end_time := CURRENT_TIMESTAMP;
    RAISE NOTICE '==========================================';
    RAISE NOTICE 'Loading Silver Layer is Completed';
    RAISE NOTICE 'Total Load Duration: % seconds', EXTRACT(EPOCH FROM (batch_end_time - batch_start_time));
    RAISE NOTICE '==========================================';
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE '==========================================';
        RAISE NOTICE 'ERROR OCCURRED DURING LOADING BRONZE LAYER';
        RAISE NOTICE 'Error Message: %', SQLERRM;
        RAISE NOTICE '==========================================';
END;
$$ LANGUAGE plpgsql;
