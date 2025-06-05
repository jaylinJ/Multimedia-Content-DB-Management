/*
File: ReadData.java
Description: Java file used to properly parse data and populate DB tables.
TABLES POPULATED WITH THIS FILE:
Content, Director, Country, Actors, Release, Tags, ContentTags, GenreTags
ContentActors, ContentCountry, Content_Availability, Content_Release, Rating

Collaborators: Jaylin Jack
 */
import java.io.*;
import java.sql.*;
import java.util.*;


/*
WORK CITED:
1. https://www.geeksforgeeks.org/how-to-get-the-insert-id-in-jdbc/
2. https://www.geeksforgeeks.org/how-to-use-preparedstatement-in-java/
*/

public class ReadData {

    // The number corresponding to each column in the CSV file to the DB Table name
    public static final int contentID = 0;
    public static final int contentFormat = 1;
    public static final int title = 2;
    public static final int director = 3;
    public static final int cast = 4;
    public static final int country = 5;
    public static final int dateAdded = 6;
    public static final int releaseYear = 7;
    public static final int rating = 8;
    public static final int duration = 9;
    public static final int genre = 10;
    public static final int contentDescription = 11;

    // This function gets the number value for each month.
    //  -> Useful for putting the date into SQL DATE format.
    public static String getMonth(String month) {
        month = month.trim();
        switch (month) {
            case "January":
                return "01";
            case "February":
                return "02";
            case "March":
                return "03";
            case "April":
                return "04";
            case "May":
                return "05";
            case "June":
                return "06";
            case "July":
                return "07";
            case "August":
                return "08";
            case "September":
                return "09";
            case "October":
                return "10";
            case "November":
                return "11";
            case "December":
                return "12";
            default:

        }


        return "Not a month";
    }

    // Formats any date in Month Day, Year format into SQL Date format.
    public static String getDateFormatted(String date){
        // date will be a toString, so it will have []. So remove them
        date = date.substring(1, date.length() - 1);

        int length = date.length();
        // Extract Year from release_date in CSV. & Remove the Year & ', ' from date
        String year = date.substring(length - 5, length);
        date = date.substring(0, length - 6);


        length = date.length();
        // Extract Day from release_date in CSV.
        String day = date.substring(length - 2, length);


        // This means the day is only 1 digit
        if (day.contains(" ")){
            day = "0" + day.substring(1);
            date = date.substring(0, length - 2);
        }else{
            date = date.substring(0, length - 3);
        }

        // GET the number for the month.
        String month = getMonth(date);



        return year + "-" + month + "-" + day;

    }



    // Remove the 's' from all ID's for a clean INSERT.
    public static String truncateID(String str){
        str = str.substring(1);
        return str;
    }



    // Get all csv values depending on the columns.
    public static String getEntireLine(List<String> l1){
        String cleanedWord = "";
        for (int i = 0; i < l1.size() ; i++){
            // Add the csv back to the previous csv value
            if (i == l1.size() - 1){
                cleanedWord = cleanedWord.concat(l1.get(i));
            }else{
                // Include the ',' back into the sentence since we are not at the end of the sentence.
                cleanedWord = cleanedWord.concat(l1.get(i) + ",");
            }

        }
        return trimQuotes(cleanedWord);
    }

    // Function to trim the Quotes off csv values.
    public static String trimQuotes(String str){

        if (str.length() < 2){
            return str;
        }

        if (str.startsWith("\"") && str.endsWith("\"")){
            str = str.substring(1, str.length() - 1);
        }else if (str.startsWith("\"")){
            str = str.substring(1);
        }else if(str.endsWith("\"")){
            str = str.substring(0, str.length() - 1);
        }

        return str;
    }

    public static void columnSwitch(int caseNum,List<String> contentRow, List<String> l1, String value){
        switch (caseNum) {


            case contentFormat:
            case title:
            case duration:
            case releaseYear:
            case contentDescription:
            case rating:
                // IN all these cases just simply add the last value and clean the line into the contentRow.
                l1.add(value);
                contentRow.add(getEntireLine(l1));
                break;
            case director:
                // Assign director value 1 "Multiple Directors" value.
                contentRow.add("1");
            case cast:
            case genre:
                l1.add(value);
                break;
            case country:
                break;
            case dateAdded:
                value = value.substring(1);
                l1.add(value);
                break;
            default:
        }

    }

    // Assigns the genre depending on Content ID.
    // Content is given a random Genre.
    public static String randomGenre(String content_id){
        int id = Integer.parseInt(content_id);
        int genre = (id % 9) + 1;
        return (String.valueOf(genre));
    }

    /*
        BELOW are my functions that checks if the value exists in the associated table already.
        The reason for me creating Hashmaps that hold the values
        of each Primary Key value with the associated name/description was to lessen the amount of queries.
        Plus I like to have the values accessible in my java file to check.

        1. Check if HashMap already contains the value, if so return the ID associated with it.
        2. If value doesn't access then check to make sure the value doesn't exist in the DB already as well.
            2A. If it does then get the ID returned from SELECT and place in the HashMap and exit.
        3. If value doesn't exist in either then INSERT it into the Table.

    */

    public static int getContentFormatID_or_INSERT(HashMap<String, Integer> content_format_map, String formatDescription, Connection conn){

        // 1.
        if (content_format_map.containsKey(formatDescription)){
            return content_format_map.get(formatDescription);
        }


        String insertQuery = "INSERT INTO Content_Format (description) VALUES (?)";


        String checkQuery = "SELECT content_formatID FROM Content_Format WHERE description = ?";

        try (PreparedStatement findContentFormat = conn.prepareStatement(checkQuery)) {

            // 2.
            findContentFormat.setString(1, formatDescription);


            try (ResultSet result = findContentFormat.executeQuery()){

                if(!result.next()) {
                    try (PreparedStatement insertContentFormat = conn.prepareStatement(insertQuery, Statement.RETURN_GENERATED_KEYS)) {
                        // 3.
                        insertContentFormat.setString(1, formatDescription);
                        int rowsAffected = insertContentFormat.executeUpdate();

                        if (rowsAffected > 0) {
                            // Retrieve the auto-generated keys (insert ID)
                            ResultSet generatedKeys = insertContentFormat.getGeneratedKeys();
                            if (generatedKeys.next()) {
                                int content_formatID = generatedKeys.getInt(1);
                                return content_formatID;
                            }
                        }
                    }
                }else{
                    // 2A.
                    int content_formatID = result.getInt("content_formatID");
                    content_format_map.put(formatDescription, content_formatID);

                    return content_formatID;
                }
            }
        } catch(SQLException e) {
            e.printStackTrace();
        }


        return -1;

    }

    public static int getRatingID_or_INSERT(HashMap<String, Integer> rating_map, String ratingDescription, Connection conn) {

        // 1.
        if (rating_map.containsKey(ratingDescription)) {
            return rating_map.get(ratingDescription);
        }


        String insertQuery = "INSERT INTO Rating (name) VALUES (?)";


        String checkQuery = "SELECT ratingID FROM Rating WHERE name = ?";

        try (PreparedStatement findRating = conn.prepareStatement(checkQuery)) {

            // 2.
            findRating.setString(1, ratingDescription);


            try (ResultSet result = findRating.executeQuery()) {


                if (!result.next()) {
                    try (PreparedStatement insertRating = conn.prepareStatement(insertQuery, Statement.RETURN_GENERATED_KEYS)) {
                        // 3.
                        insertRating.setString(1, ratingDescription);

                        int rowsAffected = insertRating.executeUpdate();

                        if (rowsAffected > 0) {
                            // Retrieve the auto-generated keys (insert ID)
                            ResultSet generatedKeys = insertRating.getGeneratedKeys();
                            if (generatedKeys.next()) {
                                int ratingID = generatedKeys.getInt(1);
                                rating_map.put(ratingDescription, ratingID);

                                return ratingID;
                            }
                        }
                    }
                } else {
                    // 2A.
                    int ratingID = result.getInt(1);
                    rating_map.put(ratingDescription, ratingID);

                    return ratingID;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }


        return -1;

    }

    public static int getDirectorID_or_INSERT(HashMap<String, Integer> director_map, String directorName, Connection conn) {


        // 1.
        if (director_map.containsKey(directorName)) {
            return director_map.get(directorName);
        }



        String insertQuery = "INSERT INTO Director (name) VALUES (?)";


        String checkQuery = "SELECT directorID FROM Director WHERE name = ?";

        try (PreparedStatement findDirector = conn.prepareStatement(checkQuery)) {
            // 2.
            findDirector.setString(1, directorName);


            try (ResultSet result = findDirector.executeQuery()) {

                if (!result.next()) {
                    try (PreparedStatement insertDirector = conn.prepareStatement(insertQuery, Statement.RETURN_GENERATED_KEYS)) {
                        // 3.
                        insertDirector.setString(1, directorName);

                        int rowsAffected = insertDirector.executeUpdate();

                        if (rowsAffected > 0) {

                            ResultSet generatedKeys = insertDirector.getGeneratedKeys();
                            if (generatedKeys.next()) {
                                int directorID = generatedKeys.getInt(1);
                                director_map.put(directorName, directorID);
                                return directorID;
                            }
                        }
                    }
                } else {
                    // 2A.
                    int directorID = result.getInt("directorID");
                    director_map.put(directorName, directorID);


                    return directorID;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }


        return -1;

    }

    public static int getActorID_or_INSERT(HashMap<String, Integer> map, String name, Connection conn) {


        // 1.
        if (map.containsKey(name)) {
            return map.get(name);
        }



        String insertQuery = "INSERT INTO Actor (name) VALUES (?)";


        String checkQuery = "SELECT ActorID FROM Actor WHERE name = ?";

        try (PreparedStatement findActor = conn.prepareStatement(checkQuery)) {

            // 2.
            findActor.setString(1, name);

            try (ResultSet result = findActor.executeQuery()) {

                if (!result.next()) {
                    try (PreparedStatement insertActor = conn.prepareStatement(insertQuery, Statement.RETURN_GENERATED_KEYS)) {
                        // 3.
                        insertActor.setString(1, name);

                        int rowsAffected = insertActor.executeUpdate();

                        if (rowsAffected > 0) {

                            ResultSet generatedKeys = insertActor.getGeneratedKeys();
                            if (generatedKeys.next()) {
                                int actorID = generatedKeys.getInt(1);
                                map.put(name, actorID);
                                return actorID;
                            }
                        }
                    }
                } else {
                    // 2A.
                    int actorID = result.getInt(1);
                    map.put(name, actorID);
                    return actorID;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }


        return -1;

    }


    public static int getTagID_or_INSERT(HashMap<String, Integer> map, String name, Connection conn) {


        // 1.
        if (map.containsKey(name)) {
            return map.get(name);
        }


        String insertQuery = "INSERT INTO Tag (description) VALUES (?)";


        String checkQuery = "SELECT tagID FROM Tag WHERE description = ?";

        try (PreparedStatement findTag = conn.prepareStatement(checkQuery)) {

            // 2.
            findTag.setString(1, name);

            try (ResultSet result = findTag.executeQuery()) {

                if (!result.next()) {
                    try (PreparedStatement insertTag = conn.prepareStatement(insertQuery, Statement.RETURN_GENERATED_KEYS)) {
                        // 3.
                        insertTag.setString(1, name);

                        int rowsAffected = insertTag.executeUpdate();

                        if (rowsAffected > 0) {
                            ResultSet generatedKeys = insertTag.getGeneratedKeys();
                            if (generatedKeys.next()) {
                                int tagID = generatedKeys.getInt(1);

                                map.put(name, tagID);
                                return tagID;
                            }
                        }
                    }
                } else {
                    // 2A.
                    int tagID = result.getInt(1);
                    map.put(name, tagID);

                    return tagID;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }


        return -1;

    }

    public static int getRelease_or_INSERT(HashMap<String, Integer> map, String date, String version, Connection conn) {

        // 1.
        if (map.containsKey(date)) {
            return map.get(date);
        }


        String insertQuery = "INSERT INTO `Release` (release_date, version) VALUES (?, ?)";


        String checkQuery = "SELECT releaseID FROM `Release` WHERE release_date = ?";

        try (PreparedStatement findReleaseDate = conn.prepareStatement(checkQuery)) {

            // 2.
            findReleaseDate.setString(1, date);


            try (ResultSet result = findReleaseDate.executeQuery()) {

                if (!result.next()) {
                    try (PreparedStatement insertReleaseDate = conn.prepareStatement(insertQuery, Statement.RETURN_GENERATED_KEYS)) {
                        // 3.
                        insertReleaseDate.setString(1, date);
                        insertReleaseDate.setString(2, version);

                        int rowsAffected = insertReleaseDate.executeUpdate();

                        if (rowsAffected > 0) {
                            // Retrieve the auto-generated keys (insert ID)
                            ResultSet generatedKeys = insertReleaseDate.getGeneratedKeys();
                            if (generatedKeys.next()) {
                                int releaseID = generatedKeys.getInt(1);

                                map.put(date, releaseID);
                                return releaseID;
                            }
                        }
                    }
                } else {
                    // 2A.
                    int releaseID = result.getInt(1);
                    map.put(date, releaseID);

                    return releaseID;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }


        return -1;

    }



    public static int getCountryID_or_INSERT(HashMap<String, Integer> map, String name, Connection conn) {

        // 1.
        if (map.containsKey(name)) {
            return map.get(name);
        }


        String insertQuery = "INSERT INTO Country (name) VALUES (?)";


        String checkQuery = "SELECT countryID FROM Country WHERE name = ?";

        try (PreparedStatement findCountry = conn.prepareStatement(checkQuery)) {

            // 2.
            findCountry.setString(1, name);


            try (ResultSet result = findCountry.executeQuery()) {

                if (!result.next()) {
                    try (PreparedStatement insertCountry = conn.prepareStatement(insertQuery, Statement.RETURN_GENERATED_KEYS)) {
                        // 3.
                        insertCountry.setString(1, name);

                        int rowsAffected = insertCountry.executeUpdate();

                        if (rowsAffected > 0) {
                            // Retrieve the auto-generated keys (insert ID)
                            ResultSet generatedKeys = insertCountry.getGeneratedKeys();
                            if (generatedKeys.next()) {
                                int countryID = generatedKeys.getInt(1);
                                map.put(name, countryID);
                                return countryID;
                            }
                        }
                    }
                } else {
                    // 2A.
                    int countryID = result.getInt(1);
                    map.put(name, countryID);
                    return countryID;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }


        return -1;

    }

    /*
        BELOW are insert functions which simply SELECTS if the values exists before inserting.
        Once I figured out a way that worked for 1 Associative Entity, I did the same thing for every
        Associative Entity in the DB.
    */

    public static void insertContentActors(String contentID, int actorID, Connection conn){

        String insertQuery = "INSERT INTO ContentActors (content, actor) VALUES (?, ?)";

        String checkQuery = "SELECT 1 FROM ContentActors WHERE content = ? AND actor = ?";


        try (PreparedStatement findContentActor = conn.prepareStatement(checkQuery)) {

            // SELECT 1 FROM ContentActors Where content = contentID AND actor = actorID.
            findContentActor.setString(1, contentID);
            findContentActor.setInt(2, actorID);


            try (ResultSet result = findContentActor.executeQuery()) {

                // If no result is returned from SELECT then INSERT
                if (!result.next()) {
                    try (PreparedStatement insertContentActor = conn.prepareStatement(insertQuery)) {
                        // INSERT INTO ContentActors (content, actor) VALUES (contentID, actorID)
                        insertContentActor.setString(1, contentID);
                        insertContentActor.setInt(2, actorID);

                        int rowsAffected = insertContentActor.executeUpdate();
                        if (rowsAffected > 0) {
                            System.out.println("ContentActors inserted successfully");
                        }


                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }


    }

    public static void insertContentTags(String contentID, int tagID, Connection conn){

        String insertQuery = "INSERT INTO ContentTags (content, tag) VALUES (?, ?)";


        String checkQuery = "SELECT 1 FROM ContentTags WHERE content = ? AND tag = ?";



        try (PreparedStatement findContentTags = conn.prepareStatement(checkQuery)) {

            // SELECT 1 FROM ContentTags Where content = contentID AND tag = tagID;
            findContentTags.setString(1, contentID);
            findContentTags.setInt(2, tagID);


            try (ResultSet result = findContentTags.executeQuery()) {

                if (!result.next()) {
                    try (PreparedStatement insertContentTags = conn.prepareStatement(insertQuery)) {
                        // INSERT INTO ContentActors (content, actor) VALUES (contentID, tagID);
                        insertContentTags.setString(1, contentID);
                        insertContentTags.setInt(2, tagID);

                        int rowsAffected = insertContentTags.executeUpdate();
                        if (rowsAffected > 0) {
                            System.out.println("ContentTags inserted successfully");
                        }


                    }
                }
            }
        } catch (SQLException e) {

            e.printStackTrace();
        }


    }

    public static void insertGenreTags(String genreID, int tagID, Connection conn){

        String insertQuery = "INSERT INTO GenreTags (genre, tag) VALUES (?, ?)";


        String checkQuery = "SELECT 1 FROM GenreTags WHERE genre = ? AND tag = ?";



        try (PreparedStatement findGenreTags = conn.prepareStatement(checkQuery)) {

            // SELECT 1 FROM GenreTags Where genre = genreID AND tag = tagID;
            findGenreTags.setString(1, genreID);
            findGenreTags.setInt(2, tagID);

            try (ResultSet result = findGenreTags.executeQuery()) {

                if (!result.next()) {
                    try (PreparedStatement insertGenreTags = conn.prepareStatement(insertQuery)) {
                        // INSERT INTO GenreTags (genre, tags) VALUES (genreID, tagID);
                        insertGenreTags.setString(1, genreID);
                        insertGenreTags.setInt(2, tagID);

                        int rowsAffected = insertGenreTags.executeUpdate();
                        if (rowsAffected > 0) {
                            System.out.println("GenreTags inserted successfully");
                        }


                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }


    }

    public static void insertContent_Country(String contentID, int countryID, Connection conn){

        String insertQuery = "INSERT INTO ContentCountry (content, country) VALUES (?, ?)";


        String checkQuery = "SELECT 1 FROM ContentCountry WHERE content = ? AND country = ?";



        try (PreparedStatement findContentCountry = conn.prepareStatement(checkQuery)) {

            // SELECT 1 FROM ContentCountry Where content = contentID AND country = countryID;
            findContentCountry.setString(1, contentID);
            findContentCountry.setInt(2, countryID);

            try (ResultSet result = findContentCountry.executeQuery()) {

                if (!result.next()) {
                    try (PreparedStatement insertContentCountry = conn.prepareStatement(insertQuery)) {
                        // INSERT INTO ContentCountry (content, country) VALUES (contentID, countryID);
                        insertContentCountry.setString(1, contentID);
                        insertContentCountry.setInt(2, countryID);

                        int rowsAffected = insertContentCountry.executeUpdate();

                        if (rowsAffected > 0) {
                            System.out.println("ContentCountry inserted successfully");
                        }


                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }


    }

    // This function was implemented purely for 11. Refresh Popular Content Ranking
    // I needed a way of making sure a user has watched half of the content
    // This way I can have a top 10 for each genre.
    public static void insertWatch_History(String contentID, int userID, Connection conn){

        String insertQuery = "INSERT INTO Watch_History (content, user) VALUES (?, ?)";


        try (PreparedStatement insertWatchHistory = conn.prepareStatement(insertQuery)) {
            // INSERT INTO Watch_History (content, user) VALUES (contentID, userID);
            insertWatchHistory.setString(1, contentID);
            insertWatchHistory.setInt(2, userID);

            int rowsAffected = insertWatchHistory.executeUpdate();

            if (rowsAffected > 0) {
                System.out.println("WatchHistory inserted successfully");
            }


        } catch (SQLException e) {
            e.printStackTrace();
        }

    }

    public static void insertContent_Availability(String contentID, int availabilityID, Connection conn){

        String insertQuery = "INSERT INTO Content_Availability (content, availability) VALUES (?, ?)";


        String checkQuery = "SELECT 1 FROM Content_Availability WHERE content = ? AND availability = ?";



        try (PreparedStatement findContentAvailability = conn.prepareStatement(checkQuery)) {

            // SELECT 1 FROM Content_Availability Where content = contentID AND availability = 1;
            findContentAvailability.setString(1, contentID);
            findContentAvailability.setInt(2, availabilityID);

            try (ResultSet result = findContentAvailability.executeQuery()) {

                if (!result.next()) {
                    try (PreparedStatement insertContentAvailability = conn.prepareStatement(insertQuery)) {
                        // INSERT INTO ContentAvailability (content, availability) VALUES (contentID, 1);
                        insertContentAvailability.setString(1, contentID);
                        insertContentAvailability.setInt(2, availabilityID);

                        int rowsAffected = insertContentAvailability.executeUpdate();

                        if (rowsAffected > 0) {
                            System.out.println("Content_Availability inserted successfully");
                        }


                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }


    }

    public static void insertContent_Directors(String contentID, int directorID, Connection conn){

        String insertQuery = "INSERT INTO ContentDirectors (content, director) VALUES (?, ?)";


        String checkQuery = "SELECT 1 FROM ContentDirectors WHERE content = ? AND director = ?";



        try (PreparedStatement findContentAvailability = conn.prepareStatement(checkQuery)) {

            // SELECT 1 FROM Content_Availability Where content = contentID AND availability = 1;
            findContentAvailability.setString(1, contentID);
            findContentAvailability.setInt(2, directorID);

            try (ResultSet result = findContentAvailability.executeQuery()) {

                if (!result.next()) {
                    try (PreparedStatement insertContentAvailability = conn.prepareStatement(insertQuery)) {
                        // INSERT INTO ContentAvailability (content, availability) VALUES (contentID, 1);
                        insertContentAvailability.setString(1, contentID);
                        insertContentAvailability.setInt(2, directorID);

                        int rowsAffected = insertContentAvailability.executeUpdate();

                        if (rowsAffected > 0) {
                            System.out.println("Content_Directors inserted successfully");
                        }


                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }


    }

    public static void insertContent_Release(String contentID, int releaseID, Connection conn){
        String insertQuery = "INSERT INTO Content_Release (content, `release`) VALUES (?, ?)";

        String checkQuery = "SELECT 1 FROM Content_Release WHERE content = ? AND `release` = ?";



        try (PreparedStatement findContentRelease = conn.prepareStatement(checkQuery)) {

            // SELECT 1 FROM ContentRelease Where content = contentID AND `release` = releaseID;
            findContentRelease.setString(1, contentID);
            findContentRelease.setInt(2, releaseID);


            try (ResultSet result = findContentRelease.executeQuery()) {

                if (!result.next()) {
                    try (PreparedStatement insertContentRelease = conn.prepareStatement(insertQuery)) {
                        // INSERT INTO ContentRelease (content, `release`) VALUES (contentID, releaseID);
                        insertContentRelease.setString(1, contentID);
                        insertContentRelease.setInt(2, releaseID);

                        int rowsAffected = insertContentRelease.executeUpdate();

                        if (rowsAffected > 0) {
                            System.out.println("Content_Release inserted successfully");
                        }


                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }


    }

    /*
        insertContent is simple, Each attribute of Content has been inserted into a list and comes here to enter the DB.
        The list has already been ordered properly for INSERT execution.
        This list is then iterated element by element for each value of Content (id, format, title etc.)
    */

    public static void insertContent(List<String> l1, Connection conn){

        // INSERT Statement for each Content.
        String insertQuery =
                "INSERT INTO Content (contentID, format, title, director, release_year, rating, duration, genre, description) " +
                        "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";


        // SELECT Statement to check if Content exists before INSERT.
        String checkQuery = "SELECT contentID FROM Content WHERE " +
                "contentID = ? AND format = ? AND title = ? AND director = ? AND " +
                "release_year = ? AND rating = ? AND duration = ? AND genre = ? AND description = ?";

        int i = 0;

        try (PreparedStatement check = conn.prepareStatement(checkQuery)) {

            // SET the first element (ContentID) as contentID. then iterate the elements after.
            check.setString(1, l1.get(title).trim());
            for (int j = 0; j < l1.size(); j++){
                if (l1.get(i).equals("NULL")){
                    check.setNull(j + 1, java.sql.Types.INTEGER);
                }else {
                    check.setString(j + 1, l1.get(i));
                }
            }

            // If no result is returned from SELECT then INSERT
            try (ResultSet result = check.executeQuery()) {

                if (!result.next()) {
                    try (PreparedStatement insertContent = conn.prepareStatement(insertQuery)) {
                        // INSERT the content into the table.

                        while (i < l1.size()) {
                            if (l1.get(i).equals("NULL")){
                                insertContent.setNull(i + 1, java.sql.Types.INTEGER);
                            }else{
                                insertContent.setString(i + 1, l1.get(i));
                            }

                            i++;
                        }

                        int rowsAffected = insertContent.executeUpdate();

                        if (rowsAffected > 0) {
                            System.out.println("Content inserted successfully");
                        }
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }



    }

    public static void addNull(List<String> l1, int i){
        if (i == director){
            l1.add("NULL");
        }

        // if no rating then i add my own (need revision)
        if (i == rating){
            l1.add("1");
        }

    }

    public static void nullActors(List<String> l1, int i){
        if (i == cast) {
            l1.add("NULL");
        }
    }

    public static void nullCountry(List<String> l1, int i){
        if (i == country) {
            l1.add("NULL");
        }
    }

    public static void nullTags(List<String> l1, int i){
        if (i == genre) {
            l1.add("NULL");
        }
    }

    public static void main(String[] args) {
        String file = "Data.csv";
        String line;
        String csvSplitBy = ",";



        String stringHelper = "";

        List<String> contentRow = new ArrayList<>();
        List<String> contentActors = new ArrayList<>();
        List<String> contentDirectors = new ArrayList<>();
        List<String> contentTags = new ArrayList<>();
        List<String> genreTags = new ArrayList<>();
        List<String> contentCountry = new ArrayList<>();
        List<String> contentDate = new ArrayList<>();
        List<List<String>> contentHelper = new ArrayList<>();
        List<List<String>> actorHelper = new ArrayList<>();
        List<List<String>> contentDirectorsHelper = new ArrayList<>();
        List<List<String>> contentTagsHelper = new ArrayList<>();
        List<List<String>> genreTagsHelper = new ArrayList<>();
        List<List<String>> countryHelper = new ArrayList<>();
        List<List<String>> dateHelper = new ArrayList<>();


        /*
        These HashMaps are essential to saving runtime
            -> Once an element already exists in the table (After we add them)
            -> It will be accessible along with the ID
        The HashMaps have their own functions to complete this operation (Listed Above)
        I created this HashMaps because each Map corresponds to a table that only has an ID and description/name
            -> ONLY 2 VALUES
         */
        HashMap<String, Integer> content_format_map = new HashMap<>();
        HashMap<String, Integer> rating_map = new HashMap<>();
        HashMap<String, Integer> director_map = new HashMap<>();
        HashMap<String, Integer> actor_map = new HashMap<>();
        HashMap<String, Integer> tag_map = new HashMap<>();
        HashMap<String, Integer> country_map = new HashMap<>();
        HashMap<String, Integer> date_map = new HashMap<>();

        // Rating & Director I created for content that don't have a Rating in the CSV File.
        rating_map.put("NEEDS REVISION", 1);
        director_map.put("Multiple Directors", 1);


        String dbUrl = "jdbc:mysql://localhost:3306/MultimediaContentDB";
        String user = "root";
        String password = "Jade";

        int itr = -1;
        int i = 0;
        try(Connection conn = DriverManager.getConnection(dbUrl, user, password)){
            System.out.println("Connected");
            try(BufferedReader br = new BufferedReader(new FileReader(file))){
                line = br.readLine();
                while(line != null) {
                    i++;
                    line = br.readLine();

                    if (line == null) {
                        break;
                    }

                    String[] values = line.split(csvSplitBy);

                    itr = -1;

                    // This loop will iterate through each csv value for a line.
                    for (int j = 0; j < values.length; j++) {
                        String value = values[j];

                        // If a value is left empty, we will assign it as NULL.
                        if (value.equals("")) {
                            // Get to the current column value.
                            itr++;
                            addNull(contentRow, itr);

                            nullCountry(contentCountry, itr);

                            // ADD NULL TO THE LIST (IMPLEMENT LOGIC LATER)
                            nullActors(contentActors, itr);
                            nullTags(contentTags, itr);
                            nullTags(genreTags, itr);


                            // If we have a column value that starts with Quotations,
                            // then we need to get every value in between the 2nd quotation.
                        } else if (value.startsWith("\"") && value.length() == 1) {

                            List<String> l1 = new ArrayList<>();


                            String newValue = "";

                            j++;
                            value = values[j];
                            newValue = newValue.concat(value);

                            while (!newValue.endsWith("\"") && j < values.length - 1) {
                                l1.add(value);
                                j++;
                                value = values[j];
                                newValue = newValue.concat(value);
                            }

                            value = trimQuotes(value);
                            l1.add(value);
                            itr++;

                            if (itr == country){
                                contentCountry.addAll(l1);
                            }

                        } else if (value.charAt(0) == '"') {

                            // This list is used to add each string within the quotes
                            List<String> l1 = new ArrayList<>();

                            // Get the next value and check if it has the matching quote.
                            //      There is a special case where Cast Members may have their nickname in DOUBLE QUOTES.
                            while (value.charAt((value.length() - 1)) != '"' || ((itr == cast - 1) && (value.charAt(value.length() - 2) == '"'))) {


                                value = trimQuotes(value);
                                // Add the value to the list
                                l1.add(value);

                                // Increment the j value
                                j++;

                                if (j < values.length) {
                                    // GET the next value within the quotes.
                                    value = values[j];

                                } else {
                                    // Value doesn't have a matching ending quote
                                    // and we are done with the current line.


                                    l1.add(value);


                                    for (int l = 0; l < l1.size() - 1; l++) {
                                        stringHelper = stringHelper.concat(l1.get(l));
                                        System.out.println(stringHelper);
                                    }
                                    String helperLine = br.readLine();
                                    if (helperLine == null) {
                                        break;
                                    }

                                    // line is now the next line.
                                    line = helperLine;

                                    value = stringHelper;

                                    stringHelper = stringHelper.concat(line);

                                    j = 0;


                                    String[] helperValue = line.split(csvSplitBy);
                                    values = helperValue;

                                    System.out.println("HValue" + helperValue[j]);

                                    if (values[j].endsWith("\"") && value.endsWith(" ")) {
                                        value = value.concat(values[j]);
                                        itr++;
                                    } else if (values[j].endsWith("\"")) {
                                        value = value.concat(" " + values[j]);
                                    } else {
                                        while (!values[j].endsWith("\"") && j < values.length) {
                                            value = value.concat(values[j]);
                                            j++;
                                        }
                                        itr++;
                                    }


                                    trimQuotes(value);


                                }

                                stringHelper = "";
                            }


                            itr++;


                            value = trimQuotes(value);


                            columnSwitch(itr, contentRow, l1, value);

                            if (itr == director) {
                                contentDirectors.addAll(l1);
                            }

                            if (itr == cast) {
                                contentActors.addAll(l1);
                            }

                            if (itr == genre){
                                contentTags.addAll(l1);

                                String randomGenre = randomGenre(contentRow.get(0));
                                genreTags.add(randomGenre);
                                genreTags.addAll(l1);
                                contentRow.add(randomGenre);
                            }

                            if (itr == country){
                                contentCountry.addAll(l1);
                            }

                            if (itr == dateAdded){
                                String date = l1.toString();
                                date = getDateFormatted(date);
                                contentDate.add(date);
                            }


                        } else {

                            /*
                            This is the case when the value is not wrapped in Quotation marks.
                            Based on the current index we will insert the value into it's respective List.
                             */

                            itr++;
                            switch (itr) {
                                // ContentID column
                                case contentID:
                                    /*
                                     What's Done:
                                     Remove the 's' from the ID values & Add the ID to all lists
                                     We make sure the ID is the 0th Element for each list's row for clarity.
                                     */

                                    value = truncateID(value);
                                    contentRow.add(value);
                                    contentActors.add(value);
                                    contentTags.add(value);
                                    contentCountry.add(value);
                                    contentDate.add(value);
                                    contentDirectors.add(value);
                                    break;
                                // Content_Format column
                                case contentFormat:
                                    /*
                                     What's Done:
                                     Pretty Simple, Get the 2nd value in the line & Add it to ContentRow
                                     */

                                    int content_formatID =
                                            getContentFormatID_or_INSERT(content_format_map, value, conn);
                                    contentRow.add(String.valueOf(content_formatID));

                                    break;
                                case title:
                                    // Add the title of show/movie only to the content row.
                                    contentRow.add(value);
                                    break;
                                case director:
                                    // Add the director of show/movie only to the content row.
                                    int directorID = getDirectorID_or_INSERT(director_map, value, conn);
                                    contentRow.add(String.valueOf(directorID));
                                    break;
                                case cast:
                                    // This case is for Content with only 1 ACTOR.
                                    // Will add each actor to Actor Table & contentActors (LIST)
                                    contentActors.add(value);


                                    break;
                                case country:
                                    contentCountry.add(value);
                                    break;
                                case dateAdded:
                                    break;
                                case releaseYear:
                                    contentRow.add(value);
                                    break;
                                case rating:
                                    /*
                                    There are certain cases where the duration is in the place where
                                    the rating should be.
                                    So in this case I add my custom Rating to the content,
                                     then  duration to the proper column
                                     */

                                    // Since both values are essential for Content I add both.
                                    if (value.endsWith(" min")) {
                                        int ratingID = 1;
                                        contentRow.add(String.valueOf(ratingID));



                                        contentRow.add(value);
                                        itr = duration;
                                    } else {
                                        int ratingID = getRatingID_or_INSERT(rating_map, value, conn);
                                        contentRow.add(String.valueOf(ratingID));
                                    }
                                    break;
                                case duration:
                                    // As listed above duration is essential for content.
                                    contentRow.add(value);
                                    break;
                                case genre:
                                    /*
                                    This is where "Tags" go that describe Content.
                                    I have it labeled Genre, so I know to assign a random genre to the content.
                                    Then, I add the actual Tag values to contentTags.
                                     */

                                    contentTags.add(value);

                                    String randomGenre = randomGenre(contentRow.get(0));
                                    genreTags.add(randomGenre);
                                    genreTags.add(value);
                                    contentRow.add(randomGenre);
                                    break;
                                case contentDescription:
                                    /*
                                    This is another special case Handle where the Description is incorrect.
                                    So If I run into this line I just skip it.
                                     */
                                    if (value.equals("Movies")) {
                                        contentRow.clear();
                                    } else {
                                        // Otherwise add the description since it's essential to the Content
                                        contentRow.add(value);
                                    }
                                    break;
                                default:

                            }
                        }


                    }






                    // IF Content contains all key 9 attributes then proceed.
                    // Add all of our cleaned values to a List<List>.
                    if (contentRow.size() == 9) {

                        // ADD the content (id, title, director etc.)
                        contentHelper.add(new ArrayList<>(contentRow));

                        // There's a weird case where one of the values for actor is the description.
                        // So if an actor's name is greater than 100 skip it.
                        if (!contentActors.contains("NULL") && contentActors.get(1).length() < 100) {
                            actorHelper.add(new ArrayList<>(contentActors));
                        }

                        if (!contentTags.contains("NULL")){
                            contentTagsHelper.add(new ArrayList<>(contentTags));
                        }

                        if (!genreTags.contains("NULL")){
                            genreTagsHelper.add(new ArrayList<>(genreTags));
                        }

                        if (!contentCountry.contains("NULL")){
                            countryHelper.add(new ArrayList<>(contentCountry));
                        }

                        if (!contentDate.contains("NULL")){
                            dateHelper.add(new ArrayList<>(contentDate));
                        }

                        if (!contentDirectors.contains("NULL")){
                            contentDirectorsHelper.add(new ArrayList<>(contentDirectors));
                        }
                    }

                    // EMPTY all List<> since they are only useful for this current line.
                    contentRow.clear();
                    contentActors.clear();
                    contentTags.clear();
                    genreTags.clear();
                    contentCountry.clear();
                    contentDate.clear();
                    contentDirectors.clear();

                }

                // Iterate through the entire List<List> of Content rows.
                for (int index = 0; index < contentHelper.size(); index++){

                    // Check if content is empty or not
                    if (contentHelper.get(index).size() > 0) {
                        // Insert Content into DB by using the List<String> at the current index.
                        insertContent(contentHelper.get(index), conn);

                        // THEN INSERT into Content_Availability, with an availability of 1.
                        //      -> This makes the status of the content 'Available'.
                        String contentID = contentHelper.get(index).get(0);
                        insertContent_Availability(contentID, 1, conn);

                        // I just simply want the tester user to watch half the content twice.
                        // Again this is for 11. testing.
                        if (index > 4000) {
                            insertWatch_History(contentID, 5, conn);
                            insertWatch_History(contentID, 5, conn);
                        }
                    }
                }

                /*
                EVERYTHING UNDER IS FOR ASSOCIATIVE ENTITIES.
                2 FOR LOOPS
                    The Outer Loop to iterate through the List<List>
                    The inner loop to iterate through each value in the inner list.

                GET the content ID which is always the 0th element.
                THEN iterate through the row of List<String>
                    -> I.E. Iterate through the different Actor Names
                    -> THEN run our checker if the name exists in the DB already or not.
                            -> This returns either the newly inserted ID or the id if the name exists.
                AFTER we insert the content and the other value for all associative entites.
                 */

                for (int index = 0; index < actorHelper.size(); index++){
                    String contentID = actorHelper.get(index).get(0).trim();

                    for (int j = 1; j < actorHelper.get(index).size(); j++) {
                        String actorName = actorHelper.get(index).get(j);
                        String actorNameTrimmed = actorName.trim();
                        int actorID = getActorID_or_INSERT(actor_map, actorNameTrimmed, conn);

                        if (actorID != -1){
                            insertContentActors(contentID, actorID, conn);
                        }

                    }
                }

                for (int index = 0; index < contentTagsHelper.size(); index++){
                    String contentID = contentTagsHelper.get(index).get(0).trim();

                    for (int j = 1; j < contentTagsHelper.get(index).size(); j++) {
                        String tagName = contentTagsHelper.get(index).get(j);
                        String tagNameTrimmed = tagName.trim();
                        int tagID = getTagID_or_INSERT(tag_map, tagNameTrimmed, conn);

                        if (tagID != -1){
                            insertContentTags(contentID, tagID, conn);
                        }

                    }
                }



                for (int index = 0; index < countryHelper.size(); index++){
                    String contentID = countryHelper.get(index).get(0).trim();

                    for (int j = 1; j < countryHelper.get(index).size(); j++) {
                        String countryName = countryHelper.get(index).get(j);
                        String countryNameTrimmed = countryName.trim();
                        int countryID = getCountryID_or_INSERT(country_map, countryNameTrimmed, conn);

                        if (countryID != -1){
                            insertContent_Country(contentID, countryID, conn);
                        }

                    }
                }

                for (int index = 0; index < dateHelper.size(); index++){
                    String contentID = dateHelper.get(index).get(0).trim();

                    for (int j = 1; j < dateHelper.get(index).size(); j++) {
                        String releaseDate = dateHelper.get(index).get(j);
                        String releaseDateTrimmed = releaseDate.trim();
                        String version = "1";
                        int releaseID = getRelease_or_INSERT(date_map, releaseDateTrimmed, version, conn);

                        if (releaseID != -1){
                            insertContent_Release(contentID, releaseID, conn);
                        }

                    }
                }

                for (int index = 0; index < contentTagsHelper.size(); index++){
                    String contentID = contentTagsHelper.get(index).get(0).trim();

                    for (int j = 1; j < contentTagsHelper.get(index).size(); j++) {
                        String tagName = contentTagsHelper.get(index).get(j);
                        String tagNameTrimmed = tagName.trim();
                        int tagID = getTagID_or_INSERT(tag_map, tagNameTrimmed, conn);

                        if (tagID != -1){
                            insertContentTags(contentID, tagID, conn);
                        }

                    }
                }

                for (int index = 0; index < genreTagsHelper.size(); index++){
                    String genreID = genreTagsHelper.get(index).get(0).trim();

                    for (int j = 1; j < genreTagsHelper.get(index).size(); j++) {
                        String tagName = genreTagsHelper.get(index).get(j);
                        String tagNameTrimmed = tagName.trim();
                        int tagID = getTagID_or_INSERT(tag_map, tagNameTrimmed, conn);

                        if (tagID != -1){
                            insertGenreTags(genreID, tagID, conn);
                        }

                    }
                }

                for (int index = 0; index < contentDirectorsHelper.size(); index++){
                    String contentID = contentDirectorsHelper.get(index).get(0).trim();

                    for (int j = 1; j < contentDirectorsHelper.get(index).size(); j++) {
                        String directorName = contentDirectorsHelper.get(index).get(j);
                        String directorNameTrimmed = directorName.trim();
                        int directorID = getDirectorID_or_INSERT(director_map, directorNameTrimmed, conn);

                        if (directorID != -1){
                            insertContent_Directors(contentID, directorID, conn);
                        }

                    }
                }


            }catch (IOException e){
                e.printStackTrace();
            }


        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
