/*
start w/filmCt, no cte, = cust, index in customer id			
Planning time	1.031	51.054	49.5152
Execution time	50.023		
Planning time	1.123	38.17	
Execution time	37.047		
Planning time	1.239	45.426	
Execution time	44.187		
Planning time	1.194	74.104	
Execution time	72.91		
Planning time	1.133	39.103	
Execution time	37.97		
Planning time	1.072	57.205	
Execution time	56.133		
Planning time	1.121	49.44	
Execution time	48.319		
Planning time	1.088	52.285	
Execution time	51.197		
Planning time	1.022	52.297	
Execution time	51.275		
Planning time	1.172	36.068	
Execution time	34.896		

*/
explain analyze 
select customer.customer_id, customer.last_name
from public.customer,
public.film_category
inner join public.inventory ON inventory.film_id = film_category.film_id
inner join public.rental ON rental.inventory_id = inventory.inventory_id
group by customer.customer_id, rental.customer_id
having count(distinct film_category.category_id) = (select count(category_id) from public.category)  and rental.customer_id = customer.customer_id
