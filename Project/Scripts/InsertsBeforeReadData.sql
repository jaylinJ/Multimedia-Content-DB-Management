/*
FILE: InsertsBeforeReadData.sql
DESCRIPTION: The statements in this file are needed to run ReadData successfully.
COLLABORATORS: Jaylin Jack
*/

USE MultimediaContentDB;

ALTER TABLE Genre AUTO_INCREMENT = 0;
ALTER TABLE Rating AUTO_INCREMENT = 0;
ALTER TABLE Content_Format AUTO_INCREMENT = 0;
ALTER TABLE Director AUTO_INCREMENT = 0;
ALTER TABLE Watch_History AUTO_INCREMENT = 0;
ALTER TABLE Watchlist AUTO_INCREMENT = 0;
ALTER TABLE Review AUTO_INCREMENT = 0;
ALTER TABLE ContentDirectors AUTO_INCREMENT = 0;
ALTER TABLE Actor AUTO_INCREMENT = 0;
ALTER TABLE Subscription_Plan AUTO_INCREMENT = 0;
ALTER TABLE User AUTO_INCREMENT = 0;
ALTER TABLE Transaction AUTO_INCREMENT = 0;
ALTER TABLE User_Subscription AUTO_INCREMENT = 0;
ALTER TABLE Payment_Method AUTO_INCREMENT = 0;


-- Subscription_Plan INSERTS
INSERT INTO Subscription_Plan (price, description) VALUES (4.99, 'Student');
INSERT INTO Subscription_Plan (price, description) VALUES (11.99, 'Basic');
INSERT INTO Subscription_Plan (price, description) VALUES (19.99, 'Premium');

-- User INSERTS
INSERT INTO User ( name, email, password) VALUES ( 'Jaylin', 'sample@mail.com', 'p1');
INSERT INTO User ( name, email, password) VALUES ('solowke', 'solowke@mail.com', 'p1');
INSERT INTO User ( name, email, password) VALUES ( 'Jamil', 'jamil@mail.com', 'p1');
INSERT INTO User ( name, email, password) VALUES ('Jerron', 'jerron@mail.com', 'p1');
INSERT INTO User ( name, email, password) VALUES ('tester', 'tester@mail.com', 'p1');

/*
    Since our .csv file doesn't give us 1 genre, I create genres and assign them in the java file.
    NEEDS TO BE RAN BEFORE READDATA.JAVA
*/

INSERT INTO Rating (ratingID, name) VALUES (1, 'NEEDS REVISION');

INSERT INTO Director (directorID, name) VALUES (1, 'Multiple Directors');
--  GENRE INSERTS
INSERT INTO Genre (genreID, description) VALUES (1, 'Action');
INSERT INTO Genre (genreID, description) VALUES (2, 'Cartoon');
INSERT INTO Genre (genreID, description) VALUES (3, 'Comedy');
INSERT INTO Genre (genreID, description) VALUES (4, 'Rom-Com');
INSERT INTO Genre (genreID, description) VALUES (5, 'Sports');
INSERT INTO Genre (genreID, description) VALUES (6, 'Game Show');
INSERT INTO Genre (genreID, description) VALUES (7, 'Anime');
INSERT INTO Genre (genreID, description) VALUES (8, 'Horror');
INSERT INTO Genre (genreID, description) VALUES (9, 'Thriller');

DELIMITER $$

/*
    This trigger is needed since transactions is only for purchasing user_subscriptions
    therefore if a "successful" transaction is triggered then a user_subscription should also exist.
 */
DROP TRIGGER IF EXISTS TRG_AUTO_INSERT_TRANSACTIONS_FOR_SUBS$$
CREATE TRIGGER IF NOT EXISTS TRG_AUTO_INSERT_TRANSACTIONS_FOR_SUBS AFTER INSERT ON Transaction FOR EACH ROW
BEGIN

    DECLARE user_id INT DEFAULT 0;

    SELECT User.userID INTO user_id
    FROM Transaction
             JOIN Payment_Method ON Payment_Method.payment_methodID = Transaction.payment_method
             JOIN User ON Payment_Method.user = User.userID
    WHERE Payment_Method.payment_methodID = NEW.payment_method
    ORDER BY transaction_date DESC
    LIMIT 1;

    IF NEW.status = 'successful' THEN
        -- ENTER the valid subscription using the sub they purchased.
        INSERT INTO User_Subscription (user, subscription)
        VALUES (user_id, NEW.subscription);
    END IF;


END$$

DELIMITER ;

-- PAYMENT AND TRANSACTION INSERTS FOR EACH USER.
INSERT INTO Payment_Method (user, card_details) VALUES (1, 2772);
INSERT INTO Payment_Method (user, card_details) VALUES (2, 2772);
INSERT INTO Payment_Method (user, card_details) VALUES (3, 2772);
INSERT INTO Payment_Method (user, card_details) VALUES (4, 2772);

-- TRANSACTION INSERTS (USEFUL FOR Function 6.)
INSERT INTO Transaction ( payment_method, status, subscription, transaction_date)
VALUES ( 1, 'successful', 3,CURRENT_TIMESTAMP - INTERVAL 2 MONTH);

INSERT INTO Transaction ( payment_method, status, subscription, transaction_date)
VALUES ( 2, 'successful', 3,CURRENT_TIMESTAMP);

INSERT INTO Transaction ( payment_method, status, subscription, transaction_date)
VALUES ( 3, 'successful', 3,CURRENT_TIMESTAMP - INTERVAL 2 MONTH);

INSERT INTO Transaction ( payment_method, status, subscription, transaction_date)
VALUES ( 4, 'successful', 3,CURRENT_TIMESTAMP);

