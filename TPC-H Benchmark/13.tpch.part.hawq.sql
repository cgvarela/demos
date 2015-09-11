CREATE TABLE tpch.part
WITH (appendonly=true,orientation=parquet, compresstype=snappy) AS
SELECT * FROM ext_tpch.part
DISTRIBUTED BY (P_PARTKEY);
