[![Review Assignment Due Date](https://classroom.github.com/assets/deadline-readme-button-22041afd0340ce965d47ae6ef1cefeee28c7c493a6346c4f15d667ab976d596c.svg)](https://classroom.github.com/a/o2fYoNlo)
# Csc675.775 Group Project

**IMPORTANT: It is the student's responsibility to read and follow all guidelines and instructions provided in all 
README files found in this repository.**

## TODO by Team Lead

1. Add all your team members as collaborators into this repository with `Write` permissions only.

2. Please fill in the information below once the instructor creates teams for this project:

| Team Member | Student Name           | Email Address               | Role                    |
|-------------|------------------------|-----------------------------|-------------------------|
| 1           |                        |                             | Team Lead               |
| 2           |                        |                             | Database Architect      |
| 3           |                        |                             | Database Developer      |
| 4           |                        |                             | Database Analyst/Tester |


--- 

## Team Roles for this Project  

The responsibilities outlined below are provided as recommendations.
However,
the Team Lead has the flexibility to adjust these responsibilities
or assign additional tasks to ensure the team's success.  

### **1. Team Lead**  
- **Leadership Responsibilities**:  
  - Manages the project timeline and coordinates tasks among team members.  
  - Serves as the main point of contact between the team and the instructor.  
  - Reviews deliverables to ensure quality and consistency.  

- **Technical Responsibilities**:  
  - Assists team members with their tasks and provides necessary training and resources.  
  - Offers iterative feedback on team members' work to ensure it meets the project's quality standards.  

### **2. Database Architect**  
- **Responsibilities**:  
  - Creates detailed database documentation and establishes best practices for developers.  
  - Defines database requirements in collaboration with the Database Developer and Database Analyst/Tester.  
  - Designs the Entity Relationship Diagram (ERD).  
  - Develops the database schema, including tables, attributes, and relationships.  
  - Ensures the database design adheres to normalization principles and meets project requirements.  

### **3. Database Developer**  
- **Responsibilities**:  
  - Implements the database schema using appropriate tools and technologies.  
  - Develops stored procedures, triggers, and other database functionalities.  
  - Performs unit testing on database components to ensure accuracy and functionality.  

### **4. Database Analyst/Tester**  
- **Responsibilities**:  
  - Creates sample data and performs testing to validate database functionality.  
  - Ensures data integrity, consistency, and compliance with requirements.  
  - Analyzes test results and provides feedback for improvements to the team.  


--- 

## Repository Content

All work in this repository is divided into four sections, which collectively account for 20% of your final grade. 


| Sections | Description                      | Weight |
|----------|----------------------------------|------|
| 1        | Database Design                  | 5%   |
| 2        | Database Implementation          | 5%   |
| 3        | Business Requirements            | 5%   |
| 4        | Testing and Performance Analysis | 5%   |


---

## Submission Guidelines

For this project, you will be using various database tools and submitting your work through this repository.
Ensure that all parts of the project are properly completed and uploaded before the submission deadline.
Failure to follow the guidelines may result in a non-satisfactory grade.

### General Guidelines:

1. **Complete All Sections**: Ensure that all sections of the project are fully completed. Missing or incomplete work will result in a non-satisfactory grade for the project.
   
2. **Organize Files**: Upload all files to the appropriate folders in the repository. The required directories for the project are:
   - `Project/Files/` for all required diagrams and documents
   - `Project/Scripts/` for SQL scripts and any data processing scripts 
   - `Project/Dataset/` for any datasets used to populate your database

3. **Naming Conventions**:
   - Ensure all files are named as specified in the project requirements (e.g., `Requirements.pdf`, `ERD.drawio`, `diagram.png`).
   - Use appropriate file extensions for your scripts (e.g., `.sql`, `.py`, `.csv`).

4. **Documentation**:
   - Provide clear comments and documentation within your scripts, explaining the purpose and logic of your code.
   - Include a README file in your repository if necessary to provide any additional information about your project.

5. **Push to Remote Repository**: 
   - After completing your work, ensure that all files are committed and pushed to the remote repository before the deadline.
   
6. **Late Submissions**:
   - Late work won't be accepted. No exceptions.

### Final Check:

- Double-check that all required files and scripts are uploaded and are in their correct folders.
- Confirm that your repository is up to date and includes all your final changes.




--- 

## Grading Rubrics

All team members will receive the same grade
unless there is documented evidence that a student did not contribute as expected to the project.
In such cases, the student will receive a non-satisfactory grade.

### Section I: Database Design (5 Points)
| Criteria                                      | Points | Description                                                                                          |
|-----------------------------------------------|--------|------------------------------------------------------------------------------------------------------|
| **Entity Relationship Diagram (ERD)**         | 2      | The ERD accurately reflects the relationships, cardinalities, and entity attributes as specified.    |
| **Database Requirements (PDF)**               | 2      | The requirements PDF outlines all relationships and constraints clearly, addressing all required relationship types (e.g., one-to-many, many-to-many). |
| **Quality of Design**                         | 1      | The database structure is logically organized and efficient, with minimal redundancy and appropriate normalization. |

### Section II: Database Implementation (5 Points)
| Criteria                                      | Points | Description                                                                                          |
|-----------------------------------------------|--------|------------------------------------------------------------------------------------------------------|
| **Database Schema Creation**                  | 2      | A new schema named `MultimediaContentDB` is created, and tables are properly set up based on the ERD design. |
| **Sample Data Insertion**                     | 2      | Data is properly inserted into the database using the provided `data.csv` file, and the script for importing is well-documented and functional. |
| **Use of DataGrip Tools**                     | 1      | Correct and efficient use of DataGrip to create and manage the schema, as well as exporting diagrams. |

### Section III: Business Requirements (5 Points)
| Criteria                                      | Points | Description                                                                                          |
|-----------------------------------------------|------|------------------------------------------------------------------------------------------------------|
| **Trigger Implementation**                    | 1.5  | All trigger-based requirements are implemented correctly, including enforcing limits, updating availability, and logging errors. |
| **Function Implementation**                   | 1    | Functions are written to meet business requirements, such as ranking genres and validating subscriptions. |
| **Procedure Implementation**                  | 1.5  | Procedures are implemented accurately for generating reports, updating content, and handling failed payments. |
| **Scheduled Event Implementation**            | 1    | Scheduled events are created to automatically update data, such as expired subscriptions and popular content rankings. |

### Section IV: Testing and Analysis (5 Points)
| Criteria                                      | Points | Description                                                                                          |
|-----------------------------------------------|--------|------------------------------------------------------------------------------------------------------|
| **Test Coverage**                             | 2      | All SQL scripts are thoroughly tested, and edge cases are considered. Proper validation of triggers, functions, procedures, and events is done. |
| **Analysis of Results**                       | 1.5    | The analysis clearly explains the testing process, expected outcomes, and any adjustments made after testing. |
| **Documentation and Clarity**                 | 1.5    | The testing and analysis are well-documented, with clear explanations and organized results. |

---

## Good Luck!

We believe in your ability to successfully complete this project.
Approach each task with focus, creativity, and attention to detail.
Remember, this is not just an opportunity to demonstrate your technical skills, but also to learn and grow.
Don’t hesitate to ask for help if you need it, and most importantly, enjoy the process!
Good luck, and we look forward to seeing your hard work come to life.

