# Telecom-Churn-Data-Warehouse
Welcome to the Telecom Customer Churn Data Warehouse repository!
This project demonstrates a comprehensive data warehousing solution built from scratch — from raw data ingestion to a business-ready star schema designed for analytics and reporting. Built as a portfolio project, it highlights industry best practices in data engineering using real telecom customer data.

🏗️ Data Architecture
The project follows the Medallion Architecture with Bronze, Silver, and Gold layers:

Bronze Layer: Stores raw data as-is from the source systems. Data is ingested from CSV files into SQL Server using BULK INSERT.
Silver Layer: Includes data cleansing, standardization, and deduplication processes to prepare data for analysis.
Gold Layer: Houses business-ready data modelled into a star schema optimized for reporting and analytics.

📖 Project Overview
This project involves:

Data Architecture: Designing a modern data warehouse using Medallion Architecture (Bronze, Silver, Gold).
ETL Pipelines: Extracting, transforming, and loading data from two source systems into the warehouse.
Data Modeling: Developing fact and dimension tables optimized for analytical queries.
Analytics & Reporting: Building a star schema that enables business analysts to answer key churn questions.
