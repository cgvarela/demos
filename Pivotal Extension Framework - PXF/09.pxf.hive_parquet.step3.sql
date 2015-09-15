CREATE EXTERNAL TABLE pxf.hive_parquet
(like pxf.wr_sample)
LOCATION (:LOCATION)
FORMAT 'custom' (formatter='pxfwritable_import');
