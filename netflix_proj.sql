SELECT *
FROM netflix


--15 Business Problems

--1.Count the number of Movies vs TV Shows.
SELECT type,COUNT(*) AS num_of_content
FROM netflix 
GROUP BY type; 

--2.Find the most common rating for movies and TV Shows.
SELECT type,rating
FROM
(SELECT type,rating,COUNT(*),RANK() OVER (PARTITION BY type ORDER BY COUNT(*) DESC) AS ranking
FROM netflix
GROUP BY 1,2) AS A
WHERE ranking=1;

--3.List all movies released in a specific year(e.g. 2020)
SELECT *
FROM netflix 
WHERE type='Movie' AND release_year='2020';

--4.Find the top 5 countries with the most content on Netflix 
SELECT
DISTINCT TRIM((UNNEST(STRING_TO_ARRAY(country, ',')))) as new_country,
COUNT(show_id) as Num_of_content
FROM netflix
GROUP BY new_country
ORDER BY Num_of_content DESC
LIMIT 5;


--5.Find the longest movie on Netflix
SELECT title,SUBSTRING(duration,1,position('m' in duration)-1)::INT duration
FROM netflix
WHERE type='Movie' AND duration IS NOT NULL
ORDER BY 2 DESC;

--6.Find content added in the last 5 years
SELECT *
FROM(
SELECT *,
 CASE 
        WHEN date_added ~ '^[A-Za-z]+ [0-9]{1,2}, [0-9]{4}$' 
        THEN TO_DATE(date_added, 'Mon DD, YYYY') 
        WHEN date_added ~ '^[0-9]{1,2}-[A-Za-z]{3}-[0-9]{2}$' 
        THEN TO_DATE(date_added, 'DD-Mon-YY') 
        ELSE NULL
		END AS date_content_was_added
FROM netflix) AS A
WHERE EXTRACT(YEAR FROM date_content_was_added)>=EXTRACT(YEAR FROM CURRENT_DATE)- 5;

--7.Find all the Movies/TV Shows by director 'Rajiv Chilaka'
SELECT *
FROM netflix
WHERE director ILIKE'%Rajiv Chilaka%';

--8.List all TV Shows with more than 5 seasons

SELECT * 
FROM netflix 
WHERE type='TV Show' AND SPLIT_PART(TRIM(duration),' ',1)::INT>5;

--9.Count the number of content in each genre
SELECT
DISTINCT TRIM(UNNEST(STRING_TO_ARRAY(listed_in,','))) AS genre,
COUNT(show_id) AS num_of_content
FROM netflix
GROUP BY genre;

--10 Find the number of content released in India each year.Find the percentage of all content released in India per year.
SELECT DISTINCT CASE 
        WHEN date_added ~ '^[A-Za-z]+ [0-9]{1,2}, [0-9]{4}$' 
        THEN EXTRACT(YEAR FROM TO_DATE(date_added, 'Mon DD, YYYY')) 
        WHEN date_added ~ '^[0-9]{1,2}-[A-Za-z]{3}-[0-9]{2}$' 
        THEN EXTRACT(YEAR FROM TO_DATE(date_added, 'DD-Mon-YY'))
        ELSE NULL
		END AS year,
COUNT(*) AS total_content,
ROUND((COUNT(*)::numeric/(SELECT COUNT(*) FROM netflix WHERE country ILIKE '%india%')::numeric)*100,2) AS percentage
FROM netflix
WHERE country ILIKE '%india%'
GROUP BY year;

--11.List all movies that are documentaries
SELECT *
FROM netflix
WHERE type='Movie' AND listed_in ILIKE '%Documentaries%';

--12. Find all content without a director
SELECT *
FROM netflix
WHERE director IS NULL;

--13.Find how many movies actor 'Salman Khan' appeared in the last 10 years
SELECT *
FROM netflix 
WHERE casts ILIKE '%Salman Khan%'
AND EXTRACT(YEAR FROM CURRENT_DATE)-release_year<=10;

--14.Find the top 10 actors who have appeared in the most movies that were produced in India.
SELECT 
TRIM(UNNEST(STRING_TO_ARRAY(casts,','))) AS actors,
COUNT(*) AS num_of_movies
FROM netflix
WHERE country ILIKE '%India%' AND type='Movie'
GROUP BY actors
ORDER BY 2 DESC
LIMIT 10;

--15.Categorize the content based on the presence of the keywords 'kill' and 'violence' in the description field.
--   Label the content containing these keywords as 'Violent' and all other content as 'Non-Violent'.
--   Count how many items fall in each category.
WITH new_table AS(
SELECT *,CASE 
WHEN description ILIKE'kill%'
OR description ILIKE'.kill%'
OR description ILIKE',kill%'
OR description ILIKE'%violence%'
OR description ILIKE'%violent%' THEN 'Violent'
ELSE 'Non-Violent' END AS category
FROM netflix )

SELECT category,COUNT(*) total_content
FROM new_table
GROUP BY category;

SELECT category,COUNT(*) total_content
FROM(SELECT *,CASE 
WHEN description ILIKE'kill%'
OR description ILIKE'.kill%'
OR description ILIKE',kill%'
OR description ILIKE'%violence%'
OR description ILIKE'%violent%' THEN 'Violent'
ELSE 'Non-Violent' END AS category
FROM netflix)
GROUP BY category;