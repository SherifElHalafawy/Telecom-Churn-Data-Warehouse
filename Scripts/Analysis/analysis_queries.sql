/*
====================================================================
Analysis Queries: Telecom Churn
The purpose of these queries is to answer key business questions about customer churn using the Gold layer.

Assumptions (verified against the silver layer):
	- fact_churn.Churn holds the text values 'Yes' / 'No'
	- MonthlyCharges is a numeric column (DECIMAL or FLOAT)
	- dim_customers.tenure is a number of months
====================================================================
*/
-- ====================================================================
-- Q1: What is our overall churn rate?
--=====================================================================
SELECT
	COUNT(*)  AS total_customers,
	SUM(CASE WHEN Churn = 'Yes' Then 1 ELSE 0 END) AS Churned_customers,
	CAST(100.0 * SUM(CASE WHEN Churn = 'Yes' Then 1 ELSE 0 END)
		 / COUNT(*) AS DECIMAL(5,2)) AS churn_rate_pct
FROM gold.fact_churn;


-- ====================================================================
-- Q2: Which contract type churns the most?
--=====================================================================

SELECT
	ds.[Contract],
	COUNT(*)														AS customers,
	SUM(CASE WHEN f.Churn = 'Yes' THEN 1 ELSE 0 END)				AS churned,
	CAST(100.0 * SUM(CASE WHEN f.Churn = 'Yes' THEN 1 ELSE 0 END)
		 / COUNT(*) AS DECIMAL(5,2))								AS churn_rate_pct			

FROM gold.fact_churn f
JOIN gold.dim_services ds
	ON f.service_key = ds.service_key
GROUP BY ds.[Contract]
ORDER BY churn_rate_pct DESC
;


-- ====================================================================
-- Q3: Are new customers more likely to leave? (Churn by tenure group)
--=====================================================================
SELECT 
	CASE
		WHEN dc.tenure <= 12 THEN '1. 0-12 months'
		WHEN dc.tenure <= 24 THEN '2. 13-24 months'
		WHEN dc.tenure <= 48 THEN '3. 25-48 months'
		ELSE					   '4. 49+ months'
	END																	AS tenure_group,
	COUNT(*)															AS customers,
	CAST(100.0 * SUM(CASE WHEN f.Churn = 'Yes' THEN 1 ELSE 0 END)
         / COUNT(*) AS DECIMAL(5,2))													AS churn_rate_pct
FROM gold.fact_churn f
JOIN  gold.dim_customers dc
	ON f.customer_key = dc.customer_key
GROUP BY 
		CASE
		WHEN dc.tenure <= 12 THEN '1. 0-12 months'
		WHEN dc.tenure <= 24 THEN '2. 13-24 months'
		WHEN dc.tenure <= 48 THEN '3. 25-48 months'
		ELSE					   '4. 49+ months'
	END			
ORDER BY tenure_group
;

-- ====================================================================
-- Q4: Does tech support or internet type affect churn?
--=====================================================================
SELECT
	ds.InternetService,
	ds.TechSupport,
	COUNT(*)				AS customers,
	CAST(100.0 * SUM(CASE WHEN f.Churn = 'Yes' THEN 1 ELSE 0 END)
         / COUNT(*) AS DECIMAL(5,2))													AS churn_rate_pct
FROM gold.fact_churn f
JOIN gold.dim_services ds
	ON f.service_key = ds.service_key
GROUP BY ds.InternetService, ds.TechSupport
ORDER BY ds.InternetService, ds.TechSupport
;


-- ====================================================================
-- Q5: How much monthly revenue are we losing to churn, by contract type?
--=====================================================================
SELECT 
	ds.[Contract],
	SUM(CASE WHEN f.churn = 'Yes' THEN f.MonthlyCharges ELSE 0 END)					AS monthly_revenue_lost,
	CAST(100.0 * SUM(CASE WHEN f.churn = 'Yes' THEN f.MonthlyCharges ELSE 0 END)
		 / SUM(SUM(CASE WHEN f.churn = 'Yes' THEN f.MonthlyCharges ELSE 0 END)) OVER () AS DECIMAL(5,2))	AS pct_of_total_loss
FROM gold.fact_churn f
JOIN gold.dim_services ds
	ON f.service_key = ds.service_key
GROUP BY ds.[Contract]
ORDER BY monthly_revenue_lost DESC
;

-- ====================================================================
-- Q6: Rank payment methods from highest to lowest churn rate
--=====================================================================

WITH payment_churn AS(
SELECT
	ds.[PaymentMethod],
	COUNT(*)				AS customers,
	Cast(100.0 * SUM(CASE WHEN f.churn = 'Yes' THEN 1 ELSE 0 END)
		 / COUNT(*) AS DECIMAL(5,2))  AS churn_rate_pct
	
FROM gold.fact_churn f
JOIN gold.dim_services ds
	ON f.service_key = ds.service_key
GROUP BY ds.PaymentMethod
)
SELECT 
	RANK() OVER (ORDER BY churn_rate_pct DESC) as risk_rank,
	PaymentMethod,
	customers,
	churn_rate_pct
FROM payment_churn
ORDER BY risk_rank
;

-- ====================================================================
-- Q7: Do demographics matter? 
--=====================================================================

SELECT 
	'SeniorCitizen' AS Attribute,
	CAST(Dc.SeniorCitizen AS varchar(10))	AS Value,
	COUNT(*)								AS customers,
	CAST(100.0 * SUM(CASE WHEN f.churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(*) AS DECIMAL(5,2)) AS churn_rate_pct
FROM gold.fact_churn f

JOIN gold.dim_customers dc
	ON f.customer_key = dc.customer_key
GROUP BY dc.SeniorCitizen

UNION ALL
SELECT 
	'Partner',
	CAST (dc.[Partner] AS varchar(10)),
	COUNT(*),
	CAST(100.0 * SUM(CASE WHEN f.churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(*) AS DECIMAL(5,2)) AS churn_rate_pct
FROM gold.fact_churn f
JOIN gold.dim_customers dc
	ON f.customer_key = dc.customer_key
GROUP BY dc.[Partner]
UNION ALL
SELECT
	'Dependents',
	CAST(dc.dependents as varchar(10)),
	COUNT(*),
	CAST(100.0 *SUM(CASE WHEN f.churn = 'Yes' THEN 1 ELSE 0 END)/ COUNT(*) AS DECIMAL (5,2)) AS churn_rate_pct
FROM gold.fact_churn f
JOIN gold.dim_customers dc
	ON f.customer_key = dc.customer_key
GROUP BY dc.dependents
;

-- ====================================================================
-- Q8:Which customer segments are the highest risk?
-- A segment is a contract + internet service combination. Ignore any segment below 100 customers.
--=====================================================================

WITH segments AS (
SELECT
	ds.[Contract],
	ds.InternetService,
	COUNT(*)				AS customers,
	SUM(CASE WHEN f.churn = 'Yes' THEN 1 ELSE 0 END) AS churned,
	CAST(100.0 * SUM(CASE WHEN f.churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(*) AS DECIMAL (5,2)) AS churn_rate_pct,
	CAST(AVG(f.monthlyCharges) AS DECIMAL(8,2)) AS avg_monthly_charge

FROM gold.fact_churn f
JOIN gold.dim_services ds
	ON f.service_key = ds.service_key
GROUP BY ds.[Contract],
		 ds.InternetService
HAVING COUNT(*) >= 100
)
SELECT 
	RANK() OVER(ORDER BY churn_rate_pct DESC) AS risk_rank,
	Contract,
	InternetService,
	customers,
	churned,
	churn_rate_pct,
	avg_monthly_charge

FROM segments
ORDER BY risk_rank
;