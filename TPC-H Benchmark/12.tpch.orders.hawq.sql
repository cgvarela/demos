CREATE TABLE tpch.orders
WITH (appendonly=true,orientation=parquet,compresstype=snappy) AS
SELECT * FROM ext_tpch.orders
DISTRIBUTED BY (O_ORDERKEY, O_CUSTKEY);
