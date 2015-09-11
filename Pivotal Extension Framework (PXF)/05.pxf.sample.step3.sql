--Create a HAWQ table by selecting from the External Table that uses HDFS text files
CREATE TABLE pxf.sample 
WITH (appendonly=true,orientation=parquet, compresstype=snappy) AS
SELECT * FROM pxf.ext_sample
DISTRIBUTED BY (i);
