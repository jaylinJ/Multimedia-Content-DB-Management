/*
FILE: Procedures.sql
DESCRIPTION: Procedure-Based Requirements
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
    3. Ensure Unique Director for Content
    Prevent duplicate Director entries for the same Content.
    Log any failed attempts to assign a duplicate director into a Director_Assignment_Errors table.
*/

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

/*
    7. Generate Monthly User Activity Report
    Generate a report detailing user activity for the past month, including:
        - The number of content items watched
        - Average ratings provided
        - Hours spent on the platform
*/

DROP PROCEDURE IF EXISTS PRC_GENERATE_USER_REPORT$$
CREATE PROCEDURE IF NOT EXISTS PRC_GENERATE_USER_REPORT(IN user_id INT)
    BEGIN
        DECLARE number_of_content_watched INT DEFAULT 0;
        DECLARE avg_of_ratings DECIMAL(8,2) DEFAULT 0.00;
        DECLARE watch_hours DECIMAL(8,2) DEFAULT 0.00;

        -- Get the count of Watch_History for the user over the last month
        SELECT COUNT(Watch_History.content) INTO number_of_content_watched
        FROM Watch_History
        WHERE Watch_History.user = user_id
        AND Watch_History.watch_date + INTERVAL 1 MONTH > CURRENT_TIMESTAMP;

        -- Get the hours watched from Watch_History for the user over the last month
        SELECT SUM(Content.duration)/ 60.0 INTO watch_hours
        FROM Watch_History
        JOIN Content ON Watch_History.content = Content.contentID
        JOIN User ON Watch_History.user = User.userID
        WHERE User.userID = user_id
        AND Watch_History.watch_date + INTERVAL 1 MONTH > CURRENT_TIMESTAMP;

        -- Get the avg of ratings the user has left from Review over the last month
        SELECT AVG(Review.rating_value) INTO avg_of_ratings
        FROM Review
        JOIN User ON Review.user = User.userID
        WHERE User.userID = user_id AND
        Review.review_date + INTERVAL 1 MONTH > CURRENT_TIMESTAMP;

        -- TEMP Table to store the User_Report.
        DROP TEMPORARY TABLE IF EXISTS User_Report;
        CREATE TEMPORARY TABLE IF NOT EXISTS User_Report(
            user_reportID INT PRIMARY KEY AUTO_INCREMENT,
            user INT NOT NULL, -- FK
            content_watched INT NOT NULL,
            avg_ratings DECIMAL(8,2) NOT NULL,
            hours_watched DECIMAL(8,2) NOT NULL,
            addedAt DATETIME DEFAULT CURRENT_TIMESTAMP
        );

        IF number_of_content_watched IS NULL THEN
            SET number_of_content_watched = 0;
        end if;

        IF avg_of_ratings IS NULL THEN
            SET avg_of_ratings = 0.00;
        end if;

        IF watch_hours IS NULL THEN
            SET watch_hours = 0.00;
        end if;

        INSERT INTO User_Report (user, content_watched, avg_ratings, hours_watched) VALUES
            (user_id, number_of_content_watched, avg_of_ratings, watch_hours);


        SELECT * FROM User_Report WHERE user_reportID = LAST_INSERT_ID();



    END$$

/*
    8. Process Batch Content Updates
    Update the Content_Availability status for multiple Content entries
    based on a given list of criteria

    MY Criteria:
    If a content has no watch_history and was in our release for over 5 years.
    This content will now be marked as 'AT RISK'.
*/
DROP PROCEDURE IF EXISTS PRC_UPDATE_CONTENT_AVAILABILITY$$
CREATE PROCEDURE IF NOT EXISTS PRC_UPDATE_CONTENT_AVAILABILITY()
BEGIN

    DECLARE tmp_content_id INT;
    DECLARE done BOOLEAN DEFAULT FALSE;

    -- GET all the content that have no record inside Watch_History (0 watch records)
    -- Then make sure it meets our criteria.
    DECLARE tmp_content_cursor CURSOR FOR
        SELECT Content.contentID AS 'Content ID'
        FROM Content
        LEFT JOIN Watch_History ON Watch_History.content = Content.contentID
        JOIN Content_Release ON Content_Release.content = Content.contentID
        JOIN `Release` ON `Release`.releaseID = Content_Release.`release`
        WHERE `Release`.release_date < (CURRENT_TIMESTAMP - INTERVAL 5 YEAR)
        GROUP BY Content.contentID
        HAVING COUNT(Watch_History.content) < 1;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN tmp_content_cursor;

    for_loop: LOOP
        FETCH tmp_content_cursor INTO tmp_content_id;

        IF done = TRUE THEN
            LEAVE for_loop;
        END IF;

        -- Use the cursor to set the Availability of the current Content to 'AT RISK'.
        UPDATE Content_Availability SET availability = 'AT RISK' WHERE content = tmp_content_id;

    END LOOP for_loop;

    CLOSE tmp_content_cursor;

    SELECT * FROM Content_Availability WHERE availability = 'AT RISK';



END$$

/*
    9. Handle Failed Payments
    Log failed payment attempts into a Payment_Errors table.
    Send notifications to affected users regarding the failed payments.
*/

DROP PROCEDURE IF EXISTS PRC_FAILED_PAYMENT_FOR_USERS$$
CREATE PROCEDURE IF NOT EXISTS PRC_FAILED_PAYMENT_FOR_USERS()
BEGIN
    DECLARE noti VARCHAR(50) DEFAULT 'Payment Failed! Try again.';

    DROP TEMPORARY TABLE IF EXISTS Payment_Errors;
    CREATE TEMPORARY TABLE IF NOT EXISTS Payment_Errors
    (
        payment_errorsID INT PRIMARY KEY AUTO_INCREMENT,
        payment_method INT NOT NULL, -- FK
        createdAt DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL
    );

    -- SIMPLY insert all failed transactions into Payment_Errors.
    INSERT INTO Payment_Errors (payment_method)
    SELECT Transaction.payment_method
    FROM Transaction
    WHERE Transaction.status = 'failed';

    DROP TABLE IF EXISTS User_Payment_Notification;
    CREATE TABLE IF NOT EXISTS User_Payment_Notification(
        user_payment_notificationID INT PRIMARY KEY AUTO_INCREMENT,
        user INT NOT NULL, -- FK
        notification VARCHAR(255) NOT NULL,
        addedAt DATETIME DEFAULT CURRENT_TIMESTAMP
    );

    -- Notify users that have failed payments.
    INSERT INTO User_Payment_Notification (user, notification)
    SELECT User.userID, noti
    FROM Payment_Errors
    JOIN Payment_Method ON Payment_Errors.payment_method = Payment_Method.payment_methodID
    JOIN User ON User.userID = Payment_Method.user;


    SELECT * FROM User_Payment_Notification;
END$$

DELIMITER ;