-- 1. Who is the senior most employee based on job title?
--  Larger the levels of employee seniority be also larger
select * from employee;

select * 
from employee 
order by levels desc 
limit 1;

-- 2. Which countries have the most Invoices?
select * from invoice;

select billing_country,count(*) as c
from invoice 
group by billing_country 
order by c desc; 

-- 3. What are top 3 values of total invoice?
select total
from invoice  
order by total desc
limit 3; 

-- 4. Which city has the best customers? We would like to throw a promotional Music 
-- Festival in the city we made the most money. Write a query that returns one city that 
-- has the highest sum of invoice totals. Return both the city name & sum of all invoice 
-- totals
select billing_city ,sum(total) as tot
from invoice 
group  by billing_city
order by tot desc; 

-- 5. Who is the best customer? The customer who has spent the most money will be 
-- declared the best customer. Write a query that returns the person who has spent the 
-- most money
select c.customer_id as id,c.first_name,c.last_name,c.city,c.country,sum(i.total) as tot
from invoice as i
inner join customer c
on i.customer_id = c.customer_id
group by id
order by tot desc
limit 1;

-- 6.Write query to return the email, first name, last name, & Genre of all Rock Music 
-- listeners. Return your list ordered alphabetically by email starting with A
select * from genre;

SELECT DISTINCT email,first_name, last_name
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
WHERE track_id IN(
	SELECT track_id FROM track
	JOIN genre ON track.genre_id = genre.genre_id
	WHERE genre.name LIKE 'Rock'
)
ORDER BY email;

-- 7. Let's invite the artists who have written the most rock music in our dataset. Write a 
-- query that returns the Artist name and total track count of the top 10 rock bands
select * from artist;

select artist.name, count (track.track_id) as Songs
from artist
join album on artist.artist_id = album.artist_id
join track on album.album_id = track.album_id
where track.genre_id like '1'
group by artist.name
order by Songs desc
limit 10;

-- 8. Return all the track names that have a song length longer than the average song length. 
-- Return the Name and Milliseconds for each track. Order by the song length with the 
-- longest songs listed first
select * from track;

select name,milliseconds as length from track
where milliseconds > (
select avg(milliseconds) from track
)
order by length desc;

-- 9. Find how much amount spent by each customer on artists? Write a query to return
-- customer name, artist name and total spent
with cte as(
    select a.artist_id,a.name,sum(i.unit_price * i.quantity) as sales
	from artist a join album on a.artist_id = album.artist_id
	join track on album.album_id = track.album_id
	join invoice_line i on track.track_id = i.track_id
	group by 1
	order by 3 desc
	limit 1
)
select c.customer_id,c.first_name,c.last_name,cte.name,
sum(il.unit_price * il.quantity) as total_spent
from customer c
join invoice on c.customer_id = invoice.customer_id
join invoice_line il on invoice.invoice_id = il.invoice_id
join track on il.track_id = track.track_id
join album on track.album_id = album.album_id
join cte on album.artist_id = cte.artist_id
group by 1,4
order by 5 desc;


-- 10. We want to find out the most popular music Genre for each country. We determine the 
-- most popular genre as the genre with the highest amount of purchases. Write a query 
-- that returns each country along with the top Genre. For countries where the maximum 
-- number of purchases is shared return all Genres
with cte as(
	select count(il.quantity) as purchases, i.billing_country as country, g.name as genre,
	g.genre_id as genre_id,
	ROW_NUMBER() over (partition by i.billing_country order by count(il.quantity) desc) as rows
	from invoice_line il 
	join invoice i on il.invoice_id = i.invoice_id
	join track on il.track_id = track.track_id
	join genre g on track.genre_id = g.genre_id
	group by 2,3,4
	order by 2,1 desc
)
select purchases,country,genre,genre_id 
from cte
where rows <= 1;


-- 11. Write a query that determines the customer that has spent the most on music for each 
-- country. Write a query that returns the country along with the top customer and how
-- much they spent. For countries where the top amount spent is shared, provide all 
-- customers who spent this amount
select * from invoice_line;

with cte as(
	select i.billing_country as country,c.customer_id as id,c.first_name as fname,
	c.last_name as lname,sum(i.total) as spending,
	row_number() over (partition by i.billing_country order by sum(i.total)) as rank
	from invoice i
	join customer c on c.customer_id = i.customer_id
	group by 2,1
	order by 1,5 desc
)
select country,id,fname,lname,spending from cte where rank <=1













