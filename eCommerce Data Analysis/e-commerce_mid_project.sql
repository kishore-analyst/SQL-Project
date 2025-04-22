-- 1. Monthly Trend Analysis of Gsearch Sessions and Orders
        
SELECT 
	YEAR(ws.created_at) `year`,
    MONTH(ws.created_at) `month`,
    COUNT(DISTINCT ws.website_session_id) AS total_sessions,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM
	website_sessions ws
    LEFT JOIN orders o
		ON o.website_session_id = ws.website_session_id
WHERE 
	ws.created_at < '2012-11-27'
	AND ws.utm_source = 'gsearch'
GROUP BY 
	1,2;
			
    
 -- 2. Monthly Trend Analysis of Gsearch Sessions and Orders by Brand and Nonbrand Campaigns

        
SELECT * FROM website_sessions;        
 SELECT 
	YEAR(ws.created_at) `year`,
    MONTH(ws.created_at) `month`,
    COUNT(DISTINCT ws.website_session_id) AS total_sessions,
    COUNT(DISTINCT CASE WHEN utm_campaign = 'nonbrand' THEN ws.website_session_id ELSE NULL END) AS nonbrand_session,
    COUNT(DISTINCT CASE WHEN utm_campaign = 'nonbrand' THEN order_id ELSE NULL END) AS nonbrand_orders,
    COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN ws.website_session_id ELSE NULL END) AS brand_session,
    COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN order_id ELSE NULL END) AS brand_orders
 FROM
	website_sessions ws
    LEFT JOIN orders o
		ON o.website_session_id = ws.website_session_id
 WHERE
	ws.created_at < '2012-11-27'
	AND ws.utm_source = 'gsearch'
    
GROUP BY 
	1,2
;
        
        
 -- 3.Monthly Trend Analysis of Gsearch Nonbrand Sessions and Orders by Device Type

        
SELECT 
	YEAR(ws.created_at) AS `year`,
	MONTH(ws.created_at) AS `month`,
    COUNT(DISTINCT CASE WHEN ws.device_type = 'mobile' THEN ws.website_session_id ELSE NULL END) AS mobile_sessions,
	COUNT(DISTINCT CASE WHEN ws.device_type = 'mobile' THEN order_id ELSE NULL END) AS mobile,
    COUNT(DISTINCT CASE WHEN ws.device_type = 'desktop' THEN ws.website_session_id ELSE NULL END) AS desktop_sessions,
    COUNT(DISTINCT CASE WHEN ws.device_type = 'desktop' THEN order_id ELSE NULL END) AS desktop
FROM 
   website_sessions ws
	LEFT JOIN orders o
		ON o.website_session_id = ws.website_session_id
WHERE
	ws.created_at < '2012-11-27'
	AND ws.utm_source = 'gsearch'
    AND ws.utm_campaign = 'nonbrand'
GROUP BY 
	1,2;
        
        
-- 4. Monthly Trend Analysis of Sessions by Marketing Channel Including Gsearch

        
-- SELECT DISTINCT utm_source, utm_campaign, http_referer
-- FROM website_sessions
-- WHERE created_at < '2012-11-27';

SELECT
	YEAR(ws.created_at) `year`,
    MONTH(ws.created_at) `month`,
    COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' THEN ws.website_session_id ELSE NULL END) AS gsearch_paid_sessions,
    COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' THEN ws.website_session_id ELSE NULL END) AS bsearch_paid_sessions,
	COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NOT NULL THEN website_session_id ELSE NULL END)  AS organic_search_sessions,
    COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NULL THEN website_session_id ELSE NULL END)  AS direct_search_sessions
FROM website_sessions ws
        
WHERE
 	ws.created_at < '2012-11-27'        
GROUP BY 
	1,2;
        
        
 -- 5. Monthly Trend Analysis of Session-to-Order Conversion Rate

	
SELECT
   YEAR(ws.created_at) AS year,
   MONTH(ws.created_at) AS month,
   COUNT(DISTINCT ws.website_session_id) AS total_sessions,
   COUNT(DISTINCT o.order_id) AS total_order,
   CONCAT(
		ROUND(COUNT(DISTINCT o.order_id)*100
				/COUNT(DISTINCT ws.website_session_id),2),'%'
		) AS conv_rate
FROM 
	website_sessions ws
	LEFT JOIN orders o
		ON o.website_session_id = ws.website_session_id
WHERE 
	ws.created_at < '2012-11-27'
 GROUP BY 
	1,2;
	
 
 -- 6. Revenue Impact Analysis from Gsearch Lander Test (Jun 19 – Jul 28)

        
-- SELECT * FROM website_pageviews;
-- SELECT * FROM website_sessions;

SELECT 
	MIN(website_pageview_id)
FROM
	website_pageviews
WHERE 
	pageview_url = '/lander-1';
    
-- min_lander-1_session_id = 23504

CREATE TEMPORARY TABLE first_test_pages	
SELECT 
    ws.website_session_id,
    MIN(wp.website_pageview_id) AS min_pv_id,
    MIN(wp.pageview_url) AS lander_page
FROM 
    website_pageviews wp
LEFT JOIN website_sessions ws
    ON ws.website_session_id = wp.website_session_id
    AND ws.created_at < '2012-07-28'
    AND ws.utm_source = 'gsearch'
    AND ws.utm_campaign = 'nonbrand'
    AND wp.website_pageview_id >= 23504
GROUP BY 
    ws.website_session_id;


CREATE TEMPORARY TABLE session_w_landers    
SELECT 
	swl.website_session_id,
    wp.pageview_url
FROM 
	first_test_pages swl
	LEFT JOIN website_pageviews wp
    ON wp.website_session_id = swl.website_session_id
WHERE 
	wp.pageview_url IN ('/home', '/lander-1');
    
    
-- finding conversion rate    
SELECT
	sw.pageview_url,
    COUNT(DISTINCT sw.website_session_id) AS total_sessions,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT o.order_id)/COUNT(DISTINCT sw.website_session_id) AS cover_rate
FROM 
	session_w_landers sw
    LEFT JOIN orders o
		ON o.website_session_id = sw.website_session_id
GROUP BY  1;
    

SELECT
	MAX(ws.website_session_id) AS max_home_url_id
FROM 
	website_sessions ws
	LEFT JOIN website_pageviews wp
		ON wp.website_session_id = ws.website_session_id
WHERE
	ws.created_at < '2012-11-27'
    AND ws.utm_source = 'gsearch'
    AND ws.utm_campaign = 'nonbrand'
    AND wp.pageview_url = '/home'
   ;
 -- max_session_id of /home = 17145  
   
SELECT 
	COUNT(website_session_id) as session_id
FROM 
	website_sessions
WHERE 
	created_at < '2012-11-27'
	AND utm_source = 'gsearch'
    AND utm_campaign = 'nonbrand'
    AND website_session_id > 17145;
    
-- 22,972 is the session since the test
-- /home conv_rate = 3.18% and /lander-1 conv_rate = 4.06% 
-- increased CVR is 3.18 - 4.06 = 0.88 %
-- so incremental order since 7-29 is (22972*0.88) =  202 
    
    
-- Conversion Funnel Analysis of Landing Page Test (Jun 19 – Jul 28)

    
SELECT  distinct pageview_url
from website_pageviews
where created_at between '2012-06-19' and '2012-07-28'
;
-- /products, /the-original-mr-fuzzy, /cart, /lander-1, /home, /shipping, /billing, /thank-you-for-your-order

CREATE TEMPORARY TABLE flag
SELECT
	wp.website_session_id,
    wp.created_at,
    CASE WHEN pageview_url ='/home' THEN 1 ELSE 0 END AS home,
	CASE WHEN pageview_url ='/lander-1' THEN 1 ELSE 0 END AS custom,
    CASE WHEN pageview_url ='/products' THEN 1 ELSE 0 END AS product,
    CASE WHEN pageview_url ='/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS fuzzy,
    CASE WHEN pageview_url ='/cart' THEN 1 ELSE 0 END AS cart,
    CASE WHEN pageview_url ='/shipping' THEN 1 ELSE 0 END AS shippping,
    CASE WHEN pageview_url ='/billing' THEN 1 ELSE 0 END AS billing,
    CASE WHEN pageview_url ='/thank-you-for-your-order' THEN 1 ELSE 0 END AS thank_you
FROM
	website_pageviews wp
	LEFT JOIN website_sessions ws
		ON ws.website_session_id = wp.website_session_id
WHERE 
	ws.created_at > '2012-06-19'
	AND ws.created_at < '2012-07-28'
	AND ws.utm_source = 'gsearch'
	AND ws.utm_campaign = 'nonbrand';

CREATE TEMPORARY TABLE flagged_tab
SELECT 
	website_session_id,
    MAX(home) AS home,
	MAX(custom) AS custom,
    MAX(product) AS product,
    MAX(fuzzy) AS fuzzy,
	MAX(cart) AS cart,
    MAX(shippping) AS shippping,
    MAX(billing) AS billing,
    MAX(thank_you) AS thank_you
    
FROM flag
GROUP BY 1;
        
        
SELECT 
	CASE 
		WHEN home = 1 THEN  'HOME' 
        WHEN custom = 1 THEN 'CUSTOM'
	ELSE 'UHH NO THERE' END AS segment,
    COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT CASE WHEN product = 1 THEN website_session_id ELSE NULL END) product,
    COUNT(DISTINCT CASE WHEN fuzzy = 1 THEN website_session_id ELSE NULL END) fuzzy,
    COUNT(DISTINCT CASE WHEN cart = 1 THEN website_session_id ELSE NULL END) cart,
    COUNT(DISTINCT CASE WHEN shippping = 1 THEN website_session_id ELSE NULL END) shippping,
    COUNT(DISTINCT CASE WHEN billing = 1 THEN website_session_id ELSE NULL END) billing,
    COUNT(DISTINCT CASE WHEN thank_you = 1 THEN website_session_id ELSE NULL END) thank_you
FROM 
	flagged_tab
GROUP BY 1;
        

 -- 8. Revenue Impact Analysis of Billing Page Test (Sep 10 – Nov 10)

        
SELECT	
	pageview_url AS billing_version,
    COUNT(DISTINCT  website_session_id) AS total_session,
    SUM(price_usd)/COUNT(DISTINCT  website_session_id) AS revenue_per_page

FROM(
SELECT
	wp.website_session_id,
    wp.pageview_url,
    o.order_id,
    o.price_usd
FROM 
	website_pageviews wp
	LEFT JOIN orders o
		ON o.website_session_id = wp. website_session_id
WHERE 
	wp.created_at > '2012-09-10'
	AND wp.created_at < '2012-11-10'
    AND wp.pageview_url IN ('/billing','/billing-2')
) AS session_order_price

GROUP BY 1;

-- billing revenue per pageview - 22.82
-- billing-2 revenue per pageview - 31.33

-- so the lift is 8.51 USD

SELECT COUNT(DISTINCT website_session_id)
FROM website_pageviews
WHERE 
	created_at BETWEEN '2012-10-27' and '2012-11-27'
    AND pageview_url IN ('/billing','/billing-2');
    
-- the total billing happend past month is 1193
-- so the gain we acquired after the test is 1193*8.51 = $ 10,152