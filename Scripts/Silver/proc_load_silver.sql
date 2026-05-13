/*
===============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===============================================================================
Script Purpose:
    This stored procedure performs the ETL (Extract, Transform, Load) process to 
    populate the 'silver' schema tables from the 'bronze' schema.
	Actions Performed:
		- Truncates Silver tables.
		- Inserts transformed and cleansed data from Bronze into Silver tables.
		
Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC Silver.load_silver;
===============================================================================
*/

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
	BEGIN TRY
	SET @batch_start_time = GETDATE();
	PRINT '=========================================';
	PRINT 'Loading Silver Layer';
	PRINT '=========================================';

	PRINT '------------------------------------------';
	PRINT 'Loading CRM Tables';
	PRINT '------------------------------------------';


	-- Loading silver.crm_cust_info 
	Set @start_time = GETDATE();
	PRINT '>> Truncating Table: silver.crm_cust_info';
	TRUNCATE TABLE silver.crm_cust_info;
	PRINT 'Inserting Data Into: silver.crm_cust_info';
	INSERT INTO silver.crm_cust_info(
			customerID,
			gender,
			SeniorCitizen,
			[Partner],
			Dependents,
			tenure,
			dwh_create_date
	)
	SELECT
			customerID,
			gender,
			CASE 
				WHEN SeniorCitizen = '1' THEN 'Yes'
				WHEN SeniorCitizen = '0' THEN 'No'
			END AS SeniorCitizen,
			[Partner],
			Dependents,
			tenure,
			GETDATE()
	FROM (
		SELECT
			*,
			ROW_NUMBER() OVER (PARTITION BY customerID ORDER BY customerID) AS flag_last
		FROM bronze.crm_cust_info
		WHERE customerID IS NOT NULL
	)t
	WHERE flag_last = 1 
	SET @end_time = GETDATE();
	PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
    PRINT '>> -------------';
	PRINT '-----------------------------------';
	PRINT 'Loading ERP Tables';
	PRINT '-----------------------------------';


-- Loading silver.erp_services
Set @start_time = GETDATE();
	PRINT '>> Truncating Table: silver.erp_services';
	TRUNCATE TABLE silver.erp_services;
	PRINT 'Inserting Data Into: silver.erp_services';
	INSERT INTO silver.erp_services(
	customerID,
	PhoneService,
	MultipleLines,
	InternetService,
	OnlineSecurity,
	OnlineBackup,
	DeviceProtection,
	TechSupport,
	StreamingTV,
	StreamingMovies,
	[Contract],
	PaperlessBilling,
	PaymentMethod,
	MonthlyCharges,
	TotalCharges,
	Churn,
	dwh_create_date
	)
SELECT 
	customerID,
	PhoneService,
	MultipleLines,
	InternetService,
	OnlineSecurity,
	OnlineBackup,
	DeviceProtection,
	TechSupport,
	StreamingTV,
	StreamingMovies,
	[Contract],
	PaperlessBilling,
	PaymentMethod,
	MonthlyCharges,
	CASE
		WHEN TotalCharges = ' ' THEN NULL
		ELSE CAST(TotalCharges AS FLOAT)
	END AS TotalCharges,
	Churn,
	GETDATE()
FROM bronze.erp_services;
SET @end_time = GETDATE();
PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
	PRINT '>> -------------';
	SET @batch_end_time = GETDATE();
	PRINT '=========================================';
	PRINT 'Loading Silver Layer is Completed';
	PRINT '   - Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
	PRINT '=========================================';
	END TRY
	BEGIN CATCH
		PRINT '=========================================';
		PRINT 'ERROR OCCURED DURING LOADING SILVER LAYER';
		PRINT 'Error Message: ' + ERROR_MESSAGE();
		PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error State: ' + CAST(ERROR_STATE() AS NVARCHAR);
		PRINT '=========================================';
	END CATCH
END
GO
