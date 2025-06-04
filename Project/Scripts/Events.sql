/*
FILE: Events.sql
DESCRIPTION: Scheduled Events Requirements
COLLABORATORS: Jaylin Jack
*/

USE MultimediaContentDB;

DELIMITER $$

/*
    10. Remove Expired Subscriptions
    Automatically remove expired subscriptions from the User_Subscription table.
    Notify users of the expiration and removal.
*/

DROP TABLE IF EXISTS User_Notification;
CREATE TABLE IF NOT EXISTS User_Notification(
    user_notificationID INT PRIMARY KEY AUTO_INCREMENT,
    user INT NOT NULL, -- FK
    notification VARCHAR(255) NOT NULL,
    addedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_UserNotification_user
        FOREIGN KEY (user) REFERENCES User(userID)
);

/*
    11. Refresh Popular Content Rankings
    Update a table storing the top 10 most popular Content for each Genre daily, based on view counts.
*/
-- Table I use to store the top Content and Genres.
DROP TABLE IF EXISTS Popular_Content_And_Genres;
CREATE TABLE IF NOT EXISTS Popular_Content_And_Genres(
     popularID INT PRIMARY KEY AUTO_INCREMENT,
     content INT NOT NULL, -- FK
     genre INT NOT NULL, -- FK
     addedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
     CONSTRAINT fk_popularContentAndGenre_content
         FOREIGN KEY (content) REFERENCES Content(contentID),
     CONSTRAINT fk_popularContentAndGenre_genre
         FOREIGN KEY (genre) REFERENCES Genre(genreID)
);

DROP EVENT IF EXISTS UpdatePopularContentAndGenres$$
CREATE EVENT IF NOT EXISTS UpdatePopularContentAndGenres
ON SCHEDULE EVERY 1 DAY
STARTS (CURRENT_TIMESTAMP )
DO
    BEGIN
        DECLARE  i INT DEFAULT 1;
        SET i = 1;

        -- Reset the table and then get the latest values.
        TRUNCATE TABLE Popular_Content_And_Genres;

        -- For Loop to iterate through the 9 Genres we offer.
        for_loop: LOOP

            -- Exit Case.
            IF i > 9 THEN
                LEAVE for_loop;
            END IF;

            -- Get the top 10 content for genre at i (1, 2, 3 ... ,9)
            INSERT INTO Popular_Content_And_Genres (content, genre)
            SELECT Content.contentID, Content.genre
            FROM Content
            JOIN Watch_History ON Watch_History.content = Content.contentID
            WHERE genre = i
            GROUP BY Content.contentID, Content.genre
            ORDER BY COUNT(Watch_History.content)DESC
            LIMIT 10;

            SET i = i + 1;

        END LOOP ;

    END$$


/*
    This Scheduled Event Automatically Checks All User's Watchlist.
    Enforcing the cleanup if necessary every minute.
*/

DROP EVENT IF EXISTS CheckAllUsersWatchlist$$
CREATE EVENT IF NOT EXISTS CheckAllUsersWatchlist
    ON SCHEDULE EVERY 1 MINUTE
        STARTS (CURRENT_TIMESTAMP)
    DO
    BEGIN
        DECLARE tmp_user_id INT;
        DECLARE done BOOLEAN DEFAULT FALSE;

        DECLARE tmp_user_cursor CURSOR FOR
            SELECT User.userID
            FROM Watchlist
            JOIN User ON User.userID = Watchlist.user;

        DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

        OPEN tmp_user_cursor;

        for_loop: LOOP
            FETCH tmp_user_cursor INTO tmp_user_id;

            IF done = TRUE THEN
                LEAVE for_loop;
            end if;

            CALL PRC_ENFORCE_WATCHLIST_LIMIT(tmp_user_id);
        end loop for_loop;
        -- INSERT all rows that return from expired User_Subscription INTO User_Notification

        CLOSE tmp_user_cursor;


    END$$

DELIMITER ;