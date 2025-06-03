/*
FILE: Triggers.sql
DESCRIPTION: Trigger-Based Requirements
COLLABORATORS: Jaylin Jack
*/


USE MultimediaContentDB;

DELIMITER $$

/*
    1. Limit Watchlist Capacity
    Enforce a maximum of 50 items in a user's Watchlist.
    Automatically remove the oldest item if the user adds an item exceeding the limit.
*/
DROP PROCEDURE IF EXISTS PRC_ENFORCE_WATCHLIST_LIMIT$$
CREATE PROCEDURE IF NOT EXISTS PRC_ENFORCE_WATCHLIST_LIMIT(IN user_id INT)
BEGIN
    DECLARE watchlist_count INT;
    DECLARE amount_over_limit INT;

    # SELECT the count of the user from watchlist.
    SELECT COUNT(Watchlist.user) INTO watchlist_count
    FROM Watchlist
    WHERE user = user_id;

    SET amount_over_limit = watchlist_count - 50;
    # If the count is greater than 50,
    # THEN delete the earliest rows until there is only 50 watchlist entries for the user.
    IF watchlist_count > 50 THEN

        DELETE FROM Watchlist WHERE user = user_id
        ORDER BY Watchlist.watchlistID
        LIMIT amount_over_limit;
    END IF;


END$$

/*
    2. Rating Impact on Content Availability
    Automatically set the Content_Availability status to "Archived" if the average rating
    of a piece of Content falls below 2.0 after a new review is added.
*/

DROP TRIGGER IF EXISTS TRG_RATING_ON_CONTENT_AVAILABILITY$$
CREATE TRIGGER IF NOT EXISTS TRG_RATING_ON_CONTENT_AVAILABILITY AFTER INSERT ON Review FOR EACH ROW
    BEGIN

        DECLARE avg_rating DECIMAL (8, 2) DEFAULT 0.00;

        -- GET the average rating for the newly inserted Review & store in avg_rating
        SELECT AVG(Review.rating_value) INTO avg_rating
        FROM Review
        JOIN Content ON Content.contentID = Review.content
        WHERE content = NEW.content;

        IF avg_rating < 2 THEN
            -- UPDATE the newly reviewed content's availability to 'Archived'
            UPDATE Content_Availability SET availability = 'archived' WHERE content = NEW.content;
        END IF;
    END $$


-- 3. Ensure Unique Director for Content

DROP TRIGGER IF EXISTS TRG_UPDATE_CONTENT_DIRECTOR$$
CREATE TRIGGER IF NOT EXISTS TRG_UPDATE_CONTENT_DIRECTOR AFTER INSERT ON ContentDirectors FOR EACH ROW
    BEGIN
        DECLARE current_director INT;

        SELECT Content.director INTO current_director
        FROM Content
        WHERE Content.contentID = NEW.content;

        IF current_director IS NULL OR current_director > 0 THEN
            # IF the Content has a NULL director THEN change director to 'Multiple Directors'.
            # DO the same if content has an initial director since there will be more directors.
            UPDATE Content
            SET director = 1
            WHERE contentID = NEW.content;
        END IF;
    END $$

# This function simply alerts the error.
DROP FUNCTION IF EXISTS FNC_RETURN_CONTENT_DIRECTOR_ERROR $$
CREATE FUNCTION IF NOT EXISTS FNC_RETURN_CONTENT_DIRECTOR_ERROR(msg VARCHAR(60)) RETURNS VARCHAR(60)
    DETERMINISTIC
BEGIN
    RETURN msg;
END$$


DROP PROCEDURE IF EXISTS PRC_INSERT_CONTENTDIRECTORS_OR_LOG_ERROR$$
CREATE PROCEDURE IF NOT EXISTS PRC_INSERT_CONTENTDIRECTORS_OR_LOG_ERROR(IN content_id INT, director_id INT)
    BEGIN
        DECLARE director_matches INT DEFAULT 0;
        DECLARE error_msg VARCHAR(60);

        -- GET the count of directors
        SELECT COUNT(director) INTO director_matches
        FROM ContentDirectors
        WHERE director = director_id AND content = content_id;

        -- IF the director is already connected to the content then throw error.
        IF director_matches > 0 THEN
            -- LOG it first in our error table.
            INSERT INTO Director_Assignment_Errors (content, director) VALUES (content_id, director_id);
            SET error_msg = 'Director can not be associated with the same content twice.';
            SELECT FNC_RETURN_CONTENT_DIRECTOR_ERROR(error_msg);
        ELSE
            # Otherwise INSERT INTO ContentDirectors.
            INSERT INTO ContentDirectors (content, director) VALUES (content_id, director_id);
        END IF;

    end $$


DELIMITER ;


