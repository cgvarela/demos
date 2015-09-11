CREATE TABLE tpch.region
WITH (appendonly=true,orientation=parquet, compresstype=snappy) AS
SELECT * FROM ext_tpch.region
DISTRIBUTED BY (R_REGIONKEY);
