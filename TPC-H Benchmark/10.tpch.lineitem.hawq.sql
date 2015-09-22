CREATE TABLE tpch.lineitem 
WITH (appendonly=true,orientation=parquet,compresstype=snappy) AS
SELECT * FROM ext_tpch.lineitem
DISTRIBUTED BY (L_ORDERKEY);
