/*
FILE: InsertsAfterReadData.sql
DESCRIPTION: The statements in this file are needed to run Tests.sql successfully.
COLLABORATORS: Jaylin Jack
*/

USE MultimediaContentDB;

# -- INSERTS FOR TRIGGER TEST 1.
INSERT INTO Watchlist (user, content) VALUES (2, 2);
INSERT INTO Watchlist (user, content) VALUES (2, 3);
INSERT INTO Watchlist (user, content) VALUES (2, 4);
INSERT INTO Watchlist (user, content) VALUES (2, 5);
INSERT INTO Watchlist (user, content) VALUES (2, 6);
INSERT INTO Watchlist (user, content) VALUES (2, 7);
INSERT INTO Watchlist (user, content) VALUES (2, 1);
INSERT INTO Watchlist (user, content) VALUES (2, 8);
INSERT INTO Watchlist (user, content) VALUES (2, 9);
INSERT INTO Watchlist (user, content) VALUES (2, 10);
INSERT INTO Watchlist (user, content) VALUES (2, 11);
INSERT INTO Watchlist (user, content) VALUES (2, 12);
INSERT INTO Watchlist (user, content) VALUES (2, 13);
INSERT INTO Watchlist (user, content) VALUES (2, 14);
INSERT INTO Watchlist (user, content) VALUES (2, 15);
INSERT INTO Watchlist (user, content) VALUES (2, 16);
INSERT INTO Watchlist (user, content) VALUES (2, 17);
INSERT INTO Watchlist (user, content) VALUES (2, 18);
INSERT INTO Watchlist (user, content) VALUES (2, 7016);
INSERT INTO Watchlist (user, content) VALUES (2, 183);
INSERT INTO Watchlist (user, content) VALUES (2, 183);
INSERT INTO Watchlist (user, content) VALUES (2, 184);
INSERT INTO Watchlist (user, content) VALUES (2, 185);
INSERT INTO Watchlist (user, content) VALUES (2, 186);
INSERT INTO Watchlist (user, content) VALUES (2, 187);
INSERT INTO Watchlist (user, content) VALUES (2, 188);
INSERT INTO Watchlist (user, content) VALUES (2, 189);
INSERT INTO Watchlist (user, content) VALUES (2, 190);
INSERT INTO Watchlist (user, content) VALUES (2, 192);
INSERT INTO Watchlist (user, content) VALUES (2, 194);
INSERT INTO Watchlist (user, content) VALUES (2, 195);
INSERT INTO Watchlist (user, content) VALUES (2, 196);
INSERT INTO Watchlist (user, content) VALUES (2, 197);
INSERT INTO Watchlist (user, content) VALUES (2, 1968);
INSERT INTO Watchlist (user, content) VALUES (2, 200);
INSERT INTO Watchlist (user, content) VALUES (2, 248);
INSERT INTO Watchlist (user, content) VALUES (2, 300);
INSERT INTO Watchlist (user, content) VALUES (2, 301);
INSERT INTO Watchlist (user, content) VALUES (2, 303);
INSERT INTO Watchlist (user, content) VALUES (2, 304);
INSERT INTO Watchlist (user, content) VALUES (2, 305);
INSERT INTO Watchlist (user, content) VALUES (2, 306);
INSERT INTO Watchlist (user, content) VALUES (2, 307);
INSERT INTO Watchlist (user, content) VALUES (2, 308);
INSERT INTO Watchlist (user, content) VALUES (2, 309);
INSERT INTO Watchlist (user, content) VALUES (2, 310);
INSERT INTO Watchlist (user, content) VALUES (2, 311);
INSERT INTO Watchlist (user, content) VALUES (2, 312);
INSERT INTO Watchlist (user, content) VALUES (2, 313);
INSERT INTO Watchlist (user, content) VALUES (2, 414);
INSERT INTO Watchlist (user, content) VALUES (2, 415);
INSERT INTO Watchlist (user, content) VALUES (2, 320);
INSERT INTO Watchlist (user, content) VALUES (2, 321);
INSERT INTO Watchlist (user, content) VALUES (2, 323);
INSERT INTO Watchlist (user, content) VALUES (2, 344);
INSERT INTO Watchlist (user, content) VALUES (2, 378);
INSERT INTO Watchlist (user, content) VALUES (2, 389);

/*
    -> Essential for 4. Rank Top Genres By Watch Hours Testing
    -> & Essential for 7. Generate Monthly User Activity Report
    -> These inserts are only movies.
    NO WAY OF KNOWING THE DURATION OF A TV SHOW'S SEASONS.
    ONLY WAY YOU CAN PROPERLY MEASURE DURATION IS IF THE CONTENT IS A MOVIE.

    POPULATE THE Watch_History Table but make the watch_date a couple weeks ago for testing.
*/

-- WATCH_HISTORY INSERTS FOR PROCEDURE #7
INSERT INTO Watch_History (user, content, watch_date) VALUES
(1, 1, CURRENT_TIMESTAMP - INTERVAL 1 DAY );
INSERT INTO Watch_History (user, content, watch_date) VALUES
    (1, 300, CURRENT_TIMESTAMP - INTERVAL 1 DAY );
INSERT INTO Watch_History (user, content, watch_date) VALUES
    (2, 303, CURRENT_TIMESTAMP - INTERVAL 1 DAY );
INSERT INTO Watch_History (user, content, watch_date) VALUES
    (2, 301, CURRENT_TIMESTAMP - INTERVAL 1 DAY );

-- REVIEW INSERTS (FIRST 2 FOR TRIGGER #2 TEST & LAST 2 FOR PROCEDURE #7.)
INSERT INTO Review (user, content, rating_value, review_text)
VALUES (1, 1, 1, 'Boring.');
INSERT INTO Review (user, content, rating_value, review_text)
VALUES (2, 1, 1, 'Boring.');
-- Content 1 should be 'archived' now.


-- REVIEW INSERTS (Proves avg works in 7.
INSERT INTO Review (user, content, rating_value, review_text, review_date)
VALUES (1, 300, 6, 'Decent.', CURRENT_TIMESTAMP - INTERVAL 5 DAY);
INSERT INTO Review (user, content, rating_value, review_text, review_date)
VALUES (2, 300, 6, 'Decent.', CURRENT_TIMESTAMP - INTERVAL 5 DAY);

-- FAILED TRANSACTION INSERTS FOR PROCEDURE #9
INSERT INTO Transaction (payment_method, subscription, status)
VALUES (1, 1, 2);
INSERT INTO Transaction (payment_method, subscription, status)
VALUES (1, 1, 2);
INSERT INTO Transaction (payment_method, subscription, status)
VALUES (2, 2, 2);
-- User 1 and 2 should be notified of their failed payments.



