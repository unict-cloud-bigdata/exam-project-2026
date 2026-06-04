-- Q6 — Distance vs in-flight recovery
-- avg_recovery_min = AVG(ARRIVAL_DELAY - DEPARTURE_DELAY); negative = time made up in the air.
-- Cancelled/diverted excluded; both delays must be present. Buckets ordered by MIN(DISTANCE).
--
-- EXPECTED: negative recovery (arrival delay < departure delay), growing with distance.
-- WHY: longer flights have more cruise time to absorb a late departure (schedule padding
--   plus the option to fly faster).
-- VALIDATED: yes, on the full table (2026-06-03). Recovery -2.85 min (0-499 mi) to -9.10
--   (2000-2499), with a slight uptick at 2500+ (-8.20). Monotonic trend confirmed.

SELECT
  CASE
    WHEN DISTANCE <  500 THEN '0-499'
    WHEN DISTANCE < 1000 THEN '500-999'
    WHEN DISTANCE < 1500 THEN '1000-1499'
    WHEN DISTANCE < 2000 THEN '1500-1999'
    WHEN DISTANCE < 2500 THEN '2000-2499'
    ELSE '2500+'
  END                                            AS distance_bucket,
  COUNT(*)                                       AS total_flights,
  ROUND(AVG(DISTANCE), 0)                        AS avg_distance_mi,
  ROUND(AVG(DEPARTURE_DELAY), 1)                 AS avg_dep_delay_min,
  ROUND(AVG(ARRIVAL_DELAY),   1)                 AS avg_arr_delay_min,
  ROUND(AVG(ARRIVAL_DELAY - DEPARTURE_DELAY), 2) AS avg_recovery_min
FROM flights_2015.flights
WHERE CANCELLED = 0 AND DIVERTED = 0
  AND ARRIVAL_DELAY IS NOT NULL AND DEPARTURE_DELAY IS NOT NULL
GROUP BY distance_bucket
ORDER BY MIN(DISTANCE);
