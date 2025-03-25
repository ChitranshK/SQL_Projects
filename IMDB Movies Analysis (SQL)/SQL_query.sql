CREATE DATABASE IMDB;

CREATE TABLE movie_details(
	Poster_Link	varchar(200),
	Series_Title varchar(200),
	Released_Year int,
	Certificate varchar(15),
	Runtime varchar(10),
	Genre varchar(50),
	IMDB_Rating	double precision,
	Overview varchar(100),
	Meta_score int,
	Director varchar(80),
	Star1 varchar(80),
	Star2 varchar(80),
	Star3 varchar(80),
	Star4 varchar(80),
	No_of_Votes int,
	Gross int
);

-- Loading the data
COPY movie_details FROM 'D:\DataScience\DataSets\IMBD\imdb_top_1000.csv'
DELIMITER ',' 
CSV HEADER;


-- Dropping unnecessary columns from the table
ALTER TABLE movie_details
DROP COLUMN poster_link,
DROP COLUMN overview,
DROP COLUMN star3,
DROP COLUMN star4;

-- Genre should have name of only top genre
UPDATE movie_details
SET genre = SPLIT_PART(genre,',',1);

-- Changing format of data in gross column
ALTER TABLE movie_details
ALTER COLUMN gross TYPE int
USING REPLACE(gross, ',', '')::int;

-- Changing format of data in runtime column
ALTER TABLE movie_details
ALTER COLUMN runtime TYPE INT
USING LEFT(runtime, POSITION(' ' IN runtime) - 1)::INT;

-- Null values in series_title column
SELECT COUNT(*) AS null_count
FROM movie_details
WHERE series_title IS NULL;
-- 0

-- Null values in released_year column
SELECT COUNT(*) AS null_count
FROM movie_details
WHERE released_year IS NULL;
-- 1

-- Dropping the data row
DELETE FROM movie_details
WHERE released_year IS NULL;

-- Null values in certificate column
SELECT COUNT(*) AS null_count
FROM movie_details
WHERE certificate IS NULL;
-- 101

-- Updating null values to 'Unknown'
UPDATE movie_details
SET certificate='Unknown'
WHERE certificate IS NULL;

-- Null values in runtime column
SELECT COUNT(*) AS null_count
FROM movie_details
WHERE runtime IS NULL;
-- 0

-- Null values in genre column
SELECT COUNT(*) AS null_count
FROM movie_details
WHERE genre IS NULL;
-- 0

-- Null values in IMDB_Rating column
SELECT COUNT(*) AS null_count
FROM movie_details
WHERE IMDB_Rating IS NULL;
-- 0

-- Null values in Meta_score column
SELECT COUNT(*) AS null_count
FROM movie_details
WHERE Meta_score IS NULL;
-- 157

-- Finding no. of rows where meta_score is greater than average value
SELECT COUNT(*)
FROM movie_details 
WHERE meta_score > (
	SELECT ROUND(AVG(meta_score),1) FROM movie_details
);
-- 432

-- Finding no. of rows where meta_score is lower than average value
SELECT COUNT(*)
FROM movie_details 
WHERE meta_score < (
	SELECT ROUND(AVG(meta_score),1) FROM movie_details
);
-- 386

-- Finding no. of rows where meta_score is equal to average value
SELECT COUNT(*)
FROM movie_details 
WHERE meta_score = (
	SELECT ROUND(AVG(meta_score),1) FROM movie_details
);
-- 24

-- Updating null values to average value of meta_score
UPDATE movie_details
SET meta_score= (
SELECT ROUND(AVG(meta_score),1) FROM movie_details
)
WHERE meta_score IS NULL;

-- Null values in director column
SELECT COUNT(*) AS null_count
FROM movie_details
WHERE director IS NULL;
-- 0

-- Null values in Star1 column
SELECT COUNT(*) AS null_count
FROM movie_details
WHERE Star1 IS NULL;
-- 0

-- Null values in Star2 column
SELECT COUNT(*) AS null_count
FROM movie_details
WHERE Star2 IS NULL;
-- 0

-- Null values in No_of_votes column
SELECT COUNT(*) AS null_count
FROM movie_details
WHERE No_of_votes IS NULL;
-- 0

-- Null values in gross column
SELECT COUNT(*) AS null_count
FROM movie_details
WHERE gross IS NULL;
-- 169

-- Replacing null values by average gross value in each genre.
UPDATE movie_details AS m
SET gross = (
    SELECT AVG(Gross) FROM movie_details 
    WHERE genre = m.genre AND gross IS NOT NULL
)
WHERE gross IS NULL;

-- Since there are some rows left where gross is still null, replace it by 
-- average value of gross
UPDATE movie_details
SET gross= (
	SELECT ROUND(AVG(gross)) 
	FROM movie_details
) 
WHERE gross IS NULL;

-- Adding new column:
ALTER TABLE movie_details
ADD COLUMN decade TEXT;

UPDATE movie_details
SET decade=
	CASE 
		WHEN released_year BETWEEN 1920 AND 1929 THEN '1920s'
        WHEN released_year BETWEEN 1930 AND 1939 THEN '1930s'
        WHEN released_year BETWEEN 1940 AND 1949 THEN '1940s'
        WHEN released_year BETWEEN 1950 AND 1959 THEN '1950s'
        WHEN released_year BETWEEN 1960 AND 1969 THEN '1960s'
        WHEN released_year BETWEEN 1970 AND 1979 THEN '1970s'
        WHEN released_year BETWEEN 1980 AND 1989 THEN '1980s'
        WHEN released_year BETWEEN 1990 AND 1999 THEN '1990s'
        WHEN released_year BETWEEN 2000 AND 2009 THEN '2000s'
        WHEN released_year BETWEEN 2010 AND 2019 THEN '2010s'
        WHEN released_year BETWEEN 2020 AND 2029 THEN '2020s'
        ELSE 'Unknown'
    END;

-- 1. Find the director with most number of movies in top 1000.
SELECT COUNT(*) AS no_of_movies,director 
FROM movie_details 
GROUP BY director
ORDER BY no_of_movies DESC LIMIT 5;

-- 2. Find the actors with most number of movies in top 1000.
SELECT COUNT(*) AS no_of_movies,star1
FROM movie_details
GROUP BY star1
ORDER BY no_of_movies DESC LIMIT 5;

-- 3. Find the average gross by genre having atleast 15 movies.
SELECT genre, ROUND(AVG(gross)::NUMERIC,2) AS avg_gross,COUNT(*) AS num_movies
FROM movie_details
GROUP BY genre
HAVING COUNT(*)>15
ORDER BY avg_gross DESC;

-- 4. Compare avg rating before and after 2000
SELECT 
    CASE WHEN  released_year< 2000 THEN 'Before 2000' 
		ELSE 'After 2000' END AS era,  
    ROUND(AVG(imdb_rating)::NUMERIC,3) AS avg_rating  
FROM movie_details 
GROUP BY era;

-- 5. Find no. of movies with many votes but low ratings.
SELECT COUNT(*) AS num_movies 
FROM movie_details m1 
WHERE no_of_votes>(
	SELECT ROUND(AVG(no_of_votes)::NUMERIC) FROM movie_details m2
	WHERE m1.genre=m2.genre
) AND imdb_rating< (
	SELECT ROUND(AVG(imdb_rating)::NUMERIC) FROM movie_details m2
	WHERE m1.genre=m2.genre
);

-- 6. Find top 3 genre having the highest average IMDB rating.
SELECT ROUND(AVG(imdb_rating)::NUMERIC,2) AS avg_imdb_rating,genre 
FROM movie_details
GROUP BY genre
ORDER BY avg_imdb_rating DESC LIMIT 3;

-- 7. Find movies with low IMDB ratings but high gross income.
SELECT COUNT(*) AS num_movies 
FROM movie_details m1 
WHERE imdb_rating <(
	SELECT ROUND(AVG(imdb_rating)::NUMERIC,2) 
	FROM movie_details m2 WHERE m1.genre=m2.genre
) AND gross > (
	SELECT ROUND(AVG(gross)::NUMERIC) 
	FROM movie_details m2 WHERE m1.genre=m2.genre
);

-- 8. Find the top 3 actor-director combo which has the highest IMDB rating.
SELECT MAX(imdb_rating) AS max_rating ,star1,director 
FROM movie_details
GROUP BY star1,director
ORDER BY max_rating DESC LIMIT 3;

-- 9. Find all the common genres in each decade.
WITH common_genre AS (
    SELECT COUNT(genre) AS num_genre, decade, genre
    FROM movie_details
    GROUP BY genre, decade
)
SELECT cg.decade, cg.genre, cg.num_genre
FROM common_genre cg
WHERE cg.num_genre = (
    SELECT MAX(sub.num_genre)
    FROM common_genre sub
    WHERE sub.decade = cg.decade
) ORDER BY decade DESC;

-- 10. Find top 3 frequent actor pairings in top rated movies.
SELECT MAX(imdb_rating) AS max_rating,star1,star2,COUNT(*) AS num_movies
FROM movie_details
GROUP BY star1,star2
ORDER BY num_movies DESC LIMIT 3;

-- 11. Find top 3 directors whose movies have earned the highest total 
-- gross income.
SELECT SUM(gross) AS total_income,director
FROM movie_details
GROUP BY director
ORDER BY total_income DESC LIMIT 3;

-- 12. Find the highest rated movie in each decade.
SELECT decade,series_title FROM movie_details 
WHERE (imdb_rating,decade) IN (
	SELECT MAX(imdb_rating) AS max_rating,decade 
	FROM movie_details
	GROUP BY decade 
	)ORDER BY decade DESC;

-- 13. Find top 3 most popular genre based on no. of movies.
SELECT COUNT(*) AS num_movies, genre
FROM movie_details
GROUP BY genre
ORDER BY num_movies DESC LIMIT 3;

-- 14. Find which genre is most common in different certificate ratings
-- having at least 10 movies.
WITH GenreRanking AS (
    SELECT 
        certificate,genre,
        COUNT(*) AS num_movies,
        RANK() OVER (PARTITION BY certificate ORDER BY COUNT(*) DESC) AS rank_num
    FROM movie_details
    GROUP BY certificate, genre
	HAVING COUNT(*)>10
)
SELECT certificate, genre, num_movies
FROM GenreRanking
WHERE rank_num =1
ORDER BY certificate ASC, num_movies DESC;

-- 15. Find no. of movies with high IMDB score but low meta score.
SELECT COUNT(*) FROM movie_details m1 WHERE meta_score<(
	SELECT ROUND(AVG(meta_score)::NUMERIC) FROM movie_details m2
	WHERE m1.genre=m2.genre
) AND imdb_rating> (
	SELECT ROUND(AVG(imdb_rating)::NUMERIC) FROM movie_details m2
	WHERE m1.genre=m2.genre
);

-- 16. Find top 3 actors with highest gross income.
SELECT star1,SUM(gross) AS total_income
FROM movie_details
GROUP BY star1
ORDER BY total_income DESC LIMIT 3;

-- 17. Find if longer duration movies tend to be higher rated or not.
SELECT COUNT(*) AS num_movies 
FROM movie_details m1 
WHERE runtime>(
	SELECT ROUND(AVG(runtime)::NUMERIC) FROM movie_details m2
	WHERE m1.genre=m2.genre
) AND imdb_rating> (
	SELECT ROUND(AVG(imdb_rating)::NUMERIC) FROM movie_details m2
	WHERE m1.genre=m2.genre
);

-- 18. Find the top 10 most profitable movies.
SELECT series_title, gross, runtime,  
       ROUND(gross / runtime, 2) AS revenue_per_minute  
FROM movie_details    
ORDER BY revenue_per_minute DESC  
LIMIT 10;

-- 19. Find if higher rated movies have higher gross income.
SELECT COUNT(*) AS num_movies 
FROM movie_details m1 
WHERE gross>(
	SELECT ROUND(AVG(gross)::NUMERIC) FROM movie_details m2
	WHERE m1.genre=m2.genre
) AND imdb_rating> (
	SELECT ROUND(AVG(imdb_rating)::NUMERIC) FROM movie_details m2
	WHERE m1.genre=m2.genre
);

-- 20.	Find the most active directors having at least 7 movies.
SELECT COUNT(*) AS num_movies,director
FROM movie_details
GROUP BY director
HAVING COUNT(*)>7
ORDER BY num_movies DESC;