--This is selecting from the Text files stored in hdfs using PXF 
SELECT title, count(*), sum(salary) FROM pxf.ext_sample GROUP BY title ORDER BY 2 DESC;
