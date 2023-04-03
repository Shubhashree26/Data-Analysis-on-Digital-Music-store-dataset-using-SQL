-- Project on Music store Dataset 
-- Let's find out some important and useful insights from the music store dataset


/*
Q1. Which city has the best customers? We would like to throw a promotional Music 
Festival in the city we made the most money. Write a query that returns one city that 
has the highest sum of invoice totals. Return both the city name & sum of all invoice 
totals
*/

select billing_city, (sum(total)::int) as total_sale 
from invoice 
group by billing_city
order by total_sale desc
limit 1;

/*
Q2. Who is the best customer? The customer who has spent the most money will be 
declared the best customer. Write a query that returns the person who has spent the 
most money
*/

select c.customer_id, c.first_name, c.last_name, sum(total)::int as total_purchase
from invoice i 
	join customer c on i.customer_id = c.customer_id
group by c.customer_id
order by total_purchase desc
limit 1;


/*
Q3. Write query to return the email, first name, last name, & Genre of all Rock Music 
listeners. Return your list ordered alphabetically by email starting with A
*/
select distinct c.email, c.first_name, c.last_name, g.name as genre
from invoice i 
	join customer c on i.customer_id = c.customer_id
	join invoice_line il on il.invoice_id = i.invoice_id
	join track t on t.track_id = il.track_id
	join genre g on g.genre_id = t.genre_id
where g.name LIKE 'Rock'
order by email;


/*
Q4. Let's invite the artists who have written the most rock music in our dataset. Write a 
query that returns the Artist name and total track count of the top 10 rock bands
*/
select a.name, count(*) as total_tracks 
from artist a 
	join album al on a.artist_id = al.artist_id
	join track t on t.album_id = al.album_id
	join genre g on g.genre_id = t.genre_id
where g.name like 'Rock'
group by a.artist_id
order by total_tracks desc
limit 10;


/*
Q5. Return all the track names that have a song length longer than the average song length. Return 
the Name and Milliseconds for each track. Order by the song length with the longest songs listed first
*/

with avg_time(avg_track_length) as
	(select avg(milliseconds) as avg_track_length from track)
select name, milliseconds from track, avg_time where milliseconds > avg_time.avg_track_length
order by milliseconds desc;

-- optinal query
select name, milliseconds 
from track 
where milliseconds > 
	(select avg(milliseconds) as avg_track_length from track)
order by milliseconds desc;



/*
Q6. Find how much amount spent by each customer on artists? Write a query to return
customer name, artist name and total spent
*/
select  concat(trim(c.first_name), ' ',trim(c.last_name)) as customer_name, a.name as artist,
		sum(il.unit_price * il.quantity)::int as amount_spent
from customer c 
	join invoice i on c.customer_id = i.customer_id
	join invoice_line il on il.invoice_id = i.invoice_id
	join track t on t.track_id = il.track_id
	join album al on al.album_id = t.album_id
	join artist a on a.artist_id = al.artist_id
group by c.first_name , c.last_name, a.name
order by amount_spent desc;


-- Lets find amount spent by customers on best selling artist

with customer_artist_spend AS 
		(select  concat(trim(c.first_name), ' ',trim(c.last_name)) as customer_name,
				a.name as artist,
				sum(il.unit_price * il.quantity) as amount_spent
		from customer c join invoice i 
				on c.customer_id = i.customer_id
			join invoice_line il 
				on il.invoice_id = i.invoice_id
			join track t 
				on t.track_id = il.track_id
			join album al 
				on al.album_id = t.album_id
			join artist a 
				on a.artist_id = al.artist_id
		group by c.first_name , c.last_name, a.name
		order by amount_spent desc),
	best_selling_artist(artist) AS
		(select artist 
			from customer_artist_spend 
			group by artist
			order by sum(amount_spent) desc
			limit 1)
select cas.customer_name, cas.artist,cas.amount_spent
from customer_artist_spend cas ,best_selling_artist bsa 
	where cas.artist = bsa.artist;
	
	
	
/*
Q7. We want to find out the most popular music Genre for each country.
We determine the  most popular genre as the genre with the highest amount of purchases.
Write a query that returns each country along with the top Genre. 
For countries where the maximum number of purchases is shared return all Genres
*/

with country_genre_table as 
	(select i.billing_country as country,
			sum(il.unit_price * il.quantity) as total_purchase,
			g.name as genre
	from invoice i join invoice_line il 
		on i.invoice_id = il.invoice_id
	join track t 
		on t.track_id = il.track_id
	join genre g 
		on g.genre_id = t.genre_id
	group by i.billing_country, g.name
	order by country, total_purchase desc),
	rank_table as
	(select * ,
	rank() over(partition by country order by total_purchase desc) as rank_of_genre
	from country_genre_table)
select country, total_purchase, genre as top_genre
from rank_table
where rank_of_genre = 1;



/*
Q8. Write a query that determines the customer that has spent the most on music for each 
country. Write a query that returns the country along with the top customer and how
much they spent. For countries where the top amount spent is shared, provide all 
customers who spent this amount
*/
with customer_purchase as
	(select concat(trim(c.first_name),' ', trim(c.last_name))as customer_name, 
			i.billing_country as country, 
			sum(i.total) as total_purchase
	from customer c join invoice i on c.customer_id = i.customer_id
	group by c.first_name, c.last_name, i.billing_country
	order by billing_country),
	rank_table as 
	(select * ,
	rank() over(partition by country order by total_purchase desc) as purchase_rank
	from customer_purchase)
select country, customer_name as top_customer, total_purchase
from rank_table 
where purchase_rank = 1


/*
Q9. Who is the senior most employee based on job title?
*/

select * from employee
order by levels desc
limit 1;



/*
Q10. Which countries have the most Invoices?
*/

select billing_country, COUNT(*) as total_invoices 
from invoice 
group by billing_country
order by total_invoices desc;
	
	
/*
Q11. What are top 3 values of total invoice?
*/

select total from invoice 
order by total desc 
limit 3;


	


