--This is selecting from the HAWQ tables stored in HDFS in Parquet and Snappy compression
SELECT title, count(*), sum(salary) FROM pxf.sample GROUP BY title ORDER BY 2 DESC;
