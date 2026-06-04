-- Q2 — Delay propagation by scheduled departure hour
-- Hour derived from the HHMM field: SAFE_CAST to INT64 (works whether the column was
-- loaded as INTEGER or zero-padded STRING), integer-divide by 100, MOD 24 maps 2400 -> 0.
-- "Delayed" = ARRIVAL_DELAY >= 15. Cancelled flights excluded.
-- LIMITATION: hours 0-4 carry very few flights (red-eye departures, ~0.5k-13k each), so
-- their averages are noisy; the meaningful signal is the monotonic rise across hours 5-23.
--
-- EXPECTED: low/negative delay for early-morning departures, rising to an evening peak.
-- WHY: delays propagate through the day as aircraft and crews fall behind schedule
--   (the late-aircraft effect quantified in Q5).
-- VALIDATED: yes, on the full table (2026-06-03). Hour 5 arrives early (-3.6 min, 7.4%
--   delayed), rising to a ~19:00 peak (+10.8 min, 27%). See LIMITATION above on hours 0-4.

SELECT
  MOD(DIV(SAFE_CAST(SCHEDULED_DEPARTURE AS INT64), 100), 24) AS sched_dep_hour,
  COUNT(*)                       AS total_flights,
  ROUND(AVG(ARRIVAL_DELAY), 1)   AS avg_arr_delay_min,
  ROUND(100 * SAFE_DIVIDE(COUNTIF(ARRIVAL_DELAY >= 15),
                          COUNTIF(ARRIVAL_DELAY IS NOT NULL)), 1) AS pct_delayed
FROM flights_2015.flights
WHERE CANCELLED = 0 AND SCHEDULED_DEPARTURE IS NOT NULL
GROUP BY sched_dep_hour
ORDER BY sched_dep_hour;
