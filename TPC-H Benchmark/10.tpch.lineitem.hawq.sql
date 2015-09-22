CREATE TABLE tpch.lineitem 
WITH (appendonly=true,orientation=parquet) AS
SELECT * FROM ext_tpch.lineitem
DISTRIBUTED BY (L_ORDERKEY);
