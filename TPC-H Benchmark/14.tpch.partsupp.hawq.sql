CREATE TABLE tpch.partsupp
WITH (appendonly=true,orientation=parquet, compresstype=snappy) AS
SELECT * FROM ext_tpch.partsupp
DISTRIBUTED BY (PS_PARTKEY, PS_SUPPKEY);
