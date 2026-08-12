/* ============================================================
   CHINOOK DATABASE — ADVANCED SQL ANALYSIS
   Real relational database of a digital music store
   (11 tables: Customer, Invoice, InvoiceLine, Track, Album,
   Artist, Genre, Employee, MediaType, Playlist, PlaylistTrack)
   ============================================================ */


/* ------------------------------------------------------------
   Q1. TOP 10 COUNTRIES BY REVENUE
   Business question: Where should we focus marketing spend?
   Technique: JOIN + GROUP BY + aggregate
   ------------------------------------------------------------ */
SELECT
    c.Country,
    COUNT(DISTINCT i.InvoiceId)      AS TotalOrders,
    ROUND(SUM(i.Total), 2)           AS TotalRevenue,
    ROUND(SUM(i.Total) * 1.0 / COUNT(DISTINCT i.InvoiceId), 2) AS AvgOrderValue
FROM Invoice i
JOIN Customer c ON c.CustomerId = i.CustomerId
GROUP BY c.Country
ORDER BY TotalRevenue DESC
LIMIT 10;


/* ------------------------------------------------------------
   Q2. TOP 10 CUSTOMERS BY LIFETIME VALUE (CLV)
   Business question: Who are our most valuable customers to retain?
   Technique: JOIN + aggregate + RANK() window function
   ------------------------------------------------------------ */
SELECT
    RANK() OVER (ORDER BY SUM(i.Total) DESC) AS Rank,
    c.CustomerId,
    c.FirstName || ' ' || c.LastName AS CustomerName,
    c.Country,
    COUNT(DISTINCT i.InvoiceId)      AS TotalOrders,
    ROUND(SUM(i.Total), 2)           AS LifetimeValue
FROM Customer c
JOIN Invoice i ON i.CustomerId = c.CustomerId
GROUP BY c.CustomerId
ORDER BY LifetimeValue DESC
LIMIT 10;


/* ------------------------------------------------------------
   Q3. MONTHLY REVENUE TREND WITH RUNNING TOTAL
   Business question: How is revenue trending, and what's cumulative growth?
   Technique: CTE + window function (running total)
   ------------------------------------------------------------ */
WITH monthly AS (
    SELECT
        strftime('%Y-%m', InvoiceDate) AS Month,
        ROUND(SUM(Total), 2) AS Revenue
    FROM Invoice
    GROUP BY Month
)
SELECT
    Month,
    Revenue,
    ROUND(SUM(Revenue) OVER (ORDER BY Month), 2) AS RunningTotal,
    ROUND(Revenue - LAG(Revenue) OVER (ORDER BY Month), 2) AS ChangeVsPrevMonth
FROM monthly
ORDER BY Month;


/* ------------------------------------------------------------
   Q4. TOP 5 BEST-SELLING GENRES BY REVENUE AND UNITS SOLD
   Business question: Which genres should we stock/promote more?
   Technique: Multi-table JOIN (4 tables) + aggregate
   ------------------------------------------------------------ */
SELECT
    g.Name AS Genre,
    COUNT(il.InvoiceLineId) AS UnitsSold,
    ROUND(SUM(il.UnitPrice * il.Quantity), 2) AS Revenue
FROM InvoiceLine il
JOIN Track t  ON t.TrackId = il.TrackId
JOIN Genre g  ON g.GenreId = t.GenreId
GROUP BY g.Name
ORDER BY Revenue DESC
LIMIT 5;


/* ------------------------------------------------------------
   Q5. TOP 5 ARTISTS BY REVENUE
   Business question: Which artists drive the most sales — negotiate better deals with them?
   Technique: 5-table JOIN chain
   ------------------------------------------------------------ */
SELECT
    ar.Name AS Artist,
    COUNT(DISTINCT al.AlbumId) AS Albums,
    COUNT(il.InvoiceLineId)    AS TracksSold,
    ROUND(SUM(il.UnitPrice * il.Quantity), 2) AS Revenue
FROM InvoiceLine il
JOIN Track t   ON t.TrackId = il.TrackId
JOIN Album al  ON al.AlbumId = t.AlbumId
JOIN Artist ar ON ar.ArtistId = al.ArtistId
GROUP BY ar.ArtistId
ORDER BY Revenue DESC
LIMIT 5;


/* ------------------------------------------------------------
   Q6. EMPLOYEE SALES PERFORMANCE (Support Reps)
   Business question: Which support reps are managing the highest-value customers?
   Technique: JOIN across Employee -> Customer -> Invoice
   ------------------------------------------------------------ */
SELECT
    e.EmployeeId,
    e.FirstName || ' ' || e.LastName AS EmployeeName,
    e.Title,
    COUNT(DISTINCT c.CustomerId) AS CustomersManaged,
    COUNT(DISTINCT i.InvoiceId)  AS OrdersHandled,
    ROUND(SUM(i.Total), 2)       AS RevenueGenerated
FROM Employee e
JOIN Customer c ON c.SupportRepId = e.EmployeeId
JOIN Invoice i  ON i.CustomerId = c.CustomerId
GROUP BY e.EmployeeId
ORDER BY RevenueGenerated DESC;


/* ------------------------------------------------------------
   Q7. CUSTOMER VALUE SEGMENTATION (High / Mid / Low tiers)
   Business question: Which customer tier should get the loyalty campaign budget?
   Technique: CTE + NTILE() window function (quartile-style bucketing)
   ------------------------------------------------------------ */
WITH customer_spend AS (
    SELECT CustomerId, SUM(Total) AS TotalSpent
    FROM Invoice
    GROUP BY CustomerId
),
tiered AS (
    SELECT
        CustomerId,
        TotalSpent,
        NTILE(3) OVER (ORDER BY TotalSpent DESC) AS Tier
    FROM customer_spend
)
SELECT
    CASE Tier
        WHEN 1 THEN 'High Value'
        WHEN 2 THEN 'Mid Value'
        ELSE 'Low Value'
    END AS Segment,
    COUNT(*) AS NumCustomers,
    ROUND(AVG(TotalSpent), 2) AS AvgSpentPerCustomer,
    ROUND(SUM(TotalSpent), 2) AS SegmentRevenue
FROM tiered
GROUP BY Tier
ORDER BY Tier;


/* ------------------------------------------------------------
   Q8. TOP TRACK PER GENRE (using window function PARTITION BY)
   Business question: What's the best-selling track in each genre? (for playlists/promo)
   Technique: Window function ROW_NUMBER() PARTITION BY + CTE
   ------------------------------------------------------------ */
WITH track_sales AS (
    SELECT
        g.Name AS Genre,
        t.Name AS Track,
        SUM(il.Quantity) AS UnitsSold,
        ROW_NUMBER() OVER (PARTITION BY g.Name ORDER BY SUM(il.Quantity) DESC) AS rn
    FROM InvoiceLine il
    JOIN Track t ON t.TrackId = il.TrackId
    JOIN Genre g ON g.GenreId = t.GenreId
    GROUP BY g.Name, t.Name
)
SELECT Genre, Track, UnitsSold
FROM track_sales
WHERE rn = 1
ORDER BY UnitsSold DESC
LIMIT 10;


/* ------------------------------------------------------------
   Q9. CUSTOMERS WHO SPENT ABOVE AVERAGE (subquery)
   Business question: Identify high-value customers for a loyalty program
   Technique: Correlated subquery in WHERE clause
   ------------------------------------------------------------ */
SELECT
    c.CustomerId,
    c.FirstName || ' ' || c.LastName AS CustomerName,
    c.Country,
    ROUND(SUM(i.Total), 2) AS TotalSpent
FROM Customer c
JOIN Invoice i ON i.CustomerId = c.CustomerId
GROUP BY c.CustomerId
HAVING SUM(i.Total) > (
    SELECT AVG(CustomerTotal) FROM (
        SELECT SUM(Total) AS CustomerTotal FROM Invoice GROUP BY CustomerId
    )
)
ORDER BY TotalSpent DESC;


/* ------------------------------------------------------------
   Q10. ALBUM VS SINGLE-TRACK PURCHASE BEHAVIOR
   Business question: Do customers buy full albums or individual tracks?
   (Useful for pricing/bundling strategy)
   Technique: CTE comparing purchased tracks vs full album track count
   ------------------------------------------------------------ */
WITH album_track_counts AS (
    SELECT AlbumId, COUNT(*) AS TotalTracksInAlbum
    FROM Track
    GROUP BY AlbumId
),
customer_album_purchases AS (
    SELECT
        i.CustomerId,
        t.AlbumId,
        COUNT(DISTINCT il.TrackId) AS TracksPurchased
    FROM InvoiceLine il
    JOIN Invoice i ON i.InvoiceId = il.InvoiceId
    JOIN Track t   ON t.TrackId = il.TrackId
    WHERE t.AlbumId IS NOT NULL
    GROUP BY i.CustomerId, t.AlbumId
)
SELECT
    CASE
        WHEN cap.TracksPurchased = atc.TotalTracksInAlbum THEN 'Full Album Purchase'
        ELSE 'Partial / Single Track Purchase'
    END AS PurchaseType,
    COUNT(*) AS Occurrences
FROM customer_album_purchases cap
JOIN album_track_counts atc ON atc.AlbumId = cap.AlbumId
GROUP BY PurchaseType;


/* ------------------------------------------------------------
   Q11. YEAR-OVER-YEAR REVENUE GROWTH
   Business question: Is the business growing year on year?
   Technique: CTE + LAG() window function + percentage growth calc
   ------------------------------------------------------------ */
WITH yearly AS (
    SELECT strftime('%Y', InvoiceDate) AS Year, ROUND(SUM(Total), 2) AS Revenue
    FROM Invoice
    GROUP BY Year
)
SELECT
    Year,
    Revenue,
    LAG(Revenue) OVER (ORDER BY Year) AS PrevYearRevenue,
    ROUND(
        (Revenue - LAG(Revenue) OVER (ORDER BY Year)) * 100.0
        / LAG(Revenue) OVER (ORDER BY Year), 2
    ) AS YoY_Growth_Pct
FROM yearly
ORDER BY Year;


/* ------------------------------------------------------------
   Q12. PLAYLIST COMPOSITION ANALYSIS
   Business question: What genres dominate our curated playlists?
   Technique: 4-table JOIN + aggregate + percentage share
   ------------------------------------------------------------ */
SELECT
    p.Name AS Playlist,
    g.Name AS Genre,
    COUNT(*) AS TrackCount,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY p.Name), 1) AS PctOfPlaylist
FROM PlaylistTrack pt
JOIN Playlist p ON p.PlaylistId = pt.PlaylistId
JOIN Track t    ON t.TrackId = pt.TrackId
JOIN Genre g    ON g.GenreId = t.GenreId
WHERE p.Name IN ('Music', 'TV Shows', '90s Music')
GROUP BY p.Name, g.Name
ORDER BY p.Name, TrackCount DESC;
