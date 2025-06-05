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

# This trigger automatically updates Content's Director if more Directors are added
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

DELIMITER ;


