USE sakila;
/*1.*/
SELECT DISTINCT title
FROM film;
/*2.*/
SELECT title,rating
FROM film
WHERE rating= "PG-13";
/*3*/
SELECT title, description
FROM film
WHERE description LIKE '%amazing%';
/*4*/
SELECT title
FROM film
WHERE length > '120';
/*5*/
SELECT first_name,last_name 
FROM actor;
/*6*/
SELECT first_name,last_name
FROM actor
WHERE last_name LIKE "Gibson";

/*7*/

SELECT first_name,last_name
FROM actor
WHERE actor_id BETWEEN 10 AND 20;

/*8*/

SELECT title, rating
FROM film
WHERE rating NOT IN ('R', 'PG-13');

/*9*/

SELECT rating, COUNT(*) as total_movies
FROM film
GROUP BY rating;

/*10*/
/* podría haber añadido alias en el from para hacer más corto la llamada a cada columna d ela tabla correspondiente,*/
/*pero al ser solo un join no he creído que duera necesario y así se ve más claro de donde saco cada columna*/

SELECT customer.customer_id,customer.first_name,customer.last_name, COUNT(rental.rental_id) AS Total_Alquiladas
FROM customer
INNER JOIN rental
ON customer.customer_id=rental.rental_id
GROUP BY rental.rental_id;
/*11*/
/* al existir varios joins, he añadido alias en los FROM de cada tabla para llamar a las columnas*/

SELECT c.name AS Genero_pelicula, COUNT(r.rental_id) AS Total_alquiladas
FROM category c
JOIN film_category AS fc 
ON c.category_id = fc.category_id
JOIN film AS f 
ON fc.film_id = f.film_id
JOIN inventory AS i 
ON f.film_id = i.film_id
JOIN rental AS r 
ON i.inventory_id = r.inventory_id
GROUP BY c.name;

/*12*/

SELECT rating AS Clasificiacion, AVG(length) as Promedio_duracion
FROM film
GROUP BY rating;

/*13*/
SELECT a.first_name, a.last_name,f.title
FROM actor AS a
JOIN film_actor AS fa
ON a.actor_id=fa.actor_id
JOIN film AS f
ON fa.film_id=f.film_id
WHERE title = "Indian Love";

/* otra forma de presentar la query sería usando el GROUP_CONCAT*/
/*para que aparecieran todos los actores que participan en una sola celda y tener una tabla de resultados más corta.*/
/*Si añadimos el GROUP_CONCAT debemos añadir un GROUP BY */

SELECT f.title, GROUP_CONCAT(a.first_name, ' ', a.last_name) AS actor_names
FROM film AS f
JOIN film_actor AS fa ON f.film_id = fa.film_id
JOIN actor AS a ON fa.actor_id = a.actor_id
WHERE f.title = "Indian Love"
GROUP BY f.title;

/*14.*/
/* en SELECT he añadido la columna description para tener una verificación del resultado*/
SELECT title, description
FROM film
WHERE description LIKE '%dog%'
OR description LIKE '%cat%';

/* 15.*/
/* el resultado de la query, muestra que no hay ningún actor que no haya participado en ninguna película.*/
/* Todos han aparecido en alguna. De ahí que el métodos left join sea el método correcto "TODOS*/

SELECT actor.actor_id, actor.first_name, actor.last_name
FROM actor
LEFT JOIN film_actor ON actor.actor_id = film_actor.actor_id
WHERE film_actor.actor_id IS NULL;

/*16*/
/* devuelve 1000 filas, que corresponden a la info que nos da la tabla film. Todas las películas han sido released en 2006.*/
SELECT title, release_year
FROM film
WHERE release_year BETWEEN 2005 AND 2010;

/*17.*/

SELECT f.title
FROM film f
JOIN film_category fc 
ON f.film_id = fc.film_id
JOIN category c 
ON fc.category_id = c.category_id
WHERE c.name = 'Family';

/*18*/
/*agrupo por actor_id para que no me salgan múltiples filas repetidas*/

SELECT actor.first_name, actor.last_name
FROM actor 
JOIN film_actor 
ON actor.actor_id = film_actor.actor_id
GROUP BY actor.actor_id
HAVING COUNT(film_actor.film_id) > 10;

/*19.*/

SELECT title
FROM film
WHERE rating = 'R' AND length > 120;

/*20.*/

SELECT category.name AS nombre_categoria, ROUND(AVG(film.length),2) AS promedio_duracion
FROM category
JOIN film_category ON category.category_id = film_category.category_id
JOIN film ON film_category.film_id = film.film_id
GROUP BY category.name
HAVING AVG(film.length) > 120;

/*21*/

SELECT actor.first_name, actor.last_name,COUNT(film_actor.film_id) AS cantidad_peliculas
FROM actor
JOIN film_actor 
ON actor.actor_id = film_actor.actor_id
GROUP BY actor.actor_id
HAVING COUNT(film_actor.film_id) >= 5;

/*22*/
/*Primero he encapsulado "rental_ids con una duración superior a 5 días " como subquery principal*/
/*a la tabla de inventory para llegar hasta la de film. Era necesario para que saliera el título de la película.*/
/*Se hubiero podido resolver con joins (segunda query del ejercicio)*/

SELECT film.title
FROM film
WHERE film.film_id IN (
SELECT i.film_id
FROM inventory i
WHERE i.inventory_id IN (
	SELECT r.inventory_id
	FROM rental r
	WHERE DATEDIFF(r.return_date, r.rental_date) > 5));
    
/* con joins*/

SELECT DISTINCT film.title
FROM film
JOIN inventory ON film.film_id = inventory.film_id
JOIN rental ON inventory.inventory_id = rental.inventory_id
WHERE DATEDIFF(rental.return_date, rental.rental_date) > 5;

/*23*/
SELECT first_name,last_name
FROM actor
WHERE actor_id NOT IN
(SELECT actor_id 
FROM film_actor
WHERE film_id IN
(SELECT film_id 
FROM film_category
WHERE category_id IN
(SELECT category_id
FROM category
WHERE name = "horror")));

/* Solución con join y con concat del nombre*/
SELECT DISTINCT CONCAT(actor.first_name,'  ',actor.last_name) AS Nombre_actor
FROM actor
LEFT JOIN film_actor ON actor.actor_id = film_actor.actor_id
LEFT JOIN film_category ON film_actor.film_id = film_category.film_id
LEFT JOIN category ON film_category.category_id = category.category_id
WHERE category.name IS NULL OR category.name != 'Horror';

/*24*/
/* La misma casuística de la anterior query pero en este caso se añade otra característica.*/
/* la length está enmarcada en la query principal pq la columna lenght está dentro d ela tabla film */

SELECT title
FROM film
WHERE film_id IN (
SELECT film_id
FROM film_category
WHERE category_id IN (
SELECT category_id
FROM category
WHERE name = 'Comedy')
)AND length > 180;

/* la misma búsqueda con joins*/

SELECT DISTINCT film.title
FROM film
JOIN film_category ON film.film_id = film_category.film_id
JOIN category ON film_category.category_id = category.category_id
WHERE category.name = 'Comedy' AND film.length > 180;
 
/*25*/
/*self join?*/
SELECT CONCAT(a1.first_name, ' ', a1.last_name) AS actor1,CONCAT(a2.first_name, ' ', a2.last_name) AS actor2,
COUNT(DISTINCT t1.film_id) AS peliculas_en_comun
FROM film_actor AS t1
JOIN film_actor AS t2 ON t1.film_id = t2.film_id AND t1.actor_id < t2.actor_id
JOIN actor a1 ON t1.actor_id = a1.actor_id
JOIN actor a2 ON t2.actor_id = a2.actor_id
GROUP BY actor1, actor2
HAVING peliculas_en_comun > 0;











    
    
    
    
    
    
    
    
    









