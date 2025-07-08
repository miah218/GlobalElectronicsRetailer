#Electronics Sales & Customer Analytics Using SQL
________________________________________
🧭 Objective:
Use SQL to explore and analyse a retail dataset containing sales, customers, products, stores, and currency exchange rates. This project answers key business questions around profitability, customer demographics, product performance, and operational efficiency.
________________________________________
📁 Dataset Overview:
•	Sales: Order transactions with date, quantity, and delivery info
•	Customers: Demographics and location
•	Products: Product names, categories, subcategories, unit price/cost
•	Stores: Store location and size
•	Exchange Rates: Currency conversion rates by date
________________________________________
🔍 Key Business Questions and Insights
________________________________________
✅ Q1. Monthly Profit Trend
Goal: Analyse monthly profit over time .
Insight: Identified trends in monthly profit across years. Can be used to detect seasonal patterns.
________________________________________
✅ Q2. Customer Demographics
Goal: Segment customers by age group, gender, country, and state.
Query: (age groups defined manually using DATEDIFF)
Insight: Shows where most customers come from and how they’re distributed by age and gender.
________________________________________
✅ Q3. Significant MoM Profit Growth
Goal: Identify months with 10%+ growth in cumulative profit.
Approach: Used window functions and LAG() to calculate month-over-month percentage change.
Insight: Pinpoints months of rapid profit increase, useful for campaign evaluation.
________________________________________
✅ Q4. Product Subcategory Pairs Bought Together
Goal: Identify which different subcategories are purchased in the same order.
Approach: Self-join on [Order Number] and filter pairs where Subcategory_1 & Subcategory_2 are different to keep unique pairs only.
Insight: Supports product bundling and marketing strategies.
________________________________________
✅ Q5 & Q7. Top 2 Selling Products by Country & Category
Goal: Find best-selling products across regions and categories.
Method: ROW_NUMBER() partitioned by Country and Category.
Insight: Helps optimize product stocking and local promotions.
________________________________________
✅ Q6. Store Profitability Efficiency
Goal: Rank stores by how much profit they generate per square meter.
Metric:
•	TotalProfitLocalCurrency = SUM(profit × exchange)
•	ProfitPerSquareMeter = TotalProfitLocalCurrency / Store Size
Insight: Highlights high-performing stores. Could inform expansion or remodelling.
________________________________________
✅ Q8. Customer Daily Order Behaviour
Goal: Track daily purchase quantity by each customer.
Output: Total orders, total quantity, first order, last delivery
Insight: Reveals buying frequency and lifetime value.
________________________________________
✅ Q9. Total Orders by Country (Pivot Format)
Goal: View total orders per country per year (pivoted).
Method: Use PIVOT on yearly order counts
Insight: Helps visualize growth by geography over time.

