WITH table_sizes AS (
    SELECT
        n.nspname AS schema_name,
        c.relname AS table_name,
        pg_total_relation_size(c.oid) AS size_bytes,
        pg_relation_size(c.oid) AS table_bytes,
        pg_indexes_size(c.oid) AS index_bytes,
        pg_total_relation_size(c.oid)
          - pg_relation_size(c.oid)
          - pg_indexes_size(c.oid) AS toast_bytes
    FROM pg_class c
    JOIN pg_namespace n
      ON n.oid = c.relnamespace
    WHERE c.relkind = 'r'
      AND n.nspname NOT IN ('pg_catalog', 'information_schema')
      AND n.nspname NOT LIKE 'pg_toast%'
)
SELECT
    schema_name,
    table_name,
    size_bytes,
    CASE
        WHEN size_bytes >= power(1024::numeric, 4)
            THEN to_char(round(size_bytes / power(1024::numeric, 4), 2), 'FM999999990.00') || ' TiB'
        WHEN size_bytes >= power(1024::numeric, 3)
            THEN to_char(round(size_bytes / power(1024::numeric, 3), 2), 'FM999999990.00') || ' GiB'
        WHEN size_bytes >= power(1024::numeric, 2)
            THEN to_char(round(size_bytes / power(1024::numeric, 2), 2), 'FM999999990.00') || ' MiB'
        WHEN size_bytes >= 1024
            THEN to_char(round(size_bytes / 1024::numeric, 2), 'FM999999990.00') || ' KiB'
        ELSE
            size_bytes::text || ' B'
    END AS size_human,
    table_bytes,
    index_bytes,
    toast_bytes
FROM table_sizes
ORDER BY size_bytes DESC;
