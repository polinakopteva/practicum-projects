-- Find the number of questions that have scored more than 300 points or have been added to Bookmarks at least 100 times.
SELECT 
	COUNT(title)
FROM stackoverflow.posts
WHERE score > 300 
	OR favorites_count >= 100

/*More than 300 points earned 1355 questions*/

-- How many questions were asked on average per day from November 1 to November 18, 2008 inclusive? Round the result to an integer.
SELECT 
	ROUND(AVG(count))
FROM (SELECT COUNT(title)
	FROM stackoverflow.posts
	WHERE creation_date::date >= '2008-11-01'
		AND creation_date::date <= '2008-11-18'
	GROUP BY creation_date::date) t1

 /*On average, 383 questions were asked in November 2008*/

-- How many users received badges immediately on the day of registration? Output the number of unique users.
SELECT 
	COUNT(DISTINCT u.id)
FROM stackoverflow.users u
	JOIN stackoverflow.badges b 
		ON b.user_id=u.id
WHERE b.creation_date::date = u.creation_date::date

/*7047 unique users received badges immediately on the day of registration*/

-- How many unique posts of a user named Joel Coehoorn received at least one vote?
SELECT 
	COUNT(DISTINCT p.id)
FROM stackoverflow.users u
	JOIN stackoverflow.posts p 
		ON p.user_id=u.id
	JOIN stackoverflow.votes v 
		ON v.post_id=p.id
WHERE u.display_name = 'Joel Coehoorn'

/*12 unique questions of a user named Joel Coehoorn received at least one vote*/

-- Unload all the fields of the vote_types table. Add the rank field to the table, which will include the record numbers in reverse order. The table should be sorted by the id field.
SELECT *,
    RANK() OVER (ORDER BY id DESC)
FROM stackoverflow.vote_types
ORDER BY id

/*Now we know it is 15 unique vote types*/

-- Select the 10 users who put the most votes of the Close type. Display a table of two fields: the user ID and the number of votes. Sort the data first in descending order of the number of votes, then in descending order of the value of the user ID.
SELECT 
	u.id, 
	COUNT(v.id)
FROM stackoverflow.vote_types v_t
	JOIN stackoverflow.votes v 
		ON v.vote_type_id=v_t.id
	JOIN stackoverflow.users u 
		ON u.id=v.user_id
WHERE v_t.name = 'Close'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10

-- Select 10 users by the number of badges received in the period from November 15 to December 15, 2008 inclusive. Display multiple fields:
	-- user ID;
	-- number of icons;
	-- place in the rating — the more badges, the higher the rating.
-- Assign the same place in the rating to users who have scored the same number of badges.
-- Sort the entries by the number of badges in descending order, and then in ascending order of the user ID value.
SELECT 
	user_id, 
	COUNT(id),
    DENSE_RANK() OVER(ORDER BY COUNT(id) DESC)
FROM stackoverflow.badges
WHERE creation_date::date >= '2008-11-15' 
    AND creation_date::date <= '2008-12-15'
GROUP BY 1
ORDER BY count(id) DESC, user_id ASC
LIMIT 10

-- How many points does each user's post get on average?
-- Create a table from the following fields:
	-- post title;
	-- user ID;
	-- number of post points;
	-- the average number of user points per post, rounded to an integer.
-- Do not take into account posts without a title, as well as those that scored zero points.
SELECT 
	title,
	user_id, 
	score,
    ROUND(AVG(score) OVER (PARTITION BY user_id))
FROM stackoverflow.posts
WHERE score <> 0 
	AND length(title) > 0
GROUP BY 1, 2, score

/*On average , the user with id = 1 received the most points - 573 . After him comes the user with an average of 76 points.*/ 

-- Display the titles of posts that were written by users who received more than 1000 badges. Posts without titles should not be included in the list.
WITH t1 AS (
    SELECT user_id
    FROM stackoverflow.badges
    GROUP BY 1
    HAVING COUNT(user_id) > 1000
)
SELECT title
FROM t1
	JOIN stackoverflow.posts p 
		ON t1.user_id=p.user_id
WHERE length(title) <> 0

/*
Project management to go with GitHub
What are the correct version numbers for C#?
What's the hardest or most misunderstood aspect of LINQ?
What's the strangest corner case you've seen in C# or .NET?
*/

-- Write a request that will upload data about users from the United States. Divide users into three groups depending on the number of views of their profiles:
	-- assign group 1 to users with a number of views greater than or equal to 350;
	-- group 2 to users with a number of views less than 350, but greater than or equal to 100;
	-- group 3 to users with a number of views less than 100.
-- Display in the final table the user ID, the number of views profile and group. Users with zero views should not be included in the final table.
SELECT 
	id, 
	views, 
	CASE
        WHEN views >= 350 THEN 1
        WHEN views < 350 
        	AND views >= 100 THEN 2
        WHEN views < 100 THEN 3
    	END AS user_group
FROM stackoverflow.users
WHERE location LIKE '%United States%' 
				AND views <> 0

-- Complete the previous request. Display the leaders of each group — the users who have scored the maximum number of views in their group. Output the fields with the user ID, group, and number of views. Sort the table in descending order of views, and then in ascending order of the ID value.
WITH t1 as (

	SELECT
		id, 
		views, 
		CASE
        	WHEN views >= 350 THEN 1
        	WHEN views < 350 
        			AND views >= 100 THEN 2
        	WHEN views < 100 THEN 3
    		END user_group
	FROM stackoverflow.users
	WHERE location LIKE '%United States%' 
					AND views <> 0

),

	t2 as (

	SELECT MAX(views) OVER (PARTITION BY user_group)
	FROM t1

)

SELECT DISTINCT 
	t1.id, 
	t1.views, 
	t1.user_group
FROM t2
	JOIN t1 
		ON t2.max = t1.views
ORDER BY views DESC, id ASC

/*The leader of the first group scored 62813 views, the leader of the second group - 349, and the third - 99. The latest results are artificial, since we ourselves set the maximum value of views in groups.*/

-- Calculate the daily increase in new users in November 2008. Create a table with fields:
	-- number of the day;
	-- the number of users registered on that day;
	-- the amount of users with accumulation.
SELECT DISTINCT 
	DATE_PART('day', creation_date),
    COUNT(id) OVER(PARTITION BY DATE_PART('day', creation_date)),
    COUNT(id) OVER(ORDER BY DATE_PART('day', creation_date))
FROM stackoverflow.users
WHERE creation_date::date >= '2008-11-01'
    AND creation_date::date < '2008-12-01'

/*The daily increase in new users in November 2008 was 2,375 users. The most users - 192 - came on November 4*/

-- For each user who has written at least one post, find the interval between registration and the time of creation of the first post. Display:
	-- user ID;
	-- the time difference between registration and the first post.
WITH t1 as (

	SELECT DISTINCT 
		user_id,
    	FIRST_VALUE(creation_date) OVER (PARTITION BY user_id ORDER BY creation_date)
	FROM stackoverflow.posts
)

SELECT 
	u.id,
    t1.first_value - u.creation_date AS dif
FROM t1
	JOIN stackoverflow.users u 
		ON t1.user_id = u.id

 /*The resulting table shows that there is no single pattern between creating a profile and writing a post.*/

-- Output the total amount of post views for each month of 2008. If there is no data for any month in the database, you can skip such a month. Sort the result in descending order of the total number of views.
SELECT DISTINCT 
	DATE_TRUNC('month', creation_date)::date,
    SUM(views_count)
FROM stackoverflow.posts
GROUP BY 1
ORDER BY 2 DESC

 /*The data is different. Perhaps the increased activity in September and October is associated with the beginning of the school year. Low activity in July may indicate incomplete data*/

-- Print the names of the most active users who gave more than 100 responses in the first month after registration (including the day of registration). Do not take into account the questions that users asked. For each user name, output the number of unique user_id values. Sort the result by the field with names in lexicographic order.
WITH t1 AS (

	SELECT DISTINCT 
		u.display_name, 
		p.user_id,
		COUNT(p.id) OVER (PARTITION BY u.display_name) AS post_count
FROM stackoverflow.posts p
	JOIN stackoverflow.users u 
		ON u.id=p.user_id
WHERE p.post_type_id = 2
    AND p.creation_date::date >= u.creation_date::date
    AND p.creation_date::date <= u.creation_date::date + INTERVAL '1 months'

    )

SELECT 
	display_name,
    COUNT(DISTINCT user_id)
FROM t1
WHERE post_count > 100
GROUP BY 1

/*It seems that one username should correspond to one user_id. But this is not the case: many popular names like Alan , Dan or Chris correspond to several user_id values. It is better not to analyze the data by name, otherwise the results will be incorrect.*/

-- Print the number of posts for 2008 by month. Select posts from users who registered in September 2008 and made at least one post in December of the same year. Sort the table by month value in descending order.
SELECT DISTINCT 
	DATE_TRUNC('month', p.creation_date)::date,
    COUNT(p.id) OVER (PARTITION BY(DATE_TRUNC('month', p.creation_date))::date)
FROM stackoverflow.posts p
WHERE p.user_id IN (

	SELECT 
		p.user_id
    FROM stackoverflow.posts p
    	JOIN stackoverflow.users u 
    		ON u.id=p.user_id
    WHERE u.creation_date >= '2008-09-01' 
    	AND u.creation_date < '2008-10-01'
        AND p.creation_date >= '2008-12-01' 
        AND p.creation_date <= '2008-12-31'

)
	
	AND p.creation_date >= '2008-01-01' 
	AND p.creation_date <= '2008-12-31'
ORDER BY 1 DESC

/*There are abnormal values in the final table: users registered in September were active in August as well. It may be an error in the data.*/

-- Using post data, output several fields:
	-- id of the user who wrote the post;
	-- date of creation of the post;
	-- the number of views of the current post;
	-- the amount of views of the author's posts with accumulation.
-- The data in the table should be sorted in ascending order of user IDs, and the data about the same user should be sorted in ascending order of the post creation date.
SELECT 
	user_id, 
	creation_date, 
	views_count,
    SUM(views_count) OVER (PARTITION BY user_id ORDER BY id, creation_date)
FROM stackoverflow.posts
ORDER BY user_id, creation_date

-- On average, how many days in the period from December 1 to December 7, 2008 inclusive, did users interact with the platform? For each user, select the days on which he or she published at least one post. You need to get one integer — do not forget to round the result.
SELECT 
    ROUND(AVG(count))
FROM (

	SELECT DISTINCT 
	user_id,
    COUNT(id) OVER (PARTITION BY user_id, creation_date::date)
FROM stackoverflow.posts
WHERE creation_date::date >= '2008-12-01' 
	AND creation_date::date >= '2008-12-07'

) t1

/*On average, users interacted with the platform for 2 days in the period from December 1 to December 7, 2008 inclusive. The relatively small time interval that we use is an excellent indicator.*/

-- How many percent did the number of posts change monthly from September 1 to December 31, 2008? Display a table with the following fields:
	-- month number;
	-- number of posts per month;
	-- percentage that shows how much the number of posts has changed in the current month compared to the previous one.
-- If there are fewer posts, the percentage value should be negative, if more — positive. Round the percentage value to two decimal places.
-- Recall that when dividing one integer by another in PostgreSQL, the result is an integer rounded down to the nearest integer. To avoid this, convert the divisible to the numeric type.
WITH t AS (

	SELECT DISTINCT
    DATE_PART('month', creation_date) AS month,
    COUNT(id) OVER (PARTITION BY DATE_PART('month', creation_date)) AS post_cnt
FROM stackoverflow.posts
WHERE creation_date::date >= '2008-09-01' 
	AND creation_date::date <= '2008-12-31'

)

SELECT *,
    ROUND(-100 + (post_cnt::numeric / LAG(post_cnt) OVER (ORDER BY month) * 100), 2)
FROM t

/*In October, the number of posts decreased by 10%. 
The following month saw the strongest decline in a given period by almost 26%. 
In December 2008, the number of posts decreased by 5%. 
We can say that in November there was a decrease in user activity*/

-- Upload the activity data of the user who has published the most posts of all time. Output the data for October 2008 in this form:
	-- number of the week;
	-- date and time of the last post published this week.
WITH t1 AS (
	
	SELECT
		user_id,
    	COUNT(id)
	FROM stackoverflow.posts
	GROUP BY user_id
	ORDER BY 2 DESC
	LIMIT 1

),

t2 as (

	SELECT 
		t1.user_id, 
		p.creation_date AS date_of_post,
    	DATE_PART('week', creation_date) AS number_of_week
	FROM t1 
		JOIN stackoverflow.posts p 
			ON t1.user_id = p.user_id
	WHERE creation_date::date >= '2008-10-01' 
		AND creation_date::date < '2008-11-01'

),

t3 as (
	
	SELECT 
	MAX(date_of_post) OVER (PARTITION BY number_of_week)::timestamp
	FROM t2
)

SELECT DISTINCT 
	t2.date_of_post, 
	t2.number_of_week
FROM t3
	JOIN t2 
		ON t3.max = t2.date_of_post

/*According to the output table, you can see that the user with the largest number of posts in October published posts either in the morning or late at night.*/

