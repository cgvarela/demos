CREATE EXTERNAL TABLE ext_tpch.orders
(O_ORDERKEY BIGINT, --key
O_CUSTKEY BIGINT, --key
O_ORDERSTATUS CHAR(1),
O_TOTALPRICE DECIMAL(15,2),
O_ORDERDATE DATE,
O_ORDERPRIORITY CHAR(15), 
O_CLERK  CHAR(15), 
O_SHIPPRIORITY INTEGER,
O_COMMENT VARCHAR(79))
LOCATION (:LOCATION)
FORMAT 'TEXT' (DELIMITER '|');
