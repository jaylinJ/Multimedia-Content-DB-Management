/*
FILE: Tests.sql
DESCRIPTION: Testing file to ensure all implemented business logic behaves as expected.
COLLABORATORS: Jaylin Jack
*/

USE MultimediaContentDB;

SELECT * FROM Actor WHERE actorID = 1;

-- ------------------- TRIGGER TESTING BELOW ---------------------------
-- 1. Limit Watchlist Capacity ❌
Select * from Watchlist;




-- 2. Rating Impact on Content_Availability
/*
 The 2 Review INSERTS make the avg rating value of Content 1 less than 2.
 SELECT Statement will return that Content 1 is "Archived".
 */

-- I first run this query to make sure all content is available at the start.
-- Should print 0 Rows. ✅
SELECT *
FROM Content
JOIN Content_Availability ON Content_Availability.content = Content.contentID
WHERE Content_Availability.availability != 1;


-- ------------ MAKE SURE InsertsAfterReadData.sql has been executed by now. -------------------

-- TEST Actual Output, Content 1 shall now be archived ✅
SELECT contentID AS 'Content ID', Content.title AS 'Title', Content_Availability.availability AS 'status'
FROM Content
JOIN Content_Availability ON Content_Availability.content = Content.contentID
WHERE Content_Availability.availability != 1;


-- TESTS FOR 3. ❌
INSERT INTO ContentDirectors (content, director) VALUES (1, 1);
INSERT INTO ContentDirectors (content, director) VALUES (1, 1);

SELECT * FROM ContentDirectors;
SELECT * FROM Director_Assignment_Errors;
-- ------------------- FUNCTION TESTING BELOW ---------------------------


--  4. Rank Top Genres by Watch Hours ✅
-- My top genres will change since they are generated randomly in ReadData. but works correctly still
SELECT FNC_TOP_GENRES_BY_WATCH_HISTORY();


-- 5.Find Most Frequent Collaborators ✅
-- EXPECTED OUTPUT: Top Actor, Director Pair: Julie Tejwani, Rajiv Chilaka
SELECT FNC_MOST_FREQUENT_ACTOR_DIRECTORS();

/*
    6. Validate Subscription Status
    INSERT some User_Subscriptions for proper testing for both.
    THEN test.
*/

-- TEST BOTH CASES FOR 6. ✅
-- 1 & 3 should be expired.
-- 2 & 4 should be active.
SELECT FNC_VALIDATE_USER_SUBSCRIPTION(1);
SELECT FNC_VALIDATE_USER_SUBSCRIPTION(2);
SELECT FNC_VALIDATE_USER_SUBSCRIPTION(3);
SELECT FNC_VALIDATE_USER_SUBSCRIPTION(4);

-- ------------------- PROCEDURE TESTING BELOW ---------------------------

-- 7. Generate Monthly User Activity Report ✅
CALL PRC_GENERATE_USER_REPORT(1);
CALL PRC_GENERATE_USER_REPORT(2);
CALL PRC_GENERATE_USER_REPORT(3);
CALL PRC_GENERATE_USER_REPORT(4);
CALL PRC_GENERATE_USER_REPORT(5);


-- 8. Process Batch Content Updates ✅
-- EXPECTED OUTPUT: 1,460 Content should be 'AT RISK' now.
CALL PRC_UPDATE_CONTENT_AVAILABILITY();

-- 9. Handled Failed Payments ✅
-- EXPECTED OUTPUT: 2 Failed Payments for user 1 and 1 Failed Payment for user 2.
CALL PRC_FAILED_PAYMENT_FOR_USERS();

-- 10. Remove Expired Subscriptions ✅
-- Wait about 5 minutes from testing 6.
-- The Event is ran every 5 minutes so there's enough time to test 6. and 10.
SELECT * FROM User_Subscription;
SELECT * FROM User_Notification;

-- 11. Refresh Popular Content Rankings ✅
-- This result when change on different runs of ReadData since the genre is randomly generated.
SELECT Content.title AS 'Content', Genre.description AS 'Genre'
FROM Popular_Content_And_Genres
JOIN Content ON Popular_Content_And_Genres.content = Content.contentID
JOIN Genre ON Popular_Content_And_Genres.genre = Genre.genreID;
