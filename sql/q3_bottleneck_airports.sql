-- Q3 — Bottleneck origin airports (hub congestion)
-- Top origin airports by average departure delay, with a minimum-volume filter to
-- avoid tiny-airport noise. Join to airport city/state. Cancelled flights excluded.
--
-- EXPECTED: large, congested hubs at the top of the average-departure-delay ranking.
-- WHY: high-traffic and slot-constrained hubs queue departures, inflating delay.
-- VALIDATED: yes, on the full table (2026-06-03). Top: Chicago O'Hare 14.1 min, Newark
--   13.6, Baltimore 13.3, LaGuardia 13.2, Chicago Midway 12.8 (Chicago + NYC-area hubs).
--   Minimum-volume filter set to 10000 flights.

SELECT
  f.ORIGIN_AIRPORT AS airport_code,
  ap.AIRPORT       AS airport_name,
  ap.CITY, ap.STATE,
  COUNT(*)                          AS total_flights,
  ROUND(AVG(f.DEPARTURE_DELAY), 1)  AS avg_dep_delay_min,
  ROUND(100 * SAFE_DIVIDE(COUNTIF(f.DEPARTURE_DELAY >= 15), COUNT(*)), 1) AS pct_dep_delayed
FROM flights_2015.flights AS f
JOIN flights_2015.airports AS ap ON f.ORIGIN_AIRPORT = ap.IATA_CODE
WHERE f.CANCELLED = 0
GROUP BY airport_code, airport_name, CITY, STATE
HAVING total_flights >= 10000          -- minimum flight volume (anti-noise)
ORDER BY avg_dep_delay_min DESC
LIMIT 20;
