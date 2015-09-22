CREATE TABLE tpch.supplier
WITH (appendonly=true,orientation=parquet) AS
SELECT * FROM ext_tpch.supplier
DISTRIBUTED BY (S_SUPPKEY);
