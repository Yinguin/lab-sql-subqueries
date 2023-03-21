USE sakila;

# 1. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT COUNT(inventory_id) 
FROM inventory
WHERE film_id = (SELECT film_id 
				 FROM film 
                 WHERE title = 'Hunchback Impossible');

SELECT COUNT(i.inventory_id)
FROM inventory i
JOIN film f ON i.film_id = f.film_id
WHERE f.title = 'Hunchback Impossible';

# 2. List all films whose length is longer than the average of all the films.
SELECT film_id, title, length
FROM film
WHERE length > (SELECT AVG(length) FROM film);

SELECT f.film_id, f.title, f.length
FROM film f
JOIN ( SELECT AVG(length) AS avg_length FROM film) avg_film_length 
ON f.length > avg_film_length.avg_length;

# 3. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT first_name, last_name
FROM actor
WHERE actor_id IN (SELECT actor_id 
				   FROM film_actor 
                   WHERE film_id = (SELECT film_id 
									FROM film
                                    WHERE title = 'Alone Trip'));

SELECT a.first_name, a.last_name
FROM actor a
JOIN film_actor fa USING (actor_id)
JOIN film f USING (film_id)
WHERE f.title = 'Alone Trip';


# 4. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
SELECT title
FROM film
WHERE film_id IN (SELECT film_id 
				  FROM film_category 
                  WHERE category_id = (SELECT category_id 
									   FROM category
                                       WHERE name = 'Family'));
                                       
SELECT title
FROM film
JOIN film_category USING (film_id)
JOIN category USING (category_id)
WHERE name = 'Family';

# 5. Get name and email from customers from Canada using subqueries. 
SELECT first_name, last_name
FROM customer
WHERE address_id IN (SELECT address_id 
					 FROM address
                     WHERE city_id IN (SELECT city_id 
									   FROM city
                                       WHERE country_id = (SELECT country_id 
														   FROM country 
                                                           WHERE country='Canada')));

# Do the same with joins.
SELECT first_name, last_name
FROM customer
JOIN address USING (address_id)
JOIN city USING (city_id)
JOIN country USING (country_id)
WHERE country = 'Canada';

# 6. Which are films starred by the most prolific actor? Most prolific actor is defined as the actor that has acted in the most number of films. First you will have to find the most prolific actor and then use that actor_id to find the different films that he/she starred.
SELECT title 
FROM film
WHERE film_id IN (SELECT film_id 
				 FROM film_actor
                 WHERE actor_id = (SELECT actor_id 
								   FROM film_actor
                                   GROUP BY actor_id
                                   ORDER BY COUNT(actor_id) DESC
                                   LIMIT 1));

SELECT f.title
FROM film f
JOIN film_actor fa USING (film_id)
JOIN (
SELECT actor_id
FROM film_actor
GROUP BY actor_id
ORDER BY COUNT(*) DESC
LIMIT 1
) most_prolific_actor USING (actor_id);

# 7. Films rented by most profitable customer. You can use the customer table and payment table to find the most profitable customer ie the customer that has made the largest sum of payments.
SELECT title 
FROM film 
JOIN inventory USING(film_id)
JOIN rental USING (inventory_id)
JOIN (
SELECT customer_id
FROM payment 
GROUP BY customer_id 
ORDER BY SUM(amount) DESC 
LIMIT 1) most_profitable_customer USING(customer_id);

# 8. Get the client_id and the total_amount_spent of those clients who spent more than the average of the total_amount spent by each client.
SELECT customer_id, SUM(amount) AS total_amount_spent
FROM payment
GROUP BY customer_id
HAVING SUM(amount) > (SELECT AVG(total_amount_spent) 
					  FROM (SELECT SUM(amount) AS total_amount_spent 
							FROM payment 
							GROUP BY customer_id) AS customer_payments);
