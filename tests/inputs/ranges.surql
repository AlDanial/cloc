/*
https://surrealdb.com/docs/surrealql/statements/select#example-usage
   */
-- Select all person records with IDs between the given range
SELECT * FROM person:1..1000;
#  Select all records for a particular location, inclusive
SELECT * FROM temperature:['London', NONE]..=['London', time::now()];
-- Select all temperature records with IDs less than a maximum value
SELECT * FROM temperature:..['London', '2022-08-29T08:09:31'];
-- Select all temperature records with IDs greater than a minimum value
SELECT * FROM temperature:['London', '2022-08-29T08:03:39']..;
-- Select all temperature records with IDs between the specified range
SELECT * FROM temperature:['London', '2022-08-29T08:03:39']..['London', '2022-08-29T08:09:31'];
