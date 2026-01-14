USE zomato_db;
SELECT * FROM zomato;

-- 1) Help Zomato in identifying the cities with poor Restaurant ratings

WITH cte AS(
SELECT City, round(avg(Rating)) AS avg_rating
FROM zomato
GROUP BY City)
SELECT city, avg_rating
FROM cte
WHERE avg_rating < (SELECT round(avg(Rating)) AS avg_rating from zomato);

/* 2) Mr.roy is looking for a restaurant in kolkata which provides online delivery. Help him choose the best restaurant */

WITH cte AS(
SELECT RestaurantID, City, Rating, Votes, Average_Cost_for_two,
rank() over(Order by Rating desc, Votes desc) AS rnk
FROM zomato
WHERE City = "Kolkata" AND Has_Online_delivery = "Yes")
SELECT *
FROM cte
WHERE rnk = 1;


-- 3) Help Peter in finding the best rated Restraunt for Pizza in New Delhi.

WITH c AS
(SELECT RestaurantID, City, Cuisines, Rating, votes, Average_Cost_for_two,
rank() over(partition by City order by rating desc, votes desc) AS Rnk
FROM zomato
WHERE City = "New Delhi" AND Cuisines LIKE "%Pizza%")
select * from c
where Rnk = 1;

-- 4)Enlist most affordable and highly rated restaurants city wise.

WITH cte AS(
SELECT City, RestaurantID, Rating, votes, Average_Cost_for_two,
		rank() over (partition by City order by Rating desc, votes desc, Average_Cost_for_two asc) AS rnk
FROM zomato
WHERE Average_Cost_for_two > 0)
SELECT *
FROM cte
WHERE rnk = 1;

-- 5)Help Zomato in identifying the restaurants with poor offline services

SET @avg_rating:=(select round(avg(rating)) FROM zomato WHERE Has_Online_delivery = "no"AND Has_Table_booking = "yes");
SELECT @avg_rating;

SELECT RestaurantID, Res_identify, Has_Online_delivery, Has_Table_booking, rating
FROM zomato
WHERE Has_Online_delivery = "no" AND Has_Table_booking = "yes"
AND rating < @avg_rating
Order by rating desc;

/*6)Help zomato in identifying those cities which have atleast 3 restaurants with ratings >= 4.9
  In case there are two cities with the same result, sort them in alphabetical order.*/
  
WITH c AS (select city, count(RestaurantID) as total_restro
FROM zomato 
WHERE rating >= 4.9 
group by city)
SELECT *
FROM c
WHERE total_restro >= 3
order by city asc;

/*7) What are the top 5 countries with most restaurants linked with Zomato?*/

WITH cte1 AS(
WITH cte AS(
SELECT count(RestaurantID) AS Restaurant_count, c.country
FROM zomato AS z inner join countrytable AS c ON z.countrycode = c.countrycode
group by c.Country)
SELECT * , rank() over (order by Restaurant_count desc) AS rnk
FROM cte)
SELECT * FROM cte1 WHERE rnk<=5;
  
/*8) What is the average cost for two across all Zomato listed restaurants? */

SELECT RestaurantID, Average_Cost_for_two
FROM zomato;

/*9) Group the restaurants basis the average cost for two into: 
Luxurious Expensive, Very Expensive, Expensive, High, Medium High, Average. 
Then, find the number of restaurants in each category. */

WITH cte1 AS(
	WITH cte AS 
			(SELECT RestaurantID, Average_Cost_for_two, 
			rank() over (order by Average_Cost_for_two desc) AS cost_wise_rnk
			FROM zomato)
	SELECT *, 
		CASE
			WHEN cost_wise_rnk BETWEEN 1 AND 5 THEN "luxurious expensive"
			WHEN cost_wise_rnk BETWEEN 6 AND 10 THEN "very expensive" 
			WHEN cost_wise_rnk BETWEEN 11 AND 15 THEN "expensive" 
			WHEN cost_wise_rnk BETWEEN 16 AND 20 THEN "high" 
			WHEN cost_wise_rnk BETWEEN 21 AND 25 THEN "medium high" 
			ELSE "average"
		END AS `status`
	FROM cte
	order by Average_Cost_for_two desc)
SELECT `status`, count(*) as cnt
FROM cte1
group by `status`;

SELECT RestaurantID, Average_Cost_for_two, rank() over (order by Average_Cost_for_two desc) as cost_wise_rnk
FROM zomato;

/*10) List the two top 5 restaurants with highest rating with maximum votes. */

WITH cte AS(
SELECT RestaurantID, Rating, Votes, rank() over(Order by Rating desc, Votes desc) AS rnk
FROM zomato)
SELECT *
FROM cte
WHERE rnk<=5;

