/* Paso 1 */

SELECT
  event_timestamp,
  user_pseudo_id,
FROM
  `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*` date_range
WHERE
  _table_suffix BETWEEN '20210101' AND '20210131'
  
  
  
/* Paso 2 */
SELECT
  DATETIME(DATETIME_TRUNC(timestamp_micros(event_timestamp), HOUR), "Europe/Madrid") as event_hour,
  user_pseudo_id,
FROM
  `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*` date_range
WHERE
  _table_suffix BETWEEN '20210101' AND '20210131'
  
  

/* Paso 3 */
SELECT event_hour, count(distinct user_pseudo_id) as users FROM (
    SELECT
    DATETIME(DATETIME_TRUNC(timestamp_micros(event_timestamp), HOUR), "Europe/Madrid") as event_hour,
    user_pseudo_id,
    FROM
    `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*` date_range
    WHERE
    _table_suffix BETWEEN '20210101' AND '20210131'
) GROUP BY event_hour
ORDER BY event_hour ASC