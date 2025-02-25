# Netflix Movies and TV Shows Data Analysis using SQL
This is my first guided project in Data Analytics using SQL to apply my knowledge solving real-world problems.

<img src='https://github.com/LukeTritsis13/NETFLIX_Project_SQL/blob/main/Netflix_Logo.jpg' width='1000' height='300'>

## Overview
This project involves a comprehensive analysis of Netflix's movies and TV shows data using SQL. The goal is to extract valuable insights and answer various business questions based on the dataset. The following README provides a detailed account of the project's objectives, business problems, solutions, findings, and conclusions.

## Objectives

- Analyze the distribution of content types (movies vs TV shows).
- Identify the most common ratings for movies and TV shows.
- List and analyze content based on release years, countries, and durations.
- Explore and categorize content based on specific criteria and keywords.

## Dataset
The data for this project is sourced from the Kaggle dataset:

- **Dataset Link:** [Movies Dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download)

## Schema

```sql
DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
    show_id      VARCHAR(5),
    type         VARCHAR(10),
    title        VARCHAR(250),
    director     VARCHAR(550),
    casts        VARCHAR(1050),
    country      VARCHAR(550),
    date_added   VARCHAR(55),
    release_year INT,
    rating       VARCHAR(15),
    duration     VARCHAR(15),
    listed_in    VARCHAR(250),
    description  VARCHAR(550)
);
```
## Business Problems & Solutions

### 1.Count the number of Movies vs TV Shows.

```sql
SELECT type,COUNT(*) AS num_of_content
FROM netflix 
GROUP BY type;
```
**Objective:** Determine the distribution of content types on Netflix.

### 2.Find the most common rating for movies and TV Shows.
```sql
SELECT type,rating
FROM
(SELECT type,rating,COUNT(*),RANK() OVER (PARTITION BY type ORDER BY COUNT(*) DESC) AS ranking
FROM netflix
GROUP BY 1,2) AS A
WHERE ranking=1;
```
**Objective:** Identify the most frequently occurring rating for each type of content.

### 3.List all movies released in a specific year(e.g. 2020)
```sql
SELECT *
FROM netflix 
WHERE type='Movie' AND release_year='2020';
```
**Objective:** Retrieve all movies released in a specific year.

### 4.Find the top 5 countries with the most content on Netflix 
```sql
SELECT
DISTINCT TRIM((UNNEST(STRING_TO_ARRAY(country, ',')))) as new_country,
COUNT(show_id) as Num_of_content
FROM netflix
GROUP BY new_country
ORDER BY Num_of_content DESC
LIMIT 5;
```
**Objective:** Identify the top 5 countries with the highest number of content items.


### 5.Find the longest movie on Netflix
```sql
SELECT title,SUBSTRING(duration,1,position('m' in duration)-1)::INT duration
FROM netflix
WHERE type='Movie' AND duration IS NOT NULL
ORDER BY 2 DESC;
```
**Objective:** Find the movie with the longest duration.

### 6.Find content added in the last 5 years
```sql
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
```
**Objective:** Retrieve content added to Netflix in the last 5 years.

### 7.Find all the Movies/TV Shows by director 'Rajiv Chilaka'
```sql
SELECT *
FROM netflix
WHERE director ILIKE'%Rajiv Chilaka%';
```
**Objective:** List all content directed by 'Rajiv Chilaka'.

### 8.List all TV Shows with more than 5 seasons
```sql
SELECT * 
FROM netflix 
WHERE type='TV Show' AND SPLIT_PART(TRIM(duration),' ',1)::INT>5;
```
**Objective:** Identify TV shows with more than 5 seasons.

### 9.Count the number of content in each genre
```sql
SELECT
DISTINCT TRIM(UNNEST(STRING_TO_ARRAY(listed_in,','))) AS genre,
COUNT(show_id) AS num_of_content
FROM netflix
GROUP BY genre;
```
**Objective:** Count the number of content items in each genre.

### 10.Find the number of content released in India each year.Find the percentage of all content released in India per year.
```sql
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
```
**Objective:** Calculate and rank years by the average number of content releases produced in India.

### 11.List all movies that are documentaries
```sql
SELECT *
FROM netflix
WHERE type='Movie' AND listed_in ILIKE '%Documentaries%';
```

**Objective:** Retrieve all movies classified as documentaries.

### 12.Find all content without a director
```sql
SELECT *
FROM netflix
WHERE director IS NULL;
```
**Objective:** List content that does not have a director.

### 13.Find how many movies actor 'Salman Khan' appeared in the last 10 years
```sql
SELECT *
FROM netflix 
WHERE casts ILIKE '%Salman Khan%'
AND EXTRACT(YEAR FROM CURRENT_DATE)-release_year<=10;
```
**Objective:** Count the number of movies featuring 'Salman Khan' in the last 10 years.

### 14.Find the top 10 actors who have appeared in the most movies that were produced in India.
```sql
SELECT 
TRIM(UNNEST(STRING_TO_ARRAY(casts,','))) AS actors,
COUNT(*) AS num_of_movies
FROM netflix
WHERE country ILIKE '%India%' AND type='Movie'
GROUP BY actors
ORDER BY 2 DESC
LIMIT 10;
```
**Objective:** Identify the top 10 actors with the most appearances in Indian-produced movies.

### 15.Categorize the content based on the presence of the keywords 'kill' and 'violence' in the description field.
```sql
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
```
**Objective:** To categorize content as 'Violent' or 'Non-violent' according to their description.Find the amount of each category.


## Findings and Conclusion

- **Content Distribution:** The dataset contains a diverse range of movies and TV shows with varying ratings and genres.
- **Common Ratings:** Insights into the most common ratings provide an understanding of the content's target audience.
- **Content Categorization:** Categorizing content based on specific keywords helps in understanding the nature of content available on Netflix.

This analysis provides a comprehensive view of Netflix's content and can help inform content strategy and decision-making.
