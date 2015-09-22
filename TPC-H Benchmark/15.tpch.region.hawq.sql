CREATE TABLE tpch.region
WITH (appendonly=true,orientation=parquet) AS
SELECT * FROM ext_tpch.region
DISTRIBUTED BY (R_REGIONKEY);
