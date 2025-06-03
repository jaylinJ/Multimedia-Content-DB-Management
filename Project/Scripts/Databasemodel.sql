/*
FILE: Databasemodel.sql
DESCRIPTION: The statements in this file are needed to build Tables for the entire Project.
COLLABORATORS: Jaylin Jack
*/

DROP DATABASE IF EXISTS MultimediaContentDB;
CREATE DATABASE IF NOT EXISTS MultimediaContentDB;

USE MultimediaContentDB;

-- Genre TABLE
DROP TABLE IF EXISTS Genre;
CREATE TABLE IF NOT EXISTS Genre
(
    genreID INT PRIMARY KEY AUTO_INCREMENT,
    description VARCHAR(255) NOT NULL UNIQUE
);

-- Content_Format TABLE
DROP TABLE IF EXISTS Content_Format;
CREATE TABLE IF NOT EXISTS Content_Format
(
    content_formatID INT PRIMARY KEY AUTO_INCREMENT,
    description VARCHAR(255) NOT NULL UNIQUE
);

-- Director TABLE
DROP TABLE IF EXISTS Director;
CREATE TABLE IF NOT EXISTS Director
(
    directorID INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL UNIQUE
);


-- Actor TABLE
DROP TABLE IF EXISTS Actor;
CREATE TABLE IF NOT EXISTS Actor
(
    actorID INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL UNIQUE
);

-- Release TABLE
DROP TABLE IF EXISTS `Release`;
CREATE TABLE IF NOT EXISTS `Release`
(
    releaseID INT PRIMARY KEY AUTO_INCREMENT,
    release_date DATE NOT NULL,
    version INT
);


-- Accessibility TABLE
DROP TABLE IF EXISTS Accessibility;
CREATE TABLE IF NOT EXISTS Accessibility
(
    accessibilityID INT PRIMARY KEY AUTO_INCREMENT,
    description VARCHAR(255) NOT NULL
);


-- Tag TABLE
DROP TABLE IF EXISTS Tag;
CREATE TABLE IF NOT EXISTS Tag
(
    tagID INT PRIMARY KEY AUTO_INCREMENT,
    description VARCHAR(255) NOT NULL UNIQUE
);

-- Country TABLE
DROP TABLE IF EXISTS Country;
CREATE TABLE IF NOT EXISTS Country
(
    countryID INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL UNIQUE
);


-- Subscription_Plan TABLE
DROP TABLE IF EXISTS Subscription_Plan;
CREATE TABLE IF NOT EXISTS Subscription_Plan
(
    subscription_planID TINYINT PRIMARY KEY AUTO_INCREMENT,
    price DECIMAL (8,2) NOT NULL,
    description VARCHAR(255) NOT NULL
);

-- User TABLE
DROP TABLE IF EXISTS User;
CREATE TABLE IF NOT EXISTS User
(
    userID INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL
);

-- Rating TABLE (PG and Rated R way)
DROP TABLE IF EXISTS Rating;
CREATE TABLE IF NOT EXISTS Rating
(
    ratingID TINYINT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL UNIQUE
);

/*
 ALL TABLES UNDER CONTAIN FKs.
 */

-- Content TABLE
DROP TABLE IF EXISTS Content;
CREATE TABLE IF NOT EXISTS Content
(
    contentID INT PRIMARY KEY,
    genre INT NOT NULL, -- FK
    format INT NOT NULL, -- FK
    rating TINYINT NOT NULL, -- FK
    director INT, -- FK
    title VARCHAR(255) NOT NULL,
    description VARCHAR(500) NOT NULL,
    duration VARCHAR(20) NOT NULL,
    release_year INT NOT NULL,
    CONSTRAINT fk_content_genre
        FOREIGN KEY (genre) REFERENCES Genre(genreID),
    CONSTRAINT fk_content_format
        FOREIGN KEY (format) REFERENCES Content_Format(content_formatID),
    CONSTRAINT fk_content_rating
        FOREIGN KEY (rating) REFERENCES Rating(ratingID),
    CONSTRAINT fk_content_director
        FOREIGN KEY (director) REFERENCES Director(directorID)
);



-- Review TABLE
DROP TABLE IF EXISTS Review;
CREATE TABLE IF NOT EXISTS Review
(
    user INT NOT NULL, -- FK
    content INT NOT NULL, -- FK
    PRIMARY KEY (user, content),
    rating_value INT NOT NULL,
    review_text VARCHAR(500) NOT NULL,
    review_date DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    -- All review content should be reviewed before live on the site.
    -- I learned this standard from my CSC_648 Project.
    approval_status ENUM('pending', 'approved', 'rejected') NOT NULL DEFAULT 'pending',
    CONSTRAINT CHECK_rating_check CHECK ( rating_value >= 1 AND rating_value <= 10),
    CONSTRAINT fk_review_user
        FOREIGN KEY (user) REFERENCES User(userID),
    CONSTRAINT fk_review_content
        FOREIGN KEY (content) REFERENCES Content(contentID)
);

-- ASK JOSE (Does this table need to account for encryption or keep it simple?)
-- Payment_Method TABLE
DROP TABLE IF EXISTS Payment_Method;
CREATE TABLE IF NOT EXISTS Payment_Method
(
    payment_methodID INT PRIMARY KEY AUTO_INCREMENT,
    user INT NOT NULL, -- FK
    card_details INT(4) NOT NULL,
    CONSTRAINT fk_paymentMethod_user
        FOREIGN KEY (user) REFERENCES User(userID)
);

-- Transaction TABLE
DROP TABLE IF EXISTS Transaction;
CREATE TABLE IF NOT EXISTS Transaction
(
    transactionID INT PRIMARY KEY AUTO_INCREMENT,
    payment_method INT NOT NULL, -- FK
    subscription TINYINT NOT NULL, -- FK
    transaction_date DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    status ENUM('successful', 'failed') NOT NULL,
    CONSTRAINT fk_transaction_paymentMethod
        FOREIGN KEY (payment_method) REFERENCES Payment_Method(payment_methodID),
    CONSTRAINT fk_transaction_subscription
        FOREIGN KEY (subscription) REFERENCES Subscription_Plan(subscription_planID)
);

-- Payment_Errors TABLE
DROP TABLE IF EXISTS Payment_Errors;
CREATE TABLE IF NOT EXISTS Payment_Errors
(
    payment_errorsID INT PRIMARY KEY AUTO_INCREMENT,
    payment_method INT NOT NULL, -- FK
    createdAt DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT fk_paymentErrors_paymentMethod
        FOREIGN KEY (payment_method) REFERENCES Payment_Method(payment_methodID)
);

-- Playlist TABLE
-- Think I should make the updatedAt connect to PlaylistContent
DROP TABLE IF EXISTS Playlist;
CREATE TABLE IF NOT EXISTS Playlist
(
    playlistID INT PRIMARY KEY AUTO_INCREMENT,
    user INT NOT NULL, -- FK
    title VARCHAR(255) NOT NULL,
    createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
    updatedAt DATETIME NOT NULL,
    CONSTRAINT fk_playlist_user
        FOREIGN KEY (user) REFERENCES User(userID)
);

/*
    Content should be unique to each Playlist.
    So no playlist should have the same content within it more than once.
 */

-- PlaylistContent TABLE
DROP TABLE IF EXISTS PlaylistContent;
CREATE TABLE IF NOT EXISTS PlaylistContent
(
    playlist INT NOT NULL, -- PK/FK
    content INT NOT NULL, -- PK/FK
    updatedAt DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (playlist, content),
    CONSTRAINT fk_playlistContent_playlist
        FOREIGN KEY (playlist) REFERENCES Playlist(playlistID),
    CONSTRAINT fk_playlistContent_content
        FOREIGN KEY (content) REFERENCES Content(contentID)
);


/*
    Watchlist should be unique to each user.
    So no user should have the same content in their watchlist more than once.
 */

-- Watchlist TABLE
DROP TABLE IF EXISTS Watchlist;
CREATE TABLE IF NOT EXISTS Watchlist
(
    watchlistID INT PRIMARY KEY AUTO_INCREMENT,
    user INT NOT NULL, -- FK
    content INT NOT NULL, -- FK
    addedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
    status ENUM('available', 'TO DELETE') NOT NULL DEFAULT 'available',
    CONSTRAINT fk_watchlist_user
        FOREIGN KEY (user) REFERENCES User(userID),
        -- After User is deleted the Watchlist is meaningless since it's made for the user.
    CONSTRAINT fk_watchlist_content
        FOREIGN KEY (content) REFERENCES Content(contentID)
        -- After Content is deleted it's meaningless to be on the watchlist.
);

-- Content_Release TABLE
DROP TABLE IF EXISTS Content_Release;
CREATE TABLE IF NOT EXISTS Content_Release(
    content_releaseID INT PRIMARY KEY AUTO_INCREMENT,
    content INT NOT NULL, -- FK
    `release` INT NOT NULL,
    CONSTRAINT fk_contentRelease_content
        FOREIGN KEY (content) REFERENCES Content(contentID),
    CONSTRAINT fk_contentRelease_release
        FOREIGN KEY (`release`) REFERENCES `Release`(releaseID)

);


/*
-----    All Tables Below Are Associative Entities.     -----
*/



/*
    PK/FK since an actor shouldn't be linked to the
    same content more than once.
 */
-- ContentActors TABLE
DROP TABLE IF EXISTS ContentActors;
CREATE TABLE IF NOT EXISTS ContentActors
(
    content INT NOT NULL, -- PK/FK
    actor INT NOT NULL, -- PK/FK
    PRIMARY KEY (content, actor),
    CONSTRAINT fk_contentActors_content
        FOREIGN KEY (content) REFERENCES Content(contentID),
    CONSTRAINT fk_contentActors_actor
        FOREIGN KEY (actor) REFERENCES Actor(actorID)
);

/*
    PK/FK since a tag shouldn't be linked to the
    same content more than once.
 */
-- ContentTags TABLE
DROP TABLE IF EXISTS ContentTags;
CREATE TABLE IF NOT EXISTS ContentTags
(
    content INT NOT NULL, -- PK/FK
    tag INT NOT NULL, -- PK/FK
    PRIMARY KEY (content, tag),
    CONSTRAINT fk_contentTags_content
        FOREIGN KEY (content) REFERENCES Content(contentID),
    CONSTRAINT fk_contentTags_tag
        FOREIGN KEY (tag) REFERENCES Tag(tagID)
);



/*
    PK/FK since a tag shouldn't be linked to the
    same genre more than once.
 */
-- GenreTags TABLE
DROP TABLE IF EXISTS GenreTags;
CREATE TABLE IF NOT EXISTS GenreTags
(
    genre INT NOT NULL, -- PK/FK
    tag INT NOT NULL, -- PK/FK
    PRIMARY KEY (genre, tag),
    CONSTRAINT fk_genreTags_genre
        FOREIGN KEY (genre) REFERENCES Genre(genreID),
    CONSTRAINT fk_genreTags_tag
        FOREIGN KEY (tag) REFERENCES Tag(tagID)
);


-- User_Subscription TABLE
DROP TABLE IF EXISTS User_Subscription;
CREATE TABLE IF NOT EXISTS User_Subscription
(
    user INT NOT NULL, -- FK
    subscription TINYINT NOT NULL, -- FK
    status ENUM('active', 'expired') NOT NULL DEFAULT 'active',
    PRIMARY KEY (user, subscription),
    CONSTRAINT fk_userSubscription_user
        FOREIGN KEY (user) REFERENCES User(userID),
    CONSTRAINT fk_userSubscription_subscription
        FOREIGN KEY (subscription) REFERENCES Subscription_Plan(subscription_planID)
);



-- Content_Availability TABLE
DROP TABLE IF EXISTS Content_Availability;
CREATE TABLE IF NOT EXISTS Content_Availability
(
    content_availabilityID INT PRIMARY KEY AUTO_INCREMENT,
    content INT NOT NULL, -- PK/FK
    availability ENUM('available', 'archived', 'unavailable', 'AT RISK'),
    CONSTRAINT fk_contentAvailability_content
        FOREIGN KEY (content) REFERENCES Content(contentID)
);

DROP TABLE IF EXISTS Watch_History;
CREATE TABLE IF NOT EXISTS Watch_History(
    watch_historyID INT PRIMARY KEY AUTO_INCREMENT,
    user INT NOT NULL, -- FK
    content INT NOT NULL, -- FK
    watch_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_watchHistory_user
        FOREIGN KEY (user) REFERENCES User(userID),
    CONSTRAINT fk_watchHistory_content
        FOREIGN KEY (content) REFERENCES Content(contentID)
);

DROP TABLE IF EXISTS ContentDirectors;
CREATE TABLE IF NOT EXISTS ContentDirectors
(
    content_directorsID INT PRIMARY KEY AUTO_INCREMENT,
    content INT NOT NULL, -- FK
    director INT NOT NULL, -- FK
    CONSTRAINT fk_contentDirectors_content
        FOREIGN KEY (content) REFERENCES Content(contentID),
    CONSTRAINT fk_contentDirectors_director
        FOREIGN KEY (director) REFERENCES Director(directorID)
);

DROP TABLE IF EXISTS ContentCountry;
CREATE TABLE IF NOT EXISTS ContentCountry
(
    content_country INT PRIMARY KEY AUTO_INCREMENT,
    content INT NOT NULL, -- FK
    country INT NOT NULL, -- FK
    CONSTRAINT fk_contentCountry_content
        FOREIGN KEY (content) REFERENCES Content(contentID),
    CONSTRAINT fk_contentCountry_country
        FOREIGN KEY (country) REFERENCES Country(countryID)
);

-- 3. Ensure Unique Director for Content
-- Log any failed attempts to assign a duplicate director into a Director_Assignment_Errors table.
DROP TABLE IF EXISTS Director_Assignment_Errors;
CREATE TABLE IF NOT EXISTS Director_Assignment_Errors(
    director_assignment_errorID INT PRIMARY KEY AUTO_INCREMENT,
    director INT NOT NULL , -- FK
    content INT NOT NULL , -- FK
    createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_directorAssignmentErrors_content
        FOREIGN KEY (content) REFERENCES Content(contentID),
    CONSTRAINT fk_directorAssignmentErrors_director
        FOREIGN KEY (director) REFERENCES Director(directorID)
);

DROP TABLE IF EXISTS WatchlistDeleteHelper;
CREATE TABLE IF NOT EXISTS WatchlistDeleteHelper(
    watchlist_delete_helperID INT

);
