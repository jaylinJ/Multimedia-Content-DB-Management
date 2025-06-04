/*
FILE: Triggers.sql
DESCRIPTION: Trigger-Based Requirements
COLLABORATORS: Jaylin Jack
*/


USE MultimediaContentDB;

DELIMITER $$


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



DELIMITER ;


