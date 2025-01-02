-- Apple Sales Data - 1M rows Sales Datset -- 

select * from category;
select * from products;
select * from stores;
select * from sales;
select * from warranty;

-- EDA 

select DISTINCT repair_status from warranty;
select COUNT(*) from sales;

-- Improving Query Performance 

-- et - 103.ms
-- pt - 0.095ms

EXPLAIN ANALYZE
select * from sales
where product_id= 'P-44';

CREATE INDEX sales_product_id ON sales(product_id);
CREATE INDEX sales_store_id ON sales(store_id);
CREATE INDEX sales_sale_date ON sales(sale_date);

-- et -0.1ms
-- pt - 69.8ms
EXPLAIN ANALYZE 
select * from sales
where store_id = 'ST-31'
-----------------------------------------------------------------------------------------
-- Bussiness problems
-- Medium Problems
-----------------------------------------------------------------------------------------
-- 1.Find the number of stores in each country.

select 
       country,
	   COUNT(store_id) as total_stores
from stores
group by 1
order by 2 desc;

-- 2.Calculate the total number of units sold by each store.

select 
    s.store_id,
	st.store_name,
     SUM(s.quantity) as total_unit_sold
from sales as s
join stores as st
on st.store_id = s.store_id 
group by 1, 2
order by 3 desc;

-- 3.Identify how many sales occurred in December 2023.

select 
  Count(sale_id) as total_sale
from sales
where TO_CHAR(sale_date, 'MM-YYYY') = '12-2023'

-- 4. Determine how many stores have never had a warranty claim filed.

select COUNT(*)from stores
where store_id NOT IN( 
						select 
						    DISTINCT store_id
						from sales as s
						RIGHT JOIN warranty as w 
						on s.sale_id = w.sale_id
						);


-- 5.Calculate the percentage of warranty claims marked as "Warranty Void".
-- no claim that as wv/ total claim * 100

select 
      ROUND
	  (COUNT(claim_id) / 
	               (select count(*) from warranty) ::numeric
	 * 100 ,2) as warranty_void_per
from warranty
where repair_status = 'Warranty Void';

-- 6. Identify which store had the highest total units sold in the last year.

select 
      store_id,
	  sum(quantity)
from sales 
where sale_date >= (CURRENT_DATE - INTERVAL '1 year')
group by 1
order by 2 desc
limit 1;

-- select current_date - interval '1 year'
-- --------- OR   -----------------

select 
      s.store_id,
	  st.store_name,
	  sum(s.quantity)
from sales as s
join stores as st
on s.store_id = st.store_id
where sale_date >= (CURRENT_DATE - INTERVAL '1 year')
group by 1,2
order by 3 desc
limit 1;

-- 7.Count the number of unique products sold in the last year.

select 
    COUNT(DISTINCT product_id) 
from sales
where sale_date >= (CURRENT_DATE - INTERVAL '1 year')

-- Find the average price of products in each category

select
     p.category_id,
	 c.category_name,
	 AVG(p.price) as avg_price
from products as p 
join category as c
on p.category_id = c.category_id
group by 1,2
order by 3 desc;

-- 9.How many warranty claims were filed in 2020?

select 
     count(*) as warranty_claim
from warranty 
where extract (year from claim_date)= 2020

-- 10.For each store, identify the best-selling day based on highest quantity sold

--- store_id, day_name , sum(qty)

select *
from
(
select
     store_id,
     TO_CHAR(sale_date, 'Day') as day_name,
	 sum(quantity) as total_unit_sold,
	 RANK() OVER (PARTITION BY store_id ORDER BY sum(quantity) desc) as rank
from sales
group by 1,2) as x1
where rank = 1; 
--------------------------------------------------------------------------------------------
-- Medium to Hard Question 
--------------------------------------------------------------------------------------------
-- 11. Identify the least selling product in each country for each year based on total units sold.

WITH product_rank
AS
(
select 
       st.country,
	   p.product_name,
	   sum(s.quantity) as total_unit_sold,
	   RANK() OVER(partition by st.country ORDER BY sum(s.quantity)) as rank
from sales as s
join stores as st
on s.store_id = st.store_id
join products as p 
on s.product_id = p.product_id
group by 1, 2
)
select * from product_rank
where rank = 1;

-- 12.Calculate how many warranty claims were filed within 180 days of a product sale.

select 
       COUNT(*)
from warranty as w 
left join sales as s 
on s.sale_id = w.sale_id 
where  
   w.claim_date - sale_date <= 180
   
-- 13.Determine how many warranty claims were filed for products launched in the last two years.

-- each prob
-- no claim 
-- no sale
-- each must be launched in last 2 year

select 
       p.product_name,
	   COUNT(w.claim_id) as no_claim,
	   Count(s.sale_id) as no_sale
from warranty as w
right join sales as s
on s.sale_id = w.sale_id
 join products as p
on p.product_id = s.product_id
where p.launch_date >= current_Date - interval'2 years'
group by 1
HAVING COUNT(w.claim_id) >0 

-- 14.List the months in the last three years where sales exceeded 5,000 units in the USA.


 select 
     TO_CHAR(sale_date, 'MM-YYYY') as month,
	 SUM(quantity) as total_unit_sold
from sales as s 
join stores as st
on s.store_id = st.store_id
where st.country = 'USA' 
         AND 
		 s.sale_date >= CURRENT_DATE - INTERVAL '3 year'
group by 1
Having SUM(s.quantity) >5000;

-- 15.Identify the product category with the most warranty claims filed in the last two years

 select 
      c.category_name,
	  COUNT(w.claim_id) as total_claim
from warranty as w
left join 
sales as s
on w.sale_id = s.sale_id
join products as p
on p.product_id = s.product_id
join category as c
on c.category_id = p.category_id
where w.claim_date >= CURRENT_DATE - INTERVAL '2 year'
group by 1;



-----------------------  END  ------------------------









































































