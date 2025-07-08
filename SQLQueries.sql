/*
QUESTION 1:
Analyze the total profit each month of each year based on unit USD; Note: Profit of one products = unit_price - unit_cost
*/

SELECT 
	YEAR(s.Order_Date) Year,
	MONTH(s.Order_Date) Month,
	SUM((p.Unit_Price_USD -p.Unit_Cost_USD)*s.Quantity) Total_profit	
FROM Sales s
Join Products p
ON s.ProductKey = p.ProductKey
GROUP BY 
	MONTH(s.Order_Date),
	YEAR(s.Order_Date)
ORDER BY 
	YEAR(s.Order_Date),
	MONTH(s.Order_Date)

/*
QUESTION 2:
Write a SQL query to see customer demographics meaning with format table Age_Group, Gender, Country, State, Count_Customer
With Age_Group is 0-17, 18-25, 26,35, 36-45, 46-55, 56+
*/
SELECT
	CASE
		WHEN DATEDIFF(YEAR,Birthday,GETDATE()) <= 17 THEN '0-17'
		WHEN DATEDIFF(YEAR,Birthday,GETDATE())> 17 AND DATEDIFF(YEAR,Birthday,GETDATE()) <= 25 THEN '18-25'
		WHEN DATEDIFF(YEAR,Birthday,GETDATE())> 25 AND DATEDIFF(YEAR,Birthday,GETDATE()) <= 35 THEN '26-35'
		WHEN DATEDIFF(YEAR,Birthday,GETDATE())> 35 AND DATEDIFF(YEAR,Birthday,GETDATE()) <= 45 THEN '36-45'
		WHEN DATEDIFF(YEAR,Birthday,GETDATE())> 45 AND DATEDIFF(YEAR,Birthday,GETDATE()) <= 55 THEN '46-55'
		ELSE '56+'
	END AS Age_Group,
	Gender,
	Country,
	State,
	COUNT(DISTINCT CustomerKey) CustomerCount
FROM Customers
GROUP BY 
	CASE
		WHEN DATEDIFF(YEAR,Birthday,GETDATE()) <= 17 THEN '0-17'
		WHEN DATEDIFF(YEAR,Birthday,GETDATE())> 17 AND DATEDIFF(YEAR,Birthday,GETDATE()) <= 25 THEN '18-25'
		WHEN DATEDIFF(YEAR,Birthday,GETDATE())> 25 AND DATEDIFF(YEAR,Birthday,GETDATE()) <= 35 THEN '26-35'
		WHEN DATEDIFF(YEAR,Birthday,GETDATE())> 35 AND DATEDIFF(YEAR,Birthday,GETDATE()) <= 45 THEN '36-45'
		WHEN DATEDIFF(YEAR,Birthday,GETDATE())> 45 AND DATEDIFF(YEAR,Birthday,GETDATE()) <= 55 THEN '46-55'
		ELSE '56+'
	END,
	Gender,
	Country,
	State
ORDER BY Age_Group DESC

/*
QUESTION 3:
Write a SQL query to determine the months where the month-over-month growth in cumulative profit is significant (at least 10%).
Based on unit USD
*/
WITH total_rev AS(
SELECT 
	YEAR(s.Order_Date) Year,
	MONTH(s.Order_Date) Month,
	SUM((p.Unit_Price_USD -p.Unit_Cost_USD)*s.Quantity) current_sales
FROM Sales s
Join Products p
ON s.ProductKey = p.ProductKey
GROUP BY 
	MONTH(s.Order_Date),
	YEAR(s.Order_Date)
),
cumulative_profit AS(
SELECT 
	Year,
	Month,
	SUM(current_sales) OVER (ORDER BY Year, Month) AS cumulative
FROM total_rev
),
diff_cal AS (
SELECT *,
((cumulative - LAG(cumulative) OVER (ORDER BY Year, Month))/LAG(cumulative) OVER (ORDER BY Year, Month))*100 AS sales_diff
FROM cumulative_profit
)
SELECT 
	Year, 
	Month, 
	ROUND(sales_diff,1) AS sale_diff, 
	cumulative
FROM diff_cal
WHERE sales_diff >=10
ORDER BY Year, Month

/*
QUESTION 4:
Write a SQL query to find pairs of different Subcategories that are purchased together in the same order. 
Only include unique pairs (e.g., "Desktops" and "Movie DVD", not both "Desktops"-"Movie DVD" and "Movie DVD"-"Desktops").*/

WITH purchases AS(
	SELECT 
		s.Order_Number, 
		p.Subcategory
	FROM Sales s
	LEFT JOIN Products p 
	ON s.ProductKey = p.ProductKey
)
SELECT
	a.Subcategory AS Subcategory_1,
	b.Subcategory AS Subcategory_2,
	COUNT(*) AS Count_Pair,
	RANK() OVER (ORDER BY COUNT(*) DESC) AS Rank_Pair
FROM
	purchases a
JOIN 
	purchases b
	ON a.Order_Number = b.Order_Number
	AND a.Subcategory < b.Subcategory
GROUP BY
	a.Subcategory,b.Subcategory
ORDER BY
	Count_Pair DESC


/*
QUESTION 5:
Create report of the top 2 selling products in each country, category, product name and ranking them accordingly.
*/
WITH top_selling AS(
SELECT p.Category, st.Country, p.Product_Name,
	ROW_NUMBER() OVER(PARTITION BY p.Category, st.Country ORDER BY SUM(s.Quantity) DESC) AS SalesRank
FROM Sales s 
JOIN Products p ON s.ProductKey = p.ProductKey
JOIN Stores st ON s.StoreKey = st.StoreKey
GROUP BY p.Category, st.Country, p.Product_Name
)
SELECT *
FROM top_selling
WHERE SalesRank <= 2

/*
QUESTION 6:
Write a query to analyse the profitability efficiency of each store by calculating:
The total profit in local currency (TotalProfitLocalCurrency)
The profit per square meter (ProfitPerSquareMeter)
A ranking of stores based on ProfitPerSquareMeter in descending order
*/
WITH profit_efficiency AS(
SELECT 
	st.StoreKey, st.Country, st.State, st.Square_Meters, 
	ROUND(SUM((p.Unit_Price_USD -p.Unit_Cost_USD)*s.Quantity* er.Exchange),2) TotalProfitLocalCurrency,
	ROUND((SUM((p.Unit_Price_USD -p.Unit_Cost_USD)*s.Quantity*er.Exchange)/st.Square_Meters),2) ProfitPerSquareMeter
FROM Products p
JOIN Sales s ON p.ProductKey = s.ProductKey
JOIN Stores st ON s.StoreKey = st.StoreKey
JOIN Exchange_Rates er ON er.Date = s.Order_Date AND er.Currency = s.Currency_Code
GROUP BY st.StoreKey, st.Country, st.State, st.Square_Meters
)
SELECT *,
	ROW_NUMBER() OVER(ORDER BY ProfitPerSquareMeter DESC) AS Ranking
FROM profit_efficiency

/*
QUESTION 7: Same as QUESTION 5 output. 
Analyze the total sales in local currency per product by country and category and ranking top 2 each product name of each category within each country
*/
WITH product_sales AS (
    SELECT 
        p.Category, 
        st.Country, 
        p.Product_Name, 
        SUM(p.Unit_Price_USD * s.Quantity * er.Exchange) AS total_sales
    FROM Products p
    JOIN Sales s ON p.ProductKey = s.ProductKey
    JOIN Stores st ON s.StoreKey = st.StoreKey
    JOIN Exchange_Rates er ON er.Date = s.Order_Date AND er.Currency = s.Currency_Code
    GROUP BY p.Category, st.Country, p.Product_Name
),
ranked_sales AS (
    SELECT 
        Category, 
        Country, 
        Product_Name, 
        ROW_NUMBER() OVER(PARTITION BY Category, Country ORDER BY total_sales DESC) AS Ranking
    FROM product_sales
)
SELECT *
FROM ranked_sales
WHERE Ranking <= 2;


/*
QUESTION 8: Check total quantity make by each day of each customer
Write the query to calcualte total quantity of each customer make in one day
*/
--- Declare a specific order date for analysis
DECLARE @TargetOrderDate DATE = '2016-01-01';

SELECT s.CustomerKey, c.Name,c.City,c.State,c.Country, 
	COUNT(DISTINCT s.Order_Number) Total_Orders,
	SUM(s.Quantity) Total_Quantity,
	MIN(s.Order_Date) First_Order,
	MAX(s.Delivery_Date) Last_Delivery
FROM Sales s
JOIN Customers c
ON s.CustomerKey =c.CustomerKey
WHERE s.Order_Date = @TargetOrderDate
GROUP BY s.CustomerKey, c.Name,c.City,c.State,c.Country,Order_Date,Delivery_Date
ORDER BY Order_Date,Total_Quantity DESC


/*
QUESTION 9: Write the query to calculate total order make by each country for each year
Format table Country, Year 1, Year 2, Year 3,...
*/
SELECT Country, [2016], [2017],[2018],[2019],[2020], [2021]
FROM 
(
    SELECT 
        c.Country, 
        YEAR(s.Order_Date) AS OrderYear, 
        COUNT(DISTINCT s.Order_Number) AS TotalOrders
    FROM Sales s
    JOIN Customers c ON s.CustomerKey = c.CustomerKey
	GROUP BY  c.Country, YEAR(s.Order_Date)
) AS SourceTable
PIVOT
(
    SUM(TotalOrders)
    FOR OrderYear IN ([2016], [2017],[2018],[2019],[2020], [2021])
) AS PivotTable;
