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


-- Remove Film and Inventory table from Joins
WITH cte as (
Select customer.customer_id, customer.last_name, date(rental.return_date) as date
from public.customer
inner join public.rental on rental.customer_id = customer.customer_id
group by customer.customer_id, date
having count(rental.rental_id) >= 4) 
select cte.customer_id, cte.last_name
from cte
group by cte.customer_id, cte.last_name
having count(cte.date) > 1

-- Remove Film and Inventory table from Joins, exchange join for =
WITH cte as (
	Select customer.customer_id, customer.last_name, date(rental.return_date) as date
	from public.customer, public.rental 
	group by customer.customer_id, rental.customer_id, date
	having  count(rental.rental_id)>= 4 and rental.customer_id = customer.customer_id
)

select cte.customer_id, cte.last_name
from cte
group by cte.customer_id, cte.last_name
having count(cte.date) > 1

-- Remove Film and Inventory table from Joins, exchange join for =
select cte.customer_id, cte.last_name
from (
	Select customer.customer_id, customer.last_name, date(rental.return_date) as date
	from public.customer inner join public.rental on rental.customer_id = customer.customer_id
	group by  customer.customer_id,date, rental.customer_id
	having  count(rental.rental_id)>= 4 
	) as cte
group by cte.customer_id, cte.last_name
having count(cte.date) > 1


-- Remove Film and Inventory table from Joins, exchange join for =
With alfa as(
	select cte.customer_id, cte.last_name
		from (
			Select customer.customer_id, customer.last_name , date(rental.return_date) as date
			from public.customer inner join public.rental on rental.customer_id = customer.customer_id
			group by date, customer.customer_id 
			having count(rental.rental_id)>= 4 
			) as cte
		group by cte.customer_id, cte.last_name
		having count(cte.date) > 1
	)
	beta as(
		Select customer.customer_id, customer.last_name , date(rental.return_date) as date
		from public.customer inner join public.rental on rental.customer_id = customer.customer_id
		group by date, customer.customer_id 
		having count(rental.rental_id)>= 4 
	)
	
select * 
from 
	(   Select customer.customer_id, customer.last_name , date(rental.return_date) as date
		from public.customer inner join public.rental on rental.customer_id = customer.customer_id
		group by date, customer.customer_id 
		having count(rental.rental_id)>= 4 
	) as cf
	except
	(
		Select customer.customer_id, customer.last_name , date(rental.return_date) as date
		from public.customer inner join public.rental on rental.customer_id = customer.customer_id
		group by date, customer.customer_id 
		having count(rental.rental_id)>= 4 
	) 
	


--
(
	Select al.customer_id from
	(
		Select rental.customer_id, date(rental.return_date) as date
		from public.rental
		group by rental.customer_id, date
		having count(rental.rental_id)>= 4 --and count(rental.return_date) > 1
	) as al
	group by al.customer_id
	having count(al.return_date) > 1
	
-- with,  + = order by
explain analyze
WITH rent AS (
	select rental.customer_id, date(rental.return_date) as date
		from public.rental
		group by rental.customer_id, date
         having count(rental.rental_id) >= 4
)
Select customer.customer_id, customer.last_name
	from public.customer, rent
	group by rent.customer_id, customer.customer_id, customer.last_name
	having count(rent.date) > 1 and rent.customer_id = customer.customer_id 
	
-- 2 Subquery + = order by
	explain analyze
Select customer.customer_id, customer.last_name
	from public.customer, (
		select rental.customer_id, date(rental.return_date) as date
		from public.rental
		group by rental.customer_id, date
         having count(rental.rental_id) >= 4 
		) as rent
	group by rent.customer_id, customer.customer_id, customer.last_name
	having count(rent.date) > 1 and rent.customer_id = customer.customer_id 
	
	-- 2 Subquery + Join order by
	explain analyze
Select customer.customer_id, customer.last_name
	from (
		select rental.customer_id, date(rental.return_date) as date
		from public.rental
		group by rental.customer_id, date
         having count(rental.rental_id) >= 4 
		) as rent inner join public.customer on rent.customer_id = customer.customer_id 
	group by rent.customer_id, customer.customer_id, customer.last_name
	having count(rent.date) > 1  
	
-- 3 Subquery =
	explain analyze
Select customer.customer_id, customer.last_name
from public.customer,
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
where rent2.customer_id = customer.customer_id 
	
	
-- 3 Subquery join
	explain analyze
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

