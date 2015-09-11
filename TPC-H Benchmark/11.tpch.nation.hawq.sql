CREATE TABLE tpch.nation
WITH (appendonly=true,orientation=parquet, compresstype=snappy) AS
SELECT * FROM ext_tpch.nation
DISTRIBUTED BY (N_NATIONKEY, N_REGIONKEY);
