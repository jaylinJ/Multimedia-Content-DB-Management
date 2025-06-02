'''
File: ReadData.py
Description: Python file used to properly parse 8807 rows of MultimediaContentData and populate DB tables.
TABLES POPULATED WITH THIS FILE:
Content, Director, Country, Actors, Release, Tags, ContentTags, GenreTags
ContentActors, ContentCountry, Content_Availability, Content_Release, Rating
'''



import numpy as np
import pandas as pd
import mysql.connector
from datetime import datetime, date

mydb = mysql.connector.connect(
  host= "localhost",
  user= "root",
  password= "Jade",
  database= "MultimediaContentDB"
)

mycursor = mydb.cursor()

def get_genre(num):
    num = int(num)
    num = (num % 9) + 1
    return num

def truncate_id(show_id):
    show_id = show_id[1:]
    return show_id

def fix_date_format(date):
    if date == "NULL":
        return None

    date = date.strip()
    date = datetime.strptime(date, "%B %d, %Y")
    date = date.strftime("%Y-%m-%d")

    date_id = get_id_or_insert_release(date, release_map)
    return date_id

def transform_actor_row(row):
    if row == "NULL":
        return None

    if ',' not in row:
        actor_id = get_id_or_insert_actor(row, actor_map)
        return actor_id

    id_rows = []
    row = str(row)

    for value in row.split(','):
        value = value.strip()
        actor_id = get_id_or_insert_actor(value, actor_map)
        id_rows.append(actor_id)
    return id_rows

def transform_director_row(row):
    if row == "NULL":
        return None

    if ',' not in row:
        if len(row) > 100:
            director_id = get_id_or_insert_country(row, director_map)
            return director_id

    id_rows = []
    row = str(row)
    for value in row.split(','):
        value = value.strip()
        director_id = get_id_or_insert_director(value, director_map)
        id_rows.append(director_id)
    return id_rows

def transform_tag_row(row):
    if row == "NULL":
        return None

    if ',' not in row:
        tag_id = get_id_or_insert_tag(row, tag_map)
        return tag_id

    id_rows = []
    row = str(row)
    for value in row.split(','):
        value = value.strip()
        tag_id = get_id_or_insert_tag(value, tag_map)
        id_rows.append(tag_id)
    return id_rows

def transform_country_row(row):
    if row == "NULL":
        return None

    if ',' not in row:
        country_id = get_id_or_insert_country(row, country_map)
        return country_id

    id_rows = []
    row = str(row)
    for value in row.split(','):
        value = value.strip()
        country_id = get_id_or_insert_country(value, country_map)
        id_rows.append(country_id)
    return id_rows

def transform_rating_row(row):
    if row == "NULL":
        return 1

    if ',' not in row:
        rating_id = get_id_or_insert_rating(row, rating_map)
        return rating_id


def remove_decimal(row):
    if row == "NULL":
        return None

    row = str(row)
    if '.' in row:
        row = row[:row.index('.')]
        return row


# Needs work, some content contains multiple directors.
def get_id_or_insert_director(name, director_map):

    # Had to implement 2 checks before INSERT.
    if name in director_map:
        return director_map[name]

    sql = ("SELECT directorID FROM Director WHERE name = %s")
    mycursor.execute(sql, (name,))
    rs = mycursor.fetchone()

    if rs:
        director_map[name] = rs[0]
        return rs[0]

    sql = ("INSERT INTO Director (name) VALUES (%s)")
    val = (name,)
    mycursor.execute(sql, val)
    mydb.commit()
    print("Director Record Inserted.")

    director_id = mycursor.lastrowid
    director_map[name] = director_id
    return director_id

# Needs work, I need to handle A.E
def get_id_or_insert_format(description, content_format_map):

    if description in content_format_map:
        return content_format_map[description]

    sql = ("SELECT content_formatID FROM Content_Format WHERE description = %s")
    mycursor.execute(sql, (description,))
    rs = mycursor.fetchone()

    if rs:
        content_format_id = rs[0]
        content_format_map[description] = content_format_id
        return content_format_id

    sql = ("INSERT INTO Content_Format (description) VALUES (%s)")
    val = (description,)
    mycursor.execute(sql, val)
    mydb.commit()
    print("Content_Format Record Inserted.")

    content_format_id = mycursor.lastrowid
    content_format_map[description] = content_format_id
    return content_format_id

def get_id_or_insert_rating(name, rating_map):

    # Had to implement 2 checks before INSERT.
    if name in rating_map:
        return rating_map[name]

    sql = ("SELECT ratingID FROM Rating WHERE name = %s")
    mycursor.execute(sql, (name,))
    rs = mycursor.fetchone()

    if rs:
        rating_id = rs[0]
        rating_map[name] = rs[0]
        return rating_id

    sql = ("INSERT INTO Rating (name) VALUES (%s)")
    val = (name,)
    mycursor.execute(sql, val)
    mydb.commit()
    print("Rating Record Inserted.")

    rating_id = mycursor.lastrowid
    rating_map[name] = rating_id
    return rating_id

def get_id_or_insert_tag(description, tag_map):

    # Had to implement 2 checks before INSERT.
    if description in tag_map:
        return tag_map[description]

    sql = ("SELECT tagID FROM Tag WHERE description = %s")
    mycursor.execute(sql, (description,))
    rs = mycursor.fetchone()

    if rs:
        tag_id = rs[0]
        tag_map[description] = rs[0]
        return tag_id

    sql = ("INSERT INTO Tag (description) VALUES (%s)")
    val = (description,)
    mycursor.execute(sql, val)
    mydb.commit()
    print("Tag Record Inserted.")

    tag_id = mycursor.lastrowid
    tag_map[description] = tag_id
    return tag_id

def get_id_or_insert_release(release_date, release_map):

    # Had to implement 2 checks before INSERT.
    if release_date in release_map:
        return release_map[release_date]

    sql = ("SELECT releaseID FROM `Release` WHERE release_date = %s")
    mycursor.execute(sql, (release_date,))
    rs = mycursor.fetchone()

    if rs:
        release_id = rs[0]
        release_map[release_date] = rs[0]
        return release_id

    sql = ("INSERT INTO `Release` (release_date) VALUES (%s)")
    val = (release_date,)
    mycursor.execute(sql, val)
    mydb.commit()
    print("Release Record Inserted.")

    release_id = mycursor.lastrowid
    release_map[release_date] = release_id
    return release_id

def get_id_or_insert_country(name, country_map):

    # Had to implement 2 checks before INSERT.
    if name in country_map:
        return country_map[name]

    sql = ("SELECT countryID FROM Country WHERE name = %s")
    mycursor.execute(sql, (name,))
    rs = mycursor.fetchone()

    if rs:
        country_id = rs[0]
        country_map[name] = rs[0]
        return country_id

    sql = ("INSERT INTO Country (name) VALUES (%s)")
    val = (name,)
    mycursor.execute(sql, val)
    mydb.commit()
    print("Country Record Inserted.")

    country_id = mycursor.lastrowid
    country_map[name] = country_id
    return country_id

def get_id_or_insert_actor(name, actor_map):

    # Had to implement 2 checks before INSERT.
    if name in actor_map:
        return actor_map[name]

    sql = ("SELECT actorID FROM Actor WHERE name = %s")
    mycursor.execute(sql, (name,))
    rs = mycursor.fetchone()

    if rs:
        actor_id = rs[0]
        actor_map[name] = rs[0]
        return actor_id

    sql = ("INSERT INTO Actor (name) VALUES (%s)")
    val = (name,)
    mycursor.execute(sql, val)
    mydb.commit()
    print("Actor Record Inserted.")

    actor_id = mycursor.lastrowid
    actor_map[name] = actor_id
    return actor_id

# GET/INSERT TODO:

def insert_content(row):
    row = list(row)
    content_id = row[0]
    if row[3] == "NULL":
        row[3] = None



    director = 1
    list_helper = []

    if row[5] == "NULL":
        row[5] = director


    if isinstance(row[3], list):
        # save our list into our helper for later A.E implementation
        list_helper = row[3]
        row[3] = director

    sql = ("SELECT contentID FROM Content WHERE contentID = %s")
    mycursor.execute(sql, (row[0],))
    rs = mycursor.fetchone()

    if rs:
        return None

    genre = get_genre(row[0])
    sql = ("INSERT INTO Content (contentID, format, title, director,"
           "release_year, rating, duration, description, genre) "
           "VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)")
    val = (row[0], row[1], row[2], row[3], row[4], row[5], row[6], row[7], genre)
    mycursor.execute(sql, val)
    mydb.commit()

    print("Content Record Inserted.")

    # This line automatically makes the INSERTED Content available
    sql = ("INSERT INTO Content_Availability (content, availability) VALUES (%s, %s)")
    val = (row[0], 1)
    mycursor.execute(sql, val)
    mydb.commit()
    print("Content_Availability Record Inserted.")

    # If our director value was a list:
        # WE need to insert the M:M relationship for Content and Director
        # into the respective Associative Entity Table "ContentDirectors"
    if row[3] == director:
        insert_content_directors(content_id, list_helper)

    return content_id

def insert_content_directors(content_id, director_list):

    for director_id in director_list:
        sql = ("SELECT 1 FROM ContentDirectors WHERE content = %s AND director = %s")
        mycursor.execute(sql, (content_id, director_id))
        rs = mycursor.fetchone()

        if rs:
            print("Content Director", content_id, director_id, " Already Exists.")
        else:
            sql = ("INSERT INTO ContentDirectors (content, director) VALUES (%s, %s)")
            val = (content_id, director_id)
            mycursor.execute(sql, val)
            mydb.commit()

            print("ContentDirectors Record Inserted.")

def insert_content_actors(content_id, actor_list):

    if isinstance(actor_list, int):
        actor_list = [actor_list]


    for actor_id in actor_list:
        sql = ("SELECT 1 FROM ContentActors WHERE content = %s AND actor = %s")
        mycursor.execute(sql, (content_id, actor_id))
        rs = mycursor.fetchone()

        if rs:
            print("Content Actor", content_id, actor_id, " Already Exists.")
        else:
            sql = ("INSERT INTO ContentActors (content, actor) VALUES (%s, %s)")
            val = (content_id, actor_id)
            mycursor.execute(sql, val)
            mydb.commit()

            print("ContentActors Record Inserted.")

def insert_content_country(content_id, country_list):

    if isinstance(country_list, int):
        country_list = [country_list]


    for country_id in country_list:
        sql = ("SELECT 1 FROM ContentCountry WHERE content = %s AND country = %s")
        mycursor.execute(sql, (content_id, country_id))
        rs = mycursor.fetchone()

        if rs:
            print("Content Country", content_id, country_id, " Already Exists.")
        else:
            sql = ("INSERT INTO ContentCountry (content, country) VALUES (%s, %s)")
            val = (content_id, country_id)
            mycursor.execute(sql, val)
            mydb.commit()

            print("ContentCountry Record Inserted.")

def insert_content_release(content_id, release_list):

    if isinstance(release_list, int):
        release_list = [release_list]


    for release_id in release_list:
        sql = ("SELECT 1 FROM Content_Release WHERE content = %s AND `release` = %s")
        mycursor.execute(sql, (content_id, release_id))
        rs = mycursor.fetchone()

        if rs:
            print("Content Release", content_id, release_id, " Already Exists.")
        else:
            print("Content Release", content_id, release_id, " NEW")
            sql = ("INSERT INTO Content_Release (content, `release`) VALUES (%s, %s)")
            val = (content_id, release_id)
            mycursor.execute(sql, val)
            mydb.commit()

            print("ContentRelease Record Inserted.")

def insert_content_tag(content_id, tag_list):

    if isinstance(tag_list, int):
        tag_list = [tag_list]


    for tag_id in tag_list:
        sql = ("SELECT 1 FROM ContentTags WHERE content = %s AND tag = %s")
        mycursor.execute(sql, (content_id, tag_id))
        rs = mycursor.fetchone()

        if rs:
            print("Content Tag", content_id, tag_id, " Already Exists.")
        else:
            sql = ("INSERT INTO ContentTags (content, tag) VALUES (%s, %s)")
            val = (content_id, tag_id)
            mycursor.execute(sql, val)
            mydb.commit()

            print("ContentTags Record Inserted.")

def insert_genre_tag(genre_id, tag_list):

    if isinstance(tag_list, int):
        tag_list = [tag_list]


    for tag_id in tag_list:
        sql = ("SELECT 1 FROM Genretags WHERE genre = %s AND tag = %s")
        mycursor.execute(sql, (genre_id, tag_id))
        rs = mycursor.fetchone()

        if rs:
            print("Genre Tag", genre_id, tag_id, " Already Exists.")
        else:
            sql = ("INSERT INTO GenreTags (genre, tag) VALUES (%s, %s)")
            val = (genre_id, tag_id)
            mycursor.execute(sql, val)
            mydb.commit()

            print("GenreTags Record Inserted.")

(director_map, rating_map, tag_map, release_map,
country_map, content_format_map, actor_map, content_director_map,
 content_actor_map)  = {}, {}, {}, {}, {}, {}, {}, {}, {}

df = pd.read_csv('Data.csv')
df = df.replace(np.nan, 'NULL')
# Remove the 's' from the id in Data.csv
df['show_id'] = df['show_id'].apply(truncate_id)

pd.set_option('display.max_columns', None)
pd.set_option('display.width', None)
pd.set_option('display.max_colwidth', None)



for row in df['type']:
    if row != 'NULL':
         get_id_or_insert_format(row, content_format_map)





df['type'] = df['type'].map(content_format_map).fillna('NULL')
df['director'] = df['director'].apply(transform_director_row).fillna('NULL')
df['listed_in'] = df['listed_in'].apply(transform_tag_row).fillna('NULL')

df['rating'] = df['rating'].apply(transform_rating_row).fillna('NULL')
df['rating'] = df['rating'].apply(remove_decimal).fillna('NULL')

df['date_added'] = df['date_added'].apply(fix_date_format).fillna('NULL')
df['date_added'] = df['date_added'].apply(remove_decimal).fillna('NULL')

df['cast'] = df['cast'].apply(transform_actor_row).fillna('NULL')
df['country'] = df['country'].apply(transform_country_row).fillna('NULL')

genre_column = df['show_id'].copy()
genre_column = genre_column.astype(int)
genre_column = genre_column.apply(get_genre).fillna('NULL')
content = list(zip(df['show_id'], df['type'], df['title'], df['director'],
               df['release_year'], df['rating'], df['duration'], df['description'], genre_column))


content_actor = list(zip(df['show_id'], df['cast']))
content_country = list(zip(df['show_id'], df['country']))
content_release = list(zip(df['show_id'], df['date_added']))
content_tag = list(zip(df['show_id'], df['listed_in']))
genre_tag = list(zip(genre_column, df['listed_in']))

for row in content:
    insert_content(row)


# At This Point, The Tables Populated ARE:
    # Content, Actor, Director, Rating, Country, Release, Content_Format, Content_Directors

# IMPLEMENT the Associative Entities.
# GenreTags

for row in content_actor:
    content_id = row[0]
    actor_list = row[1]
    if actor_list != 'NULL':
        insert_content_actors(content_id, actor_list)

for row in content_country:
    content_id = row[0]
    country_list = row[1]
    if country_list != 'NULL':
        insert_content_country(content_id, country_list)

# for row in content_release:
#     content_id = row[0]
#     release_list = row[1]
#     if release_list != 'NULL':
#         insert_content_release(content_id, release_list)

for row in content_tag:
    content_id = row[0]
    tag_list = row[1]
    if tag_list != 'NULL':
        insert_content_tag(content_id, tag_list)

for row in genre_tag:
    genre_id = row[0]
    tag_list = row[1]
    if tag_list != 'NULL':
        insert_genre_tag(genre_id, tag_list)