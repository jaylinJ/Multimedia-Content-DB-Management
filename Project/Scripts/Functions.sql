/*
FILE: Functions.sql
DESCRIPTION: Function-Based Requirements
COLLABORATORS: Jaylin Jack
*/

USE MultimediaContentDB;

DELIMITER $$


/*
    4. Rank Top Genres By Watch Hours.
     NO WAY OF KNOWING THE DURATION OF A TV SHOW'S SEASONS.
     ONLY WAY YOU CAN PROPERLY MEASURE DURATION IS IF THE CONTENT IS A MOVIE.
 */
DROP FUNCTION IF EXISTS FNC_TOP_GENRES_BY_WATCH_HISTORY $$
CREATE FUNCTION IF NOT EXISTS FNC_TOP_GENRES_BY_WATCH_HISTORY() RETURNS VARCHAR(255)
DETERMINISTIC
    BEGIN
        DECLARE top_3_genres VARCHAR(150);
        DECLARE top_genre VARCHAR(50);
        DECLARE second_genre VARCHAR(50);
        DECLARE third_genre VARCHAR(50);

        /*
            This query gets Watch_History rows that are movies and were watched last month.
            Then grouped by the genre associated with the content,
            Then sum up each content associated with each genre.

            THEN we ORDER BY the Highest Watched Genre. Limit the top one and store it as top_genre.
            We then do the same for #2 and #3.
        */
        SELECT Genre.description INTO top_genre
        FROM Watch_History
        JOIN Content ON Watch_History.content = Content.contentID
        JOIN Genre ON content.genre = Genre.genreID
        JOIN Content_Format ON content.format = Content_Format.content_formatID
        WHERE Content_Format.description = 'Movie'
        AND Watch_History.watch_date + INTERVAL 1 MONTH > CURRENT_TIMESTAMP
        GROUP BY Content.genre
        ORDER BY SUM(Content.duration)/60 DESC
        LIMIT 1;

        SELECT Genre.description INTO second_genre
        FROM Watch_History
        JOIN Content ON Watch_History.content = Content.contentID
        JOIN Genre ON content.genre = Genre.genreID
        JOIN Content_Format ON content.format = Content_Format.content_formatID
        WHERE Content_Format.description = 'Movie'
          AND Watch_History.watch_date + INTERVAL 1 MONTH > CURRENT_TIMESTAMP
        GROUP BY Content.genre
        ORDER BY SUM(Content.duration)/60 DESC
        LIMIT 1,1;

        SELECT Genre.description INTO third_genre
        FROM Watch_History
        JOIN Content ON Watch_History.content = Content.contentID
        JOIN Genre ON content.genre = Genre.genreID
        JOIN Content_Format ON content.format = Content_Format.content_formatID
        WHERE Content_Format.description = 'Movie'
        AND Watch_History.watch_date + INTERVAL 1 MONTH > CURRENT_TIMESTAMP
        GROUP BY Content.genre
        ORDER BY SUM(Content.duration)/60 DESC
        LIMIT 2,1;


        -- CONCAT #1, #2, and #3 genre and return these values.
        SET top_3_genres = CONCAT(top_genre, ', ', second_genre, ', ', third_genre);
        return top_3_genres;

    END$$

/*
 5. Find Most Frequent Collaborators
 Identify the most frequent actor-director pairs who have worked together
 */
DROP FUNCTION IF EXISTS FNC_MOST_FREQUENT_ACTOR_DIRECTORS $$
CREATE FUNCTION IF NOT EXISTS FNC_MOST_FREQUENT_ACTOR_DIRECTORS () RETURNS VARCHAR(255)
DETERMINISTIC
BEGIN
    DECLARE top_actor VARCHAR(50);
    DECLARE top_director VARCHAR(50);
    DECLARE top_duo VARCHAR(120);

    -- GET the very top actor from the most popular Actor, Director Pair
    SELECT Actor.name INTO top_actor
    FROM ContentActors
    JOIN Content ON Content.contentID = ContentActors.content
    JOIN Actor ON ContentActors.actor = Actor.actorID
    JOIN Director ON Director.directorID = Content.director
    GROUP BY Actor.actorID, Director.directorID
    ORDER BY COUNT(Actor.actorID) DESC
    LIMIT 1;

    -- GET the very top director from the most popular Actor, Director Pair
    SELECT Director.name INTO top_director
    FROM ContentActors
    JOIN Content ON Content.contentID = ContentActors.content
    JOIN Actor ON ContentActors.actor = Actor.actorID
    JOIN Director ON Director.directorID = Content.director
    GROUP BY Actor.actorID, Director.directorID
    ORDER BY COUNT(Actor.actorID) DESC
    LIMIT 1;

    -- Return both values.
    SET top_duo = CONCAT('Top Actor, Director Pair: ', top_actor, ', ', top_director);

    return top_duo;


END$$

/*
    6. Validate Subscription Status
    Return whether a user’s subscription is active or expired
    based on their subscription and transaction history.
 */
DROP FUNCTION IF EXISTS FNC_VALIDATE_USER_SUBSCRIPTION $$
CREATE FUNCTION IF NOT EXISTS FNC_VALIDATE_USER_SUBSCRIPTION(userID INT) RETURNS VARCHAR(50)
    DETERMINISTIC
    BEGIN

        DECLARE transaction_date DATETIME; -- Variable we use to store the Transaction_Timestamp
        DECLARE subscription_status VARCHAR(50);

        -- GET the latest Transaction from passed in user & store the date into our variable.
        SELECT Transaction.transaction_date INTO transaction_date
        FROM Transaction
        JOIN Payment_Method ON Transaction.payment_method = Payment_Method.payment_methodID
        JOIN User ON Payment_Method.user = User.userID
        WHERE User.userID = userID AND Transaction.status = 'successful'
        ORDER BY Transaction.transaction_date DESC
        LIMIT 1;


        /*
         IF the Transaction Date Occurred LESS than 1 month ago from today,
                -> USER_Subscription is active.
         IF the Transaction Date Occurred MORE than 1 month ago from today,
                -> USER_Subscription is expired.
         */
        IF transaction_date + INTERVAL 1 MONTH > CURRENT_TIMESTAMP THEN
            UPDATE User_Subscription SET status = 'active' WHERE User_Subscription.user = userID;
            SET subscription_status = 'User has an active subscription.';
        ELSE
            UPDATE User_Subscription SET status = 'expired' WHERE User_Subscription.user = userID;
            SET subscription_status = 'User has an expired subscription.';
        END IF;

        return subscription_status;
    END$$

DELIMITER ;