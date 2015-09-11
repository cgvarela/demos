--External Table in HAWQ that gets data from HDFS in TEXT format
CREATE EXTERNAL TABLE pxf.ext_sample
(i int, fname text, title varchar(100), salary numeric)
LOCATION (:LOCATION)
FORMAT 'TEXT' (DELIMITER '|' NULL AS 'null' ESCAPE AS E'\\');
