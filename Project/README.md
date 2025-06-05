# Project Guidelines

In this project, your team will develop a multimedia database management system similar to Netflix.
The goal is to create a database that supports functionalities for providing on-demand content to users.
You will design and implement the database structure,
which will be used by applications to manage content, subscriptions, user interactions, and more.

### Tools and Resources

You will use the following tools to complete the project:

- **[MySQL Server](https://dev.mysql.com/downloads/mysql/)**: MySQL is a widely used relational database management 
  system (RDBMS). You need to install MySQL locally on your machine to host the database. Choose the installer 
  for your operating system (Windows, macOS, or Linux).
  
- **[Draw.io](https://app.diagrams.net/)**: Draw.io is a free, web-based diagramming tool for creating ER diagrams and 
 other visual representations of your database schema. Use this tool to map out the structure of your database.

- **[DataGrip](https://www.jetbrains.com/datagrip/)**: DataGrip is a powerful database management tool by JetBrains.
  It helps you write SQL queries, manage database schemas, and interact with your MySQL database.
  You will use DataGrip for writing and testing queries and managing the database.  
  **SFSU students can access a free professional version of DataGrip
  by creating a JetBrains account with their SFSU email and activating the license.**

---

## Section I: Database Design 

In this section, you are required to create the database structure and relationships based on the entities listed below.
Ensure that you carefully analyze and model the relationships between these entities
to design an efficient and logical database schema.

### Entities

1. **Content (or Show)**
2. **Director**
3. **Actor (or Cast)**
4. **Genre**
5. **Country**
6. **Rating**
7. **Content_Format**
8. **User**
9. **Review**
10. **Subscription_Plan**
11. **User_Subscription**
12. **Playlist**
13. **Content_Release**
14. **Watchlist**
15. **Content_WatchHistory**
16. **Tag**
17. **Content_Accessibility**
18. **Content_Availability**
19. **Payment_Method**
20. **Transaction**

### Database Requirements

1. Create a **PDF file** named `Requirements.pdf` that outlines the necessary database requirements. This file should describe the relationships between the entities listed above, including all relationship types (e.g., many-to-many, one-to-one, etc.) discussed in class.
2. Once completed, **upload the PDF** to the `files` directory of this repository.

### Entity Relationship Diagram (ERD)

1. Use **[Draw.io](https://app.diagrams.net/)** to create an Entity Relationship Diagram (ERD) based on the database requirements from Section I.
2. The ERD should:
   - Include all the entity sets corresponding to the entities listed above.
   - Show the relationships, cardinalities, and primary/foreign keys (PKs and FKs) for each entity.
3. Export the ERD as a **PNG file** named `ERD.png`.
4. **Upload the PNG file** to the `files` directory of this repository.

--- 

## Section II: Database Implementation

This section assumes
that **[MySQL Server](https://dev.mysql.com/downloads/mysql/)** and **[DataGrip](https://www.jetbrains.com/datagrip/)** are properly installed
and configured on your machine.
Before you begin,
please watch the recording
posted on Canvas for guidance on how to install and use **[DataGrip](https://www.jetbrains.com/datagrip/)**.

In this section,
you will use **[DataGrip](https://www.jetbrains.com/datagrip/)** to connect to your local MySQL instance
and create a new database along with its tables based on your ERD design.

### Steps for Database Implementation

#### 1. Cloning the Project

- Open **[DataGrip](https://www.jetbrains.com/datagrip/)** and clone the project into your workspace.
- In the database explorer, select **MySQL** as the source for your project.
- Connect **DataGrip** to your local MySQL instance.

#### 2. Creating the Database Schema

- In the database explorer, right-click on your MySQL connection and create a new database schema named `MultimediaContentDB`.
- Right-click on your new database schema, then create the tables for that schema based on your ERD design.
  - You can either use the table editor or write the SQL code directly to create the tables.
  - Apply all the normalization techniques learned in class to reduce redundancy and improve the integrity of the database
  - Once completed, generate your SQL code into a file named `Databasemodel.sql`
- After all the tables are created, right-click on your database schema, select **Show Diagram**, and export the diagram as a PNG file named `Diagram.png`.
- Upload `Diagram.png` file into `Project/Files/` directory in your **DataGrip** project.
- Upload `Databasemodel.sql` file into `Project/Scripts/` directory in your **DataGrip** project.
- Push all your changes to your remote repository.

#### 4. Adding Sample Data

Adding sample data simulates real industry practices,
where raw data is often in a different format than required by the database.
Your task is to clean and insert this data programmatically,
much like handling data from external sources in professional environments.

- In the `Project/Dataset/` directory, you will find the `data.csv` file, which contains sample data to populate your database.
  
  **Steps for using the `data.csv` file:**
  - Clean up the data to ensure that all fields contain valid information for your database.
  - Create a script, named `ReadData.*` (where `*` is the extension of your chosen programming language), 
    to read the `Data.csv` file and insert the data into the corresponding database tables using SQL INSERT queries.
    - You can use any programming language of your choice (e.g., Python, Java, etc.) to create this script.
    - If the `Data.csv` file doesn't contain data for certain columns from your tables in your database, you may use fake data to populate those fields.
  - Once your script `ReadData.*` is implemented and tested successfully, upload it to the `Project/Datasets/` directory of your **DataGrip** project.
  
  **Important Notes:**
  - Ensure that your script is well-documented and readable.
  - Your script should contain both the programming language code (for cleaning and reading the CSV) and the SQL code (for inserting the data into the database).
  
- Push your script and all other changes to your remote repository.


--- 

## Section III: Business Requirements

Using **DataGrip**, create and implement four SQL scripts as follows:

1. `Triggers.sql`
2. `Functions.sql`
3. `Procedures.sql`
4. `Events.sql`

The following business requirements must be implemented in the appropriate scripts:


#### 1. Limit Watchlist Capacity
- Enforce a maximum of 50 items in a user's **Watchlist**. 
- Automatically remove the oldest item if the user adds an item exceeding the limit.

#### 2. Rating Impact on Content Availability
- Automatically set the `Content_Availability` status to **"Archived"** if the average rating of a piece of **Content** falls below 2.0 after a new review is added.

#### 3. Ensure Unique Director for Content
- Prevent duplicate **Director** entries for the same **Content**.
- Log any failed attempts to assign a duplicate director into a `Director_Assignment_Errors` table.

#### 4. Rank Top Genres by Watch Hours
- Return the top 3 genres based on total watch hours in the last month.

#### 5. Find Most Frequent Collaborators
- Identify the most frequent actor-director pairs who have worked together.

#### 6. Validate Subscription Status
- Return whether a user’s subscription is **active** or **expired** based on their subscription and transaction history.

#### 7. Generate Monthly User Activity Report
- Generate a report detailing user activity for the past month, including:
  - The number of content items watched
  - Average ratings provided
  - Hours spent on the platform

#### 8. Process Batch Content Updates
- Update the `Content_Availability` status for multiple **Content** entries based on a given list of criteria (e.g., release date, view count).

#### 9. Handle Failed Payments
- Log failed payment attempts into a `Payment_Errors` table.
- Send notifications to affected users regarding the failed payments.

#### 10. Remove Expired Subscriptions
- Automatically remove expired subscriptions from the **User_Subscription** table.
- Notify users of the expiration and removal.

#### 11. Refresh Popular Content Rankings
- Update a table storing the top 10 most popular **Content** for each **Genre** daily, based on view counts.

Once you've implemented these requirements,
upload the four SQL scripts into the `Project/Scripts/` directory of your **DataGrip** project,
and push your work to your remote repository.

--- 

## Section IV: Testing and Analysis

In this section, you will perform testing and analyze the functionality and performance of your database. The goal is to ensure that the implemented business logic, triggers, functions, procedures, and scheduled events behave as expected and that your system can handle typical data operations effectively.

### 1. Testing Requirements

Create a script named `Tests.sql` to implement the following components.
Ensure that all the components are well documented in your script

#### a. Unit Testing
- Test individual SQL components such as **Triggers**, **Functions**, and **Procedures** to ensure they function as expected.
- Use test cases for each requirement implemented in the previous section.
  - For **Triggers**: Test scenarios where the trigger conditions are met, and ensure they fire correctly (e.g., removing items from a Watchlist when it exceeds the limit).
  - For **Functions**: Verify that the functions return the correct results based on test data (e.g., ranking genres by watch hours).
  - For **Procedures**: Ensure that the stored procedures generate correct reports or perform updates (e.g., generating user activity reports, handling failed payments).

#### b. Integration Testing
- Test the interaction between the components of your system. Ensure that:
  - Data flows correctly between tables.
  - Triggers fire in response to the correct actions.
  - Procedures and functions return expected results when used together.
- For example, after inserting a new review, check if the **Content_Availability** status is updated appropriately based on the average rating.

#### c. Data Integrity Testing
- Verify that data integrity is maintained throughout the operations. For example:
  - Ensure no duplicate **Director** entries are added for the same **Content**.
  - Validate that expired subscriptions are correctly removed from the **User_Subscription** table.
  
#### d. Performance Testing
- Test the performance of your database, especially for larger datasets. Ensure that:
  - Triggers, functions, and procedures execute within an acceptable time frame.
  - Scheduled events run efficiently, even when handling large amounts of data (e.g., updating content rankings daily).


  
### 2. Analysis

Write a final analysis report `Report.pdf` summarizing your testing process for the following components.
- Include screenshots or logs of any testing done, especially if issues were resolved during the process.
- Upload the final report to the `Project/Reports/` directory of your project.

#### a. Results of Testing
- Document the results of each test and compare them to the expected outcomes.
  - For each test case, list the input, expected output, actual output, and whether the test passed or failed.
  - If a test failed, describe the issue and how you resolved it.
  
#### b. Performance Insights
- Analyze the performance of your queries, especially for large datasets. Consider:
  - Query execution time and optimization (e.g., adding indexes, adjusting query structure).
  - The impact of scheduled events on database performance.

#### c. Improvements and Recommendations
- Based on your testing and analysis, suggest any improvements or optimizations for your database design or logic. Consider:
  - Indexing strategies to speed up queries.
  - Refactoring inefficient queries or logic in triggers, functions, or procedures.



### 3. Documentation

- Ensure that all tests and analysis are well-documented. This includes:
  - Test cases, their expected and actual results.
  - Performance benchmarks and optimization strategies.
  - Any changes made to the database schema or logic after testing.

Once all testing and analysis are complete:
- Upload the file `Tests.sql` into the `Project/Scripts/` directory of your DataGrip project
- Upload the file `Report.pdf` into the `Project/Files/` directory of your DataGrip project
- Push all your work to your remote repository


--- 

## Overview 

The following is a summary of the files and scripts needed to complete this project. 

### DataGrip Directory: `Project/Datasets/`

This directory contains the following files:

- `Data.csv`: The sample dataset (provided by the instructor) that should be cleaned and used to populate the database tables.
- `ReadData.*`: A file (with an appropriate extension based on your chosen programming language) used to clean and load data from `data.csv` into the database.

### DataGrip Directory: `Project/Files/`

This directory contains the following files after submission:

- `Requirements.pdf`: A PDF document outlining all the database requirements, including entity relationships and constraints. 
- `ERD.drawio`: The ERD file created using [Draw.io](https://app.diagrams.net/), representing the database structure, entities, relationships, and their keys.
- `Diagram.png`: An exported image of the ERD created in DataGrip.
- `Report.pdf`: A report containing the testing and performance insights for your scripts

### DataGrip Directory: `Project/Scripts/`

This directory contains the following scripts after submission:

- `Databasemodel.sql`: A script with all the SQL code generated by DataGrip for your database schema and tables
- `Triggers.sql`: The SQL script implementing all trigger-based requirements for the project.
- `Functions.sql`: The SQL script implementing all function-based requirements for the project.
- `Procedures.sql`: The SQL script implementing all procedure-based requirements for the project.
- `Events.sql`: The SQL script implementing all scheduled event-based requirements for the project.
- `Tests.sql`: The SQL script implementing all the testing and performance of the database.


All scripts should be well-commented and readable,
ensuring that any developer can understand their purpose and functionality.

--- 

**Upon completion of all sections, ensure that all files are uploaded to the repository, and submit your final project report for evaluation.**
