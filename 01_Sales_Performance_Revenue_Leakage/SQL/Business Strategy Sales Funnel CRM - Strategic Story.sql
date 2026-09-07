'Analysis on sales funnel: Where are losing opportunities?'

'01_DATA EXPLORATION'

'1) Understanding SALES_PIPELINE dataset'
SELECT
    COUNT(*) AS total_rows,
    COUNT(opportunity_id) AS opportunity_id_present,
    COUNT(case when sales_agent = '' then 1 else 0 END) AS sales_agent_present,
    COUNT(case when product = '' then 1 else 0 end) AS product_present,
    COUNT(case when account = '' then 1 else 0 END) AS account_present,
    COUNT(deal_stage) AS deal_stage_present,
    COUNT(engage_date) AS engage_date_present,
    COUNT(close_date) AS close_date_present,
    COUNT(close_value) AS close_value_present
FROM sales_pipeline;

'2) Improve SALES_PIPELINE dataset for joining with other datasets'

UPDATE sales_pipeline sp
set product = 'GTX Pro'
WHERE sp.product = 'GTXPro';

ALTER TABLE sales_pipeline
ADD COLUMN sales_price NUMERIC;

UPDATE sales_pipeline sp
SET sales_price = p.sales_price
FROM products p
WHERE sp.product = p.product;

'3) Understanding funnel stages'

select deal_stage, COUNT(*) AS funnel_steps
FROM sales_pipeline
GROUP BY deal_stage
ORDER BY funnel_steps DESC;

'4) Time frame of dataset'

select sp.close_date, COUNT (*)
from sales_pipeline sp
group by close_date
order by close_date desc;

SELECT COUNT(DISTINCT close_date) AS unique_close_dates
FROM sales_pipeline;

'02_SALES FUNNEL'

'1) What proportion of our opportunities are being converted into sales?'

SELECT
    deal_stage,
    COUNT(*) AS opportunities,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS percentage_of_opportunities
FROM sales_pipeline sp
GROUP BY deal_stage
ORDER BY opportunities DESC;

'2) How much commercial value are we winning, losing and currently managing?'

select
	sp.deal_stage,
	COUNT(*) AS total_opportunities,
	ROUND(100.0 * COUNT(*) /SUM(COUNT(*)) OVER (), 2) AS percentage_of_opportunities,
	SUM(CASE WHEN sp.deal_stage = 'Won' THEN sp.close_value ELSE p.sales_price END) AS commercial_value,
	ROUND(100.0 * SUM(CASE WHEN sp.deal_stage = 'Won' THEN sp.close_value ELSE p.sales_price END)
	/SUM(SUM(case WHEN sp.deal_stage = 'Won' THEN sp.close_value ELSE p.sales_price END)) OVER (), 2) AS percentage_of_commercial_value
FROM sales_pipeline sp
JOIN products p
    ON sp.product = p.product
GROUP BY sp.deal_stage
ORDER BY commercial_value DESC;

'3) Are losses concentrated in specific products?'

select sp.product,
    COUNT(*) AS total_opportunities,
    SUM(case WHEN sp.deal_stage = 'Won' THEN 1 ELSE 0 END) AS won_opportunities,
    SUM(case WHEN sp.deal_stage = 'Lost' THEN 1 ELSE 0 END) AS lost_opportunities,
    ROUND(100.0 * SUM(case WHEN sp.deal_stage = 'Lost' THEN 1 ELSE 0 END)/
     (SUM(case WHEN sp.deal_stage = 'Won' THEN 1 ELSE 0 END) + SUM(case WHEN sp.deal_stage = 'Lost' THEN 1 ELSE 0 END)), 2) AS loss_rate,
    SUM(case WHEN sp.deal_stage = 'Lost' THEN p.sales_price ELSE 0 END) AS lost_revenue_potential
FROM sales_pipeline sp
JOIN products p
    ON sp.product = p.product
GROUP BY sp.product
ORDER BY lost_revenue_potential DESC;


'4) Which products are already performing well and could we scale them?'

SELECT
    sp.product,
    COUNT(*) AS total_opportunities,
    SUM(case WHEN sp.deal_stage = 'Won' then 1 else 0 end) AS won_opportunities,
    ROUND(100.0 * SUM(case WHEN sp.deal_stage = 'Won' then 1 else 0 end)/
        NULLIF(SUM(case WHEN sp.deal_stage IN ('Won', 'Lost') THEN 1 ELSE 0 end), 0), 2) as win_rate,
    SUM(case WHEN sp.deal_stage = 'Won' then sp.close_value else 0 end) as won_revenue,
    AVG(case WHEN sp.deal_stage = 'Won' then sp.close_value else 0 end) as average_won_deal
FROM sales_pipeline sp
GROUP BY sp.product
ORDER BY won_revenue DESC;

'03_SALES AGENT ANALYSIS'

'9) Is the problem product-related or sales-execution-related? - Are some sales agents significantly better at converting opportunities?'

'Query 1 - Win rate of each sales agent'

SELECT
    sales_agent, COUNT(*) AS total_opportunities,
    SUM(case WHEN deal_stage = 'Won' THEN 1 else 0 end) as won_opportunities,
    SUM(case WHEN deal_stage = 'Lost' THEN 1 else 0 end) as lost_opportunities,
    ROUND(100*SUM(case WHEN deal_stage = 'Won' THEN 1 else 0 end)/
    	nullif(SUM(case when deal_stage in('Won','Lost') then 1 else 0 end), 0),2) as win_rate,
    SUM(CASE WHEN deal_stage = 'Won' THEN close_value ELSE 0 END) AS won_revenue
FROM sales_pipeline
GROUP BY sales_agent
ORDER by won_opportunities DESC;

'Query 2 - Win rate of each sales agent x type of product'

SELECT
    sp.sales_agent,
    sp.product,
    COUNT(*) AS total_opportunities,
    SUM(CASE WHEN sp.deal_stage = 'Won' THEN 1 ELSE 0 END) AS won_opportunities,
    SUM(CASE WHEN sp.deal_stage = 'Lost' THEN 1 ELSE 0 END) AS lost_opportunities,
    SUM(CASE WHEN sp.deal_stage = 'Lost' THEN p.sales_price ELSE 0 END) AS lost_potencial_revenue,
    ROUND(100.0 *SUM(CASE WHEN sp.deal_stage = 'Won' THEN 1 ELSE 0 END)/
        NULLIF(SUM(CASE WHEN sp.deal_stage IN ('Won', 'Lost') THEN 1 ELSE 0 END),0),2) AS win_rate,
    ROUND(100.0 *SUM(CASE WHEN sp.deal_stage = 'Lost' THEN 1 ELSE 0 END)/
        NULLIF(SUM(CASE WHEN sp.deal_stage IN ('Won', 'Lost') THEN 1 ELSE 0 END),0),2) AS lost_rate
FROM sales_pipeline sp
join products p
	on p.product = sp.product
where sp.product in ('MG Advanced', 'GTX Pro')
GROUP BY
    sp.sales_agent,
    sp.product
having COUNT(*) > 20
ORDER BY
    sp.product,
    lost_rate DESC;


'04_PRODUCT ANALYSIS'

'Query 4 - Win rate of each sector x type of product'

SELECT
    a.sector,
    sp.product, COUNT(*) AS total_opportunities,
    SUM(CASE WHEN sp.deal_stage = 'Won' THEN 1 ELSE 0 END) AS won_opportunities,
    SUM(CASE WHEN sp.deal_stage = 'Lost' THEN 1 ELSE 0 END) AS lost_opportunities,
    SUM(CASE WHEN sp.deal_stage = 'Lost' THEN p.sales_price ELSE 0 END) AS lost_potencial_revenue,
    ROUND(100.0 *SUM(CASE WHEN sp.deal_stage = 'Won' THEN 1 ELSE 0 END)/
        NULLIF(SUM(CASE WHEN sp.deal_stage IN ('Won', 'Lost') THEN 1 ELSE 0 END),0),2) AS win_rate,
    ROUND(100.0 *SUM(CASE WHEN sp.deal_stage = 'Lost' THEN 1 ELSE 0 END)/
        NULLIF(SUM(CASE WHEN sp.deal_stage IN ('Won', 'Lost') THEN 1 ELSE 0 END),0),2) AS lost_rate
FROM sales_pipeline sp
join products p
	on p.product = sp.product
join accounts a
	on a.account = sp.account
GROUP BY
    a.sector,
    sp.product
having COUNT(*) > 20
ORDER BY
    a.sector,
    lost_rate DESC;

'05_SECTOR ANALYSIS'

'Query 1 - Win rate for each sector'

SELECT
    a.sector,
    COUNT(*) AS opportunities,
    SUM(case WHEN sp.deal_stage = 'Won' THEN sp.close_value ELSE 0 end) AS won_revenue,
    SUM(CASE WHEN sp.deal_stage = 'Lost' THEN p.sales_price ELSE 0 END) AS lost_revenue_potential,
    SUM(CASE WHEN sp.deal_stage = 'Engaging' THEN p.sales_price ELSE 0 END) AS open_pipeline_potential,
    ROUND(100.0 * SUM(case WHEN sp.deal_stage = 'Won' then sp.close_value else 0 end)/ 
        NULLIF(SUM(case WHEN sp.deal_stage = 'Won' THEN sp.close_value ELSE 0 end) + SUM(case WHEN sp.deal_stage = 'Lost' THEN p.sales_price ELSE 0 end) , 0), 2) as win_rate
FROM sales_pipeline sp
JOIN products p
    ON sp.product = p.product
join accounts a
	on sp.account = a.account
GROUP BY a.sector
ORDER by
	win_rate,
	open_pipeline_potential DESC;


'06_ACCOUNT ANALYSIS'

'10) Which accounts represent the greatest commercial opportunity?'

'Query 1 - Win rate conversion for each account (customer)'

SELECT
    sp.account, a.sector , a.office_location,
    COUNT(*) AS opportunities,
    ROUND(100.0 *SUM(CASE WHEN sp.deal_stage = 'Won' THEN 1 ELSE 0 END)/
        NULLIF(SUM(CASE WHEN sp.deal_stage IN ('Won', 'Lost') THEN 1 ELSE 0 END),0),2) AS win_rate,
    SUM(case WHEN sp.deal_stage = 'Won' THEN sp.close_value ELSE 0 END) AS won_revenue,
    SUM(CASE WHEN sp.deal_stage = 'Lost' THEN p.sales_price ELSE 0 end) AS lost_revenue_potential,
    SUM(case WHEN sp.deal_stage = 'Engaging' THEN p.sales_price ELSE 0 end) AS open_pipeline_potential
FROM sales_pipeline sp
JOIN products p
    ON sp.product = p.product
join accounts a
	on sp.account = a.account
GROUP BY sp.account, a.office_location, a.sector
ORDER BY open_pipeline_potential desc;

'Query 2 - 10 top customers which % of open pipeline'

SELECT
    sp.account,
    SUM(p.sales_price) AS open_pipeline_value
FROM sales_pipeline sp
JOIN products p
    ON sp.product = p.product
WHERE sp.deal_stage = 'Engaging'
and trim(sp.account) <> ''
GROUP BY sp.account
ORDER BY open_pipeline_value DESC;

SELECT
    SUM(open_pipeline_value) AS top_20_pipeline,
    (SELECT SUM(p.sales_price)
        FROM sales_pipeline sp
        JOIN products p
            ON sp.product = p.product
        WHERE sp.deal_stage = 'Engaging'
          AND sp.account IS NOT NULL
          AND TRIM(sp.account) <> '') AS total_account_pipeline,
    ROUND(100.0 * SUM(open_pipeline_value)/
        (SELECT SUM(p.sales_price)
            FROM sales_pipeline sp
            JOIN products p
                ON sp.product = p.product
            WHERE sp.deal_stage = 'Engaging'
              AND sp.account IS NOT NULL
              AND TRIM(sp.account) <> ''),2) AS top_20_percentage
FROM (SELECT
        sp.account,
        SUM(p.sales_price) AS open_pipeline_value
    FROM sales_pipeline sp
    JOIN products p
        ON sp.product = p.product
    WHERE sp.deal_stage = 'Engaging'
      AND sp.account IS NOT NULL
      AND TRIM(sp.account) <> ''
    GROUP BY sp.account
    ORDER BY open_pipeline_value DESC
    LIMIT 20) AS top_accounts;
   
'Query 3 - Win rate of each account x type of product'

SELECT
    sp.account,
    sp.product,
    COUNT(*) AS total_opportunities,
    SUM(CASE WHEN sp.deal_stage = 'Won' THEN 1 ELSE 0 END) AS won_opportunities,
    SUM(CASE WHEN sp.deal_stage = 'Lost' THEN 1 ELSE 0 END) AS lost_opportunities,
    SUM(CASE WHEN sp.deal_stage = 'Lost' THEN p.sales_price ELSE 0 END) AS lost_potencial_revenue,
    ROUND(100.0 *SUM(CASE WHEN sp.deal_stage = 'Won' THEN 1 ELSE 0 END)/
        NULLIF(SUM(CASE WHEN sp.deal_stage IN ('Won', 'Lost') THEN 1 ELSE 0 END),0),2) AS win_rate,
    ROUND(100.0 *SUM(CASE WHEN sp.deal_stage = 'Lost' THEN 1 ELSE 0 END)/
        NULLIF(SUM(CASE WHEN sp.deal_stage IN ('Won', 'Lost') THEN 1 ELSE 0 END),0),2) AS lost_rate
FROM sales_pipeline sp
join products p
	on p.product = sp.product
WHERE sp.account IS NOT NULL
  AND TRIM(sp.account) <> ''
GROUP BY
    sp.account,
    sp.product
having COUNT(*) > 20
ORDER BY
    sp.account,
    lost_rate DESC;


'07_CYCLE LENGTH ANALYSIS'

'11) Does sales cycle length affect conversion?'

SELECT
    deal_stage, 
    COUNT(*) AS opportunities,
    ROUND(AVG(NULLIF(close_date, '')::DATE - NULLIF(engage_date, '')::DATE), 2) AS average_sales_cycle_days
FROM sales_pipeline
WHERE NULLIF(close_date, '') IS NOT NULL
  AND NULLIF(engage_date, '') IS NOT NULL
GROUP BY deal_stage
order by average_sales_cycle_days desc;

SELECT
    CASE
        WHEN NULLIF(close_date, '')::DATE - NULLIF(engage_date, '')::DATE <= 30 THEN '0-30 days'
        WHEN NULLIF(close_date, '')::DATE - NULLIF(engage_date, '')::DATE <= 60 THEN '31-60 days'
        WHEN NULLIF(close_date, '')::DATE - NULLIF(engage_date, '')::DATE <= 80 THEN '61-80 days'
        ELSE '80+ days'
    END AS sales_cycle_bucket,
    COUNT(*) AS closed_opportunities,
    SUM(CASE WHEN deal_stage = 'Won' THEN 1 ELSE 0 END) AS won_opportunities,
     SUM(CASE WHEN deal_stage = 'Lost' THEN 1 ELSE 0 END) AS lost_opportunities,
    ROUND(100.0 * SUM(CASE WHEN deal_stage = 'Won' THEN 1 ELSE 0 END)/COUNT(*),2) AS win_rate
FROM sales_pipeline
WHERE deal_stage IN ('Won', 'Lost')
  AND NULLIF(close_date, '') IS NOT NULL
  AND NULLIF(engage_date, '') IS NOT NULL
GROUP BY sales_cycle_bucket
ORDER BY
    MIN(NULLIF(close_date, '')::DATE - NULLIF(engage_date, '')::DATE);

'07_PRIORITY SCORE ANALYSIS'

WITH sector_product AS (SELECT
        a.sector,
        sp.product,
        COUNT(*) AS total_opportunities,
        SUM(CASE WHEN sp.deal_stage = 'Won' THEN 1 ELSE 0 end) AS won_opportunities,
        SUM(CASE WHEN sp.deal_stage = 'Lost' THEN 1 ELSE 0 END) AS lost_opportunities,
        SUM(CASE
                WHEN sp.deal_stage = 'Lost'
                THEN p.sales_price
                ELSE 0 END) AS lost_revenue_potential,
        ROUND(100.0 *SUM(case WHEN sp.deal_stage = 'Lost' THEN 1 ELSE 0 END)/
            NULLIF(SUM(CASE WHEN sp.deal_stage IN ('Won','Lost') THEN 1 ELSE 0 end),0), 2) AS loss_rate
    FROM sales_pipeline sp
    JOIN products p
        ON sp.product = p.product
    JOIN accounts a
        ON sp.account = a.account
    GROUP BY
        a.sector,
        sp.product
    HAVING COUNT(*) >= 30), scored AS (SELECT *,
        100.0 * lost_revenue_potential/MAX(lost_revenue_potential) OVER () AS revenue_score,
        100.0 *loss_rate / MAX(loss_rate) OVER ()
        AS loss_score,
        100.0 * total_opportunities/MAX(total_opportunities) OVER () AS volume_score
    FROM sector_product),
prioritized AS (SELECT*, ROUND(revenue_score * 0.50 + loss_score * 0.30  + volume_score * 0.20, 2) AS priority_score
    FROM scored)
SELECT
    sector,
    product,
    total_opportunities,
    won_opportunities,
    lost_opportunities,
    loss_rate,
    lost_revenue_potential,
    ROUND(revenue_score, 2) AS revenue_score,
    ROUND(loss_score, 2) AS loss_score,
    ROUND(volume_score, 2) AS volume_score,
    priority_score,
    CASE
        WHEN priority_score >= 70
            THEN 'HIGH PRIORITY'
        WHEN priority_score >= 40
            THEN 'MEDIUM PRIORITY'
        ELSE 'LOW PRIORITY'
    END AS priority_category
FROM prioritized
ORDER BY priority_score DESC;