WITH db_sizes AS (
    SELECT
        d.datname,
        pg_database_size(d.oid) AS size_bytes
    FROM pg_database d
)
SELECT
    datname AS database_name,
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
    END AS size_human
FROM db_sizes
ORDER BY size_bytes DESC;
