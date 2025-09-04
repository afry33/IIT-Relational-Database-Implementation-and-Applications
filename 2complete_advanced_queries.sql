USE OnlineBookstore;

-- Now run all the advanced queries

-- Query 1: Top 5 Bestselling Books with Ranking
SELECT '=== QUERY 1: Top 5 Bestselling Books ===' AS '';
SELECT 
    title,
    author_name,
    total_sold,
    RANK() OVER (ORDER BY total_sold DESC) as sales_rank
FROM BestsellingBooks 
LIMIT 5;

-- Query 2: Monthly Sales Trend with Rolling Average
SELECT '=== QUERY 2: Monthly Sales Trend ===' AS '';
SELECT 
    YEAR(order_date) as year,
    MONTH(order_date) as month,
    SUM(total_amount) as monthly_sales,
    AVG(SUM(total_amount)) OVER (
        ORDER BY YEAR(order_date), MONTH(order_date) 
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) as moving_avg_3months
FROM Orders 
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY year, month;

-- Query 3: Customer Lifetime Value Analysis
SELECT '=== QUERY 3: Customer Lifetime Value ===' AS '';
WITH CustomerStats AS (
    SELECT 
        customer_id,
        customer_name,
        total_orders,
        total_spent,
        NTILE(4) OVER (ORDER BY total_spent DESC) as customer_tier
    FROM CustomerOrderSummary
)
SELECT 
    customer_tier,
    COUNT(*) as customers,
    AVG(total_spent) as avg_lifetime_value,
    SUM(total_spent) as total_revenue
FROM CustomerStats
GROUP BY customer_tier
ORDER BY customer_tier;

-- Query 4: Author Performance Comparison
SELECT '=== QUERY 4: Author Performance ===' AS '';
SELECT 
    author_name,
    books_count,
    total_revenue,
    RANK() OVER (ORDER BY total_revenue DESC) as revenue_rank,
    ROUND(PERCENT_RANK() OVER (ORDER BY total_revenue) * 100, 2) as percentile_rank,
    ROUND(total_revenue / SUM(total_revenue) OVER() * 100, 2) as revenue_percentage
FROM AuthorPerformance
ORDER BY revenue_rank;

-- Query 5: Book Price Analysis with Window Functions
SELECT '=== QUERY 5: Book Price Analysis ===' AS '';
SELECT 
    title,
    author,
    price,
    ROUND(AVG(price) OVER(), 2) as avg_price,
    ROUND(price - AVG(price) OVER(), 2) as price_diff_from_avg,
    PERCENT_RANK() OVER (ORDER BY price) as price_percentile,
    CASE 
        WHEN price > AVG(price) OVER() THEN 'Above Average'
        ELSE 'Below Average'
    END as price_category
FROM BookDetails
ORDER BY price DESC;

-- Query 6: Customer Order Frequency Analysis (FIXED)
SELECT '=== QUERY 6: Customer Order Frequency ===' AS '';
WITH OrderIntervals AS (
    SELECT 
        customer_id,
        order_date,
        LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date) as prev_order_date,
        DATEDIFF(order_date, LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date)) as days_between_orders
    FROM Orders
)
SELECT 
    c.customer_name,
    COUNT(o.customer_id) as total_orders,
    ROUND(AVG(o.days_between_orders), 2) as avg_days_between_orders,
    RANK() OVER (ORDER BY COUNT(o.customer_id) DESC) as frequency_rank
FROM OrderIntervals o
JOIN CustomerOrderSummary c ON o.customer_id = c.customer_id
WHERE o.days_between_orders IS NOT NULL
GROUP BY o.customer_id, c.customer_name
ORDER BY total_orders DESC;

-- Query 7: Stock Value Analysis by Category
SELECT '=== QUERY 7: Stock Value Analysis ===' AS '';
SELECT 
    CASE 
        WHEN stock_quantity = 0 THEN 'Out of Stock'
        WHEN stock_quantity < 5 THEN 'Low Stock'
        WHEN stock_quantity < 10 THEN 'Medium Stock'
        ELSE 'Well Stocked'
    END as stock_category,
    COUNT(*) as book_count,
    SUM(stock_quantity) as total_units,
    SUM(inventory_value) as total_value,
    ROUND(AVG(inventory_value), 2) as avg_value_per_book
FROM InventoryAnalysis
GROUP BY stock_category WITH ROLLUP;

-- Query 8: Sales Performance by Author Nationality
SELECT '=== QUERY 8: Sales by Author Nationality ===' AS '';
SELECT 
    a.country as author_country,
    COUNT(DISTINCT b.book_id) as books_count,
    COUNT(od.order_detail_id) as units_sold,
    SUM(od.quantity * od.price) as total_revenue,
    RANK() OVER (ORDER BY SUM(od.quantity * od.price) DESC) as country_rank
FROM Authors a
JOIN Books b ON a.author_id = b.author_id
JOIN Order_Details od ON b.book_id = od.book_id
GROUP BY a.country
ORDER BY total_revenue DESC;

-- Query 9: Cumulative Revenue Analysis
SELECT '=== QUERY 9: Cumulative Revenue ===' AS '';
SELECT 
    order_date,
    total_amount as daily_revenue,
    SUM(total_amount) OVER (ORDER BY order_date) as cumulative_revenue,
    ROUND(SUM(total_amount) OVER (ORDER BY order_date) / SUM(total_amount) OVER() * 100, 2) as percent_of_total
FROM Orders
ORDER BY order_date;

-- Query 10: Book Popularity vs Price Correlation (FIXED)
SELECT '=== QUERY 10: Price vs Popularity ===' AS '';
WITH BookSales AS (
    SELECT 
        b.title,
        b.price,
        COUNT(od.order_detail_id) as times_ordered,
        SUM(od.quantity) as total_units_sold,
        CAST(RANK() OVER (ORDER BY SUM(od.quantity) DESC) AS SIGNED) as popularity_rank,
        CAST(RANK() OVER (ORDER BY b.price DESC) AS SIGNED) as price_rank
    FROM Books b
    LEFT JOIN Order_Details od ON b.book_id = od.book_id
    GROUP BY b.book_id, b.title, b.price
)
SELECT 
    title,
    price,
    times_ordered,
    total_units_sold,
    popularity_rank,
    price_rank,
    ABS(popularity_rank - price_rank) as rank_difference
FROM BookSales
ORDER BY total_units_sold DESC;

-- Query 11: Customer Cohort Analysis
SELECT '=== QUERY 11: Customer Cohort Analysis ===' AS '';
WITH FirstOrders AS (
    SELECT 
        customer_id,
        MIN(order_date) as first_order_date
    FROM Orders
    GROUP BY customer_id
),
CohortAnalysis AS (
    SELECT 
        c.customer_id,
        DATE_FORMAT(c.registration_date, '%Y-%m') as registration_cohort,
        DATE_FORMAT(fo.first_order_date, '%Y-%m') as first_order_month,
        DATE_FORMAT(o.order_date, '%Y-%m') as order_month,
        COUNT(DISTINCT o.order_id) as orders_count
    FROM Customers c
    JOIN FirstOrders fo ON c.customer_id = fo.customer_id
    LEFT JOIN Orders o ON c.customer_id = o.customer_id
    GROUP BY c.customer_id, registration_cohort, first_order_month, order_month
)
SELECT 
    registration_cohort,
    order_month,
    COUNT(DISTINCT customer_id) as active_customers,
    ROUND(COUNT(DISTINCT customer_id) / FIRST_VALUE(COUNT(DISTINCT customer_id)) 
          OVER (PARTITION BY registration_cohort ORDER BY order_month) * 100, 2) as retention_rate
FROM CohortAnalysis
GROUP BY registration_cohort, order_month
ORDER BY registration_cohort, order_month;

-- Query 12: Price Elasticity Analysis
SELECT '=== QUERY 12: Price Elasticity ===' AS '';
WITH PriceSales AS (
    SELECT 
        b.book_id,
        b.title,
        b.price,
        SUM(od.quantity) as total_sold,
        AVG(SUM(od.quantity)) OVER () as avg_sold_all_books,
        ROUND((SUM(od.quantity) - AVG(SUM(od.quantity)) OVER ()) / AVG(SUM(od.quantity)) OVER () * 100, 2) as sales_deviation_percent,
        ROUND((b.price - AVG(b.price) OVER ()) / AVG(b.price) OVER () * 100, 2) as price_deviation_percent
    FROM Books b
    LEFT JOIN Order_Details od ON b.book_id = od.book_id
    GROUP BY b.book_id, b.title, b.price
)
SELECT 
    title,
    price,
    total_sold,
    sales_deviation_percent,
    price_deviation_percent,
    CASE 
        WHEN sales_deviation_percent < 0 AND price_deviation_percent > 0 THEN 'High Price, Low Sales'
        WHEN sales_deviation_percent > 0 AND price_deviation_percent < 0 THEN 'Low Price, High Sales'
        ELSE 'Neutral'
    END as elasticity_category
FROM PriceSales
ORDER BY ABS(sales_deviation_percent) DESC;

-- Query 13: Time-based Sales Analysis
SELECT '=== QUERY 13: Time-based Sales ===' AS '';
SELECT 
    DAYNAME(order_date) as day_of_week,
    MONTHNAME(order_date) as month,
    COUNT(*) as order_count,
    SUM(total_amount) as total_revenue,
    ROUND(AVG(total_amount), 2) as avg_order_value,
    RANK() OVER (PARTITION BY DAYNAME(order_date) ORDER BY SUM(total_amount) DESC) as day_rank,
    RANK() OVER (PARTITION BY MONTHNAME(order_date) ORDER BY SUM(total_amount) DESC) as month_rank
FROM Orders
GROUP BY DAYNAME(order_date), MONTHNAME(order_date)
ORDER BY total_revenue DESC;

-- Query 14: Customer Segmentation by Purchase Behavior
SELECT '=== QUERY 14: Customer Segmentation ===' AS '';
WITH CustomerRFM AS (
    SELECT 
        customer_id,
        DATEDIFF(CURRENT_DATE, MAX(order_date)) as recency,
        COUNT(order_id) as frequency,
        SUM(total_amount) as monetary,
        NTILE(5) OVER (ORDER BY DATEDIFF(CURRENT_DATE, MAX(order_date)) DESC) as recency_score,
        NTILE(5) OVER (ORDER BY COUNT(order_id)) as frequency_score,
        NTILE(5) OVER (ORDER BY SUM(total_amount)) as monetary_score,
        CONCAT(
            NTILE(5) OVER (ORDER BY DATEDIFF(CURRENT_DATE, MAX(order_date)) DESC),
            NTILE(5) OVER (ORDER BY COUNT(order_id)),
            NTILE(5) OVER (ORDER BY SUM(total_amount))
        ) as rfm_cell
    FROM Orders
    GROUP BY customer_id
)
SELECT 
    c.customer_name,
    r.recency,
    r.frequency,
    r.monetary,
    r.recency_score,
    r.frequency_score,
    r.monetary_score,
    r.rfm_cell,
    CASE 
        WHEN r.rfm_cell IN ('555', '554', '545', '544') THEN 'Champions'
        WHEN r.rfm_cell LIKE '5__' THEN 'Loyal Customers'
        WHEN r.rfm_cell LIKE '_5_' THEN 'High Frequency'
        WHEN r.rfm_cell LIKE '__5' THEN 'High Value'
        ELSE 'Need Attention'
    END as customer_segment
FROM CustomerRFM r
JOIN CustomerOrderSummary c ON r.customer_id = c.customer_id
ORDER BY r.monetary DESC;

-- Query 15: Advanced OLAP with Multiple Grouping Sets
SELECT '=== QUERY 15: Advanced OLAP ===' AS '';
SELECT 
    COALESCE(a.country, 'All Countries') as country,
    COALESCE(MONTHNAME(o.order_date), 'All Months') as month,
    COALESCE(
        CASE 
            WHEN b.stock_quantity = 0 THEN 'Out of Stock'
            WHEN b.stock_quantity < 5 THEN 'Low Stock'
            WHEN b.stock_quantity < 10 THEN 'Medium Stock'
            ELSE 'Well Stocked'
        END, 'All Stock Levels') as stock_status,
    COUNT(DISTINCT o.order_id) as order_count,
    SUM(od.quantity) as total_units,
    SUM(o.total_amount) as total_revenue,
    ROUND(AVG(o.total_amount), 2) as avg_order_value
FROM Orders o
JOIN Order_Details od ON o.order_id = od.order_id
JOIN Books b ON od.book_id = b.book_id
JOIN Authors a ON b.author_id = a.author_id
GROUP BY GROUPING SETS (
    (a.country, MONTHNAME(o.order_date), 
        CASE 
            WHEN b.stock_quantity = 0 THEN 'Out of Stock'
            WHEN b.stock_quantity < 5 THEN 'Low Stock'
            WHEN b.stock_quantity < 10 THEN 'Medium Stock'
            ELSE 'Well Stocked'
        END),
    (a.country, MONTHNAME(o.order_date)),
    (a.country, 
        CASE 
            WHEN b.stock_quantity = 0 THEN 'Out of Stock'
            WHEN b.stock_quantity < 5 THEN 'Low Stock'
            WHEN b.stock_quantity < 10 THEN 'Medium Stock'
            ELSE 'Well Stocked'
        END),
    (MONTHNAME(o.order_date), 
        CASE 
            WHEN b.stock_quantity = 0 THEN 'Out of Stock'
            WHEN b.stock_quantity < 5 THEN 'Low Stock'
            WHEN b.stock_quantity < 10 THEN 'Medium Stock'
            ELSE 'Well Stocked'
        END),
    (a.country),
    (MONTHNAME(o.order_date)),
    (CASE 
        WHEN b.stock_quantity = 0 THEN 'Out of Stock'
        WHEN b.stock_quantity < 5 THEN 'Low Stock'
        WHEN b.stock_quantity < 10 THEN 'Medium Stock'
        ELSE 'Well Stocked'
    END),
    ()
)
ORDER BY a.country, month, stock_status;