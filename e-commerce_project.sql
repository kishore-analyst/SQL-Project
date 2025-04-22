

-- Quarterly Trend Analysis of Sessions and Orders


SELECT 
	YEAR(ws.created_at) AS year,
    QUARTER(ws.created_at) AS quarter,
    COUNT(DISTINCT ws.website_session_id) AS total_sessions,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM
	website_sessions ws
    LEFT JOIN orders o
		ON o.website_session_id = ws.website_session_id
GROUP BY 
	1,2
ORDER BY
	1,2;



-- Quarterly Trend Analysis of Conversion Rate, Revenue per Order, and Revenue per Session


SELECT 
	YEAR(ws.created_at) AS year,
    QUARTER(ws.created_at) AS quarter,
    COUNT(DISTINCT ws.website_session_id) AS total_sessions,
    COUNT(DISTINCT o.order_id) AS total_orders,
    CONCAT(ROUND(COUNT(DISTINCT o.order_id)*100
		/COUNT(DISTINCT ws.website_session_id),2),'%') AS conversion_rate,
	ROUND(SUM(o.price_usd)/COUNT(DISTINCT order_id),2) AS rev_per_order,
    ROUND(SUM(o.price_usd)/COUNT(DISTINCT ws.website_session_id),2) AS rev_per_session
FROM
	website_sessions ws
    LEFT JOIN orders o
		ON o.website_session_id = ws.website_session_id
GROUP BY 
	1,2
ORDER BY
	1,2;



-- Quarterly Trend Analysis of Orders by Marketing Channel


select distinct utm_source,utm_campaign,http_referer from website_sessions;
SELECT
	YEAR(ws.created_at) AS year,
    QUARTER(ws.created_at) AS quarter,
    COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NULL THEN order_id ELSE 'others' END) AS direct_type_in_orders,
	COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NOT NULL THEN order_id ELSE 'others' END) AS organic_search_orders,
	COUNT(DISTINCT CASE WHEN utm_campaign = 'nonbrand' AND utm_source = 'gsearch' THEN order_id ELSE 'others' END) AS gsearch_nonbrand_orders,
	COUNT(DISTINCT CASE WHEN utm_campaign = 'nonbrand' AND utm_source = 'bsearch' THEN order_id ELSE 'others' END) AS bsearch_nonbrand_orders,
	COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN order_id ELSE 'others' END) AS brand_search_orders
FROM
	website_sessions ws
	LEFT JOIN orders o
		ON o.website_session_id = ws.website_session_id
GROUP BY 1,2;



-- Quarterly Trend Analysis of Conversion Rates by Marketing Channel


SELECT
	YEAR(ws.created_at) AS year,
    QUARTER(ws.created_at) AS quarter,
    ROUND(COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NULL THEN order_id ELSE NULL END)*100
		/COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NULL THEN ws.website_session_id ELSE NULL END),2) AS direct_type_in_cnvr_rt,
	ROUND(COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NOT NULL THEN order_id ELSE NULL END) *100
		/COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NOT NULL THEN ws.website_session_id ELSE NULL END),2) AS organic_search_cnvr_rt,
	ROUND(COUNT(DISTINCT CASE WHEN utm_campaign = 'nonbrand' AND utm_source = 'gsearch' THEN order_id ELSE NULL END)*100
		/COUNT(DISTINCT CASE WHEN utm_campaign = 'nonbrand' AND utm_source = 'gsearch' THEN ws.website_session_id ELSE NULL END),2) AS gsearch_nonbrand_cnvr_rt,
	ROUND(COUNT(DISTINCT CASE WHEN utm_campaign = 'nonbrand' AND utm_source = 'bsearch' THEN order_id ELSE NULL END) *100
		/COUNT(DISTINCT CASE WHEN utm_campaign = 'nonbrand' AND utm_source = 'bsearch' THEN ws.website_session_id ELSE NULL END),2) AS bsearch_nonbrand_cnvr_rt,
	ROUND(COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN order_id ELSE NULL END)*100
		/COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN ws.website_session_id ELSE NULL END),2) AS brand_search_cnvr_rt
FROM
	website_sessions ws
	LEFT JOIN orders o
		ON o.website_session_id = ws.website_session_id
GROUP BY 1,2;



-- Monthly Trend Analysis of Revenue and Margin by Product, Including Overall Totals


select* from products;
select* from orders;

SELECT
	YEAR(created_at) AS year,
    MONTH(created_at) AS quarter,
    SUM(CASE WHEN primary_product_id = 1 THEN price_usd ELSE NULL END) AS fuzzy_rev,
	SUM(CASE WHEN primary_product_id = 1 THEN price_usd-cogs_usd ELSE NULL END) AS fuzzy_mar,
    SUM(CASE WHEN primary_product_id = 2 THEN price_usd ELSE NULL END) AS lovebear_rev,
	SUM(CASE WHEN primary_product_id = 2 THEN price_usd-cogs_usd ELSE NULL END) AS lovebear_mar,
    SUM(CASE WHEN primary_product_id = 3 THEN price_usd ELSE NULL END) AS birthday_rev,
	SUM(CASE WHEN primary_product_id = 3 THEN price_usd-cogs_usd ELSE NULL END) AS birthday_mar,
    SUM(CASE WHEN primary_product_id = 4 THEN price_usd ELSE NULL END) AS mini_rev,
	SUM(CASE WHEN primary_product_id = 4 THEN price_usd-cogs_usd ELSE NULL END) AS mini_mar,
    SUM(price_usd) AS total_revenue,
    SUM(price_usd-cogs_usd) AS total_margin
FROM
	orders o
GROUP BY 1,2;



-- Monthly Trend Analysis of Product Page Engagement and Conversion Funnel


SELECT * FROM website_pageviews;

WITH product_page_session_id AS(
SELECT
	website_session_id,
    website_pageview_id,
    created_at 
FROM
	website_pageviews
WHERE 
	pageview_url = '/products'
)

SELECT 
	YEAR(pg.created_at) AS year,
    MONTH(pg.created_at) AS month,
    COUNT(DISTINCT pg.website_session_id) AS product_sessions,
    COUNT(DISTINCT wp.website_session_id) AS clck_through_next_page,
    ROUND(COUNT(DISTINCT wp.website_session_id)*100
		/COUNT(DISTINCT pg.website_session_id),2) AS prod_to_other_page_rt,
	COUNT(DISTINCT order_id) AS orders,
    ROUND(COUNT(DISTINCT order_id)*100
		/COUNT(DISTINCT pg.website_session_id),2) AS prdct_to_order_rt
FROM
	product_page_session_id pg
    LEFT JOIN website_pageviews wp
		ON wp.website_session_id = pg.website_session_id
        AND wp.website_pageview_id > pg.website_pageview_id
	LEFT JOIN orders o
		ON o.website_session_id = pg.website_session_id
GROUP BY 
	1,2;



-- Cross-Sell Analysis of Product Sales Since the Launch of the 4th Primary Product (Dec 5, 2014)


select * from order_items;
select * from orders;

CREATE TEMPORARY TABLE product_order_id
SELECT 
	order_id,
    primary_product_id
    
FROM orders
WHERE created_at > '2014-12-05';
    

SELECT 
	primary_product_id,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT CASE WHEN cross_sale_item_id = 1 THEN order_id ELSE NULL END) AS product_1,
    COUNT(DISTINCT CASE WHEN cross_sale_item_id = 2 THEN order_id ELSE NULL END) AS product_2,
    COUNT(DISTINCT CASE WHEN cross_sale_item_id = 3 THEN order_id ELSE NULL END) AS product_3,
    COUNT(DISTINCT CASE WHEN cross_sale_item_id = 4 THEN order_id ELSE NULL END) AS product_4,
    
    ROUND(COUNT(DISTINCT CASE WHEN cross_sale_item_id = 1 THEN order_id ELSE NULL END)/COUNT(DISTINCT order_id)*100,2) AS product_1_cvr,
	ROUND(COUNT(DISTINCT CASE WHEN cross_sale_item_id = 2 THEN order_id ELSE NULL END)/COUNT(DISTINCT order_id)*100,2) AS product_2_cvr,
    ROUND(COUNT(DISTINCT CASE WHEN cross_sale_item_id = 3 THEN order_id ELSE NULL END)/COUNT(DISTINCT order_id)*100,2) AS product_3_cvr,
    ROUND(COUNT(DISTINCT CASE WHEN cross_sale_item_id = 4 THEN order_id ELSE NULL END)/COUNT(DISTINCT order_id)*100,2) AS product_4_cvr
FROM(
SELECT 
	p.*,
    oi.product_id AS cross_sale_item_id
FROM 
	product_order_id p
    LEFT JOIN order_items oi
		ON oi.order_id = p.order_id
		AND is_primary_item = 0
) AS prd_id_w_crs_id
GROUP BY 1;
