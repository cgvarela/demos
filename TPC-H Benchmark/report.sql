SELECT t1.id, t1.table_name, CASE WHEN c.relstorage <> 'x' THEN c.reltuples::int ELSE 0 END AS tuples, t1.duration::interval AS hawq_duration
FROM reports.tpch t1
JOIN pg_class c on split_part(t1.table_name, '.', 2) = c.relname
JOIN pg_namespace n on split_part(t1.table_name, '.', 1) = n.nspname and c.relnamespace = n.oid
UNION ALL
SELECT t1.id, t1.table_name, -1, t1.duration::interval
FROM reports.tpch t1
WHERE split_part(t1.table_name, '.', 1) = 'query'
UNION ALL
SELECT -1, 'Average Load Time' as table_name, -1, avg(t1.duration)
FROM reports.tpch t1
WHERE table_name like 'tpch%'
UNION ALL
SELECT -1, 'Average Query Time' as table_name, -1, avg(t1.duration)
FROM reports.tpch t1
WHERE table_name like 'query%'
UNION ALL
SELECT -1, 'Total Time' as table_name, -1, sum(t1.duration)
FROM reports.tpch t1;
