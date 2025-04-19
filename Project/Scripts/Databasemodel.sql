DROP DATABASE IF EXISTS MultimediaContentDB;
CREATE DATABASE IF NOT EXISTS MultimediaContentDB;

USE MultimediaContentDB;

-- Genre TABLE
DROP TABLE IF EXISTS Genre;
CREATE TABLE IF NOT EXISTS Genre
(
    genreID INT PRIMARY KEY,
    description VARCHAR(255) NOT NULL UNIQUE
);

-- Content_Format TABLE
DROP TABLE IF EXISTS Content_Format;
CREATE TABLE IF NOT EXISTS Content_Format
(
    content_formatID INT PRIMARY KEY,
    description VARCHAR(255) NOT NULL UNIQUE
);

-- Director TABLE
DROP TABLE IF EXISTS Director;
CREATE TABLE IF NOT EXISTS Director
(
    directorID INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

-- Actor TABLE
DROP TABLE IF EXISTS Actor;
CREATE TABLE IF NOT EXISTS Actor
(
    actorID INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);


-- Content_Accessibility TABLE
DROP TABLE IF EXISTS Content_Accessibility;
CREATE TABLE IF NOT EXISTS Content_Accessibility
(
    content_accessibilityID INT PRIMARY KEY,
    description VARCHAR(255) NOT NULL
);


-- Tag TABLE
DROP TABLE IF EXISTS Tag;
CREATE TABLE IF NOT EXISTS Tag
(
    tagID INT PRIMARY KEY,
    description VARCHAR(255) NOT NULL
);

-- Country TABLE
DROP TABLE IF EXISTS Country;
CREATE TABLE IF NOT EXISTS Country
(
    countryID INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);


-- Subscription_Plan TABLE
DROP TABLE IF EXISTS Subscription_Plan;
CREATE TABLE IF NOT EXISTS Subscription_Plan
(
    subscription_planID TINYINT PRIMARY KEY,
    price DECIMAL (8,2) NOT NULL,
    description VARCHAR(255) NOT NULL
);

-- User TABLE
DROP TABLE IF EXISTS User;
CREATE TABLE IF NOT EXISTS User
(
    userID INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL
);

-- Rating TABLE (PG and Rated R way)
DROP TABLE IF EXISTS Rating;
CREATE TABLE IF NOT EXISTS Rating
(
    ratingID TINYINT PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE
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
    title VARCHAR(255) NOT NULL,
    description VARCHAR(255) NOT NULL,
    duration INT NOT NULL, -- Store duration in number of minutes.
    CONSTRAINT fk_content_genre
        FOREIGN KEY (genre) REFERENCES Genre(genreID)
        ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT fk_content_format
        FOREIGN KEY (format) REFERENCES Content_Format(content_formatID)
        ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT fk_content_rating
        FOREIGN KEY (rating) REFERENCES Rating(ratingID)
        ON DELETE SET NULL ON UPDATE CASCADE
);



-- Review TABLE
DROP TABLE IF EXISTS Review;
CREATE TABLE IF NOT EXISTS Review
(
    user INT NOT NULL, -- FK
    content INT NOT NULL, -- FK
    PRIMARY KEY (user, content),
    review_text VARCHAR(500) NOT NULL,
    review_date DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    -- All review content should be reviewed before live on the site.
    -- I learned this standard from my CSC_648 Project.
    approval_status ENUM('pending', 'approved', 'rejected') NOT NULL DEFAULT 'pending',
    CONSTRAINT fk_review_user
        FOREIGN KEY (user) REFERENCES User(userID)
        ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT fk_review_content
        FOREIGN KEY (content) REFERENCES Content(contentID)
        ON DELETE SET NULL ON UPDATE CASCADE
);

-- ASK JOSE (Should watch history be updated or should their be a new row for each watch?)
# -- Content_WatchHistory TABLE
# DROP TABLE IF EXISTS Content_WatchHistory;
# CREATE TABLE IF NOT EXISTS Content_WatchHistory
# (
#     watch_historyID INT PRIMARY KEY,
#     user INT NOT NULL, -- FK
#     content INT NOT NULL, -- FK
#     watchedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
#     CONSTRAINT fk_watchHistory_user
#         FOREIGN KEY (user) REFERENCES User(userID)
#         ON DELETE CASCADE ON UPDATE CASCADE,
#     CONSTRAINT fk_watchHistory_content
#         FOREIGN KEY (content) REFERENCES Content(contentID)
#         ON DELETE SET NULL ON UPDATE CASCADE
# );

-- ASK JOSE (Does this table need to account for encryption or keep it simple?)
-- Payment_Method TABLE
DROP TABLE IF EXISTS Payment_Method;
CREATE TABLE IF NOT EXISTS Payment_Method
(
    payment_methodID INT PRIMARY KEY,
    user INT NOT NULL, -- FK
    card_details INT(16) NOT NULL,
    CONSTRAINT fk_paymentMethod_user
        FOREIGN KEY (user) REFERENCES User(userID)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- Transaction TABLE
DROP TABLE IF EXISTS Transaction;
CREATE TABLE IF NOT EXISTS Transaction
(
    transactionID INT PRIMARY KEY,
    payment_method INT NOT NULL, -- FK
    transaction_date DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT fk_transaction_paymentMethod
        FOREIGN KEY (payment_method) REFERENCES Payment_Method(payment_methodID)
        ON DELETE SET NULL ON UPDATE CASCADE
);


-- Playlist TABLE
-- Think I should make the updatedAt connect to PlaylistContent
DROP TABLE IF EXISTS Playlist;
CREATE TABLE IF NOT EXISTS Playlist
(
    playlistID INT PRIMARY KEY,
    user INT NOT NULL, -- FK
    title VARCHAR(255) NOT NULL,
    createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
    updatedAt DATETIME NOT NULL,
    CONSTRAINT fk_playlist_user
        FOREIGN KEY (user) REFERENCES User(userID)
        ON DELETE CASCADE ON UPDATE CASCADE
);

/*
    Content should be unique to each Playlist.
    So no playlist should have the same content within it more than once.
 */

-- PlaylistContent TABLE
DROP TABLE IF EXISTS PlaylistContent;
CREATE TABLE IF NOT EXISTS PlaylistContent
(
    playlist INT NOT NULL PRIMARY KEY, -- FK
    content INT NOT NULL PRIMARY KEY, -- FK
    updatedAt DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (playlist, content),
    CONSTRAINT fk_playlistContent_playlist
        FOREIGN KEY (playlist) REFERENCES Playlist(playlistID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_playlistContent_content
        FOREIGN KEY (content) REFERENCES Content(contentID)
        ON DELETE CASCADE ON UPDATE CASCADE
);


/*
    Watchlist should be unique to each user.
    So no user should have the same content in their watchlist more than once.
 */

-- Watchlist TABLE
DROP TABLE IF EXISTS Watchlist;
CREATE TABLE IF NOT EXISTS Watchlist
(
    user INT NOT NULL, -- PK/FK
    content INT NOT NULL, -- PK/FK
    addedAt DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (user, content),
    CONSTRAINT fk_watchlist_user
        FOREIGN KEY (user) REFERENCES User(userID)
        -- After User is deleted the Watchlist is meaningless since it's made for the user.
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_watchlist_content
        FOREIGN KEY (content) REFERENCES Content(contentID)
        -- After Content is deleted it's meaningless to be on the watchlist.
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- Content_Release TABLE
DROP TABLE IF EXISTS Content_Release;
CREATE TABLE IF NOT EXISTS Content_Release(
    content INT NOT NULL PRIMARY KEY, -- PK/FK
    release_date DATE NOT NULL,
    CONSTRAINT fk_contentRelease_content
        FOREIGN KEY (content) REFERENCES Content(contentID)
        -- After Content is deleted, it's release date is meaningless.
        ON DELETE CASCADE ON UPDATE CASCADE
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
    actor INT NOT NULL, -- PK/FK
    content INT NOT NULL, -- PK/FK
    PRIMARY KEY (actor, content),
    CONSTRAINT fk_contentActors_actor
        FOREIGN KEY (actor) REFERENCES Actor(actorID)
        -- After actor is deleted the content shouldn't be linked to the actor.
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_contentActors_content
        FOREIGN KEY (content) REFERENCES Content(contentID)
        -- After Content is deleted the actors shouldn't be linked to the content.
        ON DELETE CASCADE ON UPDATE CASCADE
);


/*
    PK/FK since a director shouldn't be linked to the
    same content more than once.
 */
-- ContentDirectors TABLE
DROP TABLE IF EXISTS ContentDirectors;
CREATE TABLE IF NOT EXISTS ContentDirectors
(
    director INT NOT NULL, -- PK/FK
    content INT NOT NULL, -- PK/FK
    PRIMARY KEY (director, content),
    CONSTRAINT fk_contentDirectors_actor
        FOREIGN KEY (director) REFERENCES Director(directorID)
            -- After director is deleted the content shouldn't be linked to the actor.
            ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_contentDirectors_content
        FOREIGN KEY (content) REFERENCES Content(contentID)
            -- After Content is deleted the directors shouldn't be linked to the content.
            ON DELETE CASCADE ON UPDATE CASCADE
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
        FOREIGN KEY (content) REFERENCES Content(contentID)
        -- After content is deleted the content shouldn't be linked to any tag.
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_contentTags_tag
        FOREIGN KEY (tag) REFERENCES Tag(tagID)
        -- After tag is deleted the tag shouldn't be linked to any content.
        ON DELETE CASCADE ON UPDATE CASCADE
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
        FOREIGN KEY (genre) REFERENCES Genre(genreID)
        -- After genre is deleted the genre shouldn't be linked to any tag.
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_genreTags_tag
        FOREIGN KEY (tag) REFERENCES Tag(tagID)
        -- After tag is deleted the tag shouldn't be linked to any genre.
        ON DELETE CASCADE ON UPDATE CASCADE
);

/*
 I allow users to have multiple subscriptions because they
 should have the option to upgrade/downgrade their plan.
 */

-- User_Subscription TABLE
DROP TABLE IF EXISTS User_Subscription;
CREATE TABLE IF NOT EXISTS User_Subscription
(
    user INT NOT NULL, -- FK
    subscription TINYINT NOT NULL, -- FK
    CONSTRAINT fk_userSubscription_user
        FOREIGN KEY (user) REFERENCES User(userID)
        -- After user is deleted the user shouldn't be linked to any subscription.
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_userSubscription_subscription
        FOREIGN KEY (subscription) REFERENCES Subscription_Plan(subscription_planID)
        -- After a subscription_plan is deleted the plan shouldn't be linked to any users.
        ON DELETE CASCADE ON UPDATE CASCADE
);



-- Content_Availability TABLE
-- Ask JOSE.
DROP TABLE IF EXISTS Content_Availability;
CREATE TABLE IF NOT EXISTS Content_Availability
(
    country INT NOT NULL, -- PK/FK
    content INT NOT NULL, -- PK/FK
    availability_status ENUM('pending', 'approved', 'rejected') NOT NULL DEFAULT 'pending',
    PRIMARY KEY (country, content),
    CONSTRAINT fk_contentAvailability_country
        FOREIGN KEY (country) REFERENCES Country(countryID)
        -- After director is deleted the content shouldn't be linked to the actor.
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_contentAvailability_content
        FOREIGN KEY (content) REFERENCES Content(contentID)
        -- After Content is deleted the directors shouldn't be linked to the content.
        ON DELETE CASCADE ON UPDATE CASCADE
);


#   TO DO LIST:
/*
    Watch_History
    Payment_Method

    ---------------
    AE:
    Content_Availability
    ContentAccessibilities
 */