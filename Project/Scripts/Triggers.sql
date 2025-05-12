/*
FILE: Triggers.sql
DESCRIPTION: Trigger-Based Requirements
COLLABORATORS: Jaylin Jack
*/
USE MultimediaContentDB;

DELIMITER $$


DROP TRIGGER IF EXISTS TRG_WATCHLISTHELPER$$
CREATE TRIGGER TRG_WATCHLISTHELPER AFTER INSERT ON Watchlist FOR EACH ROW
    BEGIN
        INSERT INTO WatchlistHelper (user, content) VALUES (NEW.user, NEW.content);
    END$$


DROP TRIGGER IF EXISTS TRG_WATCHLIST_CAPACITY_EXCEEDED$$
CREATE TRIGGER TRG_WATCHLIST_CAPACITY_EXCEEDED AFTER INSERT ON WatchlistHelper FOR EACH ROW
    BEGIN
        DECLARE watchlist_count INT DEFAULT 0;

        SELECT COUNT(WatchlistHelper.user) INTO watchlist_count
        FROM WatchlistHelper
        WHERE WatchlistHelper.user = NEW.user;

        IF watchlist_count > 5 THEN
            DELETE FROM Watchlist WHERE user = NEW.user;
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
DROP TRIGGER IF EXISTS TRG_UNIQUE_DIRECTOR_FOR_CONTENT$$
CREATE TRIGGER TRG_UNIQUE_DIRECTOR_FOR_CONTENT BEFORE INSERT ON ContentDirectors FOR EACH ROW
BEGIN
    DECLARE director_matches INT DEFAULT 0;

    -- GET the count of directors
    SELECT COUNT(director) INTO director_matches
    FROM ContentDirectors
    WHERE director = NEW.director AND content = NEW.content;

    -- IF the director is already connected to the content then throw error.
    IF director_matches > 0 THEN
        -- LOG it first in our error table.
        INSERT INTO Director_Assignment_Errors (director, content) VALUES (NEW.director, NEW.content);

        SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = 'Director can not be associated with the same content twice.';
    END IF;
END$$


DELIMITER ;