/*
===============================================================================
DDL Script: Create Gold Views
===============================================================================
Script Purpose:
    This script creates views for the Gold layer in the data warehouse. 
    The Gold layer represents the final dimension and fact tables (Star Schema)

    Each view performs transformations and combines data from the Silver layer 
    to produce a clean, enriched, and business-ready dataset.

Usage:
    - These views can be queried directly for analytics and reporting.
===============================================================================
*/

-- =============================================================================
-- Create Dimension: gold.dim_customers
-- =============================================================================
IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL
	DROP VIEW gold.dim_customers;
GO

CREATE OR ALTER VIEW gold.dim_customers AS
SELECT
	ROW_NUMBER() OVER (ORDER BY customerID) AS customer_key,
	customerID,
	gender,
	SeniorCitizen,
	[Partner],
	Dependents,
	tenure
FROM silver.crm_cust_info
GO

-- =============================================================================
-- Create Dimension: gold.dim_services
-- =============================================================================



IF OBJECT_ID('gold.dim_services','V') IS NOT NULL
	DROP VIEW gold.dim_services;
GO

CREATE OR ALTER VIEW gold.dim_services AS 
SELECT
	ROW_NUMBER() OVER (ORDER BY customerID) AS service_key,
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
	PaymentMethod
FROM silver.erp_services
GO


--SELECT TOP 5 * FROM gold.dim_services

IF OBJECT_ID('gold.fact_churn','V') IS NOT NULL 
	DROP VIEW gold.fact_churn;
GO

CREATE OR ALTER VIEW gold.fact_churn AS
SELECT
	dc.customer_key,
	ds.service_key,
	e.Churn,
	e.MonthlyCharges,
	e.TotalCharges
FROM silver.crm_cust_info c
JOIN silver.erp_services e ON c.customerID = e.customerID
JOIN gold.dim_customers dc ON c.customerID = dc.customerID
JOIN gold.dim_services ds ON e.customerID = ds.customerID
GO
