CREATE TABLE tpch.customer 
WITH (appendonly=true,orientation=parquet) AS
SELECT * FROM ext_tpch.customer
DISTRIBUTED BY (C_CUSTKEY);
