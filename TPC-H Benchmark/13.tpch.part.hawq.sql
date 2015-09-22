CREATE TABLE tpch.part
WITH (appendonly=true,orientation=parquet) AS
SELECT * FROM ext_tpch.part
DISTRIBUTED BY (P_PARTKEY);
