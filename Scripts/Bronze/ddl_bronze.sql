/*
===============================================================================
DDL Script: Create Bronze Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'bronze' schema, dropping existing tables 
    if they already exist.
	Run this script to re-define the DDL structure of 'bronze' Tables
===============================================================================
*/

IF OBJECT_ID('bronze.crm_cust_info', 'U') IS NOT NULL
    DROP TABLE bronze.crm_cust_info;
GO

CREATE TABLE bronze.crm_cust_info (
    customerID          NVARCHAR(50),
    gender              NVARCHAR(50),
    SeniorCitizen       INT,
    [Partner]           NVARCHAR(50),
    Dependents          NVARCHAR(50),
    tenure              INT

);
GO



IF OBJECT_ID('bronze.erp_services', 'U') IS NOT NULL
    DROP TABLE bronze.erp_services;
GO

CREATE TABLE bronze.erp_services (
    customerID       NVARCHAR(50),
    PhoneService     NVARCHAR(50),
    MultipleLines    NVARCHAR(50),
    InternetService  NVARCHAR(50),
    OnlineSecurity   NVARCHAR(50),
    OnlineBackup     NVARCHAR(50),
    DeviceProtection NVARCHAR(50),
    TechSupport      NVARCHAR(50),
    StreamingTV      NVARCHAR(50),
    StreamingMovies  NVARCHAR(50),
    [Contract]       NVARCHAR(50),
    PaperlessBilling NVARCHAR(50),
    PaymentMethod    NVARCHAR(50),
    MonthlyCharges   FLOAT,
    TotalCharges     NVARCHAR(50),
    Churn            NVARCHAR(50)
    

    
);
GO

