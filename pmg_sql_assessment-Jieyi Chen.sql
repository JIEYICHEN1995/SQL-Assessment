/*
Name: Jieyi Chen 
Date: Dec 13, 2022


*****Please note that all the SQL statements below are based on postgresql*****
 */


--Question #1 Generate a query to get the sum of the clicks of the marketing data​	   
select sum(clicks) as sum_clicks
from marketing_data;

--Question #2 Generate a query to gather the sum of revenue by store_location from the store_revenue table​
select store_location, sum(revenue) as total_revenue
from store_revenue
group by store_location;


--Question #3 Merge these two datasets so we can see impressions, clicks, and revenue together by date and geo
--Assuming we want the total revenue (regardless of brand_id) by date and geo
select distinct case 
		     when sr.date is null then md.date
		     when md.date is null then sr.date 
		     else sr.date
	             end as new_date 
	        ,case 
	   	      when md.geo is null then right(upper(sr.store_location),2)
	   	      else md.geo
	              end as new_geo
	        ,md.impressions
	        ,md.clicks
	        ,sum(sr.revenue) over (partition by sr.date, sr.store_location) as revenue  
from  store_revenue sr
full outer join marketing_data md 
on sr.date = md.date 
and right(upper(sr.store_location),2) = upper(md.geo)
order by new_date;



--Question #4 In your opinion, what is the most efficient store and why?​
/*
Assumption: 1) the number of impressions and clicks in each geo have a direct impact on the store revenue in each corresponding location
			2) the marketing expense for each location is the same

For some reason, there is no store revenue recorded for the MN location. So based on the information we had, the store located at CA is the most effeicent store.
On average, the store located in CA generates $10.42 of revenue per impression or $758.82 of revenue per click. Compared to the store in NY ($2.59 of revenue per impression or $214.80 of revenue per click) and the store
in TX ($0.57 of revenue per impression or $40.97 of revenue per click), CA has the highest return on revenue. 

 */ 
with cte as (
select distinct case 
		     when sr.date is null then md.date
		     when md.date is null then sr.date 
		     else sr.date
	             end as new_date 
	        ,case 
	             when md.geo is null then right(upper(sr.store_location),2)
	   	     else md.geo
	             end as new_geo
	         ,md.impressions
	         ,md.clicks
	         ,sum(sr.revenue) over (partition by sr.date, sr.store_location) as revenue  
from  store_revenue sr
full outer join marketing_data md 
on sr.date = md.date 
and right(upper(sr.store_location),2) = upper(md.geo)
order by new_date)

select new_geo
       ,sum(revenue) / sum(impressions) as revenue_per_impression
       ,sum(revenue) / sum(clicks) as revenue_per_click
from cte
group by new_geo
order by revenue_per_impression desc, revenue_per_click desc;


--Question #5 (Challenge) Generate a query to rank in order the top 10 revenue producing states​
select states, rank () over (order by revenue desc) as rank
from 
    (select right(store_location, 2) as states, sum(revenue) as revenue
     from store_revenue
     group by states) sr
order by rank
limit 10;
