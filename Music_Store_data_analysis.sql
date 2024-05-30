-- Select senior employee based on job title
Select * from music_db.employee order by levels desc limit 1;

-- Which country have the most invoices

Select billing_country, count(*) as c from music_db.invoice group by billing_country order by c desc;

-- who is the  best customer

Select cus.customer_id, cus.first_name,  SUM(inv.total) as spending from music_db.customer cus
join music_db.invoice inv
on cus.customer_id = inv.customer_id
group by cus.customer_id, cus.first_name
order by spending desc;

-- Write query to return firstname of all rock music listeners

Select cus.email, cus.first_name, cus.last_name, gn.name from music_db.customer cus
JOIN music_db.invoice inv 
ON cus.customer_id = inv.customer_id
JOIN music_db.invoice_line line
ON inv.invoice_id = line.invoice_id
JOIN music_db.track tk
ON line.track_id = tk.track_id
JOIN music_db.genre gn
ON tk.genre_id = gn.genre_id
where gn.name LIKE 'Rock'
order by cus.email ;

-- let's invite the 	artists who have written the most rock music in dataset. Write
-- query that returns the artist name and total track count of the top 10 rock bands




Select art.name, COUNT(art.artist_id) as total from music_db.artist art
JOIN music_db.album alb
ON art.artist_id = alb.artist_id
JOIN music_db.track tr
ON alb.album_id = tr.album_id
JOIN music_db.genre gen
ON tr.genre_id = gen.genre_id
where gen.name LIKE 'Rock'
group by art.name
order by total desc limit 10;


-- Return all the track names that have a good song length longer than the average song length. return the name and milliseconds
-- for each track. order by the song length with the longest songs listed first.


-- with CTE

with tracking as (
			Select * from music_db.track),
     track_avg as (
			Select AVG(milliseconds)  as avg_length from tracking)
Select tk.name, tk.milliseconds from tracking tk, track_avg tk_av
where tk.milliseconds >   tk_av.avg_length
order by tk.milliseconds desc;       

-- OR with subqueries

Select name, milliseconds from music_db.track where milliseconds > 
	(Select avg(milliseconds) as avg_length from music_db.track) 
    order by milliseconds desc;

-- Find how much money spent by each customer on artists? Write a query to return customer name , artist name and total spent.



with tab1 as (
Select art.name, trk.track_id from music_db.artist art
JOIN music_db.album alb
ON art.artist_id = alb.artist_id
JOIN music_db.track trk
ON trk.album_id = alb.album_id
group by art.name, trk.track_id
),
  tab2 as (
 Select cus.first_name, inl.track_id ,SUM(inl.quantity * trk.unit_price) as total from music_db.customer cus
JOIN music_db.invoice inv
ON cus.customer_id = inv.customer_id
JOIN music_db.invoice_line inl
ON inv.invoice_id = inl.invoice_id
JOIN music_db.track trk
ON inl.track_id = trk.track_id
group by cus.first_name, inl.track_id
 )
 
 Select t2.first_name, t1.name, SUM(t2.total) as amount from tab1 t1
 JOIN tab2 t2
 ON t1.track_id = t2.track_id
 group by t2.first_name, t1.name
 order by amount desc;
 
 
 Select * from music_db.invoice;
 
 -- Most popular music genre for each country (genre with the highest amount of purchases)
 
 Select * from (Select count(inl.quantity) as purchases, inv.billing_country, gn.name,
 rank() over(partition by inv.billing_country order by count(inl.quantity) desc) as rk from music_db.invoice inv
 JOIN music_db.invoice_line inl
 ON inl.invoice_id = inv.invoice_id
 JOIN music_db.track trk
 on trk.track_id = inl.track_id
 JOIN music_db.genre gn
 ON gn.genre_id = trk.genre_id
 group by inv.billing_country, gn.name
 ) x where x.rk<=1;


-- write query for customer that has spent the most on music for each country. Write query that returns the country along with top customer
-- and how much they spent.

Select * from (Select cs.first_name, cs.country, SUM(inl.unit_price * inl.quantity) as purchases,
rank() over(partition by cs.country order by SUM(inl.unit_price * inl.quantity) desc ) as rk from music_db.customer cs
JOIN music_db.invoice inv
ON cs.customer_id = inv.customer_id
JOIN music_db.invoice_line inl
ON inv.invoice_id = inl.invoice_id
group by cs.first_name, cs.country) x
where x.rk<=1;
 