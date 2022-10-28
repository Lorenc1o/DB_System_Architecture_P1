--Initial query №3

WITH cte as (
Select customer.customer_id, customer.last_name, date(rental.return_date) as date
from public.customer
inner join public.rental on rental.customer_id = customer.customer_id
inner join public.inventory ON inventory.inventory_id = rental.inventory_id
inner join public.film on inventory.film_id = film.film_id
group by customer.customer_id, date
having count(rental.rental_id) >= 4) 
select cte.customer_id, cte.last_name
from cte
group by cte.customer_id, cte.last_name
having count(cte.date) > 1

-- ----------------------------------------------------------------------------------------
-- OPTIMIZATION (Mariana) with hash index in customer.customer_id

-- Changes: Eliminated joins, filter rental before joining with customer (starting by the filtered rental)

--Q3 versions Compared:
-- > Using with vs subqueries
-- > Merging with joins vs = in where clause
-- > Adding an extra subquery vs grouping by 3 parameters


--Festest query:


Select customer.customer_id, customer.last_name
from 
	(select rent.customer_id
	from (
		select rental.customer_id, date(rental.return_date) as date
		from public.rental
		group by rental.customer_id,  date
         having count(rental.rental_id) >= 4 
		) as rent
	group by rent.customer_id
	having count(rent.date) > 1  
	) as rent2
inner join public.customer on customer.customer_id = rent2.customer_id



-- Second fastest: Using Subquery, and merging in where clause (implication> group by rent.customer_id, customer.customer_id, customer.last_name)


Select customer.customer_id, customer.last_name
	from public.customer, (
		select rental.customer_id, date(rental.return_date) as date
		from public.rental
		group by rental.customer_id, date
         having count(rental.rental_id) >= 4 
		) as rent
	group by rent.customer_id, customer.customer_id, customer.last_name
	having count(rent.date) > 1 and rent.customer_id = customer.customer_id 



		
