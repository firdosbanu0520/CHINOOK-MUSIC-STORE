-- Objective questions

-- 1. Does any table have missing values or duplicates? If yes, how would you handle it?

select * from album;

select album_id,title,artist_id,count(*) as cnt
from album
group by 1,2,3
having count(*) > 1;

select album_id,title,artist_id
from album 
where album_id is null or title is null or artist_id is null;

select * from artist;

select artist_id,name,count(*)
from artist
group by 1,2
having count(*) > 1;

select artist_id,name
from artist
where artist_id is null or name is null;

select * from customer;

select customer_id,first_name,last_name,company,address,city,state,country,postal_code,phone,fax,email,support_rep_id,count(*)
from customer
group by 1,2,3,4,5,6,7,8,9,10,11,12,13
having count(*) > 1;

select customer_id,first_name,last_name,company,address,city,state,country,postal_code,phone,fax,email,support_rep_id
from customer
where customer_id is null or first_name is null or last_name is null or company is null or
address is null or city is null or state is null or country is null or postal_code is null or phone is null or fax is null or
email is null or support_rep_id is null;

select * from employee;

select employee_id,last_name,first_name,title,reports_to,birthdate,hire_date,address,city,state,country,postal_code,phone,fax,email,count(*)
from employee
group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
having count(*) > 1;

select employee_id,last_name,first_name,title,reports_to,birthdate,hire_date,address,city,state,country,postal_code,phone,fax,email
from employee
where employee_id is null or last_name is null or first_name is null or 
title is null or reports_to is null or birthdate is null or hire_date is null or address is null or 
city is null or state is null or country is null or postal_code is null or phone is null or fax is null or email is null;

select * from genre;

select genre_id,name,count(*)
from genre
group by 1,2
having count(*) > 1;

select genre_id,name
from genre
where genre_id is null or name is null;

select * from invoice;

select invoice_id,customer_id,invoice_date,billing_address,billing_city,billing_state,billing_country,billing_postal_code,total,count(*)
from invoice
group by 1,2,3,4,5,6,7,8,9
having count(*) > 1;

select invoice_id,customer_id,invoice_date,billing_address,billing_city,billing_state,billing_country,billing_postal_code,total
from invoice
where invoice_id is null or customer_id is null or invoice_date is null or 
billing_address is null or billing_city is null or billing_state is null or billing_country is null or billing_postal_code is null or total is null;

select * from invoice_line;

select invoice_line_id,invoice_id,track_id,unit_price,quantity,count(*)
from invoice_line
group by 1,2,3,4,5
having count(*) > 1;

select invoice_line_id,invoice_id,track_id,unit_price,quantity
from invoice_line
where invoice_line_id is null or invoice_id is null or track_id is null or unit_price is null or quantity is null;

select * from media_type;

select media_type_id,name,count(*)
from media_type
group by 1,2
having count(*) > 1;

select media_type_id,name
from media_type
where media_type_id is null or name is null;

select * from playlist;

select playlist_id, name,count(*)
from playlist
group by 1,2
having count(*) > 1;

select playlist_id, name
from playlist
where playlist_id is null or name is null;

select * from playlist_track;

select playlist_id,track_id,count(*)
from playlist_track
group by 1,2
having count(*) > 1;

select playlist_id,track_id
from playlist_track
where playlist_id is null or track_id is null;

select * from track;

select track_id,name,album_id,media_type_id,genre_id,composer,milliseconds,bytes,unit_price,count(*)
from track
group by 1,2,3,4,5,6,7,8,9
having count(*) > 1;

select track_id,name,album_id,media_type_id,genre_id,composer,milliseconds,bytes,unit_price
from track
where track_id is null or name is null or album_id is null or media_type_id is null or genre_id is null or composer is null or 
milliseconds is null or bytes is null or unit_price is null;

-- 2. Find the top-selling tracks and top artist in the USA and identify their most famous genres.

WITH TopTracks AS (
    SELECT t.track_id, t.name AS track_name, g.name AS genre_name, SUM(il.quantity) AS total_units_sold
    FROM invoice_line il
    JOIN invoice i ON il.invoice_id = i.invoice_id
    JOIN track t ON il.track_id = t.track_id
    JOIN genre g ON t.genre_id = g.genre_id
    WHERE i.billing_country = 'USA'
    GROUP BY t.track_id, t.name, g.name
    ORDER BY total_units_sold DESC
    LIMIT 5
),
TopArtist AS (
    SELECT ar.artist_id, ar.name AS artist_name, SUM(il.quantity) AS total_units_sold
    FROM invoice_line il
    JOIN invoice i ON il.invoice_id = i.invoice_id
    JOIN track t ON il.track_id = t.track_id
    JOIN album al ON t.album_id = al.album_id
    JOIN artist ar ON al.artist_id = ar.artist_id
    WHERE i.billing_country = 'USA'
    GROUP BY ar.artist_id, ar.name
    ORDER BY total_units_sold DESC
    LIMIT 1
),
TopArtistGenre AS (
    SELECT DISTINCT ar.artist_id, g.name AS genre_name
    FROM track t
    JOIN album al ON t.album_id = al.album_id
    JOIN artist ar ON al.artist_id = ar.artist_id
    JOIN genre g ON t.genre_id = g.genre_id
    WHERE ar.artist_id = (SELECT artist_id FROM TopArtist)
)
SELECT 'Top Tracks' AS category, track_name AS name, genre_name, total_units_sold FROM TopTracks
UNION ALL
SELECT 'Top Artist', artist_name, genre_name, total_units_sold FROM TopArtistGenre
JOIN TopArtist USING (artist_id);


-- 3.	What is the customer demographic breakdown (age, gender, location) of Chinook's customer base?

-- Customer count by country

SELECT 
    country, 
    COUNT(customer_id) AS total_customers
FROM customer
GROUP BY country
ORDER BY total_customers DESC;

-- Customer count by city,state

SELECT 
    country, 
    state, 
    city, 
    COUNT(customer_id) AS total_customers
FROM customer
GROUP BY country, state, city
ORDER BY total_customers DESC;

-- 4.	Calculate the total revenue and number of invoices for each country, state, and city?

SELECT 
    billing_country AS country, 
    billing_state AS state, 
    billing_city AS city, 
    COUNT(invoice_id) AS total_invoices, 
    SUM(total) AS total_revenue
FROM invoice
GROUP BY billing_country, billing_state, billing_city
ORDER BY total_revenue DESC;

-- 5.	Find the top 5 customers by total revenue in each country

WITH CustomerRevenue AS (
    SELECT 
        c.customer_id,
        c.first_name,
        c.last_name,
        i.billing_country AS country,
        SUM(i.total) AS total_revenue,
        DENSE_RANK() OVER (PARTITION BY i.billing_country ORDER BY SUM(i.total) DESC) AS rnk
    FROM customer c
    JOIN invoice i ON c.customer_id = i.customer_id
    GROUP BY c.customer_id, c.first_name, c.last_name, i.billing_country
)
SELECT 
    customer_id, 
    first_name, 
    last_name, 
    country, 
    total_revenue
FROM CustomerRevenue
WHERE rnk <= 5
ORDER BY country DESC,total_revenue desc;

-- 6.	Identify the top-selling track for each customer

WITH CustomerTrackSales AS (
    SELECT 
        i.Customer_Id,
        il.Track_Id,
        t.Name AS track_name,
        SUM(il.Quantity) AS total_quantity_sold
    FROM Invoice_Line il
    JOIN Invoice i ON il.Invoice_Id = i.Invoice_Id
    JOIN Customer c ON i.Customer_Id = c.Customer_Id
    JOIN Track t ON il.Track_Id = t.Track_Id
    GROUP BY i.Customer_Id,il.Track_Id, t.Name
), RankedTracks AS (
    SELECT 
        Customer_Id,
        track_name,
        total_quantity_sold,
        ROW_NUMBER() OVER (PARTITION BY Customer_Id ORDER BY total_quantity_sold DESC) AS row_num
    FROM CustomerTrackSales
)
SELECT 
    Customer_Id,
    track_name,
    total_quantity_sold
FROM RankedTracks
WHERE row_num = 1
ORDER BY customer_id asc;

-- 7.	Are there any patterns or trends in customer purchasing behavior (e.g., frequency of purchases, preferred payment methods, average order value)?

WITH PurchaseFrequency AS (
    SELECT customer_id, COUNT(invoice_id) AS total_purchases
    FROM invoice
    GROUP BY customer_id
),
AvgOrderValue AS (
    SELECT customer_id, ROUND(AVG(total), 2) AS avg_order_value
    FROM invoice
    GROUP BY customer_id
),
MonthlyTrends AS (
    SELECT DATE_FORMAT(invoice_date, '%Y-%m') AS purchase_month, 
           COUNT(invoice_id) AS num_purchases, 
           SUM(total) AS total_revenue
    FROM invoice
    GROUP BY purchase_month
),
TopRevenueCustomers AS (
    SELECT customer_id, SUM(total) AS total_revenue
    FROM invoice
    GROUP BY customer_id
    ORDER BY total_revenue DESC
    LIMIT 10
)
SELECT 
    pf.customer_id, 
    pf.total_purchases, 
    aov.avg_order_value, 
    trc.total_revenue
FROM PurchaseFrequency pf
JOIN AvgOrderValue aov ON pf.customer_id = aov.customer_id
JOIN TopRevenueCustomers trc ON pf.customer_id = trc.customer_id
ORDER BY trc.total_revenue DESC;

-- 8.Customer churn rate

WITH LastPurchase AS (
    SELECT 
        customer_id, 
        MAX(invoice_date) AS last_purchase_date
    FROM invoice
    GROUP BY customer_id
),
ChurnedCustomers AS (
    SELECT 
        COUNT(customer_id) AS churned_customers
    FROM LastPurchase
    WHERE last_purchase_date < DATE_SUB((SELECT MAX(invoice_date) FROM invoice), INTERVAL 1 YEAR)
),
TotalCustomers AS (
    SELECT COUNT(customer_id) AS total_customers FROM customer
)
SELECT 
    (c.churned_customers / t.total_customers) * 100 AS churn_rate
FROM ChurnedCustomers c, TotalCustomers t;

-- 9.	Calculate the percentage of total sales contributed by each genre in the USA and identify the best-selling genres and artists.

-- Query to Calculate the Percentage of Total Sales by EACH Genre in the USA

WITH GenreSales AS (
    SELECT 
        g.genre_id, 
        g.name AS genre_name, 
        SUM(il.unit_price * il.quantity) AS total_sales
    FROM invoice i
    JOIN invoice_line il ON i.invoice_id = il.invoice_id
    JOIN track t ON il.track_id = t.track_id
    JOIN genre g ON t.genre_id = g.genre_id
    JOIN customer c ON i.customer_id = c.customer_id
    WHERE c.country = 'USA'
    GROUP BY g.genre_id, g.name
),
TotalSales AS (
    SELECT SUM(total_sales) AS overall_sales FROM GenreSales
)
SELECT 
    gs.genre_name, 
    gs.total_sales, 
    round((gs.total_sales / ts.overall_sales) * 100,2) AS sales_percentage
FROM GenreSales gs
CROSS JOIN TotalSales ts
ORDER BY gs.total_sales DESC;

-- query to find best selling artist in USA

WITH ArtistSales AS (
    SELECT 
        ar.artist_id, 
        ar.name AS artist_name, 
        SUM(il.unit_price * il.quantity) AS total_sales
    FROM invoice i
    JOIN invoice_line il ON i.invoice_id = il.invoice_id
    JOIN track t ON il.track_id = t.track_id
    JOIN album al ON t.album_id = al.album_id
    JOIN artist ar ON al.artist_id = ar.artist_id
    JOIN customer c ON i.customer_id = c.customer_id
    WHERE c.country = 'USA'
    GROUP BY ar.artist_id, ar.name
)
SELECT 
    artist_name, 
    total_sales
FROM ArtistSales
ORDER BY total_sales DESC
LIMIT 5;

-- 10.Find customers who have purchased tracks from at least 3 different+ genres

WITH CustomerGenreCount AS (
    SELECT 
        c.customer_id,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        COUNT(DISTINCT g.genre_id) AS genre_count
    FROM customer c
    JOIN invoice i ON c.customer_id = i.customer_id
    JOIN invoice_line il ON i.invoice_id = il.invoice_id
    JOIN track t ON il.track_id = t.track_id
    JOIN genre g ON t.genre_id = g.genre_id
    GROUP BY c.customer_id, customer_name
)
SELECT customer_id, customer_name, genre_count
FROM CustomerGenreCount
WHERE genre_count >= 3
ORDER BY genre_count DESC, customer_id;


-- 11.Rank genres based on their sales performance in the USA

WITH GenreSales AS (
    SELECT 
        g.name AS genre,
        SUM(il.unit_price * il.quantity) AS total_sales
    FROM invoice i
    JOIN invoice_line il ON i.invoice_id = il.invoice_id
    JOIN track t ON il.track_id = t.track_id
    JOIN genre g ON t.genre_id = g.genre_id
    WHERE i.billing_country = 'USA'
    GROUP BY g.name
)
SELECT 
    genre, 
    total_sales,
    RANK() OVER (ORDER BY total_sales DESC) AS sales_rank
FROM GenreSales
ORDER BY total_sales DESC;

-- 12.Identify customers who have not made a purchase in the last 3 months

WITH LastPurchase AS (
    SELECT 
        customer_id, 
        MAX(invoice_date) AS last_purchase_date
    FROM invoice
    GROUP BY customer_id
)
SELECT 
    c.customer_id, 
    concat(c.first_name," ",c.last_name) as cutomer_name,
    lp.last_purchase_date
FROM customer c
LEFT JOIN LastPurchase lp ON c.customer_id = lp.customer_id
WHERE lp.last_purchase_date < DATE_SUB((SELECT MAX(invoice_date) FROM invoice), INTERVAL 3 MONTH)
ORDER BY customer_id ASC;

-- SUBJECTIVE QUESTIONS

-- 1.	Recommend the three albums from the new record label that should be prioritised for advertising and promotion in the USA based on genre sales analysis.gnrename,albumname and sum(itotal as totalsales)

SELECT 
    g.name AS genre_name,
    a.title AS album_name,
    SUM(il.unit_price * il.quantity) AS total_sales
FROM invoice i
JOIN invoice_line il ON i.invoice_id = il.invoice_id
JOIN track t ON il.track_id = t.track_id
JOIN album a ON t.album_id = a.album_id
JOIN genre g ON t.genre_id = g.genre_id
WHERE i.billing_country = 'USA'
GROUP BY g.name, a.title
ORDER BY total_sales DESC
LIMIT 3;

-- 2.	Determine the top-selling genres in countries other than the USA and identify any commonalities or differences.

WITH Genre_Sales AS (
    SELECT c.country, g.name AS genre_name, SUM(il.unit_price * il.quantity) AS total_sales
    FROM invoice_line il
    JOIN track t ON il.track_id = t.track_id
    JOIN genre g ON t.genre_id = g.genre_id
    JOIN invoice i ON il.invoice_id = i.invoice_id
    JOIN customer c ON i.customer_id = c.customer_id
    WHERE c.country != 'USA'
    GROUP BY c.country, g.name
),
Ranked_Genres AS (
    SELECT country, genre_name, total_sales,
           RANK() OVER (PARTITION BY country ORDER BY total_sales DESC) AS genre_rank
    FROM Genre_Sales
)
SELECT country, genre_name, total_sales
FROM Ranked_Genres
WHERE genre_rank = 1
ORDER BY total_sales DESC;

-- 3.	Customer Purchasing Behavior Analysis: How do the purchasing habits (frequency, basket size, spending amount) of long-term customers differ from those of new customers? What insights can these patterns provide about customer loyalty and retention strategies?
WITH CustomerCategory AS (
    SELECT 
        customer_id, 
        MIN(invoice_date) AS first_purchase_date,
        MAX(invoice_date) AS last_purchase_date,
        CASE 
            WHEN MIN(invoice_date) >= DATE_SUB((SELECT MAX(invoice_date) FROM invoice), INTERVAL 6 MONTH) 
            THEN 'New Customer'
            ELSE 'Long-Term Customer'
        END AS customer_type
    FROM invoice
    GROUP BY customer_id
),
PurchaseStats AS (
    SELECT 
        i.customer_id, 
        COUNT(i.invoice_id) AS total_purchases,
        SUM(i.total) AS total_spent,
        AVG(i.total) AS avg_order_value,
        COUNT(il.track_id) / COUNT(i.invoice_id) AS avg_basket_size
    FROM invoice i
    JOIN invoice_line il ON i.invoice_id = il.invoice_id
    GROUP BY i.customer_id
)
SELECT 
    cc.customer_type,
    ROUND(AVG(ps.total_purchases), 2) AS avg_purchases,
    ROUND(AVG(ps.total_spent), 2) AS avg_spent,
    ROUND(AVG(ps.avg_order_value), 2) AS avg_order_value,
    ROUND(AVG(ps.avg_basket_size), 2) AS avg_basket_size
FROM CustomerCategory cc
JOIN PurchaseStats ps ON cc.customer_id = ps.customer_id
GROUP BY cc.customer_type;

-- 4.	Product Affinity Analysis: Which music genres, artists, or albums are frequently purchased together by customers? How can this information guide product recommendations and cross-selling initiatives?

WITH 
-- Find frequently purchased genre pairs
GenrePairs AS (
    SELECT 
        t1.genre_id AS genre_1,
        t2.genre_id AS genre_2,
        COUNT(*) AS frequency
    FROM invoice_line il1
    JOIN invoice_line il2 
        ON il1.invoice_id = il2.invoice_id 
        AND il1.track_id <> il2.track_id
    JOIN track t1 ON il1.track_id = t1.track_id
    JOIN track t2 ON il2.track_id = t2.track_id
    WHERE t1.genre_id < t2.genre_id -- Avoid duplicate pairs
    GROUP BY t1.genre_id, t2.genre_id
),
-- Find frequently purchased artist pairs (Corrected)
ArtistPairs AS (
    SELECT 
        al1.artist_id AS artist_1,
        al2.artist_id AS artist_2,
        COUNT(*) AS frequency
    FROM invoice_line il1
    JOIN invoice_line il2 
        ON il1.invoice_id = il2.invoice_id 
        AND il1.track_id <> il2.track_id
    JOIN track t1 ON il1.track_id = t1.track_id
    JOIN track t2 ON il2.track_id = t2.track_id
    JOIN album al1 ON t1.album_id = al1.album_id
    JOIN album al2 ON t2.album_id = al2.album_id
    WHERE al1.artist_id < al2.artist_id -- Avoid duplicate pairs
    GROUP BY al1.artist_id, al2.artist_id
),
-- Find frequently purchased album pairs
AlbumPairs AS (
    SELECT 
        t1.album_id AS album_1,
        t2.album_id AS album_2,
        COUNT(*) AS frequency
    FROM invoice_line il1
    JOIN invoice_line il2 
        ON il1.invoice_id = il2.invoice_id 
        AND il1.track_id <> il2.track_id
    JOIN track t1 ON il1.track_id = t1.track_id
    JOIN track t2 ON il2.track_id = t2.track_id
    WHERE t1.album_id < t2.album_id
    GROUP BY t1.album_id, t2.album_id
)
-- Final selection combining results
SELECT * FROM (
    -- Top Genre Pairs
    SELECT 
        'Genre' AS category,
        g1.name AS item_1, 
        g2.name AS item_2, 
        gp.frequency
    FROM GenrePairs gp
    JOIN genre g1 ON gp.genre_1 = g1.genre_id
    JOIN genre g2 ON gp.genre_2 = g2.genre_id
    ORDER BY gp.frequency DESC
    LIMIT 5
) AS GenreResults

UNION ALL

SELECT * FROM (
    -- Top Artist Pairs
    SELECT 
        'Artist' AS category,
        a1.name AS item_1, 
        a2.name AS item_2, 
        ap.frequency
    FROM ArtistPairs ap
    JOIN artist a1 ON ap.artist_1 = a1.artist_id
    JOIN artist a2 ON ap.artist_2 = a2.artist_id
    ORDER BY ap.frequency DESC
    LIMIT 5
) AS ArtistResults

UNION ALL

SELECT * FROM (
    -- Top Album Pairs
    SELECT 
        'Album' AS category,
        al1.title AS item_1, 
        al2.title AS item_2, 
        ap.frequency
    FROM AlbumPairs ap
    JOIN album al1 ON ap.album_1 = al1.album_id
    JOIN album al2 ON ap.album_2 = al2.album_id
    ORDER BY ap.frequency DESC
    LIMIT 5
) AS AlbumResults;

-- 5.	Regional Market Analysis: Do customer purchasing behaviors and churn rates vary across different geographic regions or store locations? How might these correlate with local demographic or economic factors?

WITH CustomerActivity AS (
    -- Determine last purchase date per customer
    SELECT 
        c.customer_id,
        c.country,
        COUNT(i.invoice_id) AS total_purchases,
        SUM(i.total) AS total_spent,
        MAX(i.invoice_date) AS last_purchase_date
    FROM customer c
    JOIN invoice i ON c.customer_id = i.customer_id
    GROUP BY c.customer_id, c.country
), 

ChurnedCustomers AS (
    -- Identify customers who have not purchased in the last 12 months from the latest invoice date
    SELECT 
        country,
        COUNT(customer_id) AS churned_customers
    FROM CustomerActivity
    WHERE last_purchase_date < DATE_SUB((SELECT MAX(invoice_date) FROM invoice), INTERVAL 12 MONTH)
    GROUP BY country
)

-- Final aggregation: total customers, active customers, and churn rate
SELECT 
    ca.country,
    COUNT(ca.customer_id) AS total_customers,
    SUM(ca.total_purchases) AS total_transactions,
    ROUND(AVG(ca.total_spent), 2) AS avg_spending_per_customer,
    COALESCE(cc.churned_customers, 0) AS churned_customers,
    ROUND((COALESCE(cc.churned_customers, 0) / NULLIF(COUNT(ca.customer_id), 0)) * 100, 2) AS churn_rate_percentage
FROM CustomerActivity ca
LEFT JOIN ChurnedCustomers cc ON ca.country = cc.country
GROUP BY ca.country, cc.churned_customers
ORDER BY churn_rate_percentage DESC;

-- 6.	Customer Risk Profiling: Based on customer profiles (age, gender, location, purchase history), which customer segments are more likely to churn or pose a higher risk of reduced spending? What factors contribute to this risk?

WITH CustomerActivity AS (
    -- Determine each customer's total purchases, total amount spent, and last purchase date
    SELECT 
        c.customer_id, 
        c.country, 
        COUNT(i.invoice_id) AS total_purchases, 
        SUM(i.total) AS total_spent, 
        MAX(i.invoice_date) AS last_purchase_date
    FROM customer c
    JOIN invoice i ON c.customer_id = i.customer_id
    GROUP BY c.customer_id, c.country
),
ChurnRisk AS (
    -- Categorize customers into high-risk, medium-risk, and low-risk based on purchase activity
    SELECT 
        customer_id,
        country,
        total_purchases,
        total_spent,
        last_purchase_date,
        CASE 
            WHEN last_purchase_date < DATE_SUB((SELECT MAX(invoice_date) FROM invoice), INTERVAL 12 MONTH) 
            THEN 'High Risk'  -- No purchase in the last 12 months
            WHEN total_purchases <= 3 OR total_spent < 50 
            THEN 'Medium Risk' -- Low purchase frequency or spending
            ELSE 'Low Risk'  -- Regular customers
        END AS risk_category
    FROM CustomerActivity
)
-- Final aggregation: Risk distribution by country
SELECT 
    country,
    SUM(CASE WHEN risk_category = 'High Risk' THEN 1 ELSE 0 END) AS high_risk_customers,
    SUM(CASE WHEN risk_category = 'Medium Risk' THEN 1 ELSE 0 END) AS medium_risk_customers,
    SUM(CASE WHEN risk_category = 'Low Risk' THEN 1 ELSE 0 END) AS low_risk_customers,
    COUNT(customer_id) AS total_customers,
    ROUND((SUM(CASE WHEN risk_category = 'High Risk' THEN 1 ELSE 0 END) / COUNT(customer_id)) * 100, 2) AS high_risk_percentage
FROM ChurnRisk
GROUP BY country
ORDER BY high_risk_percentage DESC;

-- 7.	Customer Lifetime Value Modeling: How can you leverage customer data (tenure, purchase history, engagement) to predict the lifetime value of different customer segments? This could inform targeted marketing and loyalty program strategies. Can you observe any common characteristics or purchase patterns among customers who have stopped purchasing?

WITH CustomerActivity AS (
    SELECT  
        c.customer_id,  
        c.country,  
        COUNT(i.invoice_id) AS total_purchases,  
        SUM(i.total) AS total_spent,  
        MIN(i.invoice_date) AS first_purchase_date,  
        MAX(i.invoice_date) AS last_purchase_date  
    FROM customer c  
    JOIN invoice i ON c.customer_id = i.customer_id  
    GROUP BY c.customer_id, c.country  
),  
ChurnedCustomers AS (  
    SELECT  
        country,  
        COUNT(customer_id) AS churned_customers  
    FROM CustomerActivity  
    WHERE last_purchase_date < (SELECT MAX(invoice_date) FROM invoice) - INTERVAL 12 MONTH  
    GROUP BY country  
),  
LTV_Calculation AS (  
    SELECT  
        ca.country,  
        COUNT(ca.customer_id) AS total_customers,  
        SUM(ca.total_spent) / COUNT(ca.customer_id) AS avg_revenue_per_customer,  
        SUM(IFNULL(cc.churned_customers, 0)) AS churned_customers,  -- FIXED: Used SUM() for aggregation
        ROUND(1 - (SUM(IFNULL(cc.churned_customers, 0)) / COUNT(ca.customer_id)), 2) AS retention_rate,  
        IF(ROUND(1 - (SUM(IFNULL(cc.churned_customers, 0)) / COUNT(ca.customer_id)), 2) < 1,  
           1 / (1 - ROUND(1 - (SUM(IFNULL(cc.churned_customers, 0)) / COUNT(ca.customer_id)), 2)),  
           10) AS estimated_customer_lifetime  
    FROM CustomerActivity ca  
    LEFT JOIN ChurnedCustomers cc ON ca.country = cc.country  
    GROUP BY ca.country  
)  
SELECT  
    country,  
    total_customers,  
    ROUND(avg_revenue_per_customer, 2) AS avg_revenue_per_customer,  
    churned_customers,  
    retention_rate,  
    estimated_customer_lifetime,  
    ROUND(avg_revenue_per_customer * estimated_customer_lifetime, 2) AS predicted_LTV  
FROM LTV_Calculation  
ORDER BY predicted_LTV DESC;

-- 10.	How can you alter the "Albums" table to add a new column named "ReleaseYear" of type INTEGER to store the release year of each album?

ALTER TABLE Album
ADD COLUMN ReleaseYear INTEGER;

DESC Album;

-- 11.	Chinook is interested in understanding the purchasing behavior of customers based on their geographical location. They want to know the average total amount spent by customers from each country, along with the number of customers and the average number of tracks purchased per customer. Write an SQL query to provide this information.

SELECT c.country,
COUNT(DISTINCT c.customer_id) AS total_customers, 
ROUND(AVG(totals.total_amount), 2) AS avg_amount_spent_per_customer, 
ROUND(AVG(totals.total_tracks), 2) AS avg_tracks_purchased_per_customer
FROM customer c
LEFT JOIN (
-- Calculating total amount spent & total tracks purchased per customer
SELECT
i.customer_id,
SUM(i.total) AS total_amount,
SUM(il.quantity) AS total_tracks
FROM invoice i
JOIN invoice_line il ON i.invoice_id = il.invoice_id
GROUP BY i.customer_id
) AS totals ON c.customer_id = totals.customer_id
GROUP BY c.country
ORDER BY total_customers DESC;



















