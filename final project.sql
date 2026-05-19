CREATE DATABASE project;

SELECT * FROM customers;
SELECT * FROM transactions;

SELECT 
    ID_client, 
	ROUND(AVG(Sum_payment), 2) AS average_bill, 
    ROUND(SUM(Sum_payment) / 12, 2) AS average_monthly_sales,
    COUNT(Id_check) AS total_operations
FROM 
    transactions
WHERE 
	STR_TO_DATE(date_new, '%d/%m/%Y') >= '2015-06-01' 
	AND STR_TO_DATE(date_new, '%d/%m/%Y') < '2016-06-01'
GROUP BY
ID_client
HAVING COUNT(DISTINCT DATE_FORMAT(STR_TO_DATE(date_new, '%d/%m/%Y'), '%Y-%m')) = 12
ORDER BY 
    total_operations DESC;

#Информация в разрезе месяцев
WITH monthly_info AS (
SELECT 
	DATE_FORMAT(STR_TO_DATE(t.date_new, '%d/%m/%Y'), '%Y-%m') AS month,
	AVG(t.Sum_payment) AS avg_check,
	COUNT(t.ID_check) AS m_ops,
	COUNT(DISTINCT t.ID_client) AS month_clients,
	SUM(t.Sum_payment) AS month_sum,
	COUNT(CASE WHEN c.Gender = 'M' THEN 1 END) AS men_count,
	COUNT(CASE WHEN c.Gender = 'F' THEN 1 END) AS women_count,
	COUNT(CASE WHEN c.Gender NOT IN ('M', 'F') OR c.Gender IS NULL THEN 1 END) AS na_count,
	SUM(CASE WHEN c.Gender = 'M' THEN t.Sum_payment ELSE 0 END) AS men_spend,
	SUM(CASE WHEN c.Gender = 'F' THEN t.Sum_payment ELSE 0 END) AS women_spend,
	SUM(CASE WHEN c.Gender NOT IN ('M', 'F') OR c.Gender IS NULL THEN t.Sum_payment ELSE 0 END) AS na_spend
FROM transactions t
LEFT JOIN customers c ON t.ID_client = c.Id_client
WHERE 
	STR_TO_DATE(t.date_new, '%d/%m/%Y') >= '2015-06-01' 
	AND STR_TO_DATE(t.date_new, '%d/%m/%Y') < '2016-06-01'
GROUP BY DATE_FORMAT(STR_TO_DATE(t.date_new, '%d/%m/%Y'), '%Y-%m'))
SELECT 
	month,
	ROUND(avg_check, 2) AS avg_check_monthly,
	m_ops AS operations_count,
	month_clients AS clients_count,
	ROUND(m_ops / SUM(m_ops) OVER() * 100, 2) AS ops_share,
	ROUND(month_sum / SUM(month_sum) OVER() * 100, 2) AS spend_share,
	ROUND(men_count / m_ops * 100, 2) AS M_percent,
	ROUND(women_count / m_ops * 100, 2) AS F_percent,
	ROUND(na_count / m_ops * 100, 2) AS NA_percent,
	ROUND(men_spend / month_sum * 100, 2) AS M_spend_share,
	ROUND(women_spend / month_sum * 100, 2) AS F_spend_share,
	ROUND(na_spend / month_sum * 100, 2) AS NA_spend_share
FROM monthly_info
ORDER BY month;

#Возрастные группы клиентов
SELECT 
	CASE 
		WHEN c.Age IS NULL THEN 'No Data'
		WHEN c.Age BETWEEN 0 AND 19 THEN '0-19'
		WHEN c.Age BETWEEN 20 AND 29 THEN '20-29'
		WHEN c.Age BETWEEN 30 AND 39 THEN '30-39'
		WHEN c.Age BETWEEN 40 AND 49 THEN '40-49'
		WHEN c.Age BETWEEN 50 AND 59 THEN '50-59'
		ELSE '60+'
	END AS age_group,
	QUARTER(STR_TO_DATE(t.date_new, '%d/%m/%Y')) AS quarter,
	ROUND(SUM(t.Sum_payment), 2) AS spend_total,
	COUNT(t.Id_check) AS ops_total,
	ROUND(AVG(t.Sum_payment), 2) AS avg_check_quarter
FROM transactions t
LEFT JOIN customers c ON t.ID_client = c.Id_client
WHERE 
	STR_TO_DATE(t.date_new, '%d/%m/%Y') >= '2015-06-01' 
	AND STR_TO_DATE(t.date_new, '%d/%m/%Y') < '2016-06-01'
GROUP BY 
    age_group, 
    quarter
ORDER BY 
    age_group, 
    quarter;


